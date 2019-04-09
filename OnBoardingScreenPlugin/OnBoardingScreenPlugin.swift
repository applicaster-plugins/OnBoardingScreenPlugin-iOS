//
//  OnBoardingScreenPlugin.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
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
        
        let styles: [String: AnyObject] = [PluginConfiguration.backgroundColor: backgroundColor as AnyObject,
                                           PluginConfiguration.highlightColor: highlightColor as AnyObject,
                                           PluginConfiguration.titleColor: titleColor as AnyObject,
                                           PluginConfiguration.categoryBackgroundColor: categoryBackgroundColor as AnyObject,
                                           PluginConfiguration.applyBorder: applyBorder as AnyObject]
        OnBoardingManager.sharedInstance.styles = styles
    }
    
    public required override init() {
        // Nothing to do here
    }
    
    @objc public func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?) {
        //if there is userRecommendationTags in KeyChain don't launch plugin at start-up
        if let _ = APKeychain.object(forKey: "userRecommendationTags") as? [String], let completion = completion {
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
        var topmostViewController = UIApplication.shared.windows.first?.rootViewController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            while topmostViewController?.presentedViewController != nil {
                topmostViewController = topmostViewController?.presentedViewController
            }
            
            if let vc = topmostViewController {
                vc.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: ZPAdapterProtocol
    public func handleUrlScheme(_ params:NSDictionary) {
        // xcrun simctl openurl booted "<urlScheme>://plugin?type=general&action=content_preferences"
        
        if let type = params["type"] as? String, type == "general", let action = params["action"] as? String, action == "content_preferences" {
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
