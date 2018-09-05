//
//  CrashViewController.swift
//  Rideshield
//
//  Created by azamshahani on 8/7/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation

class CrashViewController : UIViewController {
    
    @IBOutlet var countdownTimer: UILabel!
    var count = 20
    var dismissed = false
    var crashTimer : Timer?
    var contactsDict = [String: [String]]()
    var latitude: String = ""
    var longitude: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Testing
        print(contactsDict)
        
        //Testing
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
    
        print("I'm in crashviewcontroller")
        if crashTimer == nil {
            crashTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CrashViewController.update), userInfo: nil, repeats: true)
        }
    }
    
    @objc func update()
    {
        if (count > 0)
        {
            print("I'm in update if")
            count -= 1
            countdownTimer.text = String(count)
        }
        else
        {
            //Stop timer
            crashTimer?.invalidate()
            print("I'm in update else")
            
            //Code to notify emergency contacts using Alamofire
            let user = "ACbd6bed42bef062e4e8f074e021da70fa"
            let password = "9c85816f333599a3fdc0c5cfd3b582be"
            
            let credentialData = "\(user):\(password)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            print("credentialData: ", credentialData)
            
            let base64Credentials = credentialData.base64EncodedString()
            print("base64Credentials: ", base64Credentials)
            
            let headers = [
                "authorization": "Basic \(base64Credentials)",
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            //Loop through contact phone numbers
            for (name, phoneNumbersArray) in contactsDict
            {
                for phoneNumber in phoneNumbersArray
                {
                    let parameters: Parameters = [
                        "To": phoneNumber,
                        "From": "+18135318998",
                        "Body": "Hello " + name + ". This is an emergency message from the RideShield app. Your contact has been in a motorcycle crash at location https://www.google.com/maps/search/?api=1&query=" + latitude + "," + longitude + " .Please arrange for emergency help."
                    ]
                    
                    Alamofire.request("https://api.twilio.com/2010-04-01/Accounts/ACbd6bed42bef062e4e8f074e021da70fa/Messages.json", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
                        print(response)
                    }
                }
            }
            
            //Displaying alert
            let alert = UIAlertController(title: "Hang Tight", message: "Your emergency contacts have been notified of the crash with your exact location. Help should arrive soon.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                //Navigating to main screen
                self.performSegue(withIdentifier: "crashToMainSegue", sender: self)
                //self.backToMain()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissed(_ sender: UILongPressGestureRecognizer) {
        print("I'm in dismissed function")
        
        if dismissed == false
        {
            dismissed = true
            print("I'm in dismissed if")
            
            //Stop timer
            crashTimer?.invalidate()
            crashTimer = nil
            
            //Navigating to main screen
            self.performSegue(withIdentifier: "crashToMainSegue", sender: self)
            //self.backToMain()
        }
    }
    
//    func backToMain() {
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let MainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
//        self.present(MainViewController, animated: true, completion: nil)
//    }
    
}

