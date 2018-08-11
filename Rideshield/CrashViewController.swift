//
//  CrashViewController.swift
//  Rideshield
//
//  Created by azamshahani on 8/7/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import Foundation
import UIKit

class CrashViewController : UIViewController {
    
    @IBOutlet var countdownTimer: UILabel!
    var count = 20
    var crashTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I'm in crashviewcontroller")
        crashTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CrashViewController.update), userInfo: nil, repeats: true)
    }
    
    @objc func update()
    {
        if (count > 0)
        {
            count -= 1
            countdownTimer.text = String(count)
        }
        else
        {
            //Stop timer
            crashTimer?.invalidate()
            
            //TODO: Code to notify emergency contacts
            
            //Displaying alert
            let alert = UIAlertController(title: "Hang Tight", message: "Your emergency contacts have been notified of the crash with your exact location. Help should arrive soon.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                //Navigating to main screen
                self.backToMain()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismissed(_ sender: UILongPressGestureRecognizer) {
        print("I'm in dismissed function")
        
        //Navigating to main screen
        backToMain()
    }
    
    func backToMain() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
        self.present(MainViewController, animated: true, completion: nil)
    }
    
}

