//
//  InMemeoruService.swift
//  CurrencyConverter
//
//  Created by Dmitriy Mirovodin on 26.07.2023.
//

import Foundation


protocol AppSettingsProtocol {
    var currentSymbol: String { get set }
    var selectedCurrencies: Set<String> { get set }
    var value: Double? { get set }
    
    func reset()
}


final class AppSettings: AppSettingsProtocol {
    var currentSymbol: String
    
    var selectedCurrencies: Set<String>
    
    var value: Double?
    
    func reset() {
        <#code#>
    }
    
    
}

// singleton
class InmemeoryService {
    
    
    static let shared = InmemeoryService()
    
    func getCurrency(id: String) -> CurrencyList.CurrencySymbol
    func getCurrencies() -> [CurrencyList.CurrencySymbol]
    func update(list: [CurrencyList.CurrencySymbol])
    
    
    private var items: [CurrencyList.CurrencySymbol]
    
    private init() {
        
    }
}

let a = InmemeoryService()

let s = Service()
s.getCurrencies { <#Result<[CurrencyList.CurrencySymbol], SerivceError>#> in
    
    InmemeoryService.shared.update(list: )
    a.update()
}
