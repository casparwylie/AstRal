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
   
    var tempStrandMapPoint: MKMapPoint = MKMapPoint();
    var mapPoints: [MKMapPoint] = [];
    var coordPoints: [CLLocation] = [];
    var realStrandIDs: [Int] = [];
    var strandFirstComments = JSON("");
    var strandDistAndBearingsFromUser: [(distance: Int, bearing: Int)] = [];
    
    
    func toggleMap(_ isAddingStrand: Bool) {
        map.tapMapToPost = isAddingStrand;
        if self.view.viewWithTag(3)?.isHidden == false && isAddingStrand == false {
            
            self.view.viewWithTag(3)?.isHidden = true;
        }else{
            self.view.viewWithTag(3)?.isHidden = false;
        }
        
    }
    
    //MARK: network request and response middleware functionality
    func renderRelStrands(_ newRender: Bool){
        
        let pxVals = self.map.collectPXfromMapPoints(mapPoints: mapPoints, currMapPoint: currMapPoint);
        var currPointPX = pxVals.currPointPX;
        var strandValsPX = pxVals.strandValsPX;
    
        
        self.map.getMapAsIMG(completion: {(image) in
            
            let toHideAsSTR = OpenCVWrapper.buildingDetect( &strandValsPX, image: image, currPoint: &currPointPX, pxLength: Int32(pxVals.pxLength),forTapLimit: false);
            
            self.scene.renderStrands(mapPoints:self.mapPoints, currMapPoint: self.currMapPoint,
                                     render: newRender, currentHeading: self.currentHeading, toHide: toHideAsSTR!, comments: self.strandFirstComments, tempStrandMapPoint: self.tempStrandMapPoint);
            
        });
    }
    
   
    
    //MARK: region data updating requests and response middleware process
    func regionDataUpdate(_ currentLocation: CLLocation, currentHeading: CLHeading){
        
        self.currentLocation = currentLocation;
        self.currMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
        self.currentHeading = currentHeading;
        oldRenderPosition = (firstRender==true ? currentLocation : oldRenderPosition);
        
        self.strandDistAndBearingsFromUser = [];
        var count = 0;
        for _ in self.mapPoints{
            
            let distAndBearing = self.location.collectStrandToUserData(point1X: currMapPoint.x, point1Y: currMapPoint.y, point2X: mapPoints[count].x, point2Y: mapPoints[count].y);
            self.strandDistAndBearingsFromUser.append(distAndBearing);
            count += 1;
        }
        
        let coordinateRegion: MKCoordinateRegion = self.map.centerToLocationRegion(location: currentLocation);
        self.map.mapView.setRegion(coordinateRegion, animated: false);

        if((currentLocation.distance(from: oldRenderPosition)>thresholdDistRerender)||firstRender==true){
            
            self.networkRequest.getRegionData(socket: self.networkWebSocket, currLocation: currentLocation);
            
        }else if(self.scene.strands.count>0){
            renderRelStrands(false);
        }
        
    
    }
    
    func regionDataResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        var coordsAsCLLocation: [CLLocation] = [];
        var realStrandIDs: [Int] = [];
        let responseStrandDataKey = "regionStrandData";
        let strandFirstCommentsKey = "fComments";
        
        if(responseJSON[responseStrandDataKey].count != 0){
            
            for coordRowCount in 0...responseJSON[responseStrandDataKey].count-1{
                let rowLatitude = Double(responseJSON[responseStrandDataKey][coordRowCount]["s_coord_lat"].rawString()!);
                let rowLongitude = Double(responseJSON[responseStrandDataKey][coordRowCount]["s_coord_lon"].rawString()!);
                let rowAsCLLocation = CLLocation(latitude: CLLocationDegrees(rowLatitude!), longitude: CLLocationDegrees(rowLongitude!));
                coordsAsCLLocation.append(rowAsCLLocation);
                realStrandIDs.append(responseJSON[responseStrandDataKey][coordRowCount]["s_id"].int!);
            }
            
        }
        self.mapPoints = self.map.getCoordsAsMapPoints(coords: coordsAsCLLocation);
        self.map.updatePins(coords: coordsAsCLLocation);
        self.coordPoints = coordsAsCLLocation;
        
        self.oldRenderPosition = self.currentLocation;
        self.strandFirstComments = responseJSON[strandFirstCommentsKey];
        self.realStrandIDs = realStrandIDs;
        
        self.renderRelStrands(true);
        if(firstRender == true){
            firstRender = false;
        }
        
    }

    
    
    //MARK: new strand request and response middleware process
    var addTempFirst = true;
    var phonePitch = 0;
    var latestDesiredStrandLocation: CLLocation!;
    func renderTempStrandFromMap(_ mapTapCoord: CLLocationCoordinate2D){
        let strandLocation = CLLocation(latitude: mapTapCoord.latitude, longitude: mapTapCoord.longitude);
        addStrandTemp(strandLocation);
    }
    
    func renderTempStrandFromUI(_ tapX: Int, tapY: Int){
        var newStrandDistMetres: Double = 0.0;
        var bearingDegreesTap: Double = 0.0;
        newStrandDistMetres = self.location.getDistFromVerticalTap(tapX: Double(tapX), tapY: Double(tapY), phonePitch: Double(self.phonePitch));
        if(newStrandDistMetres < 0){
            newStrandDistMetres = 3;
        }

        bearingDegreesTap = self.location.getBearingFromHorizontalTap(tapX: Double(tapX));
        var strandLocation = location.getPolarCoords(distance: newStrandDistMetres, bearingDegrees: bearingDegreesTap);
    
        
        let pxVals = self.map.collectPXfromMapPoints(mapPoints: [MKMapPointForCoordinate(strandLocation.coordinate)], currMapPoint: MKMapPointForCoordinate(currentLocation.coordinate));
        
        var currentPointPX = pxVals.currPointPX;
        var strandDesValPX = pxVals.strandValsPX;
        
        self.map.getMapAsIMG(completion: {(image) in
            
            let distLimitPX = Int(OpenCVWrapper.buildingDetect(&strandDesValPX, image: image, currPoint: &currentPointPX, pxLength: Int32(pxVals.pxLength), forTapLimit: true)!)!;
            
            if(distLimitPX > -1){
                let distLimitMetres = distLimitPX / 2;
                strandLocation = self.location.getPolarCoords(distance: Double(distLimitMetres), bearingDegrees: bearingDegreesTap);
            }
            
            self.addStrandTemp(strandLocation);
            
        });
    }
    func addStrandTemp(_ strandLocation: CLLocation){
        
        self.latestDesiredStrandLocation = strandLocation;
        self.userInterface.showTapFinishedOptions();
        tempStrandMapPoint = MKMapPointForCoordinate(strandLocation.coordinate);
        let currentMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);

            
        map.updateSinglePin(coord: strandLocation, temp: true);
        self.scene.renderSingleStrand(renderID: 0, mapPoint: tempStrandMapPoint, currMapPoint: currentMapPoint, strandDisplayInfo: (" ", " "), render: self.addTempFirst, tempStrand: true);
        self.addTempFirst = false;
        

    }
    
    func addStrandReady(_ comment: String){
        
        self.addTempFirst = true;
        tempStrandMapPoint = MKMapPoint();
        self.scene.removeTempStrand();
        CLGeocoder().reverseGeocodeLocation(self.latestDesiredStrandLocation, completionHandler: {(placemarks,err) in
            var areaName = "N/A";
            if((placemarks?.count)!>0){
                let placemark = (placemarks?[0])! as CLPlacemark;
                areaName = placemark.thoroughfare! + ", " + placemark.locality!;
            }
            
            let strandInfo = (comment: comment, author: self.loggedinUserData.username, userID: self.loggedinUserData.id, areaName: areaName);
            self.networkRequest.addStrand(socket: self.networkWebSocket, strandLocation: self.latestDesiredStrandLocation,strandDisplayInfo: strandInfo);
        });
    }
    
    
    func addedStrandResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        var responseMessage = "Unknown Error. Please try again later.";
        if(success == true){
            responseMessage = "Successfully posted new strand!";
        }
        self.networkRequest.getRegionData(socket: self.networkWebSocket, currLocation: currentLocation);
        self.userInterface.updateInfoLabel(newText: responseMessage, show: true, hideAfter: 4);
    }
    
    func cancelNewStrand() {
        self.scene.removeTempStrand();
        self.map.cancelTempStrand();
        self.addTempFirst = true;
    }
  
    
    //MARK: retrieve user owned strands request and response middleware process
    func requestUserStrands() {
        networkRequest.getUserStrands(socket: self.networkWebSocket, userID: self.loggedinUserData.id);
    }
    
    func userStrandsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        self.userInterface.populateUserStrands(strands: responseJSON["strands"], firstComments: responseJSON["fComments"]);
    }
    
    
    //MARK: new user sign up / profile edit request and response middleware process
    func updateUserDataRequest(_ username: String, password: String, fullname: String, email: String) {
        networkRequest.updateUserDataRequest(socket: self.networkWebSocket, username: username, password: password, fullname: fullname, email: email, userID: loggedinUserData.id);
    }
    
    
    func updatedUserDataResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        if(success==true){
            userInterface.hideAnyViews();
            if(loggedinUserData.id > 0){
                loggedinUserData.username = responseJSON["dataUsed"]["username"].string!;
                loggedinUserData.fullname = responseJSON["dataUsed"]["fullname"].string!;
                loggedinUserData.email = responseJSON["dataUsed"]["email"].string!;
                loggedinUserData.password = responseJSON["dataUsed"]["password"].string!;
                userInterface.loggedinUserData = self.loggedinUserData;
            }
        }
        self.userInterface.updateInfoLabel(newText: responseJSON["errorMsg"].string!, show: true, hideAfter: 5);
    }

    
    //MARK: User login request and response middleware process
    func loginRequest(_ username: String, password: String) {
        networkRequest.loginUserRequest(socket: self.networkWebSocket, username: username, password: password);
    }
    
    func userLoggedinResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        var responseMessage = "Incorrect username or password.";
        if(responseJSON["success"].rawString()! == "true"){
            
            userInterface.hideAnyViews();
            userInterface.renderMenu(loggedin: true);
            loggedinUserData.id = Int(responseJSON["result"]["u_id"].rawString()!)!;
            loggedinUserData.username = responseJSON["result"]["u_uname"].string!;
            loggedinUserData.fullname = responseJSON["result"]["u_fullname"].string!;
            loggedinUserData.email = responseJSON["result"]["u_email"].string!;
            loggedinUserData.password = responseJSON["result"]["u_password"].string!;
            userInterface.loggedinUserData = self.loggedinUserData;
            responseMessage = "Welcome " + loggedinUserData.fullname.components(separatedBy: " ")[0] + "!";
            
        }
        
        userInterface.updateInfoLabel(newText: responseMessage, show: true, hideAfter: 5);
    }
    
    
    func logoutUser() {
        loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown", password: "");
        self.userInterface.loggedinUserData = self.loggedinUserData;
        self.userInterface.updateInfoLabel(newText: "You are logged out!", show: true, hideAfter: 2);
    }
    
    
    //MARK: Retrieve strand comments request and response middleware process
    func getStrandComments(_ strandID: Int){
        networkRequest.getStrandComments(socket: self.networkWebSocket, strandID: realStrandIDs[strandID]);
    }
    var viewingStrandID = -1;
    func chooseStrandComments(_ tapX: Int, tapY: Int){
        let locationOfTap = CGPoint(x: tapX, y: tapY);
        var strandTapID = -1;
        let possStrandsFound = scene.sceneView.hitTest(locationOfTap, options: nil);
        if let tappedStrand = possStrandsFound.first?.node.parent?.parent{
            print(tappedStrand.name!)
            let startIndex = tappedStrand.name?.index((tappedStrand.name?.startIndex)!, offsetBy: 2);
            strandTapID = Int((tappedStrand.name?.substring(from: startIndex!))!)!;
            viewingStrandID = strandTapID;
            
        }
        if(strandTapID != nil && strandTapID != -1){
            getStrandComments(strandTapID);
            strandTapID = -1;
        }
    }
    func strandCommentsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        self.userInterface.populateStrandCommentsView(strandComments: responseJSON["strandComments"]);
    }
    
    //MARK: Post new strand comment request and response middleware process
    func postNewComment(_ commentText: String) {
        if(viewingStrandID
            != -1){
            networkRequest.postComment(socket: self.networkWebSocket, strandID: realStrandIDs[viewingStrandID], username: loggedinUserData.username, commentText: commentText);
        }
    }
    
    func postedCommentResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        self.userInterface.updateInfoLabel(newText: "Successfully Posted!", show: true, hideAfter: 2);
        self.getStrandComments(self.viewingStrandID);
    }

    
    
    //MARK: Delete strand request and response middleware process
    func deleteStrandRequest(_ realID: Int){
        networkRequest.deleteStrand(socket: self.networkWebSocket, strandID: realID);
    }
    
    func deletedStrandResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseData: responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        self.userInterface.updateInfoLabel(newText: "Successfully Deleted!", show: true, hideAfter: 2);
        self.userInterface.closeSingleStrandInfoViewWrap();
        self.requestUserStrands();
        self.networkRequest.getRegionData(socket: self.networkWebSocket, currLocation: currentLocation);
    }
    
    


    //MARK: Main stem
    override func viewDidLoad() {
        
        
        //Initilize location component
        location.delegateLoc = self;
        location.initLocation();
        
        //Initilize camera component
        let capDevice = camera.initilizeCamera();
        camera.startCameraFeed(capDevice: capDevice, view: self.view);
        
        //Initilize scene component
        scene.renderSceneLayer(frameView: self.view);
        scene.renderSceneEssentials();
        
        //Initilize Map component
        map.renderMap(view: self.view);
        map.mapActionDelegate = self;
        self.view.viewWithTag(3)?.isHidden = true;
        
        //Initilize UI component
        userInterface.renderAll(view: self.view);
        userInterface.actionDelegate = self;
        userInterface.updateInfoLabel(newText: "Please calibrate your phone by twisting it around", show: true, hideAfter: 4);
    
        //Initilize Motion Handler
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        motionManager.startDeviceMotionUpdates(
            using: CMAttitudeReferenceFrame.xMagneticNorthZVertical,
            to: OperationQueue.current!,
            withHandler: {
                (gyroData: CMDeviceMotion?, NSError) ->Void in
                let mData: CMAttitude = gyroData!.attitude;
                self.phonePitch = 90 - Int(mData.pitch * (180 / M_PI));
                self.scene.rotateCamera(gyroData: mData);
                if(NSError != nil){
                    print("\(NSError)");
                }
        });
        
        //Initilize Network socket component
        networkWebSocket = networkSocket.connectWebSocket();
        networkSocket.networkResponseDelegate = self;

        
    
        super.viewDidLoad();
    }
    
}

