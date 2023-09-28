//
//  FactoryController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 17/06/2023.
//

final class CurrenciesServiceFactory {
    func create() -> CurrencyServiceProtocol {
        CurrencyService(
            apiEnpointHelper: ApiEndpointHelper(),
            requestBuilder: RequestBuilder(),
            deserializeHelper: DeserializeHelper()
        )
    }
}
