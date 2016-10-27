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
    @objc optional func toggleMap();
    @objc optional func openLoginForm();
    @objc optional func addStrandTapped();
}

class UserInterface1{
    
    //MARK: Item initiation
    var buttons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    //var location = Location();
    var infoLabel: UIButton!;
    var pageControl: UIPageControl!;
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var scrollView: UIScrollView!;
    var view: UIView!;
    
    var screenSize: CGRect = UIScreen.main.bounds;
    
     func toggleMenu(){
        for var button in buttons{
            if(button.isHidden == false){
                button.isHidden = true;
            }else{
                button.isHidden = false;
            }
        }
    }
   
    //MARK:  UIActionDelegate method wrappers
    @objc func buttonAction(_ sender: UIButton!){
        let whichAction = sender.currentTitle!;
        switch whichAction {
        case "Show Map":
            actionDelegate?.toggleMap!();
             sender.setTitle("Hide Map", for: UIControlState());
        case "Hide Map":
            actionDelegate?.toggleMap!();
            sender.setTitle("Show Map", for: UIControlState());
        case "Login":
            actionDelegate?.openLoginForm!();
        case "Post Strand":
            updateInfoLabel(newText: "Tap wherever you want to post it", show: true);
            self.tapToPost = true;
        default:
            toggleMenu();
        }
    }
    
    func addStrandTapRecognizer(){
        
        let doubleTapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wrapTapped));
        doubleTapRec.numberOfTapsRequired = 1;
        self.view.addGestureRecognizer(doubleTapRec);
        
    }
    
    @objc func wrapTapped(touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        
        if(self.tapToPost == true){
            print(tapPoint.x, "--", tapPoint.y);
            actionDelegate?.addStrandTapped!();
            self.tapToPost = false;
            updateInfoLabel(newText: " ", show: false);
        }else{
            //get strandinfo
        }
    }
    
    func processBlurEffect(button: UIButton, cornerRadiusVal: Float) -> UIVisualEffectView {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.dark));
        blurEffect.frame = button.bounds;
        blurEffect.isUserInteractionEnabled = false;
        blurEffect.layer.cornerRadius = CGFloat(cornerRadiusVal) * button.bounds.size.width;
        blurEffect.clipsToBounds = true;
        return blurEffect;
    }
    
    func renderLabel(){
        infoLabel = UIButton(frame: CGRect(x: 5,y: 20,width: screenSize.width-10,height: 30));
        infoLabel.setTitle("this displays some info", for: UIControlState());
        infoLabel.insertSubview(processBlurEffect(button: infoLabel, cornerRadiusVal: 0.05), at: 0);
        infoLabel.titleLabel!.font =  UIFont(name: "Futura", size: 12);
        infoLabel.isHidden = true;
        self.view.addSubview(infoLabel);
    }
    
    //MARK:  menu setups
    func renderMenu(){
        
        let buttonHeight = 40;
        let yPos = Int(screenSize.height) - buttonHeight - 60;
        
        let toggleWidth = 50;
        let toggleMenu = UIButton(frame: CGRect(x: Int(screenSize.width*0.5)-toggleWidth/2,y: yPos+toggleWidth-7, width: toggleWidth,height: toggleWidth));
        toggleMenu.setTitle(" ", for: UIControlState());
        toggleMenu.addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
        toggleMenu.insertSubview(processBlurEffect(button: toggleMenu, cornerRadiusVal: 0.5), at: 0);
        self.view.addSubview(toggleMenu);
        
        let buttonList = ["Show Map","Login","Sign Up","Post Strand","Help"];
        //logggedin "see map", "post strand", "profile", "help
        var bCount = 0;
        
        var buttonSpace = 2;
        var menuWidth = 0;
        
        for var buttonTitle in buttonList{
            menuWidth += buttonTitle.characters.count*9 + buttonSpace;
        }
        
        var bxPos = Int((Int(screenSize.width)-menuWidth) / 2) + 1;
        for var buttonTitle in buttonList{
            
            let buttonWidth = buttonTitle.characters.count*9;
            buttons.append(UIButton(frame: CGRect(x: bxPos,y: yPos, width: buttonWidth,height: buttonHeight)));
            buttons[bCount].setTitle(buttonTitle, for: UIControlState());
            buttons[bCount].titleLabel!.font =  UIFont(name: "Futura", size: 11);
            buttons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            buttons[bCount].insertSubview(processBlurEffect(button: buttons[bCount],cornerRadiusVal: 0.05), at: 0);
            buttons[bCount].isHidden = true;
            self.view.addSubview(buttons[bCount]);
            bCount += 1;
            bxPos += buttonWidth + buttonSpace;
        }
        
    }
    
    //MARK: Update label contents
    func updateInfoLabel(newText: String, show: Bool){
        infoLabel.setTitle(newText, for: UIControlState());
        if(show == false){
            infoLabel.isHidden = true;
        }else{
            infoLabel.isHidden = false;
        }
    }
    
    //MARK: Render all items
    func renderAll(view: UIView){
        self.view = view;
        renderLabel();
        renderMenu();
        addStrandTapRecognizer();
    }
    
}

