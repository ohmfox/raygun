//
//  ViewController.swift
//  Raygun
//
//  Created by Conlin Durbin on 10/18/14.
//  Copyright (c) 2014 Conlin Durbin. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let captureSession = AVCaptureSession()
    var beacons: [CLBeacon]?
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var captureDevice : AVCaptureDevice?
    
    var shot_url = "http://104.131.106.164/shoot"
    var hit_url = "http://104.131.106.164/checkHits"
    var respawn_url = "http://104.131.106.164/respawn"
    
    var score = 0
    
    var isDead = false
    
    var notInBase = true
    
    let captureMetaOutput = AVCaptureMetadataOutput()
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var fireButton: UIButton!

    @IBOutlet weak var raygunReload: UIImageView!
    
    override func viewDidLoad() {
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("raygun", ofType: "wav")!)
        println(alertSound)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()

        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if(device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        if(captureDevice != nil) {
            beginSession()
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        println(metadataObjects.count)
        if let realObjects = metadataObjects {
            if let first: AnyObject = metadataObjects.first {
                println(first.stringValue)
                stopQR()
                logHit(first.stringValue)
            }
        }
        
    }
    
    func stopQR() {
        println("Stop firing")
        fireButton.enabled = true
        captureSession.removeOutput(captureMetaOutput)
    }
    
    func reload() {
        fireButton.alpha = 1
        raygunReload.alpha = 0
    }
    
    @IBAction func firePressed(sender: AnyObject) {
        println("Fired")
        audioPlayer.play()
        fireButton.enabled = false
        fireButton.alpha = 0
        raygunReload.alpha = 1
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "reload", userInfo: nil, repeats: false)
        captureSession.addOutput(captureMetaOutput)
        let dispatch_queue = dispatch_queue_create("myQueue", nil)
        captureMetaOutput.setMetadataObjectsDelegate(self, queue: dispatch_queue)
        captureMetaOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "stopQR", userInfo: nil, repeats: false)
    }
    
    var respawnTimer: NSTimer?
    
    @IBOutlet var backScreen: UIView!
    
    func killBox() {
        self.isDead = true
        dispatch_async(dispatch_get_main_queue()) {
            self.respawnTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "isRespawning", userInfo: nil, repeats: true)
            self.respawnTimer!.fire()
            self.backScreen.backgroundColor = .redColor()
            self.fireButton.enabled = false
            self.fireButton.hidden = true
            self.countLabel.hidden = true
            self.previewLayer.hidden = true
        }
    }
    
    func respawn() {
        dispatch_async(dispatch_get_main_queue()) {
            self.backScreen.backgroundColor = .whiteColor()
            self.fireButton.enabled = true
            self.fireButton.hidden = false
            self.countLabel.hidden = false
            self.previewLayer.hidden = false
        }
        var jsonDict = ["game": GlobalSettings.gameName, "player": GlobalSettings.userName]
        JSONtools.HTTPPostJSON(respawn_url, jsonObj: jsonDict, callback: { (data: String, err: String?) -> Void in
            println(err)
            if(err==nil) {
                self.respawnTimer?.invalidate()
                self.isDead = false
            }
        })
    }
    
    func pollForHits() {
        if !isDead {
            var jsonDict = ["game": GlobalSettings.gameName, "player": GlobalSettings.userName]
            JSONtools.HTTPPostJSON(hit_url, jsonObj: jsonDict, callback: { (data: String, err: String?) -> Void in
                if(err==nil) {
                    if let dataDict = JSONtools.JSONParseDict(data) as NSDictionary? {
                        if let output = dataDict["hit"] as? Int {
                            if output == 1 {
                                self.killBox()
                            }
                        } else {
                            println("I'm sorry Dave, I can't do that")
                        }
                    }
                }
            })
        }
    }
    
    func logHit(userHit: String) {
        println(userHit)
        let jsonArr = ["game": GlobalSettings.gameName, "player": GlobalSettings.userName, "victim":userHit]
        JSONtools.HTTPPostJSON(shot_url, jsonObj: jsonArr, callback: { (data: String, err: String?) -> Void in
            if (err==nil) {
                if let dataDict = JSONtools.JSONParseDict(data) as NSDictionary? {
                    if let output = dataDict["hit"] as? Int {
                        if output == 1 {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.score = dataDict["score"] as Int
                                self.countLabel.text = String(self.score)
                            })
                        }
                    } else {
                        println("I'm sorry Dave, I can't do that")
                    }
                }
            }
        })
    }
    
    func isRespawning() {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        println(appDelegate.atBase)
        println(self.isDead)
        if appDelegate.atBase && self.isDead {
            self.respawn()
        }
    }
    
    func beginSession() {
        var pollTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pollForHits", userInfo: nil, repeats: true)
        raygunReload.alpha = 0
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.insertSublayer(previewLayer, below: fireButton.layer)
        previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

