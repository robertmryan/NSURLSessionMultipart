## NSURLSessionMultipart

### Introduction

`NSURLSessionMultipart` is a framework that extends `NSURLSession`, providing `multipart/form-data` support. It supports text parameters, as well as uploading files

### Example

The most common use of multipart requests is for file uploading. Let's imagine that you wanted to submit multipart request with a few text values, as well as upload an image to a web service that accepts `multipart/form-data` requests. You could:

    let documents = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
    let fileURL = documents.URLByAppendingPathComponent("image.png")

    let parameters = ["key1": "foo", "key2": "bar"]

    let task = try! session.uploadMultipartTaskWithURL(url, parameters: parameters, fileKeyName: "file", fileURLs: [fileURL]) { data, response, error in
        guard data != nil && error == nil else {
            print("failed: \(error?.localizedDescription)")
            return
        }

        // parse and process the response here; make sure the upload was successful
    }
    task.resume()

This framework also provides `dataMultipartTaskWithURL` rendition if you want to do `NSURLSessionDataTask`-based requests. It also supports the use of both completion handler renditions as well as delegate-based `NSURLSession` implementations.

For the sake of completeness, this project also includes sample PHP script that one might install on a web server, to process multipart requests for uploading files. This project doesn't actually use this script, but it's provided for illustrative purposes.

### Reference

As contemplated in [this Stack Overflow question](http://stackoverflow.com/a/26163136/1271826).

### License

The MIT License (MIT)

Copyright (c) 2016 Rob Ryan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

