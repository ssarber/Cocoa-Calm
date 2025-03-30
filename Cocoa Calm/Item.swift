//
//  Item.swift
//  Cocoa Calm
//
//  Created by Stan Sarber on 3/30/25.
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
