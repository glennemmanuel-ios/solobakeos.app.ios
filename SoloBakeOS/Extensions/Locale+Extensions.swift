//
//  Locale+Extensions.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 6/4/26.
//

import Foundation

extension Locale {
    static var currencyCode: String {
        Locale.current.currency?.identifier ?? "PHP"
    }
}
