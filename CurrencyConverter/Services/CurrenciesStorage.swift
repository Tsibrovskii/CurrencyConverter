//
//  CurrenciesStorage.swift
//  CurrencyConverter
//
//  Created by Dmitriy Mirovodin on 27.09.2023.
//

import Foundation

protocol CurrenciesStorageProtocol: AnyObject {
    var items: [CurrencyList.CurrencySymbol] { get set }
}

final class CurrenciesStorage: CurrenciesStorageProtocol {
    var items = [CurrencyList.CurrencySymbol]()
}
