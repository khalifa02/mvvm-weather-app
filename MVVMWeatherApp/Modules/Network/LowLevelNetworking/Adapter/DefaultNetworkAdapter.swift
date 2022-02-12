//
//  DefaultNetworkAdapter.swift
//  MVVMWeatherApp
//
//  Created by khalifa on 2/13/21.
//

import Foundation
import Combine

class DefaultNetworkAdapter: NetworkingInterface {
    private let requestBaseURL: String
    private let requestHeaders: [String: String]
    private let extraParameters: [String: AnyObject]?
    private var cancellable: Set<AnyCancellable> = []
    
    
    init(baseURL: String, headers: [String: String], extraParameters: [String: AnyObject]?) {
        self.requestBaseURL = baseURL
        self.requestHeaders = headers
        self.extraParameters = extraParameters
    }
    
    //works well for get requests only
    private func createRequest<T>(specs: RequestSpecs<T>) -> URLRequest {
        var components = URLComponents(string: self.requestBaseURL + specs.urlString)!
        components.queryItems = (specs.parameters?.map({ URLQueryItem(name: $0, value:  String(describing: $1))}) ?? []) + (extraParameters?.map({ URLQueryItem(name: $0, value:  String(describing: $1))}) ?? [])
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url:  components.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = getRequestMethod(method: specs.method)
        for header in requestHeaders { request.addValue(header.value, forHTTPHeaderField: header.key) }
        return request
    }
    
    func request<T>(_ specs: RequestSpecs<T>, completionBlock: @escaping (T?, Error?) -> Void) where T : Decodable {
        let request = createRequest(specs: specs)
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }.decode(type: T.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): completionBlock(nil, error)
                }
            }, receiveValue: { completionBlock($0, nil) })
            .store(in: &cancellable)
    }
    
    private func getRequestMethod(method: RequestMethod)-> String {
        switch method {
        case .GET: return "GET"
        case .POST: return "POST"
        case .DELETE: return "DELETE"
        case .PUT: return "PUT"
        }
    }
}
