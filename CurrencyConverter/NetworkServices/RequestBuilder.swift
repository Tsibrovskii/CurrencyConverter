//
//  RequestBuilder.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 13/05/2023.
//

import Foundation

final class RequestBuilder {
    private var apiUrl: String?
    private var method: String?
    private var headers: [String: String]?
    private var params: [String: String]?

    func setEndPoint(baseUrl: String, endPoint: String) -> Self {
        apiUrl = baseUrl + endPoint
        return self
    }
    
    func setParams(params: [String :String]) -> Self {
        self.params = params
        return self
    }
    
    func setMethod(method: String) -> Self {
        self.method = method
        return self
    }
    
    func setHeaders(headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }
    
    func build() -> Result<URLRequest, SerivceError> {
        defer {
            clean()
        }
        guard let params = processParams().url else {
            return .failure(SerivceError.wrongParams)
        }

        guard let apiUrlRequest = apiUrl else {
            return .failure(SerivceError.wrongUrl)
        }
        
        guard let url = URL(string: apiUrlRequest + params.absoluteString) else {
            return .failure(SerivceError.wrongUrlWithParams)
        }

        guard method != "" else {
            return .failure(SerivceError.wrongMethod)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        
        guard let headersRequest = headers else {
            return .failure(SerivceError.wrongHeaders)
        }
        guard !headersRequest.isEmpty else {
            return .failure(SerivceError.wrongHeaders)
        }
        for header in headersRequest {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }

        return .success(request)
    }
    
    func processParams() -> URLComponents {
        var urlComponents = URLComponents()
        guard let urlParams = params else {
            return urlComponents
        }
            
        urlComponents.queryItems = []

        for param in urlParams {
            if (!param.key.isEmpty && !param.value.isEmpty) {
                urlComponents.queryItems?.append(URLQueryItem(name: param.key, value: param.value))
            }
        }
        
        return urlComponents
    }

    func clean() -> Void {
        apiUrl = nil
        method = nil
        headers = nil
        params = nil
    }
}
