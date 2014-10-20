    //
//  AppDelegate.swift
//  Raygun
//
//  Created by Conlin Durbin on 10/18/14.
//  Copyright (c) 2014 Conlin Durbin. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    var backgroundImage: UIImage!
    var atBase = false
    
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
            
            backgroundImage = UIImage(named: "background_small.jpeg")
            
            let uuidString = "e5a06431-5cc0-4d46-bce4-d5ceb0d0a2e7"
            let beaconIdentifier = "iBeaconModules.us"
            let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)
            let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
                identifier: beaconIdentifier)
            
            locationManager = CLLocationManager()
            
            if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
                locationManager!.requestAlwaysAuthorization()
            }
            
            
            locationManager!.delegate = self
            locationManager!.pausesLocationUpdatesAutomatically = false
            
            locationManager!.startMonitoringForRegion(beaconRegion)
            locationManager!.startRangingBeaconsInRegion(beaconRegion)
            
            return true
    }
    
    func startLocMan() {
        locationManager!.startUpdatingLocation()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            
            if(beacons.count > 0) {
                let nearestBeacon:CLBeacon = beacons[0] as CLBeacon
                
                if(nearestBeacon.proximity == lastProximity ||
                    nearestBeacon.proximity == CLProximity.Unknown) {
                        return;
                }
                lastProximity = nearestBeacon.proximity;
                
                var atBase = false
                
                switch nearestBeacon.proximity {
                case CLProximity.Far:
                    NSLog("You are far away from the base")
                case CLProximity.Near:
                    NSLog("You are near the base")
                    fallthrough
                case CLProximity.Immediate:
                    NSLog("You are at your base")
                    self.atBase = true
                case CLProximity.Unknown:
                    return
                }
                
                
                
            } else {
                
                if(lastProximity == CLProximity.Unknown) {
                    return;
                }
                
                NSLog("No beacons are nearby")
                lastProximity = CLProximity.Unknown
            }
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
            manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
            manager.startUpdatingLocation()
            
            NSLog("You entered the region")

    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
            manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            NSLog("You exited the region")

    }
}
