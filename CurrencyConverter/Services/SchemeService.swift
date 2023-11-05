//
//  SchemeService.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 05.11.2023.
//

import Foundation

protocol SchemeServiceProtocol {
    func getEnvironment() -> String
}

final class SchemeService: SchemeServiceProtocol {
    func getEnvironment() -> String {
        return (Bundle.main.infoDictionary?["App Name"] as? String)?
            .replacingOccurrences(of: "\\", with: "") ?? "Default"
    }
}
