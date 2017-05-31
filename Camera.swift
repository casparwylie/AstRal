//
//  Camera.swift
//  Astral
//
//  Created by Caspar Wylie on 05/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 CAMERA COMPONENT
 
 */

import AVFoundation
import Foundation
import UIKit

class Camera{
    
    let captureSession = AVCaptureSession();
    
    func initilizeCamera() -> AVCaptureDevice {
        
        //start camera session
        captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        let devices = AVCaptureDevice.devices();
        var capDevice: AVCaptureDevice?;
        
        //identify correct hardware (front cam)
        for device in devices! {
            if((device as AnyObject).hasMediaType(AVMediaTypeVideo)){
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    capDevice = device as? AVCaptureDevice;
                }
            }
        }
        return capDevice!;
    }
    
    func startCameraFeed(_ capDevice: AVCaptureDevice, view: UIView){
        
        //setup device data input, or error
        let getInput: AVCaptureDeviceInput?;
        do {
            try getInput = AVCaptureDeviceInput(device: capDevice);
        } catch let error as NSError {
            getInput = nil;
            print(error);
        }
        
        //recieve input
        captureSession.addInput(getInput);
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        view.layer.addSublayer(previewLayer!);
        previewLayer?.frame = view.layer.frame;
        captureSession.startRunning();
        
    }
}
