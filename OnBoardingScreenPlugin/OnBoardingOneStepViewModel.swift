//
//  OnBoardingOneStepViewModel.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import ZappPlugins
import ZappPushPluginsSDK

struct OnBoardingOneStepViewModel {
    let apiManager = OnBoardingManager.sharedInstance
    let isLoading = PublishSubject<Bool>()
    let completedProcessingTags = PublishSubject<Bool>()
    let availableLanguages = Variable<[String]>([])
    let categories = Variable<[Category]>([])
    let categorySelectedIndex = Variable<Int>(0)
    let segmentsSelected = Variable<[Segment]>([])
    let onboardingTexts = Variable<[String:JSON]>([:])
    
    func fetch() {
        self.isLoading.on(.next(true))
        
        apiManager.fetchOnBoardingFeed { (success, json) in
            self.isLoading.on(.next(false))
            
            if let json = json {
                if let languagesAvailableArray = json["languages"].array {
                    self.availableLanguages.value = languagesAvailableArray.compactMap{ (languageJSON) in
                        let currentLanguage = languageJSON.string
                        return currentLanguage
                    }
                }
                
                if let onboardingTexts = json["onboardingTexts"].dictionary {
                    self.onboardingTexts.value = onboardingTexts
                }
                
                if let categoriesArray = json["categories"].array {
                    self.categories.value = categoriesArray.compactMap { (categoryJSON) in
                        let category = Category(json: categoryJSON)
                        return category
                    }
                }
            }
        }
    }
    
    func shouldHideCategoryCollection() -> Bool {
        return categories.value.count > 1 ? false : true
    }
    
    func addRemoveSegmentIdSelected(segment: Segment) {
        var currentSegmentsSelected = segmentsSelected.value
        
        if let indexFound = currentSegmentsSelected.index(where: {$0.id == segment.id}) {
            currentSegmentsSelected.remove(at: indexFound)
            self.segmentsSelected.value = currentSegmentsSelected
        } else {
            currentSegmentsSelected.append(segment)
            self.segmentsSelected.value = currentSegmentsSelected
        }
    }
    
    func segmentIsCurrentlySelected(segment: Segment?) -> Bool {
        guard let segment = segment else { return false }
        var currentlySelected: Bool = false
        let currentSegmentsSelected = segmentsSelected.value
        
        if let _ = currentSegmentsSelected.index(where: {$0.id == segment.id}) {
           currentlySelected = true
        }
        return currentlySelected
    }
    
    func processSelectedTags() {
        var tagsToAdd: [String] = []
        
        //we still set an empty userRecommendationTags array to prevent plugin from launching every time
        if segmentsSelected.value.count == 0 {
            addTagsToKeychain(tagsToAdd: tagsToAdd)
            completedProcessingTags.on(.next(true))
            return
        }
        
        for segment in segmentsSelected.value {
            if let currentSegmentId = segment.id {
                tagsToAdd.append("\(currentSegmentId)-\(languageCodeToUse())")
            }
        }
        addTagsToKeychain(tagsToAdd: tagsToAdd)
        addTagsToDevice(tagsToAdd: tagsToAdd)
        completedProcessingTags.on(.next(true))
    }
    
    func addTagsToKeychain(tagsToAdd: [String]) {
        APKeychain.setObject(tagsToAdd, forKey: "userRecommendationTags")
    }
    
    func addTagsToDevice(tagsToAdd: [String]) {
        let pushProviders = ZPPushNotificationManager.sharedInstance.getProviders()
        guard let pushProvider = pushProviders.first,
            pushProvider.responds(to: #selector(ZPPushProviderProtocol.addTagsToDevice(_:completion:))) else {
                return
        }
        
        pushProvider.addTagsToDevice?(tagsToAdd) { (success, tags) in
            if success {
                print("just keep execution")
            } else {
                print("Error - addTagsToDevice")
            }
        }
    }
    
    func languageCodeToUse() -> String {
        guard let fallbackLanguageCode = availableLanguages.value.first else { return "" }
        
        if let userLanguageCode = OnBoardingManager.sharedInstance.userLocale {
            if let index = availableLanguages.value.index(of: userLanguageCode) {
                return availableLanguages.value[safe: index] ?? fallbackLanguageCode
            } else {
                return fallbackLanguageCode
            }
        }
        return fallbackLanguageCode
    }
}
