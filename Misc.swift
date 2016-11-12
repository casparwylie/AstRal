//
//  Misc.swift
//  Strands
//
//  Created by Caspar Wylie on 05/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

import Foundation
import SwiftyJSON

class Misc{
    
    //MARK: check values are in given range (Int or Float)
    func isApprox(value1: Int,value2: Int, tol: Int) -> (is: Bool, realTol: Int){
        if( ((value1 - tol) <= value2) && ((value1 + tol) >= value2 ) ){
            return (is: true, realTol: value1 - value2);
        }else{
            return (false, realTol: value1 - value2);
        }
    }
    
    func processResponseAsJSON(responseData: String) -> JSON{
        let responseData = responseData.data(using: String.Encoding.utf8,allowLossyConversion: false);
        let responseJSON = JSON(data: responseData!);
        return responseJSON;
    }
}
