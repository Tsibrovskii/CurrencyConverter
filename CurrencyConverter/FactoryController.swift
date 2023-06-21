//
//  FactoryController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 17/06/2023.
//

import Foundation

// TODO: нейминг !!! CurrenciesServiceFactory
class FactoryCurrenciesService {  // ???
    func createCurrenciesService() -> ServiceProtocol {
        return Service(
            currencyHelper: CurrencyHelper(),
            requestBuilder: RequestBuilder(),
            deserializeHelper: DeserializeHelper()
        )
    }
}
