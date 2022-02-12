//
//  APIServiceSettings.swift
//  ios-task
//
//  Created by Khalifa on 10/3/18.
//  Copyright © 2018 khalifa. All rights reserved.
//

import UIKit

struct HostService {
    static func getBaseURL() -> String {
        return "https://api.openweathermap.org/data/2.5"
    }
    static var headers: [String: String] { [:] }
    static var extraParameters: [String: AnyObject] {
        ["appid": "6d5ba33de5361a51781d1bebc4d0ca19" as AnyObject]
    }
}
