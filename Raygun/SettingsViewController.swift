//
//  SettingsViewController.swift
//  Raygun
//
//  Created by Conlin Durbin on 10/19/14.
//  Copyright (c) 2014 Conlin Durbin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var mainView: ViewController!
    
    @IBOutlet weak var gameName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var startGame: UIButton!
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        var nextTag = textField.tag+1
        var nextResp = textField.superview?.viewWithTag(nextTag)
        if (nextResp != nil) {
            nextResp!.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true;
    }
    
    var join_url : String = "http://104.131.106.164/joinGame"
    
    @IBAction func joinGame(sender: AnyObject) {
        var jsonDict : AnyObject = ["game":gameName.text, "player":userName.text]
        JSONtools.HTTPPostJSON(join_url, jsonObj: jsonDict, callback: { (data: String, err: String?) -> Void in
            if err==nil {
                if let dataDict = JSONtools.JSONParseDict(data) as NSDictionary? {
                    if let output = dataDict["joined"] as? Int {
                        GlobalSettings.gameName = self.gameName.text
                        GlobalSettings.userName = self.userName.text
                    } else {
                        println("I'm sorry Dave, I can't do that. You can't join the game.")
                    }
                }
            }
        })
    }
    
    override func awakeFromNib() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        background.image = appDelegate.backgroundImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
