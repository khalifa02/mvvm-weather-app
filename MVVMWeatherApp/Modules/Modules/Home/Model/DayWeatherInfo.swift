//
//  DayWeatherInfo.swift
//  MVVMWeatherApp
//
//  Created by khalifa on 2/13/21.
//

import Foundation

struct DayWeatherInfo: Identifiable, Equatable {
    static func == (lhs: DayWeatherInfo, rhs: DayWeatherInfo) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Date {
        return date
    }
    var date: Date
    var formatedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    var info: [WeatherInfoModel]
}
