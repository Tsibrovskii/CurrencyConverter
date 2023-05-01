//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

struct CurrencySymbolsList: Codable {
    var symbols: [String:String]
}


struct CurrencySymbol: Codable {
    var key: String
    var value: String
}

// Делаем структуру, которая хранит ключ(значение) символа и его описание
// Читаем про String, Struct, Value type.
// Читаем про Array, Dictionary.
// Читаем про Codable
