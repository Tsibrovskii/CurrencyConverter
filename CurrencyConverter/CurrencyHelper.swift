//
//  CurrencyHelper.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 13/05/2023.
//

import Foundation

final class CurrencyHelper {
    let baseUrl = "https://api.apilayer.com"
    let currenciesUrl = "/exchangerates_data/symbols"
    let exchangeData = "/exchangerates_data/latest"
    let key = "AgyTVSI1YGWROrV03KcYUlhsT0GHPtNt"
    
    enum HTTPMethods: String {
        case GET = "GET"
    }
}
