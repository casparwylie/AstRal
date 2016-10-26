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

class ViewController: UIViewController, LocationDelegate, UIActionDelegate{
    
    //MARK: Component allocation
    var misc = Misc();
    var camera = Camera();
    var scene = Scene();
    var location = Location();
    var userInterface = UserInterface1();
    var motionManager = CMMotionManager();
    var map = Map();
    var network = Network();
    
    //MARK: general data
    var reRenderStrands = true;
    var firstRender = true;
    var thresholdDistRerender = 25.0;
    var oldRenderPosition: CLLocation!;
   
    var mapPoints: [MKMapPoint] = [];
    
    //MARK: UI Action definitions
    
    func updateLabel(text: String){
        userInterface.updateLabel(labelID: 0, newText: text);
    }
    
    func toggleMap() {
        if self.view.viewWithTag(3)?.isHidden == false {
            self.view.viewWithTag(3)?.isHidden = true;
        }else{
            self.view.viewWithTag(3)?.isHidden = false;
        }
        
    }
    
    var pCount = 0;
    
    //MARK: Movement response method
    func updateAtmosphere(currentLocation: CLLocation, currentHeading: CLHeading){
        
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
                                     render: self.reRenderStrands, currentHeading: currentHeading, toHide: toHideAsSTR!);
            
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
                self.network.getRegionData(currLocation: currentLocation, onRecieveData: {(recievedCoordData) in
                    
                    //change data to newly received
                    self.mapPoints = self.map.getCoordsAsMapPoints(coords: recievedCoordData);
                    self.map.updatePins(coords: recievedCoordData);
                    
                    //reset area threshold handlers
                    self.reRenderStrands = true;
                    self.oldRenderPosition = currentLocation;
                    self.pCount += 1;
                    self.userInterface.updateLabel(labelID: 0, newText: "PASSED 25. New render."+String(recievedCoordData.count)+", ID: "+String(self.pCount));
                });

            }else{
                self.reRenderStrands = false;
            }
        });
        print(self.reRenderStrands);
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
        
        self.view.viewWithTag(3)?.isHidden = true;
        
        //Initilize UI component
        userInterface.renderAll(view: self.view);
        userInterface.actionDelegate = self;
        
        //Initilize Motion Handler
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        motionManager.startDeviceMotionUpdates(
            using: CMAttitudeReferenceFrame.xMagneticNorthZVertical,
            to: OperationQueue.current!,
            withHandler: {
                (gyroData: CMDeviceMotion?, NSError) ->Void in
                let mData: CMAttitude = gyroData!.attitude;
                self.scene.rotateCamera(gyroData: mData);
                if(NSError != nil){
                    print("\(NSError)");
                }
        });
        
        //Initilize Network socket component
        network.connectWebSocket();
        
        
    
        super.viewDidLoad();
    }
    
}

