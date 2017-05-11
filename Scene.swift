//
//  Scene.swift
//  Focals
//
//  Created by Caspar Wylie on 05/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 SCENE COMPONENT
 
 */

import Foundation
import SceneKit
import CoreMotion
import MapKit
import SwiftyJSON

class Scene{
    
    //MARK: Node initiation
    let lightNode = SCNNode();
    let cameraNode = SCNNode();
    let scene = SCNScene();
    var floorNode: SCNNode!;
    var tempFocalNode: SCNNode!;
    var focals: [SCNNode] = [];
    var sceneView: SCNView!;
    
    //MARK: Add scene view to view
    func renderSceneLayer(_ frameView: UIView) -> Void{
        
        let frameRect = frameView.frame;
        sceneView = SCNView(frame: frameRect);
        sceneView.backgroundColor = UIColor(white: 1, alpha: 0.0);
        frameView.addSubview(sceneView);
        
        sceneView.scene = scene;
        sceneView.audioEngine.mainMixerNode.outputVolume = 0.0;
    }
    
    //MARK: values are approximate within tolerance bound
    func isApprox(_ value1: CGFloat, value2: CGFloat, tol: CGFloat) -> Bool{
        if( ((value1 - tol) <= value2) && ((value1 + tol) >= value2 ) ){
            return true;
        }else{
            return false;
        }
    }
    
    //MARK: Node rendering
    func renderLight(){
        let lightObj = SCNLight();
        lightObj.type = SCNLight.LightType.omni;
        lightNode.light = lightObj;
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5);
    }
    
    func toDegrees(_ rad: Double) -> Double{
        return rad*57.2958;
    }
    
    
    func renderCamera(){
        let cameraObj = SCNCamera();
        cameraNode.camera = cameraObj;
        cameraNode.camera!.zNear = 0.1;
        cameraNode.camera!.zFar = 1200.0;
        cameraNode.position = SCNVector3(x: 0.0, y: 15.0, z: 0.0);
        
    }
    
    func renderFloor(){
        let size: CGFloat = 700.0;
        let floor = SCNCylinder(radius: size,height: 1.0);
        floorNode = SCNNode(geometry: floor);
        floorNode.position = SCNVector3(x: 0,y: 0, z: 0);
        floorNode.opacity = 0.001;
        floorNode.name = "floor";
        
    }
    
    //MARK: rotate virtual 3D atmosphere around current coordinates
    func rotateAroundPoint(_ pointXY: (x: Double,y: Double),angle: Double) -> (x: Double, y: Double){
        let angle = angle * 0.0174533;
        let pX = (pointXY.x * cos(angle)) + (pointXY.y * sin(angle));
        let pY = -(pointXY.x * sin(angle)) + (pointXY.y * cos(angle));
        return (x: pX, y: pY);
    }
    
    func DAEtoSCNNodeWithText(_ filepath:String, focalDisplayInfo: (comment: String, author: String)) -> SCNNode {
        
        //setup text nodes
        let singNode = SCNNode();
        let localScene = SCNScene(named: filepath);
        let singNodeArray = localScene!.rootNode.childNodes;
        let midText = ((focalDisplayInfo.author != " ") ? " \n\n By " : "");
        let displayText = focalDisplayInfo.comment + midText + focalDisplayInfo.author;
        //let textRenderFront = SCNText(string: displayText, extrusionDepth:1);
        //let textRenderBack = SCNText(string: displayText, extrusionDepth:1);
        
        //attribute option setting
        //let textContainerFrame = CGRect(x: 0,y: 0, width: 270, height: 100);
        //let textIsWrapped = true;
        //let textColor = UIColor.black;
        //_ = SCNVector3(0.07,0.07,0.07);
        
        //setting attributes
        /*textRenderFront.isWrapped = textIsWrapped;
         textRenderFront.firstMaterial?.diffuse.contents = textColor;
         textRenderFront.containerFrame = textContainerFrame;
         textRenderFront.alignmentMode = kCAAlignmentCenter;
         textRenderBack.isWrapped = textIsWrapped;
         textRenderBack.firstMaterial?.diffuse.contents = textColor;
         textRenderBack.containerFrame = textContainerFrame;
         textRenderBack.alignmentMode = kCAAlignmentCenter;*/
        
        //build DAE scene as node by each component
        for childNode in singNodeArray {
            /*
             let textNodeFront = SCNNode(geometry: textRenderFront);
             let textNodeBack = SCNNode(geometry: textRenderBack);
             
             textNodeFront.scale = textNodeScale;
             textNodeFront.position = SCNVector3(x: 1, y: 23, z: -4); //x = depth , z = lateral
             textNodeFront.eulerAngles = SCNVector3(x: 0, y: 1.5708, z: 0);
             
             textNodeBack.scale = textNodeScale;
             textNodeBack.position = SCNVector3(x: -1.5, y: 23, z: -23);
             textNodeBack.eulerAngles = SCNVector3(x: 0, y: -1.5708, z: 0);
             
             singNode.addChildNode(textNodeFront);
             singNode.addChildNode(textNodeBack);*/
            singNode.addChildNode(childNode as SCNNode);
            
        }
        return singNode;
    }
    
    func renderSingleFocal(_ renderID: Int, mapPoint: MKMapPoint, currMapPoint: MKMapPoint, focalDisplayInfo: (String, String), render: Bool, tempFocal: Bool, vec: SCNVector3){
        
        var focalCoord = (x: mapPoint.x - currMapPoint.x, y: mapPoint.y - currMapPoint.y);
        focalCoord = rotateAroundPoint(focalCoord, angle: -90);
        
        if(render==true){
            //initiate focals
            if(tempFocal == false){
                let focal = DAEtoSCNNodeWithText("focalpost.dae", focalDisplayInfo: focalDisplayInfo);
                focal.name = "f_" + String(renderID);
                focal.position = SCNVector3(x: Float(focalCoord.x), y: 0, z:  Float(focalCoord.y));
                focals.append(focal);
                self.scene.rootNode.addChildNode(focals.last!);
            }else{
                tempFocalNode = DAEtoSCNNodeWithText("focalpost.dae", focalDisplayInfo: focalDisplayInfo);
                tempFocalNode.name = "f_" + String(renderID);
                tempFocalNode.position = vec//SCNVector3(x: Float(focalCoord.x), y: 0, z:  Float(focalCoord.y));
                self.scene.rootNode.addChildNode(tempFocalNode);
            }
            
        }else{
            //update focal position
            let newPos = SCNVector3(x: Float(focalCoord.x), y: 0.0, z:  Float(focalCoord.y));
            if(tempFocal == false){
                //print(focals);
                let moveToAction = SCNAction.move(to: newPos, duration: 1);
                focals[renderID].runAction(moveToAction);
            }else{
                tempFocalNode.position = vec;
            }
        }
    }
    
    func removeTempFocal(){
        tempFocalNode?.removeFromParentNode();
    }
    //MARK: render or update focal within 3D atmosphere
    func renderFocals(_ mapPoints: [MKMapPoint], currMapPoint: MKMapPoint,
                      render: Bool, currentHeading: CLHeading, toHide: String, comments: JSON, tempFocalMapPoint: MKMapPoint){
        
        let toHideAsArr = toHide.components(separatedBy: ",");
        
        //remove previous area / region data
        if(render==true){
            if (focals.count != 0) {
                for oldFocalID in 0...focals.count-1{
                    focals[oldFocalID].removeFromParentNode();
                }
                focals = [];
            }
        }
        if(tempFocalMapPoint.x != 0.0){
            let tempFocalDisplayInfo = (comment: " ", author: " ");
            renderSingleFocal(-1,mapPoint: tempFocalMapPoint, currMapPoint: currMapPoint, focalDisplayInfo: tempFocalDisplayInfo, render: false, tempFocal: true, vec: SCNVector3Zero);
            
        }
        
        //render or move new focals
        var i = 0;
        for mPoint in mapPoints{
            let focalDisplayInfo = (comment: comments[i]["c_text"].rawString()!, author: comments[i]["c_u_uname"].rawString()!);
            
            renderSingleFocal(i,mapPoint: mPoint, currMapPoint: currMapPoint, focalDisplayInfo: focalDisplayInfo, render: render, tempFocal: false, vec: SCNVector3Zero);
            //hide non-street visible focals
            for hideID in toHideAsArr{
                if (hideID == String(i)){
                    //focals[i].isHidden = true;
                    break;
                }else{
                    focals[i].isHidden = false;
                }
            }
            i += 1;
        }
    }
    //MARK: gyro to scene camera mapping, on new gyro/motion data (delegated call from ViewController)
    func rotateCamera(_ gyroData: CMAttitude){
        
        let qData: CMQuaternion = gyroData.quaternion;
        
        //quaternion data to eulerAngles (prevention of gimbal lock!)
        let attitudeRoll = atan2((2 * qData.y * qData.w) - (2 * qData.x * qData.z),
                                 1 - (2 * qData.y * qData.y) - (2 * qData.z * qData.z) );
        let attitudePitch = atan2((2 * qData.x * qData.w) - (2 * qData.y * qData.z),
                                  1 - (2 * qData.x * qData.x) - (2 * qData.z * qData.z) );
        let attitudeYaw = asin((2 * qData.x * qData.y) + (2 * qData.z * qData.w));
        
        cameraNode.eulerAngles = SCNVector3(x: Float(attitudePitch - 1.5708),y: Float(attitudeYaw),z: Float(-attitudeRoll));
    }
    
    //MARK: Add all nodes to scene
    func renderSceneEssentials(){
        renderLight();
        renderCamera();
        renderFloor();
        
        scene.rootNode.addChildNode(lightNode);
        scene.rootNode.addChildNode(cameraNode);
        scene.rootNode.addChildNode(floorNode);
    }
    
}
