//
//  Location.swift
//  Strands
//
//  Created by Caspar Wylie on 05/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 LOCATION COMPONENT
 
 */

import UIKit
import Foundation
import CoreLocation

//delegate design for viewController communication
protocol LocationDelegate {
    func updateLabel(text: String);
    func updateAtmosphere(currentLocation: CLLocation, currentHeading: CLHeading);
}

class Location: NSObject, CLLocationManagerDelegate{
    
    let locManager = CLLocationManager();
    var currentLocation: CLLocation?;
    var currentHeading: CLHeading?;
    var dataString: String!;
    var delegateLoc : LocationDelegate?;
    
    //MARK: setup location service and request permission
    func initLocation() -> Bool{
        
        //Check location permission
        locManager.requestWhenInUseAuthorization();
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            //Location header data
            locManager.distanceFilter = 1;
            locManager.desiredAccuracy = kCLLocationAccuracyBest;
            locManager.startUpdatingLocation();
            //todo : check headingAvaliable
            locManager.startUpdatingHeading();
            locManager.delegate = self;
            return true;
        }else{
            return false;
        }
    }
    
    
    //MARK: Automatic delegation call on heading update, update heading data.
    @objc func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        currentHeading = newHeading;
    }
    
    //MARK: Automatic delegation call on location update, updates current coord data.
    @objc func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        
        if(currentHeading != nil){
            currentLocation = locations.last;
            delegateLoc?.updateAtmosphere(currentLocation: currentLocation!, currentHeading: currentHeading!);
        }
        
    }
    
    

   
}
