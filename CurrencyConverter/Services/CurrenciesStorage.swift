//
//  CurrenciesStorage.swift
//  CurrencyConverter
//
//  Created by Dmitriy Mirovodin on 27.09.2023.
//

import Foundation

protocol CurrenciesStorageProtocol: AnyObject {
    var items: [CurrencyList.CurrencySymbol] { get set }
    
    func getSymbolName(by id: String) -> String?
}

final class CurrenciesStorage: CurrenciesStorageProtocol {
    
    static let shared = CurrenciesStorage()
    
    private var symbolsMap = [String: String]()
    private var internalItems = [CurrencyList.CurrencySymbol]()

    var items: [CurrencyList.CurrencySymbol] {
        get {
            internalItems
        }
        set {
            internalItems = newValue.sorted { $0.key > $1.key }
            
            symbolsMap.removeAll(keepingCapacity: true)
            newValue.forEach {
                symbolsMap[$0.key] = $0.value
            }
        }
    }
    
    func getSymbolName(by id: String) -> String? {
        return symbolsMap[id]
    }
}
