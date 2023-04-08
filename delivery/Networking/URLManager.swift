//
//  URLManager.swift
//  delivery
//
//  Created by mttm on 04.04.2023.
//

import Foundation

// MARK: API URL
class URLManager {
    
    let apiURL = "https://run.mocky.io/v3/e2cb1283-ce5c-462e-b4e2-7f6489777c27"

    static let shared = URLManager()
    private init() {}
}
