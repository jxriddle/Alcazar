//
//  LiveDirectory.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/9/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

/*
extension AppHttpClient: URLSessionDownloadDelegate
{
    @available(OSX 10.9, *)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading.")
    }
    
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        print("Finished downloading.")
    }
} */

class AppHttpClient: NSObject, URLSessionDelegate
{
    /*
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }() */
    
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
    //lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.ephemeral
    lazy var fetchSession: URLSession = URLSession(configuration: self.configuration)
    
    //typealias DataHandler = (Data) -> Void
    /*
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        print("Finished downloading.")
    } */
    /*
    func StartDownload(url: String)
    {
        let download = Download(url: url)
        let urlres = URL(string: url)
        download.downloadTask = self.downloadsSession.downloadTask(with: urlres)
        download.downloadTask!.resume()
        download.isDownloading = true
    } */
    
    func FetchAsync(url: String, additionalHeaders: [String: String], completion: @escaping (Data) -> Void)
    {
        let urlRes = URL(string: url)!
        var request = URLRequest(url: urlRes)
        //request.timeoutInterval = 60
        
        // Apply Headers
        for additionalHeader in additionalHeaders {
            request.addValue(additionalHeader.value, forHTTPHeaderField: additionalHeader.key)
        }
        
        let dataTask = fetchSession.dataTask(with: request) { (data, response, error) in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse)
                    print("Data size: \(data!.count)")
                    
                    switch (httpResponse.statusCode) {
                    case 200:
                        if let fetchedData = data {
                            completion(fetchedData)
                        }
                        break
                    default:
                        print(httpResponse.statusCode)
                        break
                    }
                }
            }
            else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
        
        dataTask.resume()
    }
}
