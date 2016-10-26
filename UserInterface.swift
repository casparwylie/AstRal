//
//  UserInterface.swift
//  Strands
//
//  Created by Caspar Wylie on 06/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 USER INTERFACE COMPONENT
 
 */

import Foundation
import UIKit


//MARK: Delegate declaration of all UI actions
@objc protocol UIActionDelegate {
    @objc optional func setPOIAction();
    @objc optional func toggleMap();
}

class UserInterface1{
    
    //MARK: Item initiation
    var labels: [UILabel] = [];
    var buttons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    //var location = Location();
    var pageControl: UIPageControl!;
    var actionDelegate: UIActionDelegate?;
    var scrollView: UIScrollView!;
    
    //MARK: All label setups
    func renderLabels(view: UIView){
        labels.append(UILabel(frame: CGRect(x: 10,y: 100,width: 400,height: 50)));
        labels[0].text = "";
        view.addSubview(labels[0]);
    }
    
    //MARK:  All button setups
    func renderButtons(view: UIView){
        buttons.append(UIButton(frame: CGRect(x: 10,y: 40, width: 100,height: 20)));
        buttons[0].setTitle("View Map", for: UIControlState());
        buttons[0].backgroundColor = UIColor.green;
        buttons[0].addTarget(self, action: #selector(wrapActiontoggleMap), for: .touchUpInside);
        view.addSubview(buttons[0]);
    }
    
    //MARK:  UIActionDelegate method wrappers
    @objc func wrapActionPOI(sender: UIButton!){
        actionDelegate?.setPOIAction!();
    }
    
    @objc func wrapActiontoggleMap(_ sender: UIButton!){
        actionDelegate?.toggleMap!();
    }
    
    //MARK: Update label contents
    func updateLabel(labelID: Int, newText: String){
        labels[labelID].text = newText;
    }
    
    //MARK: Render all items
    func renderAll(view: UIView){
        renderLabels(view: view);
        renderButtons(view: view);
    }
    
}

class UserInterface2{

}
