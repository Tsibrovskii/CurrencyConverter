//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import Foundation

enum SerivceError: Error {
    case wrongUrl
    case wrongData
    case failureResult
    case wrongParams
    case wrongMethod
    case wrongHeaders
    case wrongUrlWithParams
}

protocol CurrencyServiceProtocol {
    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void)
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void)
}

final class CurrencyService: CurrencyServiceProtocol {
    
    private let apiEnpointHelper: ApiEndpointHelper
    private let requestBuilder: RequestBuilder
    private let deserializeHelper: DeserializeHelper
    
    init(apiEnpointHelper: ApiEndpointHelper, requestBuilder: RequestBuilder, deserializeHelper: DeserializeHelper) {
        self.apiEnpointHelper = apiEnpointHelper
        self.requestBuilder = requestBuilder
        self.deserializeHelper = deserializeHelper
    }

    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void) {
        
        let request = requestBuilder
            .setEndPoint(baseUrl: apiEnpointHelper.baseUrl, endPoint: apiEnpointHelper.currenciesUrl)
            .setMethod(method: ApiEndpointHelper.HTTPMethods.GET.rawValue)
            .setHeaders(headers: ["apikey": apiEnpointHelper.key])
            .build()
        
        var requestUrl: URLRequest
        switch request {
        case .failure(let serviceError):
            completion(.failure(serviceError))
            return
        case .success(let request):
            requestUrl = request
        }
        let env = (Bundle.main.infoDictionary?["App Name"] as? String)?
            .replacingOccurrences(of: "\\", with: "")
        if (env == "Test") {
            let currenciesMock = CurrenciesMock()
            let symbols = self.deserializeHelper.deserializeData(dataRaw: currenciesMock.getCurrencies.data(using: .utf8), type: CurrencyList.CurrencySymbolsList.self)
            var symbolsResult: CurrencyList.CurrencySymbolsList
            switch symbols {
            case .failure(let serviceError):
                DispatchQueue.main.async {
                    completion(.failure(serviceError))
                }
                return
            case .success(let result):
                symbolsResult = result
            }
            let currencySymbolArray: [CurrencyList.CurrencySymbol] = symbolsResult.currencySymbols.map { (key, value) in
                return CurrencyList.CurrencySymbol(key: key, value: value)
            }
            DispatchQueue.main.async {
                completion(.success(currencySymbolArray))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: requestUrl, completionHandler: { [weak self] data, response, error in
            guard let self = self else {
                return
            }
//            print("data \(String(data: data!, encoding: .utf8))")
            let symbols = self.deserializeHelper.deserializeData(dataRaw: data, type: CurrencyList.CurrencySymbolsList.self)
            var symbolsResult: CurrencyList.CurrencySymbolsList
            switch symbols {
            case .failure(let serviceError):
                DispatchQueue.main.async {
                    completion(.failure(serviceError))
                }
                return
            case .success(let result):
                symbolsResult = result
            }
            if (!symbolsResult.result) {
                DispatchQueue.main.async {
                    completion(.failure(SerivceError.failureResult))
                }
                return
            }

            let currencySymbolArray: [CurrencyList.CurrencySymbol] = symbolsResult.currencySymbols.map { (key, value) in
                return CurrencyList.CurrencySymbol(key: key, value: value)
            }
            DispatchQueue.main.async {
                completion(.success(currencySymbolArray))
            }
        })
        task.resume()
    }
    
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void) {
        
        let request = requestBuilder
            .setEndPoint(baseUrl: apiEnpointHelper.baseUrl, endPoint: apiEnpointHelper.exchangeData)
            .setMethod(method: ApiEndpointHelper.HTTPMethods.GET.rawValue)
            .setHeaders(headers: ["apikey": apiEnpointHelper.key])
            .setParams(params: ["base" :baseCurrency, "symbols" :currencyList.joined(separator: ",")])
            .build()
        
        var requestUrl: URLRequest
        switch request {
        case .failure(let serviceError):
            completion(.failure(serviceError))
            return
        case .success(let request):
            requestUrl = request
        }

        let env = (Bundle.main.infoDictionary?["App Name"] as? String)?
            .replacingOccurrences(of: "\\", with: "")
        if (env == "Test") {
            let currenciesMock = CurrenciesMock()
            let rates = self.deserializeHelper.deserializeData(dataRaw: currenciesMock.getCurrenciesExchangeRates.data(using: .utf8), type: Exchange.ExchangeRatesList.self)
            var ratesResult: Exchange.ExchangeRatesList
            switch rates {
            case .failure(let serviceError):
                DispatchQueue.main.async {
                    completion(.failure(serviceError))
                }
                return
            case .success(let result):
                ratesResult = result
            }
            if (!ratesResult.result) {
                DispatchQueue.main.async {
                    completion(.failure(SerivceError.failureResult))
                }
                return
            }

            let currencySymbolArray: [Exchange.ExchangeRate] = ratesResult.exchangeRates.map { (key, value) in
                return Exchange.ExchangeRate(base: baseCurrency, currency: key, rate: value)
            }
            DispatchQueue.main.async {
                completion(.success(currencySymbolArray))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: requestUrl, completionHandler: { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            let rates = self.deserializeHelper.deserializeData(dataRaw: data, type: Exchange.ExchangeRatesList.self)
            var ratesResult: Exchange.ExchangeRatesList
            switch rates {
            case .failure(let serviceError):
                DispatchQueue.main.async {
                    completion(.failure(serviceError))
                }
                return
            case .success(let result):
                ratesResult = result
            }
            if (!ratesResult.result) {
                DispatchQueue.main.async {
                    completion(.failure(SerivceError.failureResult))
                }
                return
            }

            let currencySymbolArray: [Exchange.ExchangeRate] = ratesResult.exchangeRates.map { (key, value) in
                return Exchange.ExchangeRate(base: baseCurrency, currency: key, rate: value)
            }
            DispatchQueue.main.async {
                completion(.success(currencySymbolArray))
            }
        })
        task.resume()
    }
}
