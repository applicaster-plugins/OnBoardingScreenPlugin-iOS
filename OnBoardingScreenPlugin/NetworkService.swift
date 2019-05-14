//
//  NetworkService.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/4/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias networkServiceCompletionHandler = (_ success: Bool, _ json: JSON?) -> Void

struct NetworkService {
    static func makeRequest(_ request: NetworkURLRequestConvertible, completion: @escaping (networkServiceCompletionHandler)) {
        Alamofire.request(request).responseJSON { response in
            if let json = response.result.value {
                let jsonInfo = JSON(json)
                completion(true, jsonInfo)
            } else {
                completion(false, nil)
            }
        }
    }
}
