//
//  MockCurrencyService.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 05.11.2023.
//

import Foundation

final class MockCurrencyService: CurrencyServiceProtocol {
    
    private let deserializeHelper: DeserializeHelper
    private let currenciesMock: CurrenciesMock

    init(deserializeHelper: DeserializeHelper, currenciesMock: CurrenciesMock) {
        self.deserializeHelper = deserializeHelper
        self.currenciesMock = currenciesMock
    }

    func getCurrencies(completion: @escaping (Result<[CurrencyList.CurrencySymbol], SerivceError>) -> Void) {
        print("getCurrencies mock")
        let symbols = self.deserializeHelper.deserializeData(dataRaw: currenciesMock.getCurrencies.data(using: .utf8), type: CurrencyList.CurrencySymbolsList.self)
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
        let rates = self.deserializeHelper.deserializeData(dataRaw: currenciesMock.getCurrenciesExchangeRates.data(using: .utf8), type: Exchange.ExchangeRatesList.self)
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
