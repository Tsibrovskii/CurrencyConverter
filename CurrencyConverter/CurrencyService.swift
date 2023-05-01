//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import Foundation

class Service {
    let url = URL(string: "https://api.apilayer.com/exchangerates_data/symbols")!
    let key = "AgyTVSI1YGWROrV03KcYUlhsT0GHPtNt"
    
    func getCurrencies(completion: @escaping (Result<[CurrencySymbol], Error>) -> Void) {
        var request = URLRequest(url: url);
        request.httpMethod = "GET";
        request.setValue(key, forHTTPHeaderField: "apikey")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let symbols: CurrencySymbolsList = try! decoder.decode(CurrencySymbolsList.self, from: data!)
            let currencySymbolArray: [CurrencySymbol] = symbols.symbols.map { (key, value) in
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
