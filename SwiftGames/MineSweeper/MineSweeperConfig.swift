//
//  MineSweeperConfig.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/11/11.
//

import UIKit

enum MineSweeperLevel: String {
    case base = "初级"
    case middle = "中级"
    case high = "高级"
}

struct MineSweeperConfig {
    var rows: Int = 12
    var cols: Int = 8
    var mines: Int = 10
    
    // base config
    init() { }
    init(rows r: Int, cols c: Int, mines m: Int) {
        rows = r
        cols = c
        mines = m
    }
    var normal: Int { return total - mines }
    var total: Int { return rows * cols }
}

extension MineSweeperConfig: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.cols == rhs.cols && lhs.rows == rhs.rows && lhs.mines == rhs.mines;
    }
}

struct MineSweeperConfigOptions {
    static func from(level: MineSweeperLevel) -> MineSweeperConfig {
        var config: MineSweeperConfig
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch level {
            case .base:
                config = MineSweeperConfig.init(rows: 12, cols: 8, mines: 10)
            case .middle:
                config = MineSweeperConfig.init(rows: 15, cols: 10, mines: 20)
            case .high:
                config = MineSweeperConfig.init(rows: 18, cols: 12, mines: 50)
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            switch level {
            case .base:
                config = MineSweeperConfig.init(rows: 16, cols: 15, mines: 15)
            case .middle:
                config = MineSweeperConfig.init(rows: 24, cols: 20, mines: 30)
            case .high:
                config = MineSweeperConfig.init(rows: 35, cols: 30, mines: 50)
            }
        } else {
            config = MineSweeperConfig.init(rows: 12, cols: 8, mines: 10)
        }
        return config
    }
}

