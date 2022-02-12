//
//  HomeInteractor.swift
//  WeatherApp
//
//  Created by khalifa on 1/23/21.
//

import Foundation

protocol HomeInteractor {
    func loadWeatherInfo(lat: Double, lon: Double, completion: @escaping (WeatherInfoResult?, String?) -> Void)
    func loadStoredWeatherInfo(completion: @escaping (WeatherInfoResult?) -> Void)
}

class HomeInteractorImpl: HomeInteractor {
    private static let weatherInfoUrl = "/forecast"
    private var coreNetwork: CoreNetworkProtocol
    
    init(coreNetwork: CoreNetworkProtocol) {
        self.coreNetwork = coreNetwork
    }
    
    func loadStoredWeatherInfo(completion: @escaping (WeatherInfoResult?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle(for: type(of: self)).url(forResource: "storedData", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let result = try? JSONDecoder().decode(WeatherInfoResult.self, from: data)
            DispatchQueue.main.async { completion(result) }
        }
    }
    
    func loadWeatherInfo(lat: Double, lon: Double, completion: @escaping (WeatherInfoResult?, String?) -> Void) {
        var parameters: [String: AnyObject] = [:]
        parameters["lat"] = lat as AnyObject
        parameters["lon"] = lon as AnyObject?
        let request = RequestSpecs<WeatherInfoResult>(method: .GET, urlString: Self.weatherInfoUrl, parameters: parameters)
        coreNetwork.makeRequest(request: request) { (result, error) in
            completion(result, error?.localizedDescription)
        }
    }
}
