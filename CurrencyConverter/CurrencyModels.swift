//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

struct CurrencySymbolsList: Decodable {
    var result: Bool
    var currencySymbols: [String: String]
}

extension CurrencySymbolsList {
    enum CodingKeys: String, CodingKey {
        case result = "success"
        case currencySymbols = "symbols"
    }
}


struct CurrencySymbol {
    var key: String
    var value: String
}

// Делаем структуру, которая хранит ключ(значение) символа и его описание
// Читаем про String, Struct, Value type.
// Читаем про Array, Dictionary.
// Читаем про Codable
