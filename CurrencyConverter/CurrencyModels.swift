//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

enum CurrencyList {
    struct CurrencySymbolsList: Decodable {
        var result: Bool
        var currencySymbols: [String: String]
        
        enum CodingKeys: String, CodingKey {
            case result = "success"
            case currencySymbols = "symbols"
        }
    }

    struct CurrencySymbol {
        var key: String
        var value: String
    }
}



enum Exchange {
    struct ExchangeRatesList: Decodable {
        var baseCurrency: String
        var exchangeRates: [String: Double]
        var result: Bool
        
        enum CodingKeys: String, CodingKey {
            case result = "success"
            case baseCurrency = "base"
            case exchangeRates = "rates"
        }
    }
    
    struct ExchangeRate {
        var base: String
        var currency: String
        var rate: Double
    }
}


// Делаем структуру, которая хранит ключ(значение) символа и его описание
// Читаем про String, Struct, Value type.
// Читаем про Array, Dictionary.
// Читаем про Codable
