//
//  OpenCVWrapper.m
//  Strands1
//
//  Created by Caspar Wylie on 17/09/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "opencv2/opencv.hpp"
#import "opencv2/highgui/ios.h"
#import "opencv2/imgproc/imgproc.hpp"
#import "opencv2/core/core.hpp"
#import <vector>

/*
 
 OPENCV ObjC / C++ COMPONENT
 
 */

using namespace std;

@implementation OpenCVWrapper
+(NSString*) strandsToHide: (double[][2])pxVals image:(UIImage*)UIMap currPoint:(double[2])currPointPX pxLength:(int) pxLength{

    int testing = false;
    //setup matrix
    cv::Mat orgFrame, taskFrame;
    UIImageToMat(UIMap, orgFrame);
    
    int frameHeight = orgFrame.rows;
    int frameWidth = orgFrame.cols;

    cv::Point currPoint = cv::Point(currPointPX[0]  * frameWidth, currPointPX[1] * frameHeight);

    // performance / output variables
    vector<int>  buildingColorBounds = {232,235};
    int buildingDectectThicknessOffset = 4;
    
    cv::cvtColor(orgFrame, taskFrame, CV_BGR2GRAY);
    
    int count = 0;
    string toHide = "";
    
    
    while(count<pxLength){
        
        int colsX = pxVals[count][0] * frameWidth;
        int rowsY = pxVals[count][1] * frameHeight;
        cv::Point pointXY = cv::Point(colsX,rowsY);
        
        //visualisation of output
        if(testing == true){
            cv::circle(orgFrame, pointXY, 2, cv::Scalar(255,0,255));
        }
        
        cv::LineIterator lineIter(taskFrame, currPoint, pointXY);
        int buildingProb = 0;
        
        for(int i = 0; i < lineIter.count; i++, lineIter++){
            int colorVal = int(taskFrame.at<uchar>(lineIter.pos()));
            if(colorVal > buildingColorBounds[0] && colorVal < buildingColorBounds[1]){
                buildingProb++;
                if(buildingDectectThicknessOffset <= buildingProb){
                    toHide += to_string(count) + ",";
                    if(testing == false){
                        break;
                    }
                }

                //visualisation of output
                if(testing == true){
                    circle(orgFrame, lineIter.pos(), 1, cv::Scalar(0,255,0));
                }
            }else{
                if(testing == true){
                    circle(orgFrame, lineIter.pos(), 1, cv::Scalar(0,0,255));
                }
            }
        }
               count++;
    }
    
    //convert to UIIMAGE for view (for testing)

    //UIImage* new1IMG = MatToUIImage(orgFrame);
    
    
    NSString* toHideReturn = [NSString stringWithUTF8String:toHide.c_str()];
    return toHideReturn;
}


@end
