//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by khalifa on 1/23/21.
//

import Foundation

protocol HomeViewModel: ObservableObject {
    var daysWeatherInfo: [DayWeatherInfo]? { get }
    var city: String? { get }
    var errorMessage: String? {get set}
    var showDateFromAPI: Bool {get set}
    var loading: Bool { get }
    func loadWeatherInfo()
    func getUpdatedData()
    func getStoredData()
}

class HomeViewModelImpl: HomeViewModel {
    var showDateFromAPI: Bool {
        didSet {
            if showDateFromAPI {
                getUpdatedData()
            } else {
                getStoredData()
            }
        }
    }
    @Published var city: String?
    @Published var errorMessage: String?
    @Published var loading: Bool = false
    @Published var daysWeatherInfo: [DayWeatherInfo]?    
    private var locationManager: LocationManager
    private var interactor: HomeInteractor?
    
    init(locationManager: LocationManager, interactor: HomeInteractor) {
        self.interactor = interactor
        self.locationManager = locationManager
        self.showDateFromAPI = true
    }
    
    func loadWeatherInfo() {
        locationManager.getUserLocation()
    }
    
    func getUpdatedData() {
        loadWeatherInfo()
    }
    
    func getStoredData() {
        loading = true
        interactor?.loadStoredWeatherInfo(completion: { [weak self] in
            guard let self = self else { return }
            self.loading = false
            if let storedValue = $0 {
                self.udpateInfo(result: storedValue)
            }
        })
    }
    
    private func udpateInfo(result: WeatherInfoResult) {
        guard let list = result.list else { return }
        var daysDictionary: [Int: DayWeatherInfo] =  [:]
        for item in list {
            guard let day = item.day, let date = item.date else { break }
            if daysDictionary[day] == nil {
                daysDictionary[day] = DayWeatherInfo(date: date, info: [])
            }
            daysDictionary[day]?.info.append(item)
        }
        daysWeatherInfo = daysDictionary.values.sorted(by: { return $0.date < $1.date })
    }
    
    private func loadWeatherInfo(lat: Double, long: Double) {
        guard !loading else { return }
        loading = true
        interactor?.loadWeatherInfo(lat: lat, lon: long, completion: { [weak self] (result, errorMessage) in
            guard let self = self else { return }
            self.loading = false
            if let result = result {
                self.udpateInfo(result: result)
            } else if let error = errorMessage {
                self.errorMessage = error
            }
        })
    }
}

extension HomeViewModelImpl: LocationManagerDelegate {
    func onLocationLoaded(lat: Double, long: Double) {
        locationManager.getCityName(lat: lat, long: long, completion: { self.city = $0 })
        loadWeatherInfo(lat: lat, long: long)
    }
    
    func onError(_ error: String) {
        self.errorMessage = error
    }
    
    func onPermissionNeeded() {
        locationManager.askUserForLocationPermission()
    }
    
    func onPermissionDenied() {
        self.errorMessage = "App Will Not be able To Retrive Weather Info unless you Allow it to get Your location, Please Allow The App to access your Location And Make sure Location service is Enabled"
    }
    
    func onPermissionGiven() {
        locationManager.getUserLocation()
    }
}


