//
//  OpenCVWrapper.h
//  Strands1
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

+(NSString*) strandsToHide: (double[][2])pxVals image:(UIImage*)UIMap currPoint:(double[2])currPointPX pxLength:(int) pxLength;
//string strandsToHide(int pxVals[][2], UIImage* UIMap, int currPoint[2]);

@end
