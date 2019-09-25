//
//  OnBoardingScreenPlugin.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import ApplicasterSDK
import ZappPlugins
import UIKit
import SwiftyJSON

@objc public class OnBoardingScreenPlugin: NSObject, ZPAppLoadingHookProtocol, ZPAdapterProtocol {
    // MARK: ZPAppLoadingHookProtocol
    public var configurationJSON: NSDictionary?
    public lazy var mainStoryboard: UIStoryboard = {
        return UIStoryboard(name: "OnBoardingViewControllers", bundle: Bundle(for: self.classForCoder))
    }()
    public struct PluginConfiguration {
        public static let onBoardingFeedPath = "onBoardingFeedPath"
        public static let backgroundColor = "backgroundColor"
        public static let highlightColor = "highlightColor"
        public static let titleColor = "titleColor"
        public static let categoryBackgroundColor = "categoryBackgroundColor"
        public static let applyBorder = "applyBorder"
        public static let numberOfColumns = "numberOfColumns"
    }
    
    public required convenience init(configurationJSON: NSDictionary?) {
        self.init()
        self.configurationJSON = configurationJSON
        OnBoardingManager.sharedInstance.basePathURL = configurationJSON?[PluginConfiguration.onBoardingFeedPath] as? String
        
        let backgroundColor = configurationJSON?[PluginConfiguration.backgroundColor] as? String ?? "#ffffff"
        let highlightColor = configurationJSON?[PluginConfiguration.highlightColor] as? String ?? "#00FA9A"
        let titleColor = configurationJSON?[PluginConfiguration.titleColor] as? String ?? "#000000"
        let categoryBackgroundColor = configurationJSON?[PluginConfiguration.categoryBackgroundColor] as? String ?? "#DCDCDC"
        let applyBorder = configurationJSON?[PluginConfiguration.applyBorder] as? Bool ?? false
        let numColumns = configurationJSON?[PluginConfiguration.numberOfColumns] as? String ?? "3"
        
        let styles: [String: AnyObject] = [PluginConfiguration.backgroundColor: backgroundColor as AnyObject,
                                           PluginConfiguration.highlightColor: highlightColor as AnyObject,
                                           PluginConfiguration.titleColor: titleColor as AnyObject,
                                           PluginConfiguration.categoryBackgroundColor: categoryBackgroundColor as AnyObject,
                                           PluginConfiguration.applyBorder: applyBorder as AnyObject,
                                           PluginConfiguration.numberOfColumns: numColumns as AnyObject]
        OnBoardingManager.sharedInstance.styles = styles
    }
    
    public required override init() {
        // Nothing to do here
    }
    
    @objc public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        //if there is userRecommendationTags in KeyChain don't launch plugin at start-up
        if let userRecommendationTags = APKeychain.object(forKey: "userRecommendationTags") as? [String], let completion = completion {
            //TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
            //let stringifiedTags = userRecommendationTags.description
            //let _ = SessionStorage.sharedInstance.set(key: "userRecommendationTags", value: stringifiedTags, namespace: "onboarding")
            completion()
        } else {
            presentOnBoardingScreen(completion: completion)
        }
    }
    
    func presentOnBoardingScreen(completion: (() -> Void)?) {
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "OnBoardingOneStepViewController") as! OnBoardingOneStepViewController
        OnBoardingManager.sharedInstance.onBoardingPluginCompletion = completion
        let viewModel = OnBoardingViewModel()
        viewController.viewModel = viewModel

        //present OnBoardingVC
        //delay needed because navigationDelegate is not always instantiated when launching onBoarding at app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            ZAAppConnector.sharedInstance().navigationDelegate.topmostModal().present(viewController, animated: true, completion: nil)
        }
    }
    
    // MARK: ZPAdapterProtocol
    public func handleUrlScheme(_ params:NSDictionary) {
        // xcrun simctl openurl booted "<urlScheme>://plugin?type=general&action=ob_preferences"
        
        if let type = params["type"] as? String, type == "general", let action = params["action"] as? String, action == "ob_preferences" {
            presentOnBoardingScreen(completion: nil)
        }
    }
    
    // MARK: -
    
    public func screenPluginWillAppear(viewController: UIViewController) {
        
    }
    
    public func screenPluginDidAppear(viewController: UIViewController) {
        
    }
    
    public func screenPluginWillDisappear(viewController: UIViewController) {
        
    }
    
    public func screenPluginDidDisappear(viewController: UIViewController) {
        
    }
}
