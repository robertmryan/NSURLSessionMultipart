//
//  NSMutableURLRequest+Authentication.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 1/11/15.
//  Modified by Robert Ryan on 10/18/15 to support Swift 2.
//
//  Copyright (c) 2015 Robert Ryan. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    /// Update request for HTTP authentication
    /// 
    /// - parameter username:        The username
    /// - parameter password:        The password
    /// - parameter authentication:  The type of authentication to be applied
    
    public func updateBasicAuthForUser(username: String, password: String, authentication: String = kCFHTTPAuthenticationSchemeBasic as String) {
        let message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, HTTPMethod, URL!, kCFHTTPVersion1_1).takeRetainedValue()
        if !CFHTTPMessageAddAuthentication(message, nil, username, password, authentication, false) {
            print("authentication not added")
        }
        if let authorizationString = CFHTTPMessageCopyHeaderFieldValue(message, "Authorization")?.takeRetainedValue() {
            setValue(authorizationString as String, forHTTPHeaderField: "Authorization")
        } else {
            print("didn't find authentication header")
        }
    }
    
}
