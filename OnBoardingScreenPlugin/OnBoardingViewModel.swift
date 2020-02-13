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
import ApplicasterSDK
import ZappPlugins

struct OnBoardingViewModel {
    let apiManager = OnBoardingManager.sharedInstance
    let isLoading = PublishSubject<Bool>()
    let shouldRefresh = PublishSubject<Bool>()
    let completedProcessingTags = PublishSubject<Bool>()
    let availableLanguages = Variable<[String]>([])
    let categories = Variable<[Category]>([])
    let categorySelectedIndex = Variable<Int>(0)
    let segmentsSelected = Variable<[Segment]>([])
    let segmentsToUnregister = Variable<[Segment]>([])
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
                //after we fetch the OBFF, check if user has persisted preference data and set it
                self.prefillPersistedUserSelection()
            } else {
                //if there is a problem with the JSON OnBoardingFeed, just proceed
                self.completedProcessingTags.on(.next(true))
            }
        }
    }
    
    func prefillPersistedUserSelection() {
        guard  let userRecommendationTags = APKeychain.object(forKey: "userRecommendationTags") as? [String] else { return }
        //we need to get the tags without the language code in the scenario that a user added tags to their preferences
        //then changed the language on the device and re-launched on-boarding
        var baseRecommendationTags: [String] = []
        for segmentId in userRecommendationTags {
            let splitSegmentId = segmentId.components(separatedBy: "-")
            if let baseSegmentId = splitSegmentId.first {
                baseRecommendationTags.append(baseSegmentId)
            }
        }
        
        var segmentsToPreselect: [Segment] = []
        
        for category in categories.value {
            guard let segments = category.segments else { return }
            for segment in segments {
                if let segmentId = segment.id, baseRecommendationTags.contains(segmentId) {
                    segmentsToPreselect.append(segment)
                }
            }
        }
        
        if segmentsToPreselect.count > 0 {
            segmentsSelected.value = segmentsToPreselect
            self.shouldRefresh.on(.next(true))
        }
    }
    
    func shouldHideCategoryCollection() -> Bool {
        return categories.value.count > 1 ? false : true
    }
    
    func addRemoveSegmentIdSelected(segment: Segment) {
        var currentSegmentsSelected = segmentsSelected.value
        var currentSegmentsToUnregister = segmentsToUnregister.value
        
        if let indexFound = currentSegmentsSelected.index(where: {$0.id == segment.id}) {
            currentSegmentsSelected.remove(at: indexFound)
            currentSegmentsToUnregister.append(segment)
            self.segmentsSelected.value = currentSegmentsSelected
            self.segmentsToUnregister.value = currentSegmentsToUnregister
        } else {
            removeSegmentIfReaddedToTags(segment)
            currentSegmentsSelected.append(segment)
            self.segmentsSelected.value = currentSegmentsSelected
        }
    }
    
    func removeSegmentIfReaddedToTags(_ segment: Segment) {
        var currentSegmentsToUnregister = segmentsToUnregister.value
        
        if let indexFound = currentSegmentsToUnregister.index(where: {$0.id == segment.id}) {
            currentSegmentsToUnregister.remove(at: indexFound)
            self.segmentsToUnregister.value = currentSegmentsToUnregister
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
        // Tags to ADD
        var tagsToAdd: [String] = []
        
        //we still set an empty userRecommendationTags array to prevent plugin from launching every time
        if (segmentsSelected.value.count == 0) && (segmentsToUnregister.value.count == 0) {
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
        
        // Tags to REMOVE
        if segmentsToUnregister.value.count != 0 {
            var tagsToRemove: [String] = []
            
            for segment in segmentsToUnregister.value {
                if let currentSegmentId = segment.id {
                    tagsToRemove.append("\(currentSegmentId)-\(languageCodeToUse())")
                }
            }
            removeTagsFromDevice(tagsToRemove: tagsToRemove)
        }
        
        //complete processing flag
        completedProcessingTags.on(.next(true))
    }
    
    func addTagsToKeychain(tagsToAdd: [String]) {
        APKeychain.setObject(tagsToAdd, forKey: "userRecommendationTags")
        let stringifiedTags = tagsToAdd.description
        //TODO: enable SessionStorage once re-factored SessionStorage is in stable SDK
        //let _ = SessionStorage.sharedInstance.set(key: "userRecommendationTags", value: stringifiedTags, namespace: "onboarding")
    }
    
    func addTagsToDevice(tagsToAdd: [String]) {
        let pushProviders = ZAAppConnector.sharedInstance().pluginsDelegate?.pushNotificationsPluginsManager?.getProviders()
        guard let pushProvider = pushProviders?.first,
            pushProvider.responds(to: #selector(ZPPushProviderProtocol.addTagsToDevice(_:completion:))) else {
                return
        }
        guard tagsToAdd.count > 0 else { return }
        
        //print("|||OB===>> addedTags: \(tagsToAdd)")
        pushProvider.addTagsToDevice?(tagsToAdd) { (success, tags) in
            if success {
                // keep going
            } else {
                // no need to do anything at this time, user will see the default content as if they had skipped onboarding
            }
        }
    }
    
    
    func removeTagsFromDevice(tagsToRemove: [String]) {
        let pushProviders = ZAAppConnector.sharedInstance().pluginsDelegate?.pushNotificationsPluginsManager?.getProviders()
        guard let pushProvider = pushProviders?.first,
            pushProvider.responds(to: #selector(ZPPushProviderProtocol.addTagsToDevice(_:completion:))) else {
                return
        }
        guard tagsToRemove.count > 0 else { return }
        
        //print("|||OB===>> removedTags: \(tagsToRemove)")
        pushProvider.removeTagsToDevice?(tagsToRemove) { (success, tags) in
            if success {
                // keep going
            } else {
                // no need to do anything at this time, user will see the default content as if they had skipped onboarding
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
