//
//  DelegateSessionTests.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 1/13/16.
//  Copyright © 2016 Robert Ryan. All rights reserved.
//

import XCTest
@testable import NSURLSessionMultipart

class DelegateSessionTests: XCTestCase, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    // MARK: Properties
    
    let originalFilename = "apple.jpg"
    var fileURL: NSURL!
    let url = NSURL(string: "http://yourdomainhere.com/upload.php")!
    var session: NSURLSession!
    var expectation: XCTestExpectation!
    var responseData: NSMutableData?
    
    // MARK: Setup and tear down
    
    override func setUp() {
        super.setUp()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let bundleFileURL = NSBundle(forClass: DelegateSessionTests.self).URLForResource(originalFilename, withExtension: nil)!
        
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        fileURL = documents.URLByAppendingPathComponent(NSUUID().UUIDString + "." + bundleFileURL.pathExtension!)
        
        let _ = try? NSFileManager.defaultManager().copyItemAtURL(bundleFileURL, toURL: fileURL)
    }
    
    override func tearDown() {
        try! NSFileManager.defaultManager().removeItemAtURL(fileURL)
        responseData = nil
        expectation = nil
        session = nil
        fileURL = nil

        super.tearDown()
    }
    
    // MARK: Tests
    
    func testUploadSession() {
        expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let parameters = ["foo" : "bar"]
        
        let task = try! session.uploadMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL])
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testUploadSessionWithLocalFile() {
        expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let localFileURL = documents.URLByAppendingPathComponent(NSUUID().UUIDString + ".upload")
        
        let parameters = ["foo" : "bar"]
        
        let task = try! session.uploadMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL], localFileURL: localFileURL)
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testDataSession() {
        expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let parameters = ["foo" : "bar"]
        
        let task = try! session.dataMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL])
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    
    // MARK: NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        defer { expectation.fulfill() }  // regardless of what happens below, make sure to fulfill expectation
        
        guard responseData != nil && error == nil else {
            XCTFail("failed: \(error?.localizedDescription)")
            return
        }
        
        do {
            if let responseDictionary = try NSJSONSerialization.JSONObjectWithData(responseData!, options: []) as? [String: AnyObject] {
                if let success = responseDictionary["success"] as? Bool {
                    XCTAssert(success, "upload not successful")
                } else {
                    XCTFail("'success' not found in result")
                }
            }
        } catch {
            let responseString = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
            XCTFail("Expected JSON, but received: \(responseString)")
        }
    }

    // MARK: NSURLSessionDataTaskDelegate

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if responseData == nil {
            responseData = NSMutableData(data: data)
        } else {
            responseData?.appendData(data)
        }
    }
    
}
