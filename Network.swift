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
    
    //MARK: Initial server connection
    func connectWebSocket() -> WebSocket{
        socket.connect();
        socket.onConnect = {
            print("Connected to WebSocket");
        }
        
        return socket;
    }
    
    func processResponseAsJSON(responseData: String) -> JSON{
        let responseData = responseData.data(using: String.Encoding.utf8,allowLossyConversion: false);
        let responseJSON = JSON(data: responseData!);
        return responseJSON;
    }
}

class UserNetwork{
    
    func loginUserRequest(socket: WebSocket, username: String, password: String, onLoginResponse: @escaping (Int, String, String, String)->()){
        
        let requestJSONname = JSON("loginUser");
        let requestJSONauthData = JSON(["username": username, "password": password]);
        let requestJSON = JSON(["request": requestJSONname, "authData": requestJSONauthData]);
        
        let responseIdent = "loginResponse";
        socket.write(string: requestJSON.rawString()!);
        socket.onText = { (responseData: String) in
            let responseJSON = NetworkSocketHandler().processResponseAsJSON(responseData: responseData);
            if(String(describing: responseJSON["response"]) == responseIdent){
                var userID = 0;
                var username = "";
                var fullname =  "";
                var email =  "";
                if(responseJSON["success"].rawString()! == "true"){
                    userID = Int(responseJSON["result"]["u_id"].rawString()!)!;
                    username = responseJSON["result"]["u_uname"].rawString()!;
                    fullname = responseJSON["result"]["u_fullname"].rawString()!;
                    email = responseJSON["result"]["u_email"].rawString()!;
                }
                onLoginResponse(userID, fullname, email, username);
            }
        }
    }
    
    func signUpUserRequest(socket: WebSocket, username: String, password: String, fullname: String, email: String, onSignUpResponse: @escaping (Bool, String)->()){
        
        let requestJSONname = JSON("signUpUser");
        let requestJSONuserData = JSON(["username":username, "password": password, "email": email, "fullname": fullname]);
        
        let requestJSON = JSON(["request":requestJSONname, "userData": requestJSONuserData]);
        
        let responseIdent = "signUpResponse";
        socket.write(string: requestJSON.rawString()!);
        socket.onText = { (responseData: String) in
            let responseJSON = NetworkSocketHandler().processResponseAsJSON(responseData: responseData);
            if(String(describing: responseJSON["response"]) == responseIdent){
                var success = true;
                if(responseJSON["success"] == "false"){
                    success = false;
                }
                onSignUpResponse(success, responseJSON["errorMsg"].rawString()!);
            }
        }
    }
    
}

class StrandNetwork{

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
        
        
        let requestJSONname = JSON("getRegionData");
        let requestJSONcurrentLocation = JSON(["longitude": String(currentLon), "latitude": String(currentLat)]);
        let requestJSON = JSON(["request": requestJSONname, "currentLocation": requestJSONcurrentLocation]);
        
        socket.write(string: requestJSON.rawString()!);
        //receive response
        socket.onText = { (responseData: String) in
            
            let responseJSON = NetworkSocketHandler().processResponseAsJSON(responseData: responseData);
            
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
    func addStrand(socket: WebSocket, strandLocation: CLLocation,strandDisplayInfo: (comment: String, author: String, userID: Int),onSuccess: @escaping (Bool)->()){
        
        let responseIdent = "addedStrand";
        let strandLat = strandLocation.coordinate.latitude;
        let strandLon = strandLocation.coordinate.longitude;

        
        
        let requestJSONname = JSON("addStrandRequest");
        let requestJSONstrandLocation = JSON(["longitude":String(strandLon), "latitude": String(strandLat)]);
        let requestJSONstrandMedia = JSON(["postText": strandDisplayInfo.comment, "author": strandDisplayInfo.author, "userID": strandDisplayInfo.userID]);
        
        let requestJSON: JSON = JSON(["request":requestJSONname, "strandLocation":requestJSONstrandLocation, "strandMedia":requestJSONstrandMedia]);
        socket.write(string: requestJSON.rawString()!);
        socket.onText = { (responseData: String) in
            let responseJSON = NetworkSocketHandler().processResponseAsJSON(responseData: responseData);
             if(String(describing: responseJSON["response"]) == responseIdent){
                let success: Bool = (responseJSON["success"]=="true" ? true: false);
                onSuccess(success);
            }
        }
    }
    
    func getUserStrands(socket: WebSocket,userID: Int, onReceive: @escaping (JSON, JSON)->()){
        
        let responseIdent = "userStrands";
        
        let requestJSONname = JSON("getUserStrands");
        let requestJSONuserID = JSON(userID);
        let requestJSON = JSON(["request": requestJSONname, "userID": requestJSONuserID]);

        socket.write(string: requestJSON.rawString()!);
        socket.onText = { (responseData: String) in
            let responseJSON = NetworkSocketHandler().processResponseAsJSON(responseData: responseData);
            if(String(describing: responseJSON["response"]) == responseIdent){
                onReceive(responseJSON["strands"], responseJSON["fComments"]);
            }
        }
    }
}
