//
//  MainViewController.swift
//  Rideshield
//
//  Created by azamshahani on 6/25/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import MapKit
import CoreLocation

class MainViewController : UIViewController, CLLocationManagerDelegate {
    
    //Instance variables
    var currentAccX: Double = 0.0
    var currentAccY: Double = 0.0
    var currentAccZ: Double = 0.0
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    
    var currentRotX: Double = 0.0
    var currentRotY: Double = 0.0
    var currentRotZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    var isAutomotive: Bool = false
    var isStationary: Bool = false
    var isUnknown: Bool = false
    
    var motionManager = CMMotionManager()
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var ridingNotification: UIButton!
    @IBOutlet var ridingCheck: UIImageView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Sensors
    
        //Setting accelerometer and gyro update interval
        motionManager.accelerometerUpdateInterval = 0.01
        motionManager.gyroUpdateInterval = 0.01
        
        //CMMotionActivityManager initialization
        let motionActivityManager = CMMotionActivityManager()
        
        //Activity Recognition
        if CMMotionActivityManager.isActivityAvailable(){
            
            motionActivityManager.startActivityUpdates(to: OperationQueue.current!) { (data) in
                if let myData = data
                {
                    self.isAutomotive = myData.automotive
                    self.isStationary = myData.stationary
                    self.isUnknown = myData.unknown
                }
            }
        }
        
        //Gyro
        motionManager.startGyroUpdates(to: OperationQueue.current! ) {   (data, error) in
            if let myData = data
            {
                self.currentRotX = myData.rotationRate.x
                if fabs(myData.rotationRate.x) > fabs(self.currentMaxRotX)
                {
                    self.currentMaxRotX = myData.rotationRate.x
                }
                
                self.currentRotY = myData.rotationRate.y
                if fabs(myData.rotationRate.y) > fabs(self.currentMaxRotY)
                {
                    self.currentMaxRotY = myData.rotationRate.y
                }
                
                self.currentRotZ = myData.rotationRate.z
                if fabs(myData.rotationRate.z) > fabs(self.currentMaxRotZ)
                {
                    self.currentMaxRotZ = myData.rotationRate.z
                }
                //print(myData)
            }
        }
        
        //Accelerometer
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data
            {
                self.currentAccX = myData.acceleration.x
                if fabs(myData.acceleration.x) > fabs(self.currentMaxAccelX)
                {
                    self.currentMaxAccelX = myData.acceleration.x
                }
                
                self.currentAccY = myData.acceleration.y
                if fabs(myData.acceleration.y) > fabs(self.currentMaxAccelY)
                {
                    self.currentMaxAccelY = myData.acceleration.y
                }
                
                self.currentAccZ = myData.acceleration.z
                if fabs(myData.acceleration.z) > fabs(self.currentMaxAccelZ)
                {
                    self.currentMaxAccelZ = myData.acceleration.z
                }
                //print(myData)
                
                //Riding Detection
                if (self.isAutomotive)
                {
                    print("Riding!")
                    self.ridingNotification.setTitle("RIDING", for: .normal)
                    self.ridingNotification.backgroundColor = UIColor(red: 35/255, green: 192/255, blue: 101/255, alpha: 1)
                    self.ridingNotification.isHidden = false
                    self.ridingCheck.isHidden = false
                } else {
                    print("Not Riding!")
                    self.ridingNotification.setTitle("NOT RIDING", for: .normal)
                    self.ridingNotification.backgroundColor = UIColor.red
                    self.ridingNotification.isHidden = false
                    self.ridingCheck.isHidden = true
                    
                }
                
                //Crash Detection
                if (fabs(myData.acceleration.x) > 8.0 || fabs(myData.acceleration.y) > 8.0 || fabs(myData.acceleration.z) > 8.0) && self.isAutomotive
                {
                    print("Crash detected!")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let CrashViewController = storyBoard.instantiateViewController(withIdentifier: "CrashViewController")
                    self.present(CrashViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let center = location.coordinate
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(center, span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
