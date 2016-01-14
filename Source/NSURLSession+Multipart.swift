//
//  NSURLSession+Multipart.swift
//  NSURLSessionMultipart
//
//  Created by Robert Ryan on 10/6/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

import Foundation
import MobileCoreServices

extension NSURLSession {

    /// Create multipart upload task.
    ///
    /// If using background session, you must supply a `localFileURL` with a `NSURL` where the
    /// body of the request should be saved.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter localFileURL:       The optional file `NSURL` where the body of the request should be stored. If using non-background session, pass `nil` for the `localFileURL`.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func uploadMultipartTaskWithURL(URL: NSURL, parameters: [String: AnyObject]?, fileKeyName: String, fileURLs: [NSURL], localFileURL: NSURL? = nil) throws -> NSURLSessionUploadTask {
        let (request, data) = try createMultipartRequestWithURL(URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        if let localFileURL = localFileURL {
            try data.writeToURL(localFileURL, options: .DataWritingAtomic)
            return uploadTaskWithRequest(request, fromFile: localFileURL)
        }
        
        return uploadTaskWithRequest(request, fromData: data)
    }
    
    /// Create multipart upload task.
    ///
    /// This should not be used with background sessions. Use the rendition without
    /// `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

    public func uploadMultipartTaskWithURL(URL: NSURL, parameters: [String: AnyObject]?, fileKeyName: String, fileURLs: [NSURL], completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) throws -> NSURLSessionUploadTask {
        let (request, data) = try createMultipartRequestWithURL(URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        return uploadTaskWithRequest(request, fromData: data, completionHandler: completionHandler)
    }
    
    /// Create multipart data task.
    ///
    /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
    /// `localFileURL` and without `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func dataMultipartTaskWithURL(URL: NSURL, parameters: [String: AnyObject]?, fileKeyName: String, fileURLs: [NSURL]) throws -> NSURLSessionDataTask {
        let (request, data) = try createMultipartRequestWithURL(URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        request.HTTPBody = data
        return dataTaskWithRequest(request)
    }
    
    /// Create multipart data task.
    ///
    /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
    /// `localFileURL` and without `completionHandler` if using background sessions.
    ///
    /// - parameter URL:                The `NSURL` for the web service.
    /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
    /// - parameter fileURLs:           An optional array of `NSURL` for local files to be included in `NSData`.
    /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
    ///
    /// - returns:                      The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func dataMultipartTaskWithURL(URL: NSURL, parameters: [String: AnyObject]?, fileKeyName: String, fileURLs: [NSURL], completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) throws -> NSURLSessionDataTask {
        let (request, data) = try createMultipartRequestWithURL(URL, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs)
        request.HTTPBody = data
        return dataTaskWithRequest(request, completionHandler: completionHandler)
    }
    
    /// Create upload request.
    ///
    /// With upload task, we return separate `NSURLRequest` and `NSData` to be passed to `uploadTaskWithRequest(fromData:)`.
    ///
    /// - parameter URL:          The `NSURL` for the web service.
    /// - parameter parameters:   The optional dictionary of parameters to be passed in the body of the request.
    /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
    /// - parameter fileURLs:     An optional array of `NSURL` for local files to be included in `NSData`.
    ///
    /// - returns:                The `NSURLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.
    
    public func createMultipartRequestWithURL(URL: NSURL, parameters: [String: AnyObject]?, fileKeyName: String, fileURLs: [NSURL]) throws -> (NSMutableURLRequest, NSData) {
        let boundary = NSURLSession.generateBoundaryString()
        
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let data = try createDataWithParameters(parameters, fileKeyName: fileKeyName, fileURLs: fileURLs, boundary: boundary)
        
        return (request, data)
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary of parameters to be included.
    /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
    /// - parameter boundary:     The multipart/form-data boundary.
    ///
    /// - returns:                The `NSData` of the body of the request. This throws error if there was problem opening file in the `fileURLs`.
    
    private func createDataWithParameters(parameters: [String: AnyObject]?, fileKeyName: String?, fileURLs: [NSURL]?, boundary: String) throws -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        if fileURLs != nil {
            for fileURL in fileURLs! {
                let filename = fileURL.lastPathComponent
                guard let data = NSData(contentsOfURL: fileURL) else {
                    throw NSError(domain: NSBundle.mainBundle().bundleIdentifier ?? "NSURLSession+Multipart", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to open \(fileURL.path)"])
                }
                
                let mimetype = NSURLSession.mimeTypeForPath(fileURL.path!)
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(fileKeyName!)\"; filename=\"\(filename!)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.appendData(data)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    private class func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    class func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    
}
