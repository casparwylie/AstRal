//
//  Misc.swift
//  Focals
//
//  Created by Caspar Wylie on 05/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

import Foundation
import SwiftyJSON

class Misc{
    
    //MARK: check values are in given range (Int or Float)
    func isApprox(_ value1: Int,value2: Int, tol: Int) -> (is: Bool, realTol: Int){
        if( ((value1 - tol) <= value2) && ((value1 + tol) >= value2 ) ){
            return (is: true, realTol: value1 - value2);
        }else{
            return (false, realTol: value1 - value2);
        }
    }
    
    func objcStringToArray(string: String) ->[[(Int,Int)]] {
        var vectors: [[(Int,Int)]] = [];
        let sepGroups = string.components(separatedBy: " ");
        for group in sepGroups{
            var finalGroupVec: [(Int,Int)] = [];
            let groupVec: [String] = group.components(separatedBy: "/");
            for item in groupVec{
                var finalItem: (Int,Int) = (0,0);
                var itemVec = item.components(separatedBy: ",");
                if(itemVec[0] != ""){
                    let i1 = Int(itemVec[0]);
                    let i2 = Int(itemVec[1]);
                    finalItem.0 = i1!;
                    finalItem.1 = i2!;
                    finalGroupVec.append(finalItem);
                }
            }
            vectors.append(finalGroupVec);
        }
        
        print(vectors);
        return vectors;
    }
    
    func rotateAroundPoint(_ pointXY: (x: Double,y: Double),angle: Double) -> (x: Double, y: Double){
        let angle = angle * 0.0174533;
        let pX = (pointXY.x * cos(angle)) + (pointXY.y * sin(angle));
        let pY = -(pointXY.x * sin(angle)) + (pointXY.y * cos(angle));
        return (x: pX, y: pY);
    }
}
