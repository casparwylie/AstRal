//
//  Network.swift
//  Strands
//
//  Created by Caspar Wylie on 29/09/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 NETWORK COMPONENT
 
 */


import Foundation
import Starscream
import CoreLocation
import SwiftyJSON

class Network{
    
    let socket = WebSocket(url: URL(string: "ws://casparwylie.me:3000/")!);
    
    //MARK: Initial server connection
    func connectWebSocket(){
        socket.connect();
        socket.onConnect = {
            print("Connected to WebSocket");
        }
    }
    
    //MARK: Recurring request on new strand coord data
    func getRegionData(currLocation: CLLocation, onRecieveData: @escaping ([CLLocation])->()){
        
        //setup request
        var coordsAsCLLocation: [CLLocation] = [];
        let currentLat = currLocation.coordinate.latitude;
        let currentLon = currLocation.coordinate.longitude;
        let responseIdent = "regionData";
        let requestStringJSON = "{\"request\":\"getRegionData\", \"currentLocation\":{\"longitude\":\""+String(currentLon)+"\",\"latitude\":\""+String(currentLat)+"\"}}";
        socket.write(string: requestStringJSON);
        
        //receive response
        socket.onText = { (responseCoordData: String) in
            let responseCoordData = responseCoordData.data(using: String.Encoding.utf8,allowLossyConversion: false);
            let responseJSON = JSON(data: responseCoordData!);
            
            //format and organise response
            if(String(describing: responseJSON["response"]) == responseIdent && responseJSON[responseIdent].count != 0){
                for var coordRowCount in 0...responseJSON[responseIdent].count-1{
                    let rowLatitude = Double(responseJSON[responseIdent][coordRowCount]["s_coord_lat"].rawString()!);
                    let rowLongitude = Double(responseJSON[responseIdent][coordRowCount]["s_coord_lon"].rawString()!);
                    let rowAsCLLocation = CLLocation(latitude: CLLocationDegrees(rowLatitude!), longitude: CLLocationDegrees(rowLongitude!));
                    coordsAsCLLocation.append(rowAsCLLocation);
                }
            }
            //send response data to renderer
            onRecieveData(coordsAsCLLocation);
        }
        
    }
}
