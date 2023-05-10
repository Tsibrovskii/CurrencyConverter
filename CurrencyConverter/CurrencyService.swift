//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import Foundation

enum SerivceError: Error {
    case wrongUrl
    case wrongData
    case failureResult
    case wrongParams
}

protocol ServiceProtocol {
    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void)
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void)
}

class Service: ServiceProtocol {
    private let baseUrl = "https://api.apilayer.com"
    private let key = "AgyTVSI1YGWROrV03KcYUlhsT0GHPtNt"
    
    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void) {
        let apiUrl = baseUrl + "/exchangerates_data/symbols"
        
        guard let url = URL(string: apiUrl) else {
            completion(.failure(SerivceError.wrongUrl))
            return
        }

        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue(key, forHTTPHeaderField: "apikey")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let data = data else {
                completion(.failure(SerivceError.wrongData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let symbols: CurrencyList.CurrencySymbolsList = try? decoder.decode(CurrencyList.CurrencySymbolsList.self, from: data) else {
                completion(.failure(SerivceError.wrongData))
                return
            }
            
            if (!symbols.result) {
                completion(.failure(SerivceError.failureResult))
                return
            }

            let currencySymbolArray: [CurrencyList.CurrencySymbol] = symbols.currencySymbols.map { (key, value) in
                return CurrencyList.CurrencySymbol(key: key, value: value)
            }
            completion(.success(currencySymbolArray))
        })
        task.resume()
    }
    
    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void) {
        
        var urlComponents = URLComponents()
        urlComponents.queryItems = [URLQueryItem(name: "base", value: baseCurrency)]
        
        if (!currencyList.isEmpty) {
            urlComponents.queryItems?.append(URLQueryItem(name: "symbols", value: currencyList.joined(separator: ",")))
        }
        
        guard let params = urlComponents.url else {
            completion(.failure(SerivceError.wrongParams))
            return
        }

        let apiUrl = baseUrl + "/exchangerates_data/latest" + params.absoluteString
        
        guard let url = URL(string: apiUrl) else {
            completion(.failure(SerivceError.wrongUrl))
            return
        }
        
        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue(key, forHTTPHeaderField: "apikey")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let data = data else {
                completion(.failure(SerivceError.wrongData))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let exchangeRates: Exchange.ExchangeRatesList = try? decoder.decode(Exchange.ExchangeRatesList.self, from: data) else {
                completion(.failure(SerivceError.wrongData))
                return
            }

            if (!exchangeRates.result) {
                completion(.failure(SerivceError.failureResult))
                return
            }

            let currencySymbolArray: [Exchange.ExchangeRate] = exchangeRates.exchangeRates.map { (key, value) in
                return Exchange.ExchangeRate(base: baseCurrency, currency: key, rate: value)
            }
            completion(.success(currencySymbolArray))
        })
        task.resume()
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
