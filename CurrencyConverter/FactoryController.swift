//
//  FactoryController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 17/06/2023.
//

import Foundation

class FactoryController {
    func getCurrenciesService() -> ServiceProtocol {
        return Service(
            currencyHelper: CurrencyHelper(),
            requestBuilder: RequestBuilder(),
            deserializeHelper: DeserializeHelper()
        )
    }
}
