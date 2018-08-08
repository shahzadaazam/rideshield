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
    var count = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("I'm in crashviewcontroller")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CrashViewController.update), userInfo: nil, repeats: true)
    }
    
    @objc func update()
    {
        if (count > 0)
        {
            count -= 1
            countdownTimer.text = String(count)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

