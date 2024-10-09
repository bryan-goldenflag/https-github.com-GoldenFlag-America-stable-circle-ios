//
//  Item.swift
//  StableCircle
//
//  Created by Bryan McDowell on 9/28/24.
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
