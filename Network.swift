//
//  Network.swift
//  Focals
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

@objc protocol NetworkResponseDelegate {
    
    @objc optional func regionDataResponse(_ responseStr: String);
    @objc optional func userLoggedinResponse(_ responseStr: String);
    @objc optional func addedFocalResponse(_ responseStr: String);
    @objc optional func userFocalsResponse(_ responseStr: String);
    @objc optional func deletedFocalResponse(_ responseStr: String);
    @objc optional func focalCommentsResponse(_ responseStr: String);
    @objc optional func postedCommentResponse(_ responseStr: String);
    @objc optional func updatedUserDataResponse(_ responseStr: String);
    
}


//MARK: general socket functionality, and response function routing
class NetworkSocketHandler{
    
    let socket = WebSocket(url: URL(string: "ws://casparwylie.me:3000/")!);
    var ui: UserInterface1!;
    var networkResponseDelegate: NetworkResponseDelegate?;
    func connectWebSocket() -> WebSocket{
        socket.connect();
        socket.onConnect = {
            print("Connected to WebSocket");
        }
        setResponseRouteHandler();
        
        return socket;
    }
    
    func processResponseAsJSON(_ responseData: String) -> JSON{
        let responseData = responseData.data(using: String.Encoding.utf8,allowLossyConversion: false);
        let responseJSON = JSON(data: responseData!);
        return responseJSON;
    }
    
    func sendRelevantJsonRequest(_ socket: WebSocket, requestName: String, relevantData: [String: String]){
        
        var relevantDataAsJson: [String: JSON] = [:];
        for element in relevantData{
            relevantDataAsJson[element.key] =  JSON(element.value);
        }
        let finalRelevantDataAsJson = JSON(relevantDataAsJson);
        let finalJsonRequestObject = JSON(["request": JSON(requestName), "requestData": finalRelevantDataAsJson]);
        socket.write(string: finalJsonRequestObject.rawString()!);
    }

    
    func setResponseRouteHandler(){
        socket.onText = { (responseString: String) in
            let responseJSON = self.processResponseAsJSON(responseString);
            switch(responseJSON["response"].string!){
                case "regionData":
                    self.networkResponseDelegate?.regionDataResponse!(responseString);
                case "userLoggedin":
                    self.networkResponseDelegate?.userLoggedinResponse!(responseString);
                case "addedFocal":
                    self.networkResponseDelegate?.addedFocalResponse!(responseString);
                case "userFocals":
                    self.networkResponseDelegate?.userFocalsResponse!(responseString);
                case "deletedFocal":
                    self.networkResponseDelegate?.deletedFocalResponse!(responseString);
                case "focalComments":
                    self.networkResponseDelegate?.focalCommentsResponse!(responseString);
                case "postedComment":
                    self.networkResponseDelegate?.postedCommentResponse!(responseString);
                case "updatedUserData":
                    self.networkResponseDelegate?.updatedUserDataResponse!(responseString);
                default:
                    print("failed");

        
            }
        }
    }
    
}

//MARK: all network request data organisers
class NetworkRequestHandler{
    
    func loginUserRequest(_ socket: WebSocket, username: String, password: String){
        let organisedRelevantData = ["username": username, "password": password];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "loginUserRequest", relevantData: organisedRelevantData);

    }
    
    func updateUserDataRequest(_ socket: WebSocket, username: String, password: String, fullname: String, email: String, userID: Int){
        
        let updateType = (userID > 0 ? "userUpdate" : "userSignUp");
        let organisedRelevantData = ["username":username, "password": password, "email": email, "fullname": fullname, "userID": String(userID), "updateType" : updateType];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "updateUserDataRequest", relevantData: organisedRelevantData);
        
    }

    func getRegionData(_ socket: WebSocket, currLocation: CLLocation){
        
        let currentLat = currLocation.coordinate.latitude;
        let currentLon = currLocation.coordinate.longitude;
        
       let organisedRelevantData = ["longitude": String(currentLon), "latitude": String(currentLat)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "regionDataRequest", relevantData: organisedRelevantData);

    }
    
    func addFocal(_ socket: WebSocket, focalLocation: CLLocation,focalDisplayInfo: (comment: String, author: String, userID: Int, areaName: String)){
        
        let focalLat = focalLocation.coordinate.latitude;
        let focalLon = focalLocation.coordinate.longitude;
        
        
       let organisedRelevantData = ["longitude": String(focalLon),
                                     "latitude": String(focalLat),
                                     "postText": focalDisplayInfo.comment,
                                     "author": focalDisplayInfo.author,
                                     "userID": String(focalDisplayInfo.userID),
                                     "areaName": focalDisplayInfo.areaName];
        
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "addFocalRequest", relevantData: organisedRelevantData);
    }
    
    func getUserFocals(_ socket: WebSocket,userID: Int){
        
        let organisedRelevantData = ["userID": String(userID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "userFocalsRequest", relevantData: organisedRelevantData);
    }
    
    func deleteFocal(_ socket: WebSocket,focalID: Int){
        
        let organisedRelevantData = ["focalID": String(focalID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "deleteFocalRequest", relevantData: organisedRelevantData);

    }
    
    func getFocalComments(_ socket: WebSocket, focalID: Int){

        let organisedRelevantData = ["focalID": String(focalID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "focalCommentsRequest", relevantData: organisedRelevantData);
    }
    
    func postComment(_ socket: WebSocket, focalID: Int, username: String, commentText: String){
        
        let organisedRelevantData = ["focalID": String(focalID), "username": username, "postText": commentText];
        NetworkSocketHandler().sendRelevantJsonRequest(socket,requestName: "postFocalCommentRequest", relevantData: organisedRelevantData);
        
    }
    
}
