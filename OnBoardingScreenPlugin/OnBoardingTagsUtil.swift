//
//  OnBoardingTagsUtil.swift
//  Alamofire
//
//  Copyright © 2020 Applicaster. All rights reserved.

import Foundation
import ZappPlugins

private struct Constants {
    static let tagsStorageKey = "OnBoardingTagsUtil.userRecommendationTags"
    static let tagsSeparator = "\n"
    static let tagsDomain = "OnBoardingTagsUtil"
    static let tagsSetFlag = "OnBoardingTagsUtil.tagsSetFlag"
}

final class OnBoardingTagsUtil {
    static func saveTags(_ tags: [String]?) {
        guard let tags = tags else { return }
        
        var joinedString = String()
        if let tag = tags.first {
            joinedString = tag
        }
        for tag in tags {
            joinedString += Constants.tagsSeparator + tag
        }
        
        storeTagsString(joinedString)
    }
    
    static func storedTags() -> [String]? {
        guard let serializedTags = tagsString() else { return nil }
        return serializedTags.components(separatedBy: Constants.tagsSeparator)
    }
    
    static func wipeTags() {
//TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
        guard APKeychain.object(forKey: Constants.tagsStorageKey) != nil else { return }
        APKeychain.removeValue(forKey: Constants.tagsStorageKey)
//        _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: Constants.tagsStorageKey,
//                                                                                    value: "",
//                                                                                    namespace: Constants.tagsDomain)
    }
    
    static func cleanRunCheck() {
//TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
        if UserDefaults.standard.object(forKey: Constants.tagsSetFlag) == nil {
//        if ZAAppConnector.sharedInstance().storageDelegate?.localStorageValue(for: Constants.tagsSetFlag,
//                                                                              namespace: Constants.tagsDomain) == nil {
            wipeTags()
        }
    }
    
    private static func storeTagsString(_ tags: String) {
//TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
        APKeychain.setObject(tags, forKey: Constants.tagsStorageKey)
        UserDefaults.standard.set(true, forKey: Constants.tagsSetFlag)
        
//        _ = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageSetValue(for: Constants.tagsStorageKey,
//                                                                                    value: tags,
//                                                                                    namespace: Constants.tagsDomain)
    }
    
    private static func tagsString() -> String? {
//TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
        guard let tags = APKeychain.object(forKey: Constants.tagsStorageKey) as? String else { return nil }
        
//        guard let tags = ZAAppConnector.sharedInstance().storageDelegate?.sessionStorageValue(for: Constants.tagsStorageKey,
//                                                                                              namespace: Constants.tagsDomain) else { return nil }
        
        return tags
    }
}
