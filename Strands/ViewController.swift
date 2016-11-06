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

class ViewController: UIViewController, LocationDelegate, UIActionDelegate, mapActionDelegate{
    
    //MARK: Component allocation
    var misc = Misc();
    var camera = Camera();
    var scene = Scene();
    var location = Location();
    var userInterface = UserInterface1();
    var motionManager = CMMotionManager();
    var map = Map();
    var strandNetwork = StrandNetwork();
    var networkSocket = NetworkSocketHandler();
    var userNetwork = UserNetwork();
    
    //MARK: general data
    var reRenderStrands = true;
    var loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown");
    var firstRender = true;
    var thresholdDistRerender = 25.0;
    var oldRenderPosition: CLLocation!;
    var networkWebSocket: WebSocket!;
    var currentLocationGlobal: CLLocation!;
   
    var mapPoints: [MKMapPoint] = [];
    var strandComments: JSON = [];
    
    //MARK: UI Action definitions
    

    func toggleMap(isAddingStrand: Bool) {
        map.tapMapToPost = isAddingStrand;
        if self.view.viewWithTag(3)?.isHidden == false && isAddingStrand == false {
            
            self.view.viewWithTag(3)?.isHidden = true;
        }else{
            self.view.viewWithTag(3)?.isHidden = false;
        }
        
    }
    
    var pCount = 0;
    
    //MARK: Movement response method
    func updateAtmosphere(currentLocation: CLLocation, currentHeading: CLHeading){
        self.currentLocationGlobal = currentLocation;
        let currMapPoint = MKMapPointForCoordinate(currentLocation.coordinate);
        let pxVals = self.map.collectPXfromMapPoints(mapPoints: mapPoints, currMapPoint: currMapPoint);
        var currPointPX = pxVals.currPointPX;
        var strandValsPX = pxVals.strandValsPX;
        
        
        //aysnchronous get image for openCV wrapper
        self.map.getMapAsIMG(completion: {(image) in
            
            //get strands of true visibility
            let toHideAsSTR = OpenCVWrapper.strands(toHide: &strandValsPX, image: image, currPoint: &currPointPX, pxLength: Int32(pxVals.pxLength));
            
            //rerender or move strands
            self.scene.renderStrands(mapPoints:self.mapPoints, currMapPoint: currMapPoint,
                                     render: self.reRenderStrands, currentHeading: currentHeading, toHide: toHideAsSTR!, comments: self.strandComments, addSceneManual: false);
            
            if(self.reRenderStrands==true){
                self.scene.runScene();
            }
            
            //reposition map view
            let coordinateRegion: MKCoordinateRegion = self.map.centerToLocationRegion(location: currentLocation);
            self.map.mapView.setRegion(coordinateRegion, animated: false);
            if(self.firstRender == true){
                self.oldRenderPosition = currentLocation;
            }
            
            //new or first area threshold passed
            if(currentLocation.distance(from: self.oldRenderPosition)>self.thresholdDistRerender || self.firstRender == true){
                if(self.firstRender == true){
                    self.firstRender = false;
                }
                
                //request new strand data from network
                self.strandNetwork.getRegionData(socket: self.networkWebSocket, currLocation: currentLocation, onReceiveData: {(receivedCoordData, strandComments) in
                    
                    //change data to newly received
                    self.mapPoints = self.map.getCoordsAsMapPoints(coords: receivedCoordData);
                    self.map.updatePins(coords: receivedCoordData);
                    
                    //reset area threshold handlers
                    self.reRenderStrands = true;
                    self.oldRenderPosition = currentLocation;
                    self.strandComments = strandComments;
                    self.pCount += 1;

                });

            }else{
                self.reRenderStrands = false;
            }
        });
        print(self.reRenderStrands);
    }
    
    //MARK: new strand setting and rendering request handlers
    var addTempFirst = true;
    var phonePitch = 0;
    var newStrandDistMetres = 0.0;
    var newStrandDegDiff = 0.0;
    var latestDesiredStrandLocation: CLLocation!;
    
    func renderTempStrandFromMap(mapTapCoord: CLLocationCoordinate2D){
        let strandLocation = CLLocation(latitude: mapTapCoord.latitude, longitude: mapTapCoord.longitude);
        addStrandTemp(strandLocation: strandLocation);
    }
    
    func renderTempStrandFromUI(tapX: Int, tapY: Int){
        newStrandDistMetres = 0.0;
        
        let hozPx = 230;
        
        print(tapX, tapY);
        var yPos = tapY;
        if(tapY < hozPx){
            yPos = hozPx;
        }
        
        let acc1 = 500.0;
        let acc2 = 15.0;
        let acc3 = acc1/acc2 - Double(self.phonePitch-10);

        newStrandDistMetres = (acc2-(Double(yPos)/acc3))*5;
        if(newStrandDistMetres < 0){
            newStrandDistMetres = 3;
        }
        
        let pxMidDiff = 160.0 - Double(tapX);
        let step = 320.0/54.0;
        self.newStrandDegDiff = pxMidDiff/step;
        let strandLocation = location.getPolarCoords(distance: newStrandDistMetres, bearingDiff: self.newStrandDegDiff);
    
        addStrandTemp(strandLocation: strandLocation);
    }
    func addStrandTemp(strandLocation: CLLocation){
        
        self.latestDesiredStrandLocation = strandLocation;
        self.userInterface.showTapFinishedOptions();
        let strandMapPoint = MKMapPointForCoordinate(strandLocation.coordinate);
        let currentMapPoint = MKMapPointForCoordinate(self.currentLocationGlobal.coordinate);
        
        //render temp strand as possible as position
        map.updateSinglePin(coord: strandLocation, temp: true);
        self.scene.renderSingleStrand(renderID: 0, mapPoint: strandMapPoint, currMapPoint: currentMapPoint, strandDisplayInfo: (" ", " "), render: self.addTempFirst, tempStrand: true, addSceneManual: false);
        self.addTempFirst = false;

    }
    
    func cancelNewStrand() {
        self.scene.removeTempStrand();
        self.map.cancelTempStrand();
        self.addTempFirst = true;
    }
  
    func addStrandReady(comment: String){
        
        self.addTempFirst = true;
        map.updateSinglePin(coord: self.latestDesiredStrandLocation, temp: false);
        let strandMapPoint = MKMapPointForCoordinate(self.latestDesiredStrandLocation.coordinate);
        self.mapPoints.append(strandMapPoint);
        let currentMapPoint = MKMapPointForCoordinate(self.currentLocationGlobal.coordinate);
        self.scene.removeTempStrand();
        
        //render temp strand with text
        self.scene.renderSingleStrand(renderID: 0, mapPoint: strandMapPoint, currMapPoint: currentMapPoint, strandDisplayInfo: (comment, self.loggedinUserData.username), render: true, tempStrand: false, addSceneManual: true);
        
        let strandInfo = (comment: comment, author: self.loggedinUserData.username, userID: self.loggedinUserData.id);
        strandNetwork.addStrand(socket: self.networkWebSocket, strandLocation: self.latestDesiredStrandLocation,strandDisplayInfo: strandInfo, onSuccess: {(success) in
            var responseMessage = "Unknown Error. Please try again later.";
            if(success == true){
                responseMessage = "Successfully posted new strand!";
            }
            self.userInterface.updateInfoLabel(newText: responseMessage, show: true, hideAfter: 4);
        });
    }
    
    func loginRequest(username: String, password: String) {
        userNetwork.loginUserRequest(socket: self.networkWebSocket, username: username, password: password, onLoginResponse: {(userID, fullname, email, username)
            in
            var responseMessage = "Incorrect username or password.";
            if(userID>0){
                self.userInterface.hideAnyViews();
                self.userInterface.renderMenu(loggedin: true);
                self.loggedinUserData.id = userID;
                self.loggedinUserData.username = username;
                self.loggedinUserData.fullname = fullname;
                self.loggedinUserData.email = email;
                responseMessage = "Welcome " + fullname.components(separatedBy: " ")[0] + "!";
            }
            self.userInterface.updateInfoLabel(newText: responseMessage, show: true, hideAfter: 5);
        });
    }
    
    func signUpRequest(username: String, password: String, fullname: String, email: String) {
        userNetwork.signUpUserRequest(socket: self.networkWebSocket, username: username, password: password, fullname: fullname, email: email, onSignUpResponse: {(success, errorMsg)
            in
            var responseMessage: String!;
            if(success==true){
                self.userInterface.hideAnyViews();
                responseMessage = "Successfully signed up. You can login now!";
            }else{
                responseMessage = errorMsg;
            }
            self.userInterface.updateInfoLabel(newText: responseMessage, show: true, hideAfter: 5);
        });
    }
    
    func logoutUser() {
        loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown");
        self.userInterface.updateInfoLabel(newText: "You are logged out!", show: true, hideAfter: 2);
    }
    
    func requestUserStrands() {
        strandNetwork.getUserStrands(socket: self.networkWebSocket, userID: self.loggedinUserData.id, onReceive: {(strands, fComments)
            in
            
            self.userInterface.populateUserStrands(strands: strands, firstComments: fComments);
        
        });
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
        
        
    
        super.viewDidLoad();
    }
    
}

