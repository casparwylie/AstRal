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
import SwiftyJSON
import CoreLocation

//MARK: Delegate declaration of all UI actions
@objc protocol UIActionDelegate {
    @objc optional func toggleMap(isAddingStrand: Bool);
    @objc optional func openLoginForm();
    @objc optional func addStrandReady(comment: String);
    @objc optional func renderTempStrandFromUI(tapX: Int, tapY: Int);
    @objc optional func cancelNewStrand();
    @objc optional func loginRequest(username: String, password: String);
    @objc optional func signUpRequest(username: String, password: String, fullname: String, email: String);
    @objc optional func logoutUser();
    @objc optional func requestUserStrands();
}

class UserInterface1{
    
    //MARK: Item initiation
    
    var menuButtons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    var infoLabel: UIButton!;
    var doneChoosingTapPosButton: UIButton!;
    var cancelChoosingButton: UIButton!;
    var toggleMenuButton: UIButton!;
    var postStrandButton: UIButton!;
    var loginSubmitButton: UIButton!;
    var cancelLoginButton: UIButton!;
    var signUpSubmitButton: UIButton!;
    var cancelSignUpButton: UIButton!;
    var closeUserStrandView: UIButton!;
    var closeUserProfileView: UIButton!;
    
    var usernameLoginField: UITextField!;
    var passwordLoginField: UITextField!;
    var commentTextfield: UITextField!;
    var signUpFields: (username: UITextField?,password: UITextField?,fullname: UITextField?,email: UITextField?);
    
    var loginForm: UIView!;
    var commentForm: UIView!;
    var signUpForm: UIView!;
    var userStrandListView: UIView!;
    var userProfileView: UIView!;
    
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var userScrollStrandListView: UIScrollView!;
    var view: UIView!;
    var setTapPointForPost = (x: 0, y: 0);
    var mapShowing = false;
    var vertList = ["My Strands", "Profile", "Logout"];
    var mainMenuShowing = false;
    var vertMenuShowing = false;
    var userStrandLabelYPos = 5;
    var tagsForBlur = 100;
    var currBlurState = "light";
    var screenSize: CGRect = UIScreen.main.bounds;
    
    //MARK: UI constants
    let mainTypeFace = "Futura";
    var viewPageWidth: Int!
    var mainFont: UIFont!;
    var textFieldFont: UIFont!;
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    let userStrandLabelHeight = 18;
    let formWidth = 250;
    let defaultFormY = 150;
    let buttonHeight = 40;
    let buttonCornerRadius = CGFloat(3.0);
    let generalButtonWidth = 40;
    let textFieldSize = (width: 190, height: 40);
    
    
   
    //MARK:  UIActionDelegate method wrappers
    @objc func buttonAction(_ sender: UIButton!){
        let whichAction = sender.currentTitle!;
        switch whichAction {
        case "Show Map":
            actionDelegate?.toggleMap!(isAddingStrand: self.tapToPost);
            sender.setTitle("Hide Map", for: UIControlState());
            mapShowing = true;
            changeBlurToggle();
            
        case "Hide Map":
            actionDelegate?.toggleMap!(isAddingStrand: false);
            sender.setTitle("Show Map", for: UIControlState());
            mapShowing = false;
            changeBlurToggle();
            
        case "Login":
            hideAnyViews();
            loginForm.isHidden = false;
            
        case "Post Strand":
            hideAnyViews();
            if(mapShowing==true){
                actionDelegate?.toggleMap!(isAddingStrand: true);
            }
            updateInfoLabel(newText: "Tap wherever you want to post it (from camera or map)", show: true, hideAfter: 0);
            cancelChoosingButton.isHidden = false;
            toggleMenu(vert: false);
            self.tapToPost = true;
            
        case "Sign Up":
            hideAnyViews();
            signUpForm.isHidden = false;
            
        case " Me ":
            toggleMenu(vert: true);
            
        case "My Strands":
            toggleMenu(vert: true);
            hideAnyViews();
            actionDelegate?.requestUserStrands!();
            userStrandListView.isHidden = false;
        
        case "Profile":
            toggleMenu(vert: true);
            hideAnyViews();
            userProfileView.isHidden = false;
        
        case "Logout":
            toggleMenu(vert: true);
            renderMenu(loggedin: false);
            actionDelegate?.logoutUser!();
            
        default:
            toggleMenu(vert: false);
        }
    }
    
    func toggleMenu(vert: Bool){
        for button in menuButtons{
            if(vert == true){
                if(vertList.contains((button.titleLabel?.text)!) == true ){
                    if(button.isHidden == true){
                        button.isHidden = false;
                    }else{
                        button.isHidden = true;
                    }
                }
            }else{
                if(button.isHidden == true && vertList.contains((button.titleLabel?.text)!) == false){
                    button.isHidden = false;
                }else{
                    button.isHidden = true;
                }
                
            }
        }
    }
    
    @objc func hideAnyViews(){
        loginForm.isHidden = true;
        commentForm.isHidden = true;
        signUpForm.isHidden = true;
        userStrandListView.isHidden = true;
        userProfileView.isHidden = true;
        self.view.endEditing(true);
    }
    
    @objc func wrapTapped(touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        if(self.tapToPost == true && mapShowing == false){
            actionDelegate?.renderTempStrandFromUI!(tapX: Int(tapPoint.x), tapY: Int(tapPoint.y));
        }else{
            //get strandinfo
        }
    }
    
    
    @objc func loginSubmitWrapper(sender: UIButton!){
        self.view.endEditing(true);
        if((usernameLoginField.text?.characters.count)! > 0 && (passwordLoginField.text?.characters.count)! > 0){
            actionDelegate?.loginRequest!(username: usernameLoginField.text!, password: passwordLoginField.text!);
        }
    }
    
    @objc func signUpSubmitWrapper(sender: UIButton!){
        self.view.endEditing(true);
        actionDelegate?.signUpRequest!(username: (signUpFields.username?.text)!, password: (signUpFields.password?.text)!, fullname: (signUpFields.fullname?.text)!, email: (signUpFields.email?.text)!);

    }

    
    func showTapFinishedOptions(){
        doneChoosingTapPosButton.isHidden = false;
        updateInfoLabel(newText: "Tap 'Done' when you have choosen a position", show: true, hideAfter: 0);
    }
    
    
    @objc func cancelTap(){
        doneChoosingTapPosButton.isHidden = true;
        updateInfoLabel(newText: " ", show: false, hideAfter: 0);
        self.tapToPost = false;
        cancelChoosingButton.isHidden = true;
        commentForm.isHidden = true;
        actionDelegate?.cancelNewStrand!();
        self.view.endEditing(true);
    }
    
    @objc func newStrandComment(){
        self.tapToPost = false;
        updateInfoLabel(newText: " ", show: false, hideAfter: 0);
        doneChoosingTapPosButton.isHidden = true;
        self.commentForm.isHidden = false;
    }
    
    @objc func postStrand(){
        cancelTap();
        actionDelegate?.addStrandReady!(comment: commentTextfield.text!);
        self.view.endEditing(true);
    }
    
    //MARK: render UI components
    func renderPostCommentForm(){
        let formHeight = 100;
        commentForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonSpace,width: formWidth, height: formHeight));
        commentForm.isHidden = true;
        commentForm.insertSubview(processBlurEffect(bounds: commentForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        commentTextfield = addTextFieldProperties(pos: CGRect(x: 5, y: 5, width: 240, height: textFieldSize.height));
        commentTextfield.text = "Enter Comment...";
        
        let postStrandButtonRect = CGRect(x: 5, y: 5+textFieldSize.height+10, width: 100, height: 40);
        postStrandButton = addButtonProperties(title: "Post Strand", hidden: false, pos: postStrandButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        postStrandButton.addTarget(self, action: #selector(postStrand), for: .touchUpInside);
        
        commentForm.addSubview(commentTextfield);
        commentForm.addSubview(postStrandButton);
        self.view.addSubview(commentForm);
    }
    
    func changeBlurToggle(){
        var light = false;
        if(currBlurState == "dark"){
            light = true;
            currBlurState = "light";
        }else{
            currBlurState = "dark";
        }

        for tag in 100...tagsForBlur{
            let element = self.view.viewWithTag(tag);
            let fromView = element?.superview;
            let useCornerRadius = element?.layer.cornerRadius;
            element?.removeFromSuperview();
            
            let newColor = ((currBlurState == "dark") ? UIColor.white : mainFontColor);
            if let viewAsButton = fromView as? UIButton{
                viewAsButton.setTitleColor(newColor, for: .normal);
            }
            if let viewAsTextField = fromView as? UITextField{
                viewAsTextField.textColor = newColor;
            }
            
            fromView?.insertSubview(processBlurEffect(bounds: (element?.bounds)!, cornerRadiusVal: useCornerRadius!, light: light), at: 0);
        }
    }
    
    func renderLoginForm(){
        let formHeight = 176;
        let buttonWidthLogin =  120;
        let textWidthLogin =  240;
        
        loginForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonSpace,width: formWidth, height: formHeight));
        loginForm.isHidden = true;
        loginForm.insertSubview(processBlurEffect(bounds: loginForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        usernameLoginField = addTextFieldProperties(pos: CGRect(x: 5, y: 5, width: textWidthLogin, height: textFieldSize.height));
        usernameLoginField.text = "Test123";
        
        passwordLoginField = addTextFieldProperties(pos: CGRect(x: 5, y: 55, width: textWidthLogin, height: textFieldSize.height));
        passwordLoginField.text = "test123";
        passwordLoginField.isSecureTextEntry = true;
        
        
        
        let loginSubmitButtonRect = CGRect(x: 5, y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        loginSubmitButton = addButtonProperties(title: "Login", hidden: false, pos: loginSubmitButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        loginSubmitButton.addTarget(self, action: #selector(loginSubmitWrapper), for: .touchUpInside);
        
        let cancelLoginButtonRect = CGRect(x: 125, y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        cancelLoginButton = addButtonProperties(title: "Cancel", hidden: false, pos: cancelLoginButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        cancelLoginButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        loginForm.addSubview(usernameLoginField);
        loginForm.addSubview(passwordLoginField);
        loginForm.addSubview(loginSubmitButton);
        loginForm.addSubview(cancelLoginButton);
        self.view.addSubview(loginForm);
    }

    func renderSignUpForm(){
        toggleMenu(vert: true);
        let formHeight = 271;
        let buttonWidthSignUp =  120;
        let textWidthSignUp =  240;
        
        signUpForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonSpace,width: formWidth, height: formHeight));
        signUpForm.isHidden = true;
        signUpForm.insertSubview(processBlurEffect(bounds: signUpForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        signUpFields.username = addTextFieldProperties(pos: CGRect(x: 5, y: 5, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.username?.text = "Username...";
        
        signUpFields.password = addTextFieldProperties(pos: CGRect(x: 5, y: 55, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.password?.text = "Password...";
        signUpFields.password?.isSecureTextEntry = true;
        
        signUpFields.fullname = addTextFieldProperties(pos: CGRect(x: 5, y: 105, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.fullname?.text = "Fullname...";
        
        signUpFields.email = addTextFieldProperties(pos: CGRect(x: 5, y: 155, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.email?.text = "Email...";
        
        let signUpSubmitButtonRect = CGRect(x: 5, y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        signUpSubmitButton = addButtonProperties(title: "Sign Up", hidden: false, pos: signUpSubmitButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        signUpSubmitButton.addTarget(self, action: #selector(signUpSubmitWrapper), for: .touchUpInside);
        
        let cancelSignUpButtonRect = CGRect(x: 125, y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        cancelSignUpButton = addButtonProperties(title: "Cancel", hidden: false, pos: cancelSignUpButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        cancelSignUpButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        signUpForm.addSubview(signUpFields.username!);
        signUpForm.addSubview(signUpFields.password!);
        signUpForm.addSubview(signUpFields.fullname!);
        signUpForm.addSubview(signUpFields.email!);
        signUpForm.addSubview(signUpSubmitButton);
        signUpForm.addSubview(cancelSignUpButton);
        self.view.addSubview(signUpForm);
    }
    
    func renderUserStrandsView(){
        let viewHeight = 370;
        userStrandListView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: 60 + buttonSpace,width: viewPageWidth, height: viewHeight));
        userStrandListView.isHidden = true;
        userScrollStrandListView = UIScrollView(frame: CGRect(x:5,y: 25,width: viewPageWidth, height: viewHeight-30));
        userScrollStrandListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(viewHeight));
        userStrandListView.insertSubview(processBlurEffect(bounds: userStrandListView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        let closeButtonWidth = 40;
        let closeUserStrandViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: 20);
        closeUserStrandView = addButtonProperties(title: "Close", hidden: false, pos: closeUserStrandViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserStrandView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);

        userStrandListView.addSubview(closeUserStrandView);
        userStrandListView.addSubview(userScrollStrandListView);
        self.view.addSubview(userStrandListView);
    }
    
    func addUserStrandLabel(text: String, areaName: String){
        let strandTextLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userStrandLabelYPos+10, width: 250, height: userStrandLabelHeight));
        let strandAreaLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userStrandLabelYPos+userStrandLabelHeight+10, width: 250, height: userStrandLabelHeight));
        
        let strandIconDest = "strand_icon.png";
        let strandIcon = UIImage(named: strandIconDest);
        let strandIconView = UIImageView(image: strandIcon!);
        strandIconView.frame = CGRect(x: 0, y:  userStrandLabelYPos+12, width: 20, height: 30);
        
        strandTextLabel.text = text;
        strandAreaLabel.text = "in " + areaName;
        strandTextLabel.font = UIFont(name: mainTypeFace, size: 17);
        strandAreaLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 13);
        userScrollStrandListView.addSubview(strandTextLabel);
        userScrollStrandListView.addSubview(strandAreaLabel);
        userScrollStrandListView.addSubview(strandIconView);
    }
    
    func populateUserStrands(strands: JSON, firstComments: JSON){
        for subview in userScrollStrandListView.subviews{
            subview.removeFromSuperview();
        }
        userStrandLabelYPos = 5;
        let labelHeight = 2*userStrandLabelHeight+10;
        userScrollStrandListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+(strands.count*labelHeight)));
        var count = 0;
        for strand in strands{
            let coordLocation = CLLocation(latitude: strands[count]["s_coord_lat"].double!, longitude: strands[count]["s_coord_lon"].double!);
            CLGeocoder().reverseGeocodeLocation(coordLocation, completionHandler: {(placemarks,err) in
                var areaName = "";
                if((placemarks?.count)!>0){
                    let placemark = (placemarks?[0])! as CLPlacemark;
                    areaName = placemark.thoroughfare! + ", " + placemark.locality!;
                }
                self.addUserStrandLabel(text: firstComments[count]["c_text"].rawString()!, areaName: areaName);
                self.userStrandLabelYPos += 2*self.userStrandLabelHeight + 10;
                count += 1;
            });
        }
    }
    
    func renderProfileView(){
        let viewHeight = 370;
        userProfileView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: 60 + buttonSpace,width: viewPageWidth, height: viewHeight));
        userProfileView.isHidden = true;
        userProfileView.insertSubview(processBlurEffect(bounds: userProfileView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        let closeButtonWidth = 40;
        let closeUserProfileViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: 20);
        closeUserProfileView = addButtonProperties(title: "Close", hidden: false, pos: closeUserProfileViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserProfileView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        userProfileView.addSubview(closeUserProfileView);
        self.view.addSubview(userProfileView);
    }
    
    func addStrandTapRecognizer(){
        
        let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wrapTapped));
        tapRec.numberOfTapsRequired = 1;
        self.view.addGestureRecognizer(tapRec);
        
    }

    func processBlurEffect(bounds: CGRect, cornerRadiusVal: CGFloat, light: Bool) -> UIVisualEffectView {
        
        var style = UIBlurEffectStyle.light;
        if(light==false){
            style = UIBlurEffectStyle.dark;
        }
        
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style:
            style));
        blurEffect.frame = bounds;
        blurEffect.isUserInteractionEnabled = false;
        blurEffect.layer.cornerRadius = cornerRadiusVal;
        blurEffect.clipsToBounds = true;
        blurEffect.tag = tagsForBlur;
        tagsForBlur += 1;
        return blurEffect;
    }
    
    func renderLabel(){
        let infoLabelRect = CGRect(x: 5,y: 20,width: Int(screenSize.width)-10,height: buttonHeight);
        infoLabel = addButtonProperties(title: " ", hidden: true, pos: infoLabelRect, cornerRadius: buttonCornerRadius, blurLight: true);
        self.view.addSubview(infoLabel);
    }
    
    func addButtonProperties(title: String, hidden: Bool, pos: CGRect, cornerRadius: CGFloat, blurLight: Bool) ->UIButton{
        let button = UIButton(frame: pos);
        if(blurLight == true){
            button.setTitleColor(mainFontColor, for: .normal);
        }else{
            button.setTitleColor(UIColor.white, for: .normal);
        }
        button.setTitle(title, for: UIControlState());
        button.insertSubview(processBlurEffect(bounds: button.bounds, cornerRadiusVal: cornerRadius, light: blurLight), at: 0);
        button.titleLabel!.font =  mainFont;
        button.isHidden = hidden;
        return button;
    }
    
    
    func addTextFieldProperties(pos: CGRect) -> UITextField{
        let textField = UITextField(frame: pos);
        textField.insertSubview(processBlurEffect(bounds: textField.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        textField.layer.borderColor = UIColor.gray.cgColor;
        textField.textColor = mainFontColor;
        textField.font = textFieldFont;
        return textField;
    }
    
    func renderGeneralButtons(){
        
        let doneChoosingTapPosButtonRect = CGRect(x: Int(screenSize.width)-buttonSpace - (2*generalButtonWidth + 5),y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        doneChoosingTapPosButton = addButtonProperties(title: "Done", hidden: true, pos: doneChoosingTapPosButtonRect,cornerRadius: buttonCornerRadius, blurLight: true);
        doneChoosingTapPosButton.addTarget(self, action: #selector(newStrandComment), for: .touchUpInside);
        self.view.addSubview(doneChoosingTapPosButton);
        
        
        let cancelChoosingButtonRect = CGRect(x: Int(screenSize.width-5) - generalButtonWidth,y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        cancelChoosingButton = addButtonProperties(title: "Cancel", hidden: true, pos: cancelChoosingButtonRect,cornerRadius: buttonCornerRadius, blurLight: true);
        cancelChoosingButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside);
        self.view.addSubview(cancelChoosingButton);
    }
    
    //MARK:  menu setups
    func renderMenu(loggedin: Bool){
        if(menuButtons.count>0){
            for button in menuButtons{
                button.removeFromSuperview();
            }
            toggleMenuButton.removeFromSuperview();
            menuButtons = [];
        }
        
        var mapName = "Show Map";
        var blurLight = true;
        if(mapShowing==true){
            mapName = "Hide Map"
            blurLight = false;
        }
        
        
        let yPos = Int(screenSize.height) - buttonHeight - 60;
        let toggleWidth = 50;
        let halfTW = toggleWidth/2;
        let toggleMenuRect  = CGRect(x: Int(screenSize.width*0.5)-halfTW,y: yPos+toggleWidth-7, width: toggleWidth,height: toggleWidth);
        toggleMenuButton = addButtonProperties(title: " ", hidden: false, pos: toggleMenuRect, cornerRadius: CGFloat(halfTW), blurLight: blurLight);
        toggleMenuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
        self.view.addSubview(toggleMenuButton);
        
       
        var buttonList = [mapName,"Login","Sign Up","Post Strand"," Help "];
        if(loggedin == true){
            buttonList = [mapName,"Post Strand"," Me ", " Help ", "My Strands", "Profile", "Logout"];
        }
        
        var menuWidth = 0;
        let letterToWidthScale = 8;
        
        for var buttonTitle in buttonList{
            if(vertList.contains(buttonTitle) == false){
                menuWidth += buttonTitle.characters.count*letterToWidthScale + buttonSpace;
            }
        }
        
        var bCount = 0;
        var bxPos = Int((Int(screenSize.width)-menuWidth) / 2) + 1;
        var vertYPos = 0;
        for var buttonTitle in buttonList{
            
            let buttonWidth = buttonTitle.characters.count*letterToWidthScale;
            var useYPos = yPos;
            var useXPos = bxPos;
            var hidden = false;
            var buttonWidthUse = buttonWidth;
            if(vertList.contains(buttonTitle)){
                vertYPos -= buttonHeight + buttonSpace;
                useXPos = 172;
                buttonWidthUse = 82;
                hidden = true;
                useYPos = useYPos + vertYPos;
            }else{
                
            }
            let buttonRect = CGRect(x: useXPos,y: useYPos, width: buttonWidthUse,height: buttonHeight);
            
            
            menuButtons.append(addButtonProperties(title: buttonTitle, hidden: hidden, pos: buttonRect, cornerRadius: buttonCornerRadius, blurLight: blurLight));
            menuButtons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            self.view.addSubview(menuButtons[bCount]);
            bCount += 1;
            bxPos += buttonWidth + buttonSpace;
        }

    }
    
    //MARK: Update label contents
    func updateInfoLabel(newText: String, show: Bool, hideAfter: Int){
        infoLabel.setTitle(newText, for: UIControlState());
        if(show == false){
            infoLabel.isHidden = true;
        }else{
            infoLabel.isHidden = false;
        }
        if(hideAfter != 0){
            let timeToHide = DispatchTime.now() + .seconds(hideAfter)
            DispatchQueue.main.asyncAfter(deadline: timeToHide, execute: {
                self.infoLabel.isHidden = true;
            })
        }
    }
    
    //MARK: Render all items
    func renderAll(view: UIView){
        self.view = view;
        
        mainFont = UIFont(name: mainTypeFace, size: 12);
        textFieldFont = UIFont(name: mainTypeFace, size: 15);
        viewPageWidth = Int(screenSize.width)-10;
        
        renderLabel();
        renderMenu(loggedin: false);
        renderGeneralButtons();
        addStrandTapRecognizer();
        renderLoginForm();
        renderSignUpForm();
        renderPostCommentForm();
        renderProfileView();
        renderUserStrandsView();
    }
    
}

