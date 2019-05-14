//
//  Segment.swift
//  OnBoardingScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 4/4/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Segment: Comparable {
    var id: String?
    var title: [String: JSON]?
    var imageUrl: String?
    
    static func <(lhs: Segment, rhs: Segment) -> Bool {
        guard let lhsId = lhs.id, let rhsId = rhs.id else { return false }
        if lhsId < rhsId { return true }
        else { return false }
    }
    
    static func ==(lhs: Segment, rhs: Segment) -> Bool {
        if lhs.id == rhs.id { return true }
        else { return false }
    }
}
