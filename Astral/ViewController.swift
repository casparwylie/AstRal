//
//  ViewController.swift
//  testSwift
//
//  Created by Caspar Wylie on 02/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

import UIKit
import CoreLocation
import Darwin
import CoreMotion
import MapKit
import Starscream
import SwiftyJSON
import CryptoSwift

class ViewController: UIViewController, LocationDelegate, UIActionDelegate, mapActionDelegate, NetworkResponseDelegate{
    
    //MARK: Component allocation
    var misc = Misc();
    var camera = Camera();
    var scene = Scene();
    var location = Location();
    var userInterface = UserInterface1();
    var motionManager = CMMotionManager();
    var map = Map();
    var networkSocket = NetworkSocketHandler();
    var networkRequest = NetworkRequestHandler();
    
    //MARK: general data
    var loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown", password: "");
    var firstRender = true;
    var thresholdDistRerender = 25.0;
    var oldRenderPosition: CLLocation!;
    var networkWebSocket: WebSocket!;
    var currentLocation: CLLocation!;
    var currMapPoint: MKMapPoint!;
    var currentHeading: CLHeading!;
    var keyData: JSON!;
    var tempFocalMapPoint: MKMapPoint = MKMapPoint();
    var mapPoints: [MKMapPoint] = [];
    var coordPoints: [CLLocation] = [];
    var realFocalIDs: [Int] = [];
    var focalFirstComments = JSON("");
    var gotKeyData = false;
    var focalDistAndBearingsFromUser: [(distance: Int, bearing: Int)] = [];
    
    
    func toggleMap(_ isAddingFocal: Bool) {
        map.tapMapToPost = isAddingFocal;
        if self.view.viewWithTag(3)?.isHidden == false && isAddingFocal == false {
            self.view.viewWithTag(3)?.isHidden = true;
        }else{
            self.view.viewWithTag(3)?.isHidden = false;
        }
        
    }
    
    //MARK: network request and response middleware functionality
    func renderRelFocals(_ newRender: Bool){
        
        let pxVals = self.map.collectPXfromMapPoints(mapPoints, currMapPoint: currMapPoint);
        var currPointPX = pxVals.currPointPX;
        var focalValsPX = pxVals.focalValsPX;
    
        
        self.map.getMapAsIMG({(image) in
            
            let toHideAsSTR = OpenCVWrapper.buildingDetect( &focalValsPX, image: image, currPoint: &currPointPX, pxLength: Int32(pxVals.pxLength),forTapLimit: false, forBuildingTap: false);
            
            self.scene.renderFocals(self.mapPoints, currMapPoint: self.currMapPoint,
                                     render: newRender, currentHeading: self.currentHeading, toHide: toHideAsSTR!, comments: self.focalFirstComments, tempFocalMapPoint: self.tempFocalMapPoint);
        });
    }
    
    //MARK: region data updating requests and response middleware process
    func regionDataUpdate(_ currentLocation: CLLocation, currentHeading: CLHeading){
       // let currentLocation = CLLocation(latitude: CLLocationDegrees(51.776701), longitude: CLLocationDegrees(-1.265575));
        self.currentLocation = currentLocation;
        self.currMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
        self.currentHeading = currentHeading;
        if(firstRender==true){
            self.oldRenderPosition = self.currentLocation;
        }
        
        if(self.currentLocation.horizontalAccuracy > 10){
            self.userInterface.updateInfoLabel("Locating Focals, please wait...", show: true, hideAfter: 3);
        }
        
        if(gotKeyData == false){
            getKeyData();
        }
        
        self.focalDistAndBearingsFromUser = [];
        var count = 0;
        for _ in self.mapPoints{
            
            let distAndBearing = self.location.collectFocalToUserData(currMapPoint.x, point1Y: currMapPoint.y, point2X: mapPoints[count].x, point2Y: mapPoints[count].y);
            self.focalDistAndBearingsFromUser.append(distAndBearing);
            count += 1;
        }
        
        let coordinateRegion: MKCoordinateRegion = self.map.centerToLocationRegion(currentLocation);
        self.map.mapView.setRegion(coordinateRegion, animated: false);
        let distFromPrevPos = currentLocation.distance(from: self.oldRenderPosition);
        if((distFromPrevPos>thresholdDistRerender)||firstRender==true){
            self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
        }else if(self.scene.focals.count>0){
            renderRelFocals(false);
        }
        
    }
    
    func regionDataResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        var coordsAsCLLocation: [CLLocation] = [];
        var realFocalIDs: [Int] = [];
        let responseFocalDataKey = "regionFocalData";
        let focalFirstCommentsKey = "fComments";
        
        if(responseJSON[responseFocalDataKey].count != 0){
            for coordRowCount in 0...responseJSON[responseFocalDataKey].count-1{
                let rowLatitude = Double(responseJSON[responseFocalDataKey][coordRowCount]["f_coord_lat"].rawString()!);
                let rowLongitude = Double(responseJSON[responseFocalDataKey][coordRowCount]["f_coord_lon"].rawString()!);
                let rowAsCLLocation = CLLocation(latitude: CLLocationDegrees(rowLatitude!), longitude: CLLocationDegrees(rowLongitude!));
                coordsAsCLLocation.append(rowAsCLLocation);
                realFocalIDs.append(responseJSON[responseFocalDataKey][coordRowCount]["f_id"].int!);
            }
        }
        self.mapPoints = self.map.getCoordsAsMapPoints(coordsAsCLLocation);
        self.map.updatePins(coordsAsCLLocation);
        self.coordPoints = coordsAsCLLocation;
        
        self.userInterface.updateInfoLabel("new region, focals: " + String(self.mapPoints.count), show: true, hideAfter: 4);
        
        self.oldRenderPosition = self.currentLocation;
        self.focalFirstComments = responseJSON[focalFirstCommentsKey];
        self.realFocalIDs = realFocalIDs;
        
        self.renderRelFocals(true);
        if(firstRender == true){
            firstRender = false;
        }
        
    }

    //MARK: new focal request and response middleware process
    var addTempFirst = true;
    var phonePitch = 0;
    var latestDesiredFocalLocation: CLLocation!;
    func renderTempFocalFromMap(_ mapTapCoord: CLLocationCoordinate2D){
        let focalLocation = CLLocation(latitude: mapTapCoord.latitude, longitude: mapTapCoord.longitude);
        self.map.getMapAsIMG({(image) in
            
            let pxVals = self.map.collectPXfromMapPoints([MKMapPointForCoordinate(focalLocation.coordinate)], currMapPoint: MKMapPointForCoordinate(self.currentLocation.coordinate));
            
            var currentPointPX = pxVals.currPointPX;
            var focalDesValPX = pxVals.focalValsPX;
            
            let distNoBuilding = Int(OpenCVWrapper.buildingDetect(&focalDesValPX, image: image, currPoint: &currentPointPX, pxLength: Int32(pxVals.pxLength), forTapLimit: true, forBuildingTap: true)!)!;
            
            if(distNoBuilding > 5){
                self.addFocalTemp(focalLocation);
            }else{
                self.userInterface.updateInfoLabel("You cannot place a focal on a building.", show: true, hideAfter: 3);
            }
        });
    }
    
    func renderTempFocalFromUI(_ tapX: Int, tapY: Int){
        var newFocalDistMetres: Double = 0.0;
        var bearingDegreesTap: Double = 0.0;
        newFocalDistMetres = self.location.getDistFromVerticalTap(Double(tapX), tapY: Double(tapY), phonePitch: Double(self.phonePitch));
        if(newFocalDistMetres < 0){
            newFocalDistMetres = 3;
        }

        bearingDegreesTap = self.location.getBearingFromHorizontalTap(Double(tapX));
        var focalLocation = location.getPolarCoords(newFocalDistMetres, bearingDegrees: bearingDegreesTap);
    
        
        let pxVals = self.map.collectPXfromMapPoints([MKMapPointForCoordinate(focalLocation.coordinate)], currMapPoint: MKMapPointForCoordinate(currentLocation.coordinate));
        
        var currentPointPX = pxVals.currPointPX;
        var focalDesValPX = pxVals.focalValsPX;
        
        self.map.getMapAsIMG({(image) in
            
            let distLimitPX = Int(OpenCVWrapper.buildingDetect(&focalDesValPX, image: image, currPoint: &currentPointPX, pxLength: Int32(pxVals.pxLength), forTapLimit: true, forBuildingTap: false)!)!;
            
            if(distLimitPX > -1){
                let distLimitMetres = (distLimitPX / 2)-4;
                focalLocation = self.location.getPolarCoords(Double(distLimitMetres), bearingDegrees: bearingDegreesTap);
            }
            
            self.addFocalTemp(focalLocation);
            
        });
    }
    func addFocalTemp(_ focalLocation: CLLocation){
        
        self.latestDesiredFocalLocation = focalLocation;
        self.userInterface.showTapFinishedOptions();
        tempFocalMapPoint = MKMapPointForCoordinate(focalLocation.coordinate);
        let currentMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);

        map.updateSinglePin(focalLocation, temp: true);
        self.scene.renderSingleFocal(0, mapPoint: tempFocalMapPoint, currMapPoint: currentMapPoint, focalDisplayInfo: (" ", " "), render: self.addTempFirst, tempFocal: true);
        self.addTempFirst = false;
    
    }
    
    func addFocalReady(_ comment: String){
        
        self.addTempFirst = true;
        tempFocalMapPoint = MKMapPoint();
        self.scene.removeTempFocal();
        CLGeocoder().reverseGeocodeLocation(self.latestDesiredFocalLocation, completionHandler: {(placemarks,err) in
            var areaName = "N/A";
            if((placemarks?.count)!>0){
                let placemark = (placemarks?[0])! as CLPlacemark;
                areaName = placemark.thoroughfare! + ", " + placemark.locality!;
            }
            
            let focalInfo = (comment: comment, author: self.loggedinUserData.username, userID: self.loggedinUserData.id, areaName: areaName);
            self.networkRequest.addFocal(self.networkWebSocket, focalLocation: self.latestDesiredFocalLocation,focalDisplayInfo: focalInfo);
        });
    }
    
    func addedFocalResponse(_ responseStr: String) {

        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        var responseMessage = "Unknown Error. Please try again later.";
        if(success == true){
            responseMessage = "Successfully posted new focal!";
        }
        self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
        self.userInterface.updateInfoLabel(responseMessage, show: true, hideAfter: 4);
    }
    
    func cancelNewFocal() {
        self.scene.removeTempFocal();
        self.map.cancelTempFocal();
        self.addTempFirst = true;
    }
  
    
    //MARK: retrieve user owned focals request and response middleware process
    func requestUserFocals() {
        networkRequest.getUserFocals(self.networkWebSocket, userID: self.loggedinUserData.id);
    }
    
    func userFocalsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.populateUserFocals(responseJSON["focals"], firstComments: responseJSON["fComments"]);
    }
    
    
    //MARK: new user sign up / profile edit request and response middleware process
    func updateUserDataRequest(_ username: String, password: String, fullname: String, email: String) {
        let pass = password.sha512();
        print(pass);
        networkRequest.updateUserDataRequest(self.networkWebSocket, username: username, password: pass, fullname: fullname, email: email, userID: loggedinUserData.id);
    }
    
    
    func updatedUserDataResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        if(success==true){
            userInterface.hideAnyViews();
            if(loggedinUserData.id > 0){
                loggedinUserData.username = responseJSON["dataUsed"]["username"].string!;
                loggedinUserData.fullname = responseJSON["dataUsed"]["fullname"].string!;
                loggedinUserData.email = responseJSON["dataUsed"]["email"].string!;
                userInterface.loggedinUserData = self.loggedinUserData;
            }
        }
        self.userInterface.updateInfoLabel(responseJSON["errorMsg"].string!, show: true, hideAfter: 5);
    }

    
    //MARK: User login request and response middleware process
    func loginRequest(_ username: String, password: String) {
        let pass = password.sha512();
        print(pass);
        networkRequest.loginUserRequest(self.networkWebSocket, username: username, password: pass);
    }
    
    func userLoggedinResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        var responseMessage = "Incorrect username or password.";
        if(responseJSON["success"].rawString()! == "true"){
            
            userInterface.hideAnyViews();
            userInterface.renderMenu(true);
            loggedinUserData.id = Int(responseJSON["result"]["u_id"].rawString()!)!;
            loggedinUserData.username = responseJSON["result"]["u_uname"].string!;
            loggedinUserData.fullname = responseJSON["result"]["u_fullname"].string!;
            loggedinUserData.email = responseJSON["result"]["u_email"].string!;
            userInterface.loggedinUserData = self.loggedinUserData;
            responseMessage = "Welcome " + loggedinUserData.fullname.components(separatedBy: " ")[0] + "!";
            
        }
        
        userInterface.updateInfoLabel(responseMessage, show: true, hideAfter: 5);
    }
    
    
    func logoutUser() {
        loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown", password: "");
        self.userInterface.loggedinUserData = self.loggedinUserData;
        self.userInterface.updateInfoLabel("You are logged out!", show: true, hideAfter: 2);
    }
    
    
    //MARK: Retrieve focal comments request and response middleware process
    func getFocalComments(_ focalID: Int){
        networkRequest.getFocalComments(self.networkWebSocket, focalID: realFocalIDs[focalID]);
    }
    var viewingFocalID = -1;
    func chooseFocalComments(_ tapX: Int, tapY: Int){
        let locationOfTap = CGPoint(x: tapX, y: tapY);
        var focalTapID = -1;
        let possFocalsFound = scene.sceneView.hitTest(locationOfTap, options: nil);
        if let tappedFocal = possFocalsFound.first?.node.parent{
            print(tappedFocal.name!)
            let startIndex = tappedFocal.name?.index((tappedFocal.name?.startIndex)!, offsetBy: 2);
            focalTapID = Int((tappedFocal.name?.substring(from: startIndex!))!)!;
            viewingFocalID = focalTapID;
            
        }

        if(focalTapID != -1){
            getFocalComments(focalTapID);
            focalTapID = -1;
        }
    }
    func focalCommentsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.populateFocalCommentsView(responseJSON["focalComments"], userCommentVotes: responseJSON["commentUserVotes"], focalVisitCount: responseJSON["focalVisitCount"]);
    }
    
    //MARK: Post new focal comment request and response middleware process
    func postNewComment(_ commentText: String) {
        if(viewingFocalID
            != -1){
            networkRequest.postComment(self.networkWebSocket, focalID: realFocalIDs[viewingFocalID], username: loggedinUserData.username, commentText: commentText);
        }
    }
    
    func postedCommentResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.updateInfoLabel("Successfully Posted!", show: true, hideAfter: 2);
        self.getFocalComments(self.viewingFocalID);
    }
    
    //MARK: Vote focal comment request and response middleware process
    

    func newVoteComment(_ vote: Int, cID: Int){
        networkRequest.newVoteComment(self.networkWebSocket, vote: vote, cID: cID, uID: loggedinUserData.id);
    }
    func votedCommentResponse(_ responseStr: String){
        
    }
    
    //MARK: Delete focal request and response middleware process
    func deleteFocalRequest(_ realID: Int){
        networkRequest.deleteFocal(self.networkWebSocket, focalID: realID);
    }
    
    func deletedFocalResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        self.userInterface.updateInfoLabel("Successfully Deleted!", show: true, hideAfter: 2);
        self.userInterface.closeSingleFocalInfoViewWrap();
        self.requestUserFocals();
        self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
    }
    
    //MARK: key data request
    func getKeyData(){
        networkRequest.getKeyData(self.networkWebSocket);
    }
    func keyDataResponse(_ responseStr: String){
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        keyData = responseJSON;
        gotKeyData = true;
        self.userInterface.renderHelpText(text: keyData["data"][0]["data"].rawString()!);
    }


    //MARK: Main stem
    override func viewDidLoad() {
        
        
        //Initilize location component
        location.delegateLoc = self;
        location.initLocation();
        
        //Initilize camera component
        let capDevice = camera.initilizeCamera();
        camera.startCameraFeed(capDevice, view: self.view);
        
        //Initilize scene component
        scene.renderSceneLayer(self.view);
        scene.renderSceneEssentials();
        
        //Initilize Map component
        map.renderMap(self.view);
        map.mapActionDelegate = self;
        self.view.viewWithTag(3)?.isHidden = true;
        
        //Initilize UI component
        userInterface.renderAll(self.view);
        userInterface.actionDelegate = self;
        userInterface.updateInfoLabel("Please calibrate your phone by twisting it around", show: true, hideAfter: 4);
    
        //Initilize Motion Handler
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        motionManager.startDeviceMotionUpdates(
            using: CMAttitudeReferenceFrame.xMagneticNorthZVertical,
            to: OperationQueue.current!,
            withHandler: {
                (gyroData: CMDeviceMotion?, NSError) ->Void in
                let mData: CMAttitude = gyroData!.attitude;
                self.phonePitch = 90 - Int(mData.pitch * (180 / M_PI));
                self.scene.rotateCamera(mData);
                if(NSError != nil){
                    print("\(NSError)");
                }
        });
        
        //Initilize Network socket component
        networkWebSocket = networkSocket.connectWebSocket();
        networkSocket.networkResponseDelegate = self;
        networkSocket.ui = userInterface;
        

        
        super.viewDidLoad();
    }
    
}

