//
//  Item.swift
//  SoloBakeOS
//
//  Created by Glen Emmanuel Solo on 5/18/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
