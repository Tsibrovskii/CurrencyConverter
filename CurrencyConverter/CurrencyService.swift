//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import Foundation

enum SerivceError: Error {
    case wrongUrl
    case wrongData
    case failureResult
}

protocol ServiceProtocol {
    func getCurrencies(completion: @escaping (Result<[CurrencySymbol], SerivceError>) -> Void)
}

class Service: ServiceProtocol {
    private let baseUrl = "https://api.apilayer.com"
    private let key = "AgyTVSI1YGWROrV03KcYUlhsT0GHPtNt"
    
    func getCurrencies(completion: @escaping (Result<[CurrencySymbol], SerivceError>) -> Void) {
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

            guard let symbols: CurrencySymbolsList = try? decoder.decode(CurrencySymbolsList.self, from: data) else {
                completion(.failure(SerivceError.wrongData))
                return
            }
            
            if (!symbols.result) {
                completion(.failure(SerivceError.failureResult))
                return
            }

            let currencySymbolArray: [CurrencySymbol] = symbols.currencySymbols.map { (key, value) in
                return CurrencySymbol(key: key, value: value)
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
