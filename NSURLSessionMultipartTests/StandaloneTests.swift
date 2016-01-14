//
//  StandaloneTests.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 1/13/16.
//  Copyright © 2016 Robert Ryan. All rights reserved.
//

import XCTest
@testable import NSURLSessionMultipart

class StandaloneTests: XCTestCase {

    // MARK: Tests
    
    func testGoodMimeType() {
        let filename = "test.jpg"
        let mimetype = NSURLSession.mimeTypeForPath(filename)
        XCTAssert(mimetype == "image/jpeg", "Expected image/jpeg but got \(mimetype)")
    }
    
    func testUnknownMimeType() {
        let filename = "test.unknown"
        let mimetype = NSURLSession.mimeTypeForPath(filename)
        XCTAssert(mimetype == "application/octet-stream", "Expected application/octet-stream but got \(mimetype)")
    }
    
    func testFileNotFound() {
        let url = NSURL(string: "http://apple.com")!  // it doesn't matter what we use, as this request will not happen
        
        let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        let fileURL = documents.URLByAppendingPathComponent("nosuchfile.jpg")
        
        var badFileError: ErrorType?
        
        do {
            let _ = try NSURLSession.sharedSession().uploadMultipartTaskWithURL(url, parameters: nil, fileKeyName: "file", fileURLs: [fileURL]) { data, response, error in
                XCTFail("I should not have gotten here; request should have failed")
            }
        } catch {
            badFileError = error
        }
        
        XCTAssert(badFileError != nil, "Should have received error \(badFileError)")
    }
    

}
