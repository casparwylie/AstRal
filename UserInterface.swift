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
    @objc optional func updateUserDataRequest(username: String, password: String, fullname: String, email: String);
    @objc optional func logoutUser();
    @objc optional func requestUserStrands();
    @objc optional func deleteStrandRequest(realID: Int);
    @objc optional func chooseStrandComments(tapX: Int, tapY: Int);
    @objc optional func postNewComment(commentText: String);
    
}

class UserInterface1{
    
    //MARK: Item initiation
    
    //UI Buttons
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
    var closeSingleStrandInfoView: UIButton!;
    var closeStrandCommentsView: UIButton!;
    var deleteStrandButton: UIButton!;
    var newCommentButton: UIButton!;
    
    //UI Text Fields
    var usernameLoginField: UITextField!;
    var passwordLoginField: UITextField!;
    var commentTextfield: UITextField!;
    var signUpFields: (username: UITextField?,
                    password: UITextField?,
                    fullname: UITextField?,
                    email: UITextField?);
    var commentExistingStrandTextfield: UITextField!;
    
    //UI Views
    var loginForm: UIView!;
    var commentForm: UIView!;
    var signUpForm: UIView!;
    var userStrandListView: UIView!;
    var strandCommentsView: UIView!;
    var userProfileView: UIView!;
    var singleStrandInfoView: UIView!;
    var userScrollStrandListView: UIScrollView!;
    var strandCommentsListScrollView: UIScrollView!;
    
    //UI Labels
    var singleStrandFcommentTitle: UILabel!;
    
    //General Presets
    var loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown", password: "");
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var view: UIView!;
    var setTapPointForPost = (x: 0, y: 0);
    var mapShowing = false;
    var vertList = ["My Strands", "Profile", "Logout"];
    var mainMenuShowing = false;
    var vertMenuShowing = false;
    var userStrandLabelYPos = 5;
    var strandCommentListLabelYPos = 5;
    var tagsForBlur = 100;
    let strandIconDest = "strand_icon.png";
    var posStrandToDeleteRealID = 0;
    var userStrandsJSON: JSON!;
    var userStrandFirstCommentsJSON: JSON!;
    var currBlurState = "light";
    var screenSize: CGRect = UIScreen.main.bounds;
    var singleStrandTapRecs: [UITapGestureRecognizer] = [];
    var intentToSignUp = true;
    
    //MARK: UI constants
    let mainTypeFace = "Futura";
    var viewPageWidth: Int!
    var mainFont: UIFont!;
    var textFieldFont: UIFont!;
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    let singleStrandIconSize = (width: 60, height: 95);
    let userStrandLabelHeight = 18;
    let formWidth = 250;
    let closeButtonWidth = 40;
    let closeButtonHeight = 20;
    let defaultFormY = 60;
    let buttonHeight = 40;
    let commentTextLabelHeight = 20;
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
            intentToSignUp = true;
            signUpToProfileUpdateTransformForm(asProfile: false);
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
            intentToSignUp = false;
            signUpToProfileUpdateTransformForm(asProfile: true);
            signUpForm.isHidden = false;
        
        case "Logout":
            toggleMenu(vert: true);
            renderMenu(loggedin: false);
            hideAnyViews();
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
        strandCommentsView.isHidden = true;
        singleStrandInfoView.isHidden = true;
        userProfileView.isHidden = true;
        self.view.endEditing(true);
    }
    
    @objc func closeSingleStrandInfoViewWrap(){
        singleStrandInfoView.isHidden = true;
    }
    
    @objc func wrapTapped(touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        if(mapShowing == false){
            if(self.tapToPost == true ){
                actionDelegate?.renderTempStrandFromUI!(tapX: Int(tapPoint.x), tapY: Int(tapPoint.y));
            }else{
                actionDelegate?.chooseStrandComments!(tapX: Int(tapPoint.x), tapY: Int(tapPoint.y));
            }
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
        actionDelegate?.updateUserDataRequest!(username: (signUpFields.username?.text)!, password: (signUpFields.password?.text)!, fullname: (signUpFields.fullname?.text)!, email: (signUpFields.email?.text)!);
    }
    
    func signUpToProfileUpdateTransformForm(asProfile: Bool){
        if(asProfile == true){
            signUpFields.username?.text = loggedinUserData.username;
            signUpFields.email?.text = loggedinUserData.email;
            signUpFields.fullname?.text = loggedinUserData.fullname;
            signUpFields.password?.text = loggedinUserData.password;
            signUpSubmitButton.setTitle("Update", for: UIControlState());
        }else{
            signUpFields.username?.text = "Username..";
            signUpFields.email?.text = "Email...";
            signUpFields.fullname?.text = "Fullname...";
            signUpSubmitButton.setTitle("Sign Up", for: UIControlState());
        }
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
    
    @objc func newCommentStrand(){
        actionDelegate?.postNewComment!(commentText: commentExistingStrandTextfield.text!);
    }
    
    @objc func postStrand(){
        cancelTap();
        actionDelegate?.addStrandReady!(comment: commentTextfield.text!);
        self.view.endEditing(true);
    }
    
    @objc func deleteStrandWrap(){
        actionDelegate?.deleteStrandRequest!(realID: posStrandToDeleteRealID);
    }
    
    func addUserStrandLabel(text: String, areaName: String, localID: Int){
        
        let strandTextLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userStrandLabelYPos+10, width: 250, height: userStrandLabelHeight));
        let strandAreaLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userStrandLabelYPos+userStrandLabelHeight+10, width: 250, height: userStrandLabelHeight));
        
        let strandIcon = UIImage(named: strandIconDest);
        let strandIconView = UIImageView(image: strandIcon!);
        strandIconView.tag = localID;
        strandIconView.frame = CGRect(x: 0, y:  userStrandLabelYPos+12, width: 20, height: 30);
        
        strandTextLabel.text = text;
        strandAreaLabel.text = "in " + areaName;
        
        let uiImageTap = UITapGestureRecognizer(target: self, action: #selector(showSingleStrandInfo));
        strandIconView.isUserInteractionEnabled = true;
        strandIconView.addGestureRecognizer(uiImageTap);
        strandTextLabel.font = UIFont(name: mainTypeFace, size: 17);
        strandAreaLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 13);
        
        userScrollStrandListView.addSubview(strandTextLabel);
        userScrollStrandListView.addSubview(strandAreaLabel);
        userScrollStrandListView.addSubview(strandIconView);
        
    }
    
    @objc func showSingleStrandInfo(sender: UITapGestureRecognizer){
        let strandInfoLocalID = sender.view?.tag;
        posStrandToDeleteRealID = userStrandsJSON[strandInfoLocalID!]["s_id"].int!;
        let relTitleText = userStrandFirstCommentsJSON[strandInfoLocalID!]["c_text"].rawString()!;
        singleStrandFcommentTitle.text = relTitleText;
        singleStrandInfoView.isHidden = false;
    }
    
    func populateUserStrands(strands: JSON, firstComments: JSON){
        userStrandsJSON = strands;
        userStrandFirstCommentsJSON = firstComments;
        for subview in userScrollStrandListView.subviews{
            subview.removeFromSuperview();
        }
        userStrandLabelYPos = 5;
        let labelHeight = 2*userStrandLabelHeight+10;
        userScrollStrandListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+(strands.count*labelHeight)));
        var count = 0;
        for strand in strands{
            let areaName = strands[count]["s_area_name"].rawString()!;
            self.addUserStrandLabel(text: firstComments[count]["c_text"].rawString()!, areaName: areaName, localID: count);
            self.userStrandLabelYPos += 2*self.userStrandLabelHeight + 10;
            count += 1;
        }
    }
    
    func getHeightForField(text: String, font: UIFont, width: CGFloat) ->CGFloat{
        let tempLabel = UILabel(frame: CGRect(x:0,y:0,width:width,height:CGFloat.greatestFiniteMagnitude));
        tempLabel.numberOfLines = 0;
        tempLabel.text = text;
        tempLabel.font = font;
        tempLabel.sizeToFit();
        tempLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        return tempLabel.frame.height;
    }
    
    var lastCommentHeight = 0;
    var commentInfoHeight = 20;
    func addStrandCommentLabel(text: String, infoString: String){
        
        let labelWidth = viewPageWidth-20;
        let labelTextHeight =  getHeightForField(text: text, font: mainFont, width: CGFloat(labelWidth)) + 10;
        lastCommentHeight = Int(labelTextHeight);
        let commentTextLabel: UILabel  = UILabel(frame: CGRect(x: 5, y: strandCommentListLabelYPos+10, width: labelWidth, height: Int(labelTextHeight)));
        
        commentTextLabel.text = text;
        commentTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        commentTextLabel.numberOfLines = Int(labelTextHeight/20)+1;
        commentTextLabel.font = mainFont;
        
        let commentInfoLabel: UILabel  = UILabel(frame: CGRect(x: 5, y: strandCommentListLabelYPos+Int(labelTextHeight), width: labelWidth, height: commentInfoHeight));
        
    
        commentInfoLabel.text = infoString;


        commentInfoLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 11);
        
        strandCommentsListScrollView.addSubview(commentTextLabel);
        strandCommentsListScrollView.addSubview(commentInfoLabel);
    }
    
    func populateStrandCommentsView(strandComments: JSON){
        strandCommentsView.isHidden = false;
        lastCommentHeight = 0;
        for subview in strandCommentsListScrollView.subviews{
            subview.removeFromSuperview();
        }
        strandCommentsListScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(800));
        strandCommentListLabelYPos = 5;
        
        var count = 0;
        var nextYPosCalc = 0;
        for _ in strandComments{
            let commentText = strandComments[count]["c_text"].rawString()!;
            let infoString = "By " + strandComments[count]["c_u_uname"].rawString()! + ", at " + strandComments[count]["c_time"].rawString()!;
            addStrandCommentLabel(text: commentText, infoString: infoString);
            nextYPosCalc = lastCommentHeight + commentInfoHeight;
            strandCommentListLabelYPos += nextYPosCalc;
            count += 1;
        }
        strandCommentsListScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+strandCommentListLabelYPos+nextYPosCalc));
    }

    
    //MARK: render UI components
    func renderPostCommentForm(){
        let formHeight = 100;
        commentForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonHeight + buttonSpace,width: formWidth, height: formHeight));
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
        let buttonWidthLogin =  viewPageWidth/2 - 10;
        let textWidthLogin =  viewPageWidth-10;
        
        loginForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: formHeight));
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
        
        let cancelLoginButtonRect = CGRect(x: viewPageWidth-(buttonWidthLogin+5), y: 130, width: buttonWidthLogin, height: textFieldSize.height);
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
        let buttonWidthSignUp = viewPageWidth/2 - 10;
        let textWidthSignUp =  viewPageWidth - 10;
        
        signUpForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: formHeight));
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
        
        let cancelSignUpButtonRect = CGRect(x: viewPageWidth-(buttonWidthSignUp+5), y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
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
    
    func renderSingleStrandInfoView(){
        let viewHeight = 250;
        singleStrandInfoView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        singleStrandInfoView.isHidden = true;
        singleStrandInfoView.insertSubview(processBlurEffect(bounds: singleStrandInfoView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        
        let closeSingleStrandInfoRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeSingleStrandInfoView = addButtonProperties(title: "Close", hidden: false, pos: closeSingleStrandInfoRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeSingleStrandInfoView.addTarget(self, action: #selector(closeSingleStrandInfoViewWrap), for: .touchUpInside);
        
        let deleteButtonWidth = 70;
        let deleteStrandButtonRect = CGRect(x: viewPageWidth/2-(deleteButtonWidth/2), y: viewHeight-(buttonHeight+5), width: deleteButtonWidth, height: buttonHeight);
        
        deleteStrandButton = addButtonProperties(title: "Delete", hidden: false, pos: deleteStrandButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        deleteStrandButton.addTarget(self, action: #selector(deleteStrandWrap), for: .touchUpInside);

    
        let strandIcon = UIImage(named: strandIconDest);
        let strandIconView = UIImageView(image: strandIcon!);
        strandIconView.frame = CGRect(x: (viewPageWidth/2)-(singleStrandIconSize.width/2), y:  20, width: singleStrandIconSize.width, height: singleStrandIconSize.height);
        
        singleStrandFcommentTitle = UILabel(frame: CGRect(x: 10, y: singleStrandIconSize.height+5, width: viewPageWidth-20, height: 100));
        singleStrandFcommentTitle.font = UIFont(name: mainTypeFace, size: 15);
        singleStrandFcommentTitle.lineBreakMode = NSLineBreakMode.byWordWrapping;
        singleStrandFcommentTitle.textAlignment = .center;
        singleStrandFcommentTitle.numberOfLines = 3;
        
        
        singleStrandInfoView.addSubview(singleStrandFcommentTitle);
        singleStrandInfoView.addSubview(closeSingleStrandInfoView);
        singleStrandInfoView.addSubview(deleteStrandButton);
        singleStrandInfoView.addSubview(strandIconView);
        
        self.view.addSubview(singleStrandInfoView);
        
    }
    
    func renderStrandCommentsView(){
        let viewHeight = 300;
        strandCommentsView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        strandCommentsView.isHidden = true;
        strandCommentsView.insertSubview(processBlurEffect(bounds: strandCommentsView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        strandCommentsListScrollView = UIScrollView(frame: CGRect(x:5,y: closeButtonHeight+15+textFieldSize.height,width: viewPageWidth, height: viewHeight-(closeButtonHeight+15+textFieldSize.height)));

        let closestrandCommentsViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeStrandCommentsView = addButtonProperties(title: "Close", hidden: false, pos: closestrandCommentsViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeStrandCommentsView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        let commentExistingStrandTFWidth = viewPageWidth-55;
        commentExistingStrandTextfield = addTextFieldProperties(pos: CGRect(x: 5, y: closeButtonHeight+10, width: commentExistingStrandTFWidth, height: textFieldSize.height));
        commentExistingStrandTextfield.text = "Enter Comment...";
        
        let newCommentButtonRect = CGRect(x: 10+commentExistingStrandTFWidth, y: closeButtonHeight+10, width: 40, height: 40);
        newCommentButton = addButtonProperties(title: "Post", hidden: false, pos: newCommentButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        newCommentButton.addTarget(self, action: #selector(newCommentStrand), for: .touchUpInside);
        
        strandCommentsView.addSubview(newCommentButton);
        strandCommentsView.addSubview(commentExistingStrandTextfield);
        strandCommentsView.addSubview(closeStrandCommentsView);
        strandCommentsView.addSubview(strandCommentsListScrollView);
        self.view.addSubview(strandCommentsView);
        
    }
    

    
    func renderUserStrandsView(){
        let viewHeight = 370;
        userStrandListView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        userStrandListView.isHidden = true;
        userScrollStrandListView = UIScrollView(frame: CGRect(x:5,y: 25,width: viewPageWidth, height: viewHeight-30));
        userScrollStrandListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(viewHeight));
        userStrandListView.insertSubview(processBlurEffect(bounds: userStrandListView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        

        let closeUserStrandViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeUserStrandView = addButtonProperties(title: "Close", hidden: false, pos: closeUserStrandViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserStrandView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);

        userStrandListView.addSubview(closeUserStrandView);
        userStrandListView.addSubview(userScrollStrandListView);
        self.view.addSubview(userStrandListView);
    }
    
    
    func renderProfileView(){
        let viewHeight = 370;
        userProfileView = UIView(frame: CGRect(x:Int(screenSize.width/2)-viewPageWidth/2,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        userProfileView.isHidden = true;
        userProfileView.insertSubview(processBlurEffect(bounds: userProfileView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        let closeUserProfileViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
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
        renderStrandCommentsView();
        renderPostCommentForm();
        renderProfileView();
        renderUserStrandsView();
        renderSingleStrandInfoView();
    }
    
}

