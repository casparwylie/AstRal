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

@objc protocol NetworkResponseDelegate {
    
    @objc optional func regionDataResponse(_ responseStr: String);
    @objc optional func userLoggedinResponse(_ responseStr: String);
    @objc optional func addedStrandResponse(_ responseStr: String);
    @objc optional func userStrandsResponse(_ responseStr: String);
    @objc optional func deletedStrandResponse(_ responseStr: String);
    @objc optional func strandCommentsResponse(_ responseStr: String);
    @objc optional func postedCommentResponse(_ responseStr: String);
    @objc optional func updatedUserDataResponse(_ responseStr: String);
    
}


//MARK: general socket functionality, and response function routing
class NetworkSocketHandler{
    
    let socket = WebSocket(url: URL(string: "ws://casparwylie.me:3000/")!);
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
            let responseJSON = self.processResponseAsJSON(responseData: responseString);
            switch(responseJSON["response"].string!){
                case "regionData":
                    self.networkResponseDelegate?.regionDataResponse!(responseStr: responseString);
                case "userLoggedin":
                    self.networkResponseDelegate?.userLoggedinResponse!(responseStr: responseString);
                case "addedStrand":
                    self.networkResponseDelegate?.addedStrandResponse!(responseStr: responseString);
                case "userStrands":
                    self.networkResponseDelegate?.userStrandsResponse!(responseStr: responseString);
                case "deletedStrand":
                    self.networkResponseDelegate?.deletedStrandResponse!(responseStr: responseString);
                case "strandComments":
                    self.networkResponseDelegate?.strandCommentsResponse!(responseStr: responseString);
                case "postedComment":
                    self.networkResponseDelegate?.postedCommentResponse!(responseStr: responseString);
                case "updatedUserData":
                    self.networkResponseDelegate?.updatedUserDataResponse!(responseStr: responseString);
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
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "loginUserRequest", relevantData: organisedRelevantData);

    }
    
    func updateUserDataRequest(_ socket: WebSocket, username: String, password: String, fullname: String, email: String, userID: Int){
        
        let updateType = (userID > 0 ? "userUpdate" : "userSignUp");
        let organisedRelevantData = ["username":username, "password": password, "email": email, "fullname": fullname, "userID": String(userID), "updateType" : updateType];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "updateUserDataRequest", relevantData: organisedRelevantData);
        
    }

    func getRegionData(_ socket: WebSocket, currLocation: CLLocation){
        
        let currentLat = currLocation.coordinate.latitude;
        let currentLon = currLocation.coordinate.longitude;
        
       let organisedRelevantData = ["longitude": String(currentLon), "latitude": String(currentLat)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "regionDataRequest", relevantData: organisedRelevantData);

    }
    
    func addStrand(_ socket: WebSocket, strandLocation: CLLocation,strandDisplayInfo: (comment: String, author: String, userID: Int, areaName: String)){
        
        let strandLat = strandLocation.coordinate.latitude;
        let strandLon = strandLocation.coordinate.longitude;
        
        
       let organisedRelevantData = ["longitude": String(strandLon),
                                     "latitude": String(strandLat),
                                     "postText": strandDisplayInfo.comment,
                                     "author": strandDisplayInfo.author,
                                     "userID": String(strandDisplayInfo.userID),
                                     "areaName": strandDisplayInfo.areaName];
        
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "addStrandRequest", relevantData: organisedRelevantData);
    }
    
    func getUserStrands(_ socket: WebSocket,userID: Int){
        
        let organisedRelevantData = ["userID": String(userID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "userStrandsRequest", relevantData: organisedRelevantData);
    }
    
    func deleteStrand(_ socket: WebSocket,strandID: Int){
        
        let organisedRelevantData = ["strandID": String(strandID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "deleteStrandRequest", relevantData: organisedRelevantData);

    }
    
    func getStrandComments(_ socket: WebSocket, strandID: Int){

        let organisedRelevantData = ["strandID": String(strandID)];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "strandCommentsRequest", relevantData: organisedRelevantData);
    }
    
    func postComment(_ socket: WebSocket, strandID: Int, username: String, commentText: String){
        
        let organisedRelevantData = ["strandID": String(strandID), "username": username, "postText": commentText];
        NetworkSocketHandler().sendRelevantJsonRequest(socket: socket,requestName: "postStrandCommentRequest", relevantData: organisedRelevantData);
        
    }
    
}
