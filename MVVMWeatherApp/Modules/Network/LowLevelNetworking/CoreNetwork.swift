//
//  CoreNetwork.swift
//  ios-task
//
//  Created by Khalifa on 10/3/18.
//  Copyright © 2018 khalifa. All rights reserved.
//

import UIKit

class CoreNetwork {
    static var sharedInstance: CoreNetworkProtocol = CoreNetwork()
    fileprivate lazy var networkCommunication: NetworkingInterface! = {
        return DefaultNetworkAdapter.init(baseURL: HostService.getBaseURL(),headers: HostService.headers, extraParameters: HostService.extraParameters)
    }()
}

extension CoreNetwork: CoreNetworkProtocol {
    func makeRequest<T: Codable>(request: RequestSpecs<T>,
                                 completion: @escaping (T?, Error?) -> Void) {
        networkCommunication.request(request, completionBlock: completion)
    }
}

protocol CoreNetworkProtocol {
    func makeRequest<T: Codable>(request: RequestSpecs<T>,
                                 completion: @escaping (T?, Error?) -> Void)
}
