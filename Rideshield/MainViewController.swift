//
//  MainViewController.swift
//  Rideshield
//
//  Created by azamshahani on 6/25/18.
//  Copyright © 2018 cutr. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreMotion
import MapKit
import CoreLocation
import Alamofire
import Contacts
import ContactsUI

class MainViewController : UIViewController, CLLocationManagerDelegate, CNContactPickerDelegate {
    
    //Instance variables
    var timer: Timer?
    var logData = [String: Any]()
    var contactsDict = [String: [String]]()
    var timerFlag = false
    
    //Acceleration
    var currentAccX: Double = 0.0
    var currentAccY: Double = 0.0
    var currentAccZ: Double = 0.0
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    
    //Rotation
    var currentRotX: Double = 0.0
    var currentRotY: Double = 0.0
    var currentRotZ: Double = 0.0
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    //Motion
    var isAutomotive: Bool = false
    var isStationary: Bool = false
    var isUnknown: Bool = false
    
    //Crash
    var didCrash: Bool = false
    
    var motionManager = CMMotionManager()
    
    //Location
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    var latitude: String = ""
    var longitude: String = ""
    
    //Other Metrics
    var currentSpeed: Double = 0.0
    var totalDistance: Double = 0.0
    var currentAbsoluteGforce: Double = 0.0
    var currentLeanAngle: Double = 0.0
    
    //Outlets
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var ridingNotification: UIButton!
    @IBOutlet var ridingCheck: UIImageView!
    @IBOutlet var speedMetric: UILabel!
    @IBOutlet var distanceMetric: UILabel!
    @IBOutlet var gforceMetric: UILabel!
    @IBOutlet var leanangleMetric: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        //Testing for contacts selection
        selectContacts()
        //Testing ends
        
        //Timer
        scheduledTimerWithTimeInterval()
        
        //Firebase firestore
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        
        let db = Firestore.firestore()
        db.settings = settings
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 10
        
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
                
                //print(String(self.locationManager.location?.speed == -1 ? 0.0 : self.locationManager.location?.speed ?? 0))
                
                //Riding Detection
                if (!self.isAutomotive)
                {
                    //print("Riding!")
                    self.ridingNotification.setTitle("RIDING", for: .normal)
                    self.ridingNotification.backgroundColor = UIColor(red: 35/255, green: 192/255, blue: 101/255, alpha: 1)
                    self.ridingNotification.isHidden = false
                    self.ridingCheck.isHidden = false
                    
                    //Displaying metrics
                    
                    //Displaying total Gforce metric
                    self.currentAbsoluteGforce = (pow(self.currentAccX,2) + pow(self.currentAccY,2) + pow(self.currentAccZ,2)).squareRoot()
                    self.gforceMetric.text = String(format: "%.2f", self.currentAbsoluteGforce)
                    
                    //Displaying speed metric
                    //Change to mph
                    self.currentSpeed = self.locationManager.location?.speed == -1 ? 0.0 : (self.locationManager.location?.speed)!*2.2369
                    //self.speedMetric.text = String(format: "%.2f", self.locationManager.location?.speed == -1 ? 0.0 : self.locationManager.location?.speed ?? 0)
                    self.speedMetric.text = String(format: "%.2f", self.currentSpeed)
                    
                    //Displaying distance metric
                    self.distanceMetric.text = String(format: "%.2f", self.traveledDistance)
                    
                    //Printing lean angle
                    self.leanangleMetric.text = String(format: "%.2f", self.currentRotX)
                    
                    
                    //Firestore
                    
                    //Preparing data for logging
                    self.logData = [
                        "accX": self.currentAccX,
                        "accY": self.currentAccY,
                        "accZ": self.currentAccZ,
                        "maxAccelX": self.currentMaxAccelX,
                        "maxAccelY": self.currentMaxAccelY,
                        "maxAccelZ": self.currentMaxAccelZ,
                        
                        "rotX": self.currentRotX,
                        "rotY": self.currentRotY,
                        "rotZ": self.currentRotZ,
                        "maxRotX": self.currentMaxRotX,
                        "maxRotY": self.currentMaxRotY,
                        "maxRotZ": self.currentMaxRotZ,
                        
                        "didCrash": self.didCrash,
                        "isAutomotive": self.isAutomotive,
                        "currentSpeed": self.currentSpeed,
                        "currentAbsoluteGforce": self.currentAbsoluteGforce,
                        "distanceTraveled": self.traveledDistance,
                        
                        "latitude": self.latitude,
                        "longitude": self.longitude,
                        
                    ]
                    
                    //Logging data to Firestore as per set timer interval
                    if (self.timerFlag == true)
                    {
                        db.collection(String(uid)).document(String(NSDate().timeIntervalSince1970)).setData(self.logData) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added")
                            }
                        }
                        self.timerFlag = false
                    }
                    
                } else {
                    
                    print("Not Riding!")
                    self.ridingNotification.setTitle("NOT RIDING", for: .normal)
                    self.ridingNotification.backgroundColor = UIColor.red
                    self.ridingNotification.isHidden = false
                    self.ridingCheck.isHidden = true
                    
                    //Displaying 0s for metrics
                    self.gforceMetric.text = String(0.0)
                    self.speedMetric.text = String(0.0)
                    self.distanceMetric.text = String(0.0)
                    self.leanangleMetric.text = String(0.0)
                    
                }
                
                //Crash Detection
                //change the following to absolute gforce calculation
                if (fabs(myData.acceleration.x) > 8.0 || fabs(myData.acceleration.y) > 8.0 || fabs(myData.acceleration.z) > 8.0) && !self.isAutomotive
                {
                    if self.didCrash == false
                    {
                        //Stopping timer
                        self.timer?.invalidate()
                        self.timer = nil
                        
                        print("Crash detected!")
                        self.didCrash = true;
                        
                        self.performSegue(withIdentifier: "mainToCrashSegue", sender: self)
                        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        //let CrashViewController = storyBoard.instantiateViewController(withIdentifier: "CrashViewController")
                        //self.present(CrashViewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (self.isAutomotive)
        {
            if startLocation == nil {
                startLocation = locations.first
            } else if let location = locations.last {
                traveledDistance += lastLocation.distance(from: location)
                print("Traveled Distance:",  traveledDistance)
                print("Straight Distance:", startLocation.distance(from: locations.last!))
            }
            lastLocation = locations.last
        }
        
        let location = locations[0]
        let center = location.coordinate
        latitude = String(center.latitude)
        longitude = String(center.longitude)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(center, span)
        
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateFlag" with the interval of 5 seconds
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateFlag), userInfo: nil, repeats: true)
        }
        print("Im in timer function")
    }
    
    @objc func updateFlag()
    {
        print("Im in Flag update function pre. Flag is: ", timerFlag)
        timerFlag = (timerFlag == false) ? true : false
        print("Im in Flag update function post. Flag is: ", timerFlag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let crashViewController = segue.destination as! CrashViewController
        crashViewController.contactsDict = self.contactsDict
    }
    
    func openContacts()
    {
        print("I'm in openContacts")
        let contactPicker = CNContactPickerViewController.init()
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController)
    {
        print("I'm in contactPickerCancel")
        picker.dismiss(animated: true)
        {
        
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact])
    {
        print("I'm in contactPicker")
        //When user selects any contact
        
        for contact in contacts
        {
            var phoneNumbersArray: [String] = []
            let full_name = contact.givenName + " " + contact.familyName
            
            for phoneNumber in contact.phoneNumbers
            {
//                contactsDict[full_name] = contactsDict[full_name] != "" ? contactsDict[full_name]! + ", " + phoneNumber.value.stringValue : phoneNumber.value.stringValue
//
//                print(contactsDict[full_name]!)
                phoneNumbersArray.append(phoneNumber.value.stringValue)
            }
            contactsDict[full_name] = phoneNumbersArray
        }
        print(contactsDict)
    }
    
    func selectContacts()
    {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        
        if authStatus == CNAuthorizationStatus.notDetermined
        {
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                if success{
                    print("I'm in success")
                }
                else
                {
                    print("Not authorized")
                }
            })
        }
        else if authStatus == CNAuthorizationStatus.authorized
        {
            self.openContacts()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
