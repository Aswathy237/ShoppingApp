//
//  SSLBypassSessionDelegate.swift
//  Shopping App
//
//  Created by 61086256 on 06/04/25.
//

import Foundation

class SSLBypassSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Check if the server trust exists
        if let serverTrust = challenge.protectionSpace.serverTrust {
            // Accept the SSL certificate unconditionally
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil) // Reject if no trust exists
        }
    }
}

