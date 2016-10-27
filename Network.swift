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

class NetworkSocketHandler{
    
    let socket = WebSocket(url: URL(string: "ws://casparwylie.me:3000/")!);
    let thetet = "hi";
    //MARK: Initial server connection
    func connectWebSocket() -> WebSocket{
        socket.connect();
        socket.onConnect = {
            print("Connected to WebSocket");
        }
        
        return socket;
    }
}

class UserNetwork{
    
    
}

class StrandNetwork{
    
    func processResponseAsJSON(responseData: String) -> JSON{
        let responseData = responseData.data(using: String.Encoding.utf8,allowLossyConversion: false);
        let responseJSON = JSON(data: responseData!);
        return responseJSON;
    }
    
    //MARK: Recurring request on new strand coord data
    func getRegionData(socket: WebSocket, currLocation: CLLocation,
                       onReceiveData: @escaping ([CLLocation],JSON)->()){
        
        //setup request
        var coordsAsCLLocation: [CLLocation] = [];
        let currentLat = currLocation.coordinate.latitude;
        let currentLon = currLocation.coordinate.longitude;
        let responseIdent = "regionData";
        let responseStrandDataKey = "regionStrandData";
        let responseStrandCommentKey = "strandComments";
        let requestStringJSON = "{\"request\":\"getRegionData\", \"currentLocation\":{\"longitude\":\""+String(currentLon)+"\",\"latitude\":\""+String(currentLat)+"\"}}";
        socket.write(string: requestStringJSON);
        //receive response
        socket.onText = { (responseData: String) in
            
            let responseJSON = self.processResponseAsJSON(responseData: responseData);
            
            //format and organise response
            if(String(describing: responseJSON["response"]) == responseIdent && responseJSON[responseStrandDataKey].count != 0){
                
                for var coordRowCount in 0...responseJSON[responseStrandDataKey].count-1{
                    let rowLatitude = Double(responseJSON[responseStrandDataKey][coordRowCount]["s_coord_lat"].rawString()!);
                    let rowLongitude = Double(responseJSON[responseStrandDataKey][coordRowCount]["s_coord_lon"].rawString()!);
                    let rowAsCLLocation = CLLocation(latitude: CLLocationDegrees(rowLatitude!), longitude: CLLocationDegrees(rowLongitude!));
                    coordsAsCLLocation.append(rowAsCLLocation);
                }
                
            }
            
            //send response data to renderer
            onReceiveData(coordsAsCLLocation, responseJSON[responseStrandCommentKey]);
        }
        
    }
    
    //MARK: Add strand request to network (save in database)
    func addStrand(socket: WebSocket, strandLocation: CLLocation, strandFirstPost: String, onSuccess: @escaping (Bool)->()){
        
        let responseIdent = "addedStrand";
        let strandLat = strandLocation.coordinate.latitude;
        let strandLon = strandLocation.coordinate.longitude;
        let requestStringJSON = "{\"request\":\"addStrandRequest\", \"strandLocation\":{\"longitude\":\""+String(strandLon)+"\",\"latitude\":\""+String(strandLat)+"\"}, \"strandPostText\":\""+strandFirstPost+"\"}";
        socket.write(string: requestStringJSON);
        socket.onText = { (responseData: String) in
            let responseJSON = self.processResponseAsJSON(responseData: responseData);
             if(String(describing: responseJSON["response"]) == responseIdent){
                let success: Bool = (responseJSON["success"]=="true" ? true: false);
                onSuccess(success);
            }
        }
        
    }
}
