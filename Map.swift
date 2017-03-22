//
//  Map.swift
//  Strands
//
//  Created by Caspar Wylie on 06/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

import Foundation
import MapKit
import Darwin

/*
 
    MAP COMPONENT
 
 */


@objc protocol mapActionDelegate {
    @objc optional func renderTempStrandFromMap(_ mapTapCoord: CLLocationCoordinate2D);
}

class Map: NSObject, MKMapViewDelegate{
    
    var mapView = MKMapView();
    var mapActionDelegate: mapActionDelegate?;
    var tapMapToPost = false;
    var tempPin: MKPointAnnotation!;
    
    //MARK: setup map
    func renderMap(_ view: UIView){
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height);
        mapView.mapType = MKMapType.standard;
        mapView.isZoomEnabled = false;
        mapView.isScrollEnabled = false;
        //mapView.isUserInteractionEnabled = false;
        mapView.delegate = self;
        mapView.tag = 3;
        mapView.showsUserLocation = true;
        addStrandMapTapRecognizer();
        view.addSubview(mapView);
    }
    
    //MARK: view region setting
    func centerToLocationRegion(_ location: CLLocation) -> MKCoordinateRegion{
        let radiusArea: Double = 80;
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radiusArea * 2.0, radiusArea * 2.0);
        return coordinateRegion;
    }
    
    //MARK: add strand map tap
    func addStrandMapTapRecognizer(){
        let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wrapTappedMap));
        tapRec.numberOfTapsRequired = 1;
        mapView.addGestureRecognizer(tapRec);
        
    }
    
    @objc func wrapTappedMap(_ touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: mapView);
        let tapCoords = mapView.convert(tapPoint, toCoordinateFrom: mapView);
        if(self.tapMapToPost == true){
            mapActionDelegate?.renderTempStrandFromMap!(tapCoords);
        }else{
            //get strandinfo
        }
    }
    
    func cancelTempStrand(){
        if(tempPin != nil){
            mapView.removeAnnotation(tempPin);
        }
    }
    
    //MARK: update pins that represent strand
    var pcount = 0;
    func updateSinglePin(_ coord: CLLocation, temp: Bool){
        let CLLCoordType = CLLocationCoordinate2D(latitude: coord.coordinate.latitude,
                                                  longitude: coord.coordinate.longitude);
        
        if(temp == true){
            if(tempPin != nil){
                mapView.removeAnnotation(tempPin);
            }
            tempPin = MKPointAnnotation();
            tempPin?.coordinate = CLLCoordType;
            mapView.addAnnotation(tempPin);
        }else{
            let pin = MKPointAnnotation();
            pin.title = String(pcount);
            pcount += 1;
            pin.coordinate = CLLCoordType;
            mapView.addAnnotation(pin);
        }
    }
    
    func updatePins(_ coords: [CLLocation]){
        mapView.removeAnnotations(mapView.annotations);
        for coord in coords{
            updateSinglePin(coord, temp: false);
        }
    }
    
     //MARK: get map view snap shot for openCV wrapper
    func getMapAsIMG( _ completion: @escaping (UIImage)->() ){
        var finalImage =  UIImage();
        let imageOptions = MKMapSnapshotOptions();
        imageOptions.region = mapView.region;
        imageOptions.size = mapView.frame.size;
        imageOptions.showsBuildings = true;
        imageOptions.showsPointsOfInterest = false;
        
        let imgMap = MKMapSnapshotter(options: imageOptions);
        imgMap.start(completionHandler: { (imageObj: MKMapSnapshot?, Error) -> Void in
            if(Error != nil){
                print("\(Error)");
            }else{
                finalImage = imageObj!.image;
            }
            completion(finalImage);
        
        });
       
    }
    
    //MARK: convert single map point to PX
    func convertMapPointToPX(_ mapPoint: MKMapPoint) -> (Double,Double){
        
        let mapRect: MKMapRect = mapView.visibleMapRect;
        let tlMapPoint: MKMapPoint = MKMapPointMake( MKMapRectGetMinX(mapRect), mapRect.origin.y);

        let mapRectHeight = MKMapRectGetHeight(mapRect);
        let mapRectWidth = MKMapRectGetWidth(mapRect);
        
        let XinRectAsPercent = (mapPoint.x - tlMapPoint.x)/mapRectWidth;
        let YinRectAsPercent = (mapPoint.y - tlMapPoint.y)/mapRectHeight;
        
        return (XinRectAsPercent, YinRectAsPercent);
    }
    
    
    
    //MARK: get all map points as px in preparation for openCV wrapper
    func collectPXfromMapPoints(_ mapPoints: [MKMapPoint], currMapPoint: MKMapPoint)
        -> (strandValsPX: [(Double,Double)], currPointPX:[Double], pxLength: Int){
        
        var pixelsXY: [(Double,Double)] = [];

        let resultsCurrPointXY_T = convertMapPointToPX(currMapPoint);
        let resultsCurrPointXY = [resultsCurrPointXY_T.0,resultsCurrPointXY_T.1];
        for mapPoint in mapPoints{
            let resultsPX = convertMapPointToPX(mapPoint);
            pixelsXY.append(resultsPX);
        }
        
            return (strandValsPX: pixelsXY, currPointPX: resultsCurrPointXY, pxLength: mapPoints.count);
    }
    
    
    //MARK: convert coordinate data to 2D map points
    func getCoordsAsMapPoints(_ coords: [CLLocation]) -> [MKMapPoint]{
        var mapPoints: [MKMapPoint] = [];
        for coord in coords{
            mapPoints.append(MKMapPointForCoordinate(coord.coordinate));
        }
        return mapPoints;
    }

    //MARK: update pins delegate call, render, etc
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
                
            }
            return pinView;
        }
    }
    
    
}
