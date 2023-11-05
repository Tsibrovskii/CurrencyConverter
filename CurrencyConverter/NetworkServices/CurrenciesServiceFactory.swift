//
//  FactoryController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 17/06/2023.
//

final class CurrenciesServiceFactory {
    func create() -> CurrencyServiceProtocol {
        if (SchemeService().getEnvironment() == "Default") {
            return CurrencyService(
                apiEnpointHelper: ApiEndpointHelper(),
                requestBuilder: RequestBuilder(),
                deserializeHelper: DeserializeHelper()
            )
        } else {
            return MockCurrencyService(
                deserializeHelper: DeserializeHelper(),
                currenciesMock: CurrenciesMock()
            )
        }
    }
}
