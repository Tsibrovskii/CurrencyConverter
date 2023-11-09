//
//  MockCurrencyService.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 05.11.2023.
//

import Foundation

final class OfflineCurrencyService: CurrencyServiceProtocol {
    
    private let deserializeHelper: DeserializeHelper

    init(deserializeHelper: DeserializeHelper) {
        self.deserializeHelper = deserializeHelper
    }

    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void) {
        print("getCurrencies mock")
        guard let contentPath = Bundle.main.url(forResource: "CurrenciesMock", withExtension: "json")
        else {
            completion(.failure(SerivceError.failureResult))
            return
        }
        
        guard let content = try? Data(contentsOf: contentPath)
        else {
            completion(.failure(SerivceError.failureResult))
            return
        }
        let symbols = self.deserializeHelper.deserializeData(dataRaw: content, type: CurrencyList.CurrencySymbolsList.self)
        var symbolsResult: CurrencyList.CurrencySymbolsList
        switch symbols {
        case .failure(let serviceError):
            DispatchQueue.main.async {
                completion(.failure(serviceError))
            }
            return
        case .success(let result):
            symbolsResult = result
        }
        let currencySymbolArray: [CurrencyList.CurrencySymbol] = symbolsResult.currencySymbols.map { (key, value) in
            return CurrencyList.CurrencySymbol(key: key, value: value)
        }
        DispatchQueue.main.async {
            completion(.success(currencySymbolArray))
        }
    }

    func getExchangeRates(baseCurrency: String, currencyList: [String], completion: @escaping (Result<[Exchange.ExchangeRate], SerivceError>) -> Void) {
        guard let contentPath = Bundle.main.url(forResource: "ExchangeRatesMock", withExtension: "json")
        else {
            completion(.failure(SerivceError.failureResult))
            return
        }
        
        guard let content = try? Data(contentsOf: contentPath)
        else {
            completion(.failure(SerivceError.failureResult))
            return
        }

        let rates = self.deserializeHelper.deserializeData(dataRaw: content, type: Exchange.ExchangeRatesList.self)
        var ratesResult: Exchange.ExchangeRatesList
        switch rates {
        case .failure(let serviceError):
            DispatchQueue.main.async {
                completion(.failure(serviceError))
            }
            return
        case .success(let result):
            ratesResult = result
        }
        if (!ratesResult.result) {
            DispatchQueue.main.async {
                completion(.failure(SerivceError.failureResult))
            }
            return
        }

        let currencySymbolArray: [Exchange.ExchangeRate] = ratesResult.exchangeRates.map { (key, value) in
            return Exchange.ExchangeRate(base: baseCurrency, currency: key, rate: value)
        }
        DispatchQueue.main.async {
            completion(.success(currencySymbolArray))
        }
    }
}
