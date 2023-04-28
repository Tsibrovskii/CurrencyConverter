//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

class Service {
    
    func getCurrencies(completion: @escaping (Result<[CurrencySymbol], Error>) -> Void) {
        
        completion(.success([]))
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
