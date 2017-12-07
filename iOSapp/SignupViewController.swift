//
//  SignupViewController.swift
//  iOSapp
//
//  Created by Ran Reichman on 11/30/17.
//  Copyright © 2017 Ran Reichman. All rights reserved.
//

import UIKit

class SignupViewController : GenericProgramViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var termsAndConditionsBox: UITextView!
    
    @IBOutlet weak var emailSignupField: UITextField!
    @IBOutlet weak var firstNameSignupField: UITextField!
    @IBOutlet weak var lastNameSignupField: UITextField!
    @IBOutlet weak var firstPasswordInput: UITextField!
    @IBOutlet weak var secondPasswordInput: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Making the "Back" button black instead of blue
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        self.view.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        termsAndConditionsBox.backgroundColor = SystemVariables().LOGIN_BACKGROUND_COLOR
        registerButton.backgroundColor = SystemVariables().LOGIN_BUTTON_COLOR
        
        termsAndConditionsBox.attributedText = getTermsAndConditionsString()
        
        registerForKeyboardNotifications()
    }
    
    // TODO:: Perhaps unite with other register for notifications function
    func registerForKeyboardNotifications()
    {
        //Adding notifications on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification)
    {
        var info = notification.userInfo!
        let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
        scrollViewBottomConstraint.constant = keyboardHeight!
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        scrollViewBottomConstraint.constant = 0
        // Note - This is supposed to smoothen the constraint update
        UIView.animate(withDuration: 1)
        {
            self.view.layoutIfNeeded()
        }
    }
    
    /*func keyboardWasShown(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillBeHidden(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }*/
    
    @IBAction func alreadyMemberButton(_ sender: Any)
    {
        
        performSegue(withIdentifier: "segueToLoginScreenFromSignup", sender: self)
    }
    
    @IBAction func pressedRegisterButton(_ sender: Any)
    {
        if (validateRegisterData())
        {
            WebUtils().runFunctionAfterGettingCsrfToken(functionData: "", completionHandler: self.performSignupAction)
        }
    }
    
    func getSignupDataAsJson() -> Dictionary<String,String>
    {
        var signupData : Dictionary<String,String> = Dictionary<String,String>()
        signupData["email"] = emailSignupField.text
        signupData["first_name"] = firstNameSignupField.text
        signupData["last_name"] = lastNameSignupField.text
        signupData["password1"] = firstPasswordInput.text
        signupData["password2"] = secondPasswordInput.text
        
        return signupData
    }
    
    // TODO:: improve validation for email
    func validateRegisterData() -> Bool
    {
        if emailSignupField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert email address", viewController: self)
            return false
        }
        
        if firstNameSignupField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert first name", viewController: self)
            return false
        }
        
        if lastNameSignupField.text?.count == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please insert last name", viewController: self)
            return false
        }
        
        if (firstPasswordInput.text?.count)! == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please enter password", viewController: self)
            return false
        }
        
        if (firstPasswordInput.text?.count)! < SystemVariables().PASSWORD_LENGTH_LIMIT
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Password is too short", viewController: self)
            return false
        }
        
        if (firstPasswordInput.text?.count)! == 0
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Please re-enter password", viewController: self)
            return false
        }
        
        if (secondPasswordInput.text?.count)! < SystemVariables().PASSWORD_LENGTH_LIMIT
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Re-entered password is too short", viewController: self)
            return false
        }
        
        if (secondPasswordInput.text != firstPasswordInput.text)
        {
            promptToUser(promptMessageTitle: "Error", promptMessageBody: "Re-entered password isn't the same as original password", viewController: self)
            return false
        }
        
        return true
    }
    
    func performSignupAction(handlerParams : Any, csrfToken : String)
    {
        var urlString : String = SystemVariables().URL_STRING
        urlString.append("rest-auth/registration/")
        WebUtils().postContentWithJsonBody(jsonString: getSignupDataAsJson(), urlString: urlString, csrfToken: csrfToken, completionHandler: completeSignupAction)
    }
    
    func completeSignupAction(responseString: String)
    {
        if let jsonObj = try? JSONSerialization.jsonObject(with: responseString.data(using: .utf8)!, options: .allowFragments) as! [String : Any]
        {
            DispatchQueue.main.async
            {
                if jsonObj.keys.count == 1 && jsonObj.keys.contains("key")
                {
                        storeUserInformation(authenticationToken: jsonObj["key"] as! String)
                        UserInformation().getUserInformationFromWeb()
                    
                        promptToUser(promptMessageTitle: "Signup successful!", promptMessageBody: "", viewController: self, completionHandler: self.segueBackToContent)
                }
                else
                {
                    let errorMessageString : String = getErrorMessageFromResponse(jsonObj: jsonObj)
                    promptToUser(promptMessageTitle: "Error", promptMessageBody: errorMessageString, viewController: self)
                }
            }
        }
        else
        {
            // TODO:: answer this
            print("what to do here?")
        }
    }
    
    func getTermsAndConditionsString() -> NSMutableAttributedString
    {
        let termsStringPartOne : String = "By registering you confirm that you accept the "
        let termsStringPartTwo : String = "Terms and Conditions"
        let fullText : String = termsStringPartOne + termsStringPartTwo
        
        let termsAttributedString : NSMutableAttributedString = NSMutableAttributedString(string : fullText)
        
        
        let linkAttributes : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.link: "https://media.snip.today/Snip+-+Terms+of+Service.pdf",
            NSAttributedStringKey.foregroundColor: UIColor.blue
        ]
        
        termsAttributedString.addAttributes(linkAttributes, range: NSMakeRange(termsStringPartOne.count, termsStringPartTwo.count))
        termsAttributedString.addAttribute(NSAttributedStringKey.font, value: SystemVariables().TERMS_AND_CONDITIONS_FONT!, range: NSMakeRange(0, fullText.count))
        
        return termsAttributedString
    }
}
