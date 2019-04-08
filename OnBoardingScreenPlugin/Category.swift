//
//  Category.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/3/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Category {
    var id: String?
    var title: [String: JSON]?
    var imageUrl: String?
    var segments: [Segment]?
    
    init(json: JSON) {
        if let value = json["id"].string {
            self.id = value
        }
        if let value = json["title"].dictionary {
            self.title = value
        }
        if let value = json["imageUrl"].string {
            self.imageUrl = value
        }
        if let segmentsArray = json["segments"].array {
            self.segments = segmentsArray.compactMap { (segmentJSON) in
                var segment = Segment()
                segment.id = segmentJSON["id"].string
                segment.title = segmentJSON["title"].dictionary
                segment.imageUrl = segmentJSON["imageUrl"].string
                
                return segment
            }
        }
    }
}
