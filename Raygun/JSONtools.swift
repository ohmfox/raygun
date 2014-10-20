//
//  JSONtools.swift
//  Raygun
//
//  Created by Conlin Durbin on 10/19/14.
//  Copyright (c) 2014 Conlin Durbin. All rights reserved.
//

import Foundation

class JSONtools {
    
    init() {
        println("Here")
    }
    
    class func HTTPPostJSON(url: String,
        jsonObj: AnyObject,
        callback: (String, String?) -> Void) {
            var request = NSMutableURLRequest(URL: NSURL(string: url))
            request.HTTPMethod = "POST"
            request.addValue("application/json",
                forHTTPHeaderField: "Content-Type")
            let jsonString = JSONStringify(jsonObj)
            let data: NSData = jsonString.dataUsingEncoding(
                NSUTF8StringEncoding)!
            request.HTTPBody = data
            HTTPsendRequest(request, callback)
    }
    
    class func HTTPGet(url: String, callback: (String, String?) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url))
        HTTPsendRequest(request, callback)
    }
    
    class func HTTPsendRequest(request: NSMutableURLRequest,
        callback: (String, String?) -> Void) {
            let task = NSURLSession.sharedSession()
                .dataTaskWithRequest(request) {
                    (data, response, error) -> Void in
                    if (error != nil) {
                        callback("", error.localizedDescription)
                    } else {
                        callback(NSString(data: data,
                            encoding: NSUTF8StringEncoding), nil)
                    }
            }
            task.resume()
    }
    
    class func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
        var e: NSError?
        var data: NSData = jsonString.dataUsingEncoding(
            NSUTF8StringEncoding)!
        var jsonObj = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(0),
            error: &e) as Dictionary<String, AnyObject>
        if (e != nil) {
            return Dictionary<String, AnyObject>()
        } else {
            return jsonObj
        }
    }
    
    class func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) as NSString? {
                    return string
                }
            }
        }
        return ""
    }
}