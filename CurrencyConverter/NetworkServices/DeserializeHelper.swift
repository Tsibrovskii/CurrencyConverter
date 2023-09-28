//
//  DeserializeHelper.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 14/05/2023.
//

import Foundation

final class DeserializeHelper {

    func deserializeData<T: Decodable>(dataRaw: Data?, type: T.Type) -> Result<T, SerivceError> {
        guard let data = dataRaw else {
            return .failure(SerivceError.wrongData)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let symbols: T = try? decoder.decode(T.self, from: data) else {
            return .failure(SerivceError.wrongData)
        }

        return .success(symbols)
    }
}
