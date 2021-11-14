//
//  MineItem.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/10/31.
//

import UIKit

enum MineType {
    case normal
    case mine
}

enum MineResult: String {
    case failure = "😫"
    case next = "😄"
    case success = "🏆"
}

enum MinePosition {
    case topLeftCorner
    case topRightCorner
    case bottomLeftCorner
    case bottomRightCorner
    case topEdge
    case leftEdge
    case rightEdge
    case bottomEdge
    case inside
}

class MineItem: NSObject {
    var tapped : Bool = false
    var visited: Bool = false
    var flagged: Bool = false
    var type: MineType = .normal
    var aroundMineCount: Int = 0
    
    init(type: MineType) {
        self.type = type
    }
    
    // check if in safe area and could continue play
    func couldPlay() -> Bool {
        self.tapped = true
        return aroundMineCount == 0 && type == .normal
    }
    
    func content() -> String {
        if !tapped {
            return ""
        }
        return type == .mine ? "💣" : aroundMineCount > 0 ? String(aroundMineCount) : ""
    }
}

extension MineItem {
    func intValue() -> Int {
        return type == .mine ? 1 : 0
    }
    func canFlip() -> Bool {
        type == .normal && aroundMineCount == 0 && !tapped && !visited
    }
}

class MineGenerator: NSObject {
    class func generate(config: MineSweeperConfig) -> [MineItem] {
        var mines: [MineItem] = []
        for _ in 1...config.total {
            mines.append(MineItem.init(type: .normal))
        }
        return mines
    }
}

struct Queue<Element> {
    private var items: [Element] = []
    
    mutating func enqueue(_ item: Element) {
        self.items.append(item)
    }
    
    mutating func enqueue(_ items: [Element]) {
        self.items.append(contentsOf: items)
    }
    
    mutating func dequeue() -> Element? {
        return items.isEmpty ? nil : items.removeFirst()
    }
    
}

extension Queue {
    var count: Int {
        items.count
    }
}
