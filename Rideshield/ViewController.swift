//
//  ViewController.swift
//  Rideshield
//
//  Created by azamshahani on 6/23/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, UIScrollViewDelegate, GIDSignInUIDelegate {
    
    @IBOutlet var googleSignIn: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        //Adding borders to buttons
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.white.cgColor
        
        //First heading
        let heading1 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        heading1.textAlignment = .center
        heading1.text = "UNIQUE VALUE PROPOSITION"
        heading1.textColor = UIColor.white
        heading1.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        scrollView.addSubview(heading1)
        
        heading1.frame = CGRect(x: scrollView.frame.midX-167, y: (scrollView.frame.height/2)-10, width: 300, height: 20)
        
        //First subheading
        let subheading1 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        subheading1.textAlignment = .center
        subheading1.text = "Text to explain what the app does"
        subheading1.textColor = UIColor.white
        subheading1.font = UIFont.systemFont(ofSize: 18.0)
        
        scrollView.addSubview(subheading1)
        
        subheading1.frame = CGRect(x: scrollView.frame.midX-168, y: (scrollView.frame.height/2)+50, width: 300, height: 20)
        
        //Second heading
        let heading2 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        heading2.textAlignment = .center
        heading2.text = "UNIQUE VALUE PROPOSITION"
        heading2.textColor = UIColor.white
        heading2.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        scrollView.addSubview(heading2)
        
        heading2.frame = CGRect(x: scrollView.frame.width + scrollView.frame.midX-205, y: (scrollView.frame.height/2)-10, width: 300, height: 20)
       
        //Second subheading
        let subheading2 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        subheading2.textAlignment = .center
        subheading2.text = "Text to explain what the app does"
        subheading2.textColor = UIColor.white
        subheading2.font = UIFont.systemFont(ofSize: 18.0)
        
        scrollView.addSubview(subheading2)
        
        subheading2.frame = CGRect(x: scrollView.frame.width + scrollView.frame.midX-205, y: (scrollView.frame.height/2)+50, width: 300, height: 20)
        
        //Third heading
        let heading3 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        heading3.textAlignment = .center
        heading3.text = "UNIQUE VALUE PROPOSITION"
        heading3.textColor = UIColor.white
        heading3.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        scrollView.addSubview(heading3)
        
        heading3.frame = CGRect(x: (scrollView.frame.width * 2) + scrollView.frame.midX-245, y: (scrollView.frame.height/2)-10, width: 300, height: 20)
        
        //Third subheading
        let subheading3 = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        subheading3.textAlignment = .center
        subheading3.text = "Text to explain what the app does"
        subheading3.textColor = UIColor.white
        subheading3.font = UIFont.systemFont(ofSize: 18.0)
        
        scrollView.addSubview(subheading3)
        
        subheading3.frame = CGRect(x: (scrollView.frame.width * 2) + scrollView.frame.midX-245, y: (scrollView.frame.height/2)+50, width: 300, height: 20)

        scrollView.contentSize = CGSize(width: scrollView.frame.width*3.0, height: 60)
        
        //Connecting google sign in button
        googleSignIn.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @objc func handleCustomGoogleSignIn()
    {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func navigateToMain()
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MainViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
        self.present(MainViewController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGFloat(scrollView.frame.width))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

