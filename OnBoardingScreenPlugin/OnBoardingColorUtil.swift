//
//  OnBoardingColorUtil.swift
//  Alamofire
//
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

final class OnBoardingColorUtil {
    static func colorFromCMSString(_ colorString: String) -> UIColor {
        if colorString.count > 6 {
            return UIColor.init(argbHexString: colorString)
        } else {
            return UIColor.init(rgbHexString: colorString)
        }
    }
}
