//
//  EnvironmentService.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 08.11.2023.
//

import Foundation

protocol EnvironmentServiceProtocol {
    
    var runEnvironment: String {get set}
    var isOfflineEnvironment: Bool {get set}
}

final class EnvironmentService: EnvironmentServiceProtocol {
    var runEnvironment: String {
        get {
            return (Bundle.main.infoDictionary?["App Name"] as? String)?
                .replacingOccurrences(of: "\\", with: "") ?? "Default"
        }
        set {}
    }
    var isOfflineEnvironment: Bool {
        get {
            return runEnvironment == "Offline"
        }
        set {}
    }
}
