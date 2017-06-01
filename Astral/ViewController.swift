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
import SceneKit

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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    //MARK: general data
    var loggedinUserData = (id: 0, username: "", fullname: "", email: "", password: "");
    var loggedOutUserData = (id: 0, username: "", fullname: "", email: "", password: "");
    var firstRender = true;
    var thresholdDistRerender = 25.0;
    var oldRenderPosition: CLLocation!;
    var networkWebSocket: WebSocket!;
    var currentLocation: CLLocation!;
    var currMapPoint: MKMapPoint!;
    var currentHeading: CLHeading!;
    var reconnectTimer: Timer!;
    var keyData: JSON!;
    var tempFocalMapPoint: MKMapPoint = MKMapPoint();
    var mapPoints: [MKMapPoint] = [];
    var coordPoints: [CLLocation] = [];
    var realFocalIDs: [Int] = [];
    var focalFirstComments = JSON("");
    var gotKeyData = false;
    var userKnownFocals: JSON!;
    var focalsNotifiedAlready: [Int] = [];
    let uuid = String(describing: UIDevice.current.identifierForVendor!);
    var focalDistAndBearingsFromUser: [(distance: Int, bearing: Int)] = [];
    var uniqueUsername: String!;
    var isStationary = false;
    var renderCount = 0;
    var regionReqCount = 0;
    let firstAppLaunch = UserDefaults.standard.string(forKey: "firstAppLaunch");
    let userSavedLoggedinData = UserDefaults.standard.array(forKey: "savedUser");
    let backgroundCoords = UserDefaults.standard.array(forKey: "backgroundCoords");
    let ignoredBackgroundCoords = UserDefaults.standard.array(forKey: "ignoreBackgroundCoords");
    var lastBackCoordPos = UserDefaults.standard.array(forKey: "lastBackCoordPos");
    
    func toggleMap(_ isAddingFocal: Bool) {
        map.tapMapToPost = isAddingFocal;
        if(isAddingFocal){
            self.map.tapRec.isEnabled = true;
        }
        if self.view.viewWithTag(3)?.isHidden == false && isAddingFocal == false {
            self.view.viewWithTag(3)?.isHidden = true;
        }else{
            self.view.viewWithTag(3)?.isHidden = false;
        }
        
    }
    
    //MARK: network request and response middleware functionality
    func renderRelFocals(_ newRender: Bool){
        renderCount += 1;
        if(isStationary == false || renderCount < 3){
            let pxVals = self.map.collectPXfromMapPoints(mapPoints, currMapPoint: currMapPoint);
            var currPointPX = pxVals.currPointPX;
            var focalValsPX = pxVals.focalValsPX;
            
            let pxValsForUserInBuilding = self.map.collectPXfromMapPoints([currMapPoint], currMapPoint: currMapPoint);
            var currValPX = pxValsForUserInBuilding.focalValsPX;
            
            self.map.getMapAsIMG({(image) in
        
                let distNoBuilding = Int(OpenCVWrapper.buildingDetect( &currValPX, image: image, currPoint: &currPointPX, pxLength: Int32(pxValsForUserInBuilding.pxLength), forBuildingTap: true));
                
                if(distNoBuilding! <= 2 && distNoBuilding! >= 0){
                    self.userInterface.updateInfoLabel(13, show: true, hideAfter: 5);
                }
                
                let toHideAsSTR = OpenCVWrapper.buildingDetect( &focalValsPX, image: image, currPoint: &currPointPX, pxLength: Int32(pxVals.pxLength), forBuildingTap: false);
                
                self.scene.renderFocals(self.mapPoints, currMapPoint: self.currMapPoint,
                                        render: newRender, currentHeading: self.currentHeading, toHide: toHideAsSTR!, comments: self.focalFirstComments, tempFocalMapPoint: self.tempFocalMapPoint);
            });
        }
    }
    
    //MARK: region data updating requests and response middleware process
    func regionDataUpdate(_ currentLocation: CLLocation, currentHeading: CLHeading){
        
        
        //let currentLocation = CLLocation(latitude: CLLocationDegrees(51.776701), longitude: CLLocationDegrees(-1.265575));
        self.currentLocation = currentLocation;
        self.currMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
        self.currentHeading = currentHeading;
        if(firstRender==true){
            self.oldRenderPosition = self.currentLocation;
        }
        
        if(self.currentLocation.horizontalAccuracy > 10){
            self.userInterface.updateInfoLabel(14, show: true, hideAfter: 3);
        }
        
        if(gotKeyData == false){
            networkRequest.getKeyData(self.networkWebSocket);
            // networkRequest.getUserKnowsFocals(self.networkWebSocket, uuid: uuid);
        }
        
        self.focalDistAndBearingsFromUser = [];
        var count = 0;
        var focalsClose: [Int] = [];
        for _ in self.mapPoints{
            
            let distAndBearing = self.location.collectFocalToUserData(currMapPoint.x, point1Y: currMapPoint.y, point2X: mapPoints[count].x, point2Y: mapPoints[count].y);
            if(distAndBearing.distance < 400){
                focalsClose.append(realFocalIDs[count]);
            }
            self.focalDistAndBearingsFromUser.append(distAndBearing);
            count += 1;
        }
        
        
        let coordinateRegion: MKCoordinateRegion = self.map.centerToLocationRegion(currentLocation);
        self.map.mapView.setRegion(coordinateRegion, animated: false);
        self.userInterface.locationFocused = true;
        let distFromPrevPos = currentLocation.distance(from: self.oldRenderPosition);
        if((distFromPrevPos>thresholdDistRerender)||firstRender==true){
            self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
        }else if(self.scene.focals.count>0){
            renderRelFocals(false);
        }
        regionReqCount += 1;
        
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

        let mapPoint = MKMapPointForCoordinate(focalLocation.coordinate);
        chooseLatestTempPos(vec: SCNVector3Zero, coordLocation: focalLocation, mapPoint: mapPoint);
    }

    func renderTempFocalFromUI(_ tapX: Int, tapY: Int){

        let positionsFound = scene.sceneView.hitTest(CGPoint(x: tapX, y: tapY), options: nil);
        
        if(positionsFound.count>0){
            if(positionsFound.first?.node.name == "floor"){

                let vecFound = positionsFound.first?.worldCoordinates;
                var vecRotate = (x: Double((vecFound?.x)!), y: Double((vecFound?.z)!));
                vecRotate = misc.rotateAroundPoint(vecRotate, angle: 90);
                let mapPointT = (x: vecRotate.x + currMapPoint.x, y: vecRotate.y + currMapPoint.y);
                let mapPoint = MKMapPoint(x: mapPointT.x, y: mapPointT.y);
                let coordPoint2d = MKCoordinateForMapPoint(mapPoint);
                let coordLocation = CLLocation(latitude: coordPoint2d.latitude, longitude: coordPoint2d.longitude);
                
                chooseLatestTempPos(vec: vecFound!, coordLocation: coordLocation, mapPoint: mapPoint);
            }
        }else if(addTempFirst == true){
            userInterface.updateInfoLabel(24, show: true, hideAfter: 2);
        }
        
    }
    //render temp focal visually
    func chooseLatestTempPos(vec: SCNVector3, coordLocation: CLLocation, mapPoint: MKMapPoint){
        if(map.focalIsolated(mapPoint: mapPoint, mapPoints: mapPoints)){
            self.tempFocalMapPoint = mapPoint;
            self.latestDesiredFocalLocation = coordLocation;
            self.map.updateSinglePin(self.latestDesiredFocalLocation, temp: true);
            self.userInterface.showTapFinishedOptions();
            self.scene.renderSingleFocal(0, mapPoint: tempFocalMapPoint, currMapPoint: currMapPoint, focalDisplayInfo: (" ", " "), render: self.addTempFirst, tempFocal: true, vec: vec, tapMoveTemp: true);
            self.addTempFirst = false;
        }
    }

    func addFocalReady(_ comment: String){
        
     self.map.getMapAsIMG({(image) in
     
        let pxVals = self.map.collectPXfromMapPoints([self.tempFocalMapPoint], currMapPoint: self.currMapPoint);
        
        var currentPointPX = pxVals.currPointPX;
        var focalDesValPX = pxVals.focalValsPX;
        
        let distNoBuilding = Int(OpenCVWrapper.buildingDetect(&focalDesValPX, image: image, currPoint: &currentPointPX, pxLength: Int32(pxVals.pxLength),  forBuildingTap: true)!)!;
        
        if(distNoBuilding > 5 || distNoBuilding == -1){

            self.addTempFirst = true;
            self.tempFocalMapPoint = MKMapPoint();
            self.scene.removeTempFocal();
            CLGeocoder().reverseGeocodeLocation(self.latestDesiredFocalLocation, completionHandler: {(placemarks,err) in
                var areaName = "N/A";
                if((placemarks?.count)!>0){
                    if(placemarks?[0] != nil){
                        let placemark = (placemarks?[0])! as CLPlacemark;
                        areaName = placemark.thoroughfare! + ", " + placemark.locality!;
                    }
                }
                
                let focalInfo = (comment: comment, author: self.userInterface.loggedinUserData.username, userID: self.userInterface.loggedinUserData.id, areaName: areaName);
                self.networkRequest.addFocal(self.networkWebSocket, focalLocation: self.latestDesiredFocalLocation,focalDisplayInfo: focalInfo);
            });

        }else{
            self.userInterface.updateInfoLabel(5, show: true, hideAfter: 4);
        }
        
     });
        
    }
    
    func addedFocalResponse(_ responseStr: String) {
        
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        var responseMessage = 15;
        if(success == true){
            responseMessage = 6;
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
        networkRequest.getUserFocals(self.networkWebSocket, userID: self.userInterface.loggedinUserData.id);
    }
    
    func userFocalsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.populateUserFocals(responseJSON["focals"], firstComments: responseJSON["fComments"]);
    }
    
    
    //MARK: new user sign up / profile edit request and response middleware process
    func updateUserDataRequest(_ username: String, password: String, fullname: String, email: String) {
        var pass: String!;
        if(password != ""){
            pass = password.sha512();
        }else{
            pass = "";
        }
        networkRequest.updateUserDataRequest(self.networkWebSocket, username: username, password: pass, fullname: fullname, email: email, userID: userInterface.loggedinUserData.id);
    }
    
    
    func updatedUserDataResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        if(success==true){
            userInterface.hideAnyViews();
            if(userInterface.loggedinUserData.id > 0){
                userInterface.loggedinUserData.username = responseJSON["dataUsed"]["username"].string!;
                userInterface.loggedinUserData.fullname = responseJSON["dataUsed"]["fullname"].string!;
                userInterface.loggedinUserData.email = responseJSON["dataUsed"]["email"].string!;
            }
        }
        let responseMessage = responseJSON["errorMsg"].int! + 17;
        self.userInterface.updateInfoLabel(responseMessage, show: true, hideAfter: 5);
    }
    
    
    //MARK: User login request and response middleware process
    func loginRequest(_ username: String, password: String) {
        let pass = password.sha512();
        networkRequest.loginUserRequest(self.networkWebSocket, username: username, password: pass);
    }
    
    func userLoggedinResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        if(responseJSON["success"].rawString()! == "true"){
            
            userInterface.hideAnyViews();
            userInterface.renderMenu(true);
            userInterface.loggedinUserData.id = Int(responseJSON["result"]["u_id"].rawString()!)!;
            userInterface.loggedinUserData.username = responseJSON["result"]["u_uname"].string!;
            userInterface.loggedinUserData.fullname = responseJSON["result"]["u_fullname"].string!;
            userInterface.loggedinUserData.email = responseJSON["result"]["u_email"].string!;
            
            let defaultsSavedUserObj = [userInterface.loggedinUserData.id, userInterface.loggedinUserData.username, userInterface.loggedinUserData.fullname,userInterface.loggedinUserData.email] as [Any];
            UserDefaults.standard.set(defaultsSavedUserObj, forKey: "savedUser");
            userInterface.updateInfoLabel(16, show: true, hideAfter: 5);
        }else{
            userInterface.updateInfoLabel(23, show: true, hideAfter: 5);
        }
        
    }
    
    
    func logoutUser() {
        UserDefaults.standard.set(nil, forKey: "savedUser");
        self.userInterface.updateInfoLabel(17, show: true, hideAfter: 2);
        initlizeUser();
    }
    
    func initlizeUser(){
        let savedUser = UserDefaults.standard.array(forKey: "savedUser");
        if(savedUser != nil){
            let uID = savedUser?[0] as! Int;
            if(uID > 0){
                userInterface.loggedinUserData = (id: uID, username:"",fullname:"", email:"", password: "");
                userInterface.loggedinUserData.username = savedUser?[1] as! String;
                userInterface.loggedinUserData.fullname = savedUser?[2] as! String;
                userInterface.loggedinUserData.email = savedUser?[3] as! String;
                userInterface.renderMenu(true);
            }
        }else{
            let uuidHash = uuid.sha512();
            let index = uuid.index(uuid.startIndex, offsetBy: 5);
            let unqiueCode = uuidHash.substring(to: index);
            uniqueUsername = "user"+unqiueCode;
            loggedOutUserData = (id: 0, username: uniqueUsername, fullname: "", email: "", password: "");
            userInterface.loggedinUserData = loggedOutUserData;
        }
    }

    
    //MARK: Retrieve focal comments request and response middleware process
    func getFocalComments(_ focalID: Int, updateVisited: Bool){

        networkRequest.getFocalComments(self.networkWebSocket, focalID: focalID, updateVisited: updateVisited);
    }
    
    func chooseFocalComments(_ tapX: Int, tapY: Int){
        let locationOfTap = CGPoint(x: tapX, y: tapY);
        var focalTapID = -1;
        let possFocalsFound = scene.sceneView.hitTest(locationOfTap, options: nil);
        if(possFocalsFound.first?.node.name != "floor"){
            if let nodeTapped = possFocalsFound.first?.node{
                scene.checkCorrectParentNodeFocal(node: nodeTapped);
                focalTapID = scene.focalTapID;
                if(focalTapID != -1){
                    userInterface.viewingFocalID = realFocalIDs[focalTapID];
                }
            }
        }
        
        if(focalTapID != -1){
            getFocalComments(userInterface.viewingFocalID, updateVisited: true);
            focalTapID = -1;
        }
    }
    func focalCommentsResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.populateFocalCommentsView(responseJSON["focalComments"], userCommentVotes: responseJSON["commentUserVotes"], focalVisitCount: responseJSON["focalVisitCount"]);
    }
    
    //MARK: Post new focal comment request and response middleware process
    func postNewComment(_ commentText: String) {
        if(userInterface.viewingFocalID
            != -1){
            networkRequest.postComment(self.networkWebSocket, focalID: userInterface.viewingFocalID, username: userInterface.loggedinUserData.username, commentText: commentText);
        }
    }
    
    func postedCommentResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        self.userInterface.updateInfoLabel(7, show: true, hideAfter: 2);
        self.getFocalComments(self.userInterface.viewingFocalID, updateVisited: false);
    }
    
    //MARK: Vote focal comment request and response middleware process
    
    
    func newVoteComment(_ vote: Int, cID: Int){
        networkRequest.newVoteComment(self.networkWebSocket, vote: vote, cID: cID, uID: userInterface.loggedinUserData.id);
    }
    func votedCommentResponse(_ responseStr: String){
        
    }
    
    //MARK: edit comment request and response middleware process
    
    func editComment(_ text: String, cID: Int) {
        networkRequest.editComment(self.networkWebSocket, text: text, cID: cID);
    }
    
    func editCommentResponse(_ responseStr: String){
        self.userInterface.updateInfoLabel(27, show: true, hideAfter: 2);
        self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
        self.getFocalComments(self.userInterface.viewingFocalID, updateVisited: false);
    }
    
    //MARK: delete comment request and response middleware process
    func deleteComment(_ cID: Int) {
        networkRequest.deleteComment(self.networkWebSocket, cID: cID);
    }
    
    func deletedCommentResponse(_ responseStr: String){
        self.userInterface.updateInfoLabel(28, show: true, hideAfter: 2);
        self.getFocalComments(self.userInterface.viewingFocalID, updateVisited: false);
    }
    
    //MARK: Delete focal request and response middleware process
    func deleteFocalRequest(_ realID: Int){
        networkRequest.deleteFocal(self.networkWebSocket, focalID: realID);
    }
    
    func deletedFocalResponse(_ responseStr: String) {
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        let success: Bool = (responseJSON["success"]=="true" ? true: false);
        self.userInterface.updateInfoLabel(8, show: true, hideAfter: 2);
        self.userInterface.closeSingleFocalInfoViewWrap();
        self.requestUserFocals();
        self.networkRequest.getRegionData(self.networkWebSocket, currLocation: currentLocation);
    }
    
    //MARK: key data response
    func keyDataResponse(_ responseStr: String){
        let responseJSON = networkSocket.processResponseAsJSON(responseStr);
        keyData = responseJSON;
        gotKeyData = true;
        self.userInterface.renderHelpText(text: keyData["data"][0]["data"].rawString()!);
    }

    
    func connWebRetry(){
        networkWebSocket.connect();
    }
    
    var checkLocatedTimer: Timer!;
    var locateDeviceAttempts = 0;
    func locatingDeviceMessage(){
        
        if(self.userInterface.locationFocused == false){
            self.userInterface.updateInfoLabel(9, show: true, hideAfter: 3);
            locateDeviceAttempts += 1;
            if(locateDeviceAttempts % 6 == 0){
               self.userInterface.updateInfoLabel(30, show: true, hideAfter: 5);
            }
        }else{
            self.checkLocatedTimer.invalidate();
            self.checkLocatedTimer = nil;
        }
    }
    
    func checkFirstLaunch(){
        if(firstAppLaunch != "false"){
            userInterface.helpView.isHidden = false;
            UserDefaults.standard.set("false", forKey: "firstAppLaunch");
        }
    }
    
    func startMotionHandler(){
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        motionManager.startDeviceMotionUpdates(
            using: CMAttitudeReferenceFrame.xMagneticNorthZVertical,
            to: OperationQueue.current!,
            withHandler: {
                (gyroData: CMDeviceMotion?, NSError) ->Void in
                if(gyroData != nil){
                    let mData: CMAttitude = gyroData!.attitude;
                    self.phonePitch = 90 - Int(mData.pitch * (180 / M_PI));
                    self.scene.rotateCamera(mData);
                }
        });
        if(CMMotionActivityManager.isActivityAvailable()){
            let motionActivityManager = CMMotionActivityManager();
            motionActivityManager.startActivityUpdates(to: OperationQueue.current!, withHandler: {
                (data: CMMotionActivity?)-> Void in
                    if(data != nil){
                        self.isStationary = (data?.stationary)!;
                    }
            });
        }
    }
    
    
    func initizeNetwork(){
        networkWebSocket = networkSocket.connectWebSocket();
        networkSocket.networkResponseDelegate = self;
        networkSocket.ui = userInterface;
        
        networkWebSocket.onDisconnect = { (error: NSError?) in
            self.userInterface.updateInfoLabel(11, show: true, hideAfter: 5);
            self.reconnectTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.connWebRetry), userInfo: nil, repeats: false);
        }
        networkWebSocket.onConnect = {
            if(self.reconnectTimer != nil){
                self.userInterface.updateInfoLabel(12, show: true, hideAfter: 2);
                self.reconnectTimer.invalidate();
                self.reconnectTimer = nil;
                if(self.userInterface.locationFocused == true){
                    self.networkRequest.getRegionData(self.networkWebSocket, currLocation: self.currentLocation);
                }

            }
            
        }
        
        checkLocatedTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.locatingDeviceMessage), userInfo: nil, repeats: true);
    }
    

    //MARK: Main stem
    override func viewDidLoad() {
        
        
        //Initilize location component
        location.delegateLoc = self;
        location.initLocation();
        
        //Initilize camera component
        //let capDevice = camera.initilizeCamera();
        //camera.startCameraFeed(capDevice, view: self.view);
        
        //Initilize scene component
        scene.renderSceneLayer(self.view);
        scene.renderSceneEssentials();
        
        //Initilize Map component
        map.renderMap(self.view);
        map.mapActionDelegate = self;
        map.scene = scene;
        self.view.viewWithTag(3)?.isHidden = true;
        
        appDelegate.viewController = self;
        
    
        //Initilize UI component
        userInterface.renderAll(self.view);
        userInterface.actionDelegate = self;
        userInterface.updateInfoLabel(10, show: true, hideAfter: 4);
        location.ui = userInterface;
        
        //Start Motion Handler
        startMotionHandler();
        
        //Initilize Network component
        initizeNetwork();
    
        //Startup jobs
        checkFirstLaunch();
        initlizeUser();
        
        
        
        super.viewDidLoad();
    }
    
}

