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

protocol ServiceProtocol {
    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void)
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void)
}

class Service: ServiceProtocol {
    
    private let currencyHelper: CurrencyHelper
    private let requestBuilder: RequestBuilder
    private let deserializeHelper: DeserializeHelper
    
    init() {
        self.currencyHelper = CurrencyHelper()
        self.requestBuilder = RequestBuilder()
        self.deserializeHelper = DeserializeHelper()
    }
    
    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void) {
        
        let request = requestBuilder
            .setEndPoint(baseUrl: currencyHelper.baseUrl, endPoint: currencyHelper.currenciesUrl)
            .setMethod(method: CurrencyHelper.HTTPMethods.GET.rawValue)
            .setHeaders(headers: ["apikey": currencyHelper.key])
            .build()
        
        var requestUrl: URLRequest
        switch request {
        case .failure(let serviceError):
            completion(.failure(serviceError))
            return
        case .success(let request):
            requestUrl = request
        }
        
        DispatchQueue.global(qos: .utility).async {
            let task = URLSession.shared.dataTask(with: requestUrl, completionHandler: { data, response, error in
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
    }
    
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void) {
        
        let request = requestBuilder
            .setEndPoint(baseUrl: currencyHelper.baseUrl, endPoint: currencyHelper.exchangeData)
            .setMethod(method: CurrencyHelper.HTTPMethods.GET.rawValue)
            .setHeaders(headers: ["apikey": currencyHelper.key])
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
        
        DispatchQueue.global(qos: .utility).async {
            let task = URLSession.shared.dataTask(with: requestUrl, completionHandler: { data, response, error in
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
}

// Регаемся на https://apilayer.com
// Подключаем Currency Data API
//
// Получаем доступк к api, там 100 вызовов бесплатные
//
// Читаем про URLSession, URLRequest
// Читаем про синхронные и асинхронные методы (без async/await)


// Делаем сервис, которые возвращает список валют.
