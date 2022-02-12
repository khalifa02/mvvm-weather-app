//
//  NetworkInterface.swift
//  ios-task
//
//  Created by Khalifa on 10/3/18.
//  Copyright © 2018 khalifa. All rights reserved.
//

import UIKit

enum RequestMethod: String {
    case GET, POST, PUT, DELETE
}

enum Encoding {
    case urlEncodedInURL
    case json
}

struct RequestSpecs<ResponseType: Decodable> {
    let method: RequestMethod
    let urlString: String
    let parameters: [String: AnyObject]?
    let encoding: Encoding
    
    init(method: RequestMethod, urlString: String,
         parameters: [String: AnyObject]?, encoding: Encoding = .urlEncodedInURL) {
        self.method = method
        self.urlString = urlString
        self.parameters = parameters
        self.encoding = encoding
    }
}
protocol NetworkingInterface {
    func request<T: Decodable>(_ specs: RequestSpecs<T>,
                               completionBlock: @escaping (T?, Error?) -> Void)
}
