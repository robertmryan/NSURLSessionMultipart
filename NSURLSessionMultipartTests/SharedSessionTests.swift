//
//  SharedSessionTests.swift
//  NSURLSessionMultipartTests
//
//  Created by Robert Ryan on 1/13/16.
//  Copyright © 2016 Robert Ryan. All rights reserved.
//

import XCTest
@testable import NSURLSessionMultipart

class SharedSessionTests: XCTestCase {
    
    // MARK: Properties

    let originalFilename = "apple.jpg"
    var fileURL: NSURL!
    let url = NSURL(string: "http://yourdomainhere.com/upload.php")!
    var session: NSURLSession!
    let userid = "test"
    let password = "password"
    
    // MARK: Setup and tear down

    override func setUp() {
        super.setUp()
        
        session = NSURLSession.sharedSession()

        let bundleFileURL = NSBundle(forClass: SharedSessionTests.self).URLForResource(originalFilename, withExtension: nil)!

        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        fileURL = documents.URLByAppendingPathComponent(NSUUID().UUIDString + "." + bundleFileURL.pathExtension!)
        
        let _ = try? NSFileManager.defaultManager().copyItemAtURL(bundleFileURL, toURL: fileURL)
    }
    
    override func tearDown() {
        try! NSFileManager.defaultManager().removeItemAtURL(fileURL)
        session = nil
        fileURL = nil
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testUploadSession() {
        let expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let parameters = ["foo" : "bar"]
        
        let task = try! session.uploadMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL]) { data, response, error in
            defer { expectation.fulfill() }  // regardless of what happens below, make sure to fulfill expectation
            
            guard data != nil && error == nil else {
                XCTFail("failed: \(error?.localizedDescription)")
                return
            }
            
            do {
                if let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] {
                    if let success = responseDictionary["success"] as? Bool {
                        XCTAssert(success, "upload not successful")
                    } else {
                        XCTFail("'success' not found in result")
                    }
                }
            } catch {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                XCTFail("Expected JSON, but received: \(responseString)")
            }
        }
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testUploadSessionWithBasicAuthentication() {
        let expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let parameters = ["foo" : "bar"]
        
        let (request, data) = try! session.createMultipartRequestWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL])
        
        request.updateBasicAuthForUser(userid, password: password)
        
        let task = session.uploadTaskWithRequest(request, fromData: data) { data, response, error in
            defer { expectation.fulfill() }  // regardless of what happens below, make sure to fulfill expectation
            
            guard data != nil && error == nil else {
                XCTFail("failed: \(error?.localizedDescription)")
                return
            }
            
            do {
                if let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] {
                    if let success = responseDictionary["success"] as? Bool {
                        XCTAssert(success, "upload not successful")
                    } else {
                        XCTFail("'success' not found in result")
                    }
                }
            } catch {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                XCTFail("Expected JSON, but received: \(responseString)")
            }
        }
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
    func testDataSession() {
        let expectation = expectationWithDescription("\(__FUNCTION__)")
        
        let parameters = ["foo" : "bar"]
        
        let task = try! session.dataMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL]) { data, response, error in
            defer { expectation.fulfill() }  // regardless of what happens below, make sure to fulfill expectation
            
            guard data != nil && error == nil else {
                XCTFail("failed: \(error?.localizedDescription)")
                return
            }
            
            do {
                if let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] {
                    if let success = responseDictionary["success"] as? Bool {
                        XCTAssert(success, "upload not successful")
                    } else {
                        XCTFail("'success' not found in result")
                    }
                }
            } catch {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                XCTFail("Expected JSON, but received: \(responseString)")
            }
        }
        task.resume()
        
        waitForExpectationsWithTimeout(30, handler: nil)
    }
    
}
