//
//  SignupViewController.swift
//  Rideshield
//
//  Created by azamshahani on 6/24/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UIViewController {
    
    @IBOutlet var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding borders to buttons
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
