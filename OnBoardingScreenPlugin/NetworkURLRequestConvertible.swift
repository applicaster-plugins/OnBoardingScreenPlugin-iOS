//
//  NetworkURLRequestConvertible.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/4/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkURLRequestConvertible: URLRequestConvertible {
    case onBoardingFeed(path: String)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .onBoardingFeed(let path):
            return "\(path)"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url: URL = URL(string: "\(path)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        //Set-up parameters in the future if needed
        switch self {
        default:
            break
        }
        
        //Add necessary Header values
        switch self {
        default:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        print("Making Request: \(urlRequest)")
        return urlRequest
    }
}

