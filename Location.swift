//
//  Location.swift
//  Astral
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
    func regionDataUpdate(_ currentLocation: CLLocation, currentHeading: CLHeading);
}

class Location: NSObject, CLLocationManagerDelegate{
    
    let locManager = CLLocationManager();
    var currentLocation: CLLocation?;
    var currentHeading: CLHeading?;
    var dataString: String!;
    var delegateLoc : LocationDelegate?;
    var ui: UserInterface1!;
    
    //MARK: setup location service and request permission
    func initLocation(){
            locManager.distanceFilter = 3;
            locManager.desiredAccuracy = kCLLocationAccuracyBest;
            locManager.startUpdatingLocation();
            //todo : check headingAvaliable
            locManager.startUpdatingHeading();
            locManager.delegate = self;
    }
    
    
    func getPolarCoords(_ distance: Double, bearingDegrees: Double) ->CLLocation{
        
        let earthRadius = 6371000.0;
        let bearingRadians = bearingDegrees * (M_PI / 180);
        print("cd:",bearingDegrees);
        let distanceByER = Double(distance/earthRadius);
        
        let latitude = (currentLocation?.coordinate.latitude)!  * (M_PI / 180);
        let longitude  = (currentLocation?.coordinate.longitude)!  * (M_PI / 180);
        
        let newLatitude = asin(sin(latitude)*cos(distanceByER) + cos(latitude)*sin(distanceByER)*cos(bearingRadians));
        let newLongitude = longitude + atan2(sin(bearingRadians)*sin(distanceByER)*cos(latitude),
                                             cos(distanceByER)-sin(latitude)*sin(newLatitude));
        
        return CLLocation(latitude: newLatitude * (180 / M_PI), longitude: newLongitude * (180 / M_PI));
    }
    
    func getBearingFromTwoCoords(_ location1: CLLocation, location2: CLLocation) -> Int{
        
        let longitude1 = location1.coordinate.longitude * (M_PI / 180)
        let longitude2 = location2.coordinate.longitude * (M_PI / 180)
        let latitude1 = location1.coordinate.latitude * (M_PI / 180)
        let latitude2 = location2.coordinate.latitude * (M_PI / 180)
        
        let diff = (longitude2 - longitude1)
        let pointX = cos(latitude2) * sin(diff);
        let pointY = cos(latitude1) * sin(latitude2)-sin(latitude1) * cos(latitude2) * cos(diff);
        let bearing = atan2(pointX, pointY)*(180.0 / M_PI);
        return Int(bearing);
    }
    
    func getBearingFromTwo2dPoints(_ point1X: Double, point1Y: Double, point2X: Double, point2Y: Double) -> Int{
        
        var theta = atan2(point2X - point1X, point1Y - point2Y);
        if(theta < 0.0){
            theta += 2*M_PI;
        }
        let bearing = (180 / M_PI) * theta;
        return Int(bearing);
    }
    
    func getDistanceBetweenTwo2dPoints(_ point1X: Double, point1Y: Double, point2X: Double, point2Y: Double) -> Int{
        let xLength = point1X - point2X;
        let yLength = point1Y - point2Y;
        
        let toRoot = xLength*xLength + yLength*yLength
        let distance = Int(sqrt(Double(toRoot)));
        return distance;
    }
    
    func collectFocalToUserData(_ point1X: Double, point1Y:  Double, point2X:  Double, point2Y: Double) -> (distance: Int, bearing: Int){
        
        let lineBetweenBearing = getBearingFromTwo2dPoints(point1X, point1Y: point1Y, point2X: point2X, point2Y: point2Y);
        
        let distBetween = getDistanceBetweenTwo2dPoints(point1X, point1Y: point1Y, point2X: point2X, point2Y: point2Y);
        
        let distAndBearing = (distance: distBetween, bearing: lineBetweenBearing);
        return distAndBearing;
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedWhenInUse:
                locManager.startUpdatingLocation();
                break;
            case .notDetermined:
                locManager.requestWhenInUseAuthorization();
                break;
            case .authorizedAlways:
                locManager.startUpdatingLocation();
                break;
            case .restricted:
                self.ui.updateInfoLabel(22, show: true, hideAfter: 10);
                break;
            case .denied:
                self.ui.updateInfoLabel(22, show: true, hideAfter: 10);
                break;
            default:
                break;
        }
    }
    
    //MARK: Automatic delegation call on heading update, update heading data.
    @objc func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        currentHeading = newHeading;
        
    }
    
    //MARK: Automatic delegation call on location update, updates current coord data.
    @objc func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        
        if(currentHeading != nil){
            self.currentLocation = locations.last;
            self.delegateLoc?.regionDataUpdate(self.currentLocation!, currentHeading: self.currentHeading!);
        }
        
    }
    
}
