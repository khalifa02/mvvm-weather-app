//
//  WeatherInfoModel.swift
//  WeatherApp
//
//  Created by khalifa on 1/23/21.
//

import Foundation

// MARK: - WeatherInfoResult
struct WeatherInfoResult: Codable {
    let list: [WeatherInfoModel]?
}

// MARK: - WeatherInfoModel
struct WeatherInfoModel: Codable, Identifiable, Equatable {
    static func == (lhs: WeatherInfoModel, rhs: WeatherInfoModel) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int {
        return dt ?? 0
    }
    private static let dateFormat = ""
    let dt: Int?
    let main: MainInfo?
    let weather: [Weather]?
    let visibility: Int?
    let dtTxt: String?
    var time: String {
        guard let date = date else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    var date: Date? {
        return Date(timeIntervalSince1970: Double(dt ?? 0))
    }
    var day: Int? {
        guard let date = date else { return nil }
        return Calendar.current.dateComponents([.day], from: (date)).day
    }
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, visibility
        case dtTxt
    }
}

// MARK: - MainInfo
struct MainInfo: Codable {
    var temp: Double?
    let feelsLike, tempMin, tempMax: Double?
    let pressure, seaLevel, grndLevel, humidity: Int?
    let tempKf: Double?
    var tepreatureDescription: String {
        if let temperature = temp {
            let mf = MeasurementFormatter()
            mf.numberFormatter.maximumFractionDigits = 0
            mf.unitOptions = .providedUnit
            var ms = Measurement(value: temperature, unit: UnitTemperature.kelvin)
            ms.convert(to: .celsius)
            return mf.string(from: ms)
        } else {
            return ""
        }
    }

    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int?
    var iconUrl: String? {
        guard let icon = icon else { return "" }
        return "https://openweathermap.org/img/w/\(icon).png"
    }
    let weatherDescription, icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription
        case icon
    }
}
