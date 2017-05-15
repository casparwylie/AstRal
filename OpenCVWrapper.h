//
//  OpenCVWrapper.h
//  Focals1
//
//  Created by Caspar Wylie on 17/09/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 OPENCV INTERFACE COMPONENT
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface OpenCVWrapper : NSObject

+(NSString*) buildingDetect: (double[][2])pxVals image:(UIImage*)UIMap currPoint:(double[2])currPointPX pxLength:(int) pxLength forBuildingTap:(bool)forBuildingTap;

+(NSString*) prepVirtualStreet: (UIImage*)UIMap;
//+(NSString*) limitNewFocalDist: (double[2])currPoint image:(UIImage*)UIMap desPoint:(double[2])desPoint;

@end
