//
//  OnBoardingManager.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/4/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias OnBoardingAPICompletionHandler = (_ success: Bool, _ json: JSON?) -> Void

class OnBoardingManager: NSObject {
    static let sharedInstance = OnBoardingManager()
    public let userLocale: String? = NSLocale.current.languageCode
    public var basePathURL: String?
    public var styles: [String: AnyObject]?
    public var onBoardingPluginCompletion: (() -> Void)?
    
    func fetchOnBoardingFeed(completion: @escaping (OnBoardingAPICompletionHandler)) {
        NetworkService.makeRequest(.onBoardingFeed(path: "\(basePathURL ?? "")")) { (success, json) in
            completion(success, json)
        }
    }
}

