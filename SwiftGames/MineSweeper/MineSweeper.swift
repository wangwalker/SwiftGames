//
//  MineSweeper.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/10/27.
//

import UIKit

class MineSweeper: NSObject {
    var level: MineSweeperLevel
    private var mines: [MineItem] = []
    var state: MineResult = .next
    var config: MineSweeperConfig {
        MineSweeperConfigOptions.from(level: level)
    }

    init(level: MineSweeperLevel) {
        self.level = level
    }
    deinit {
        self.mines.removeAll()
    }
    
    /// public interface for launching games
    func play() {
        prepare()
        compute()
    }
    
    /// updates state of current mine item of cell at index
    func update(at index: Int, completion: (MineResult) -> Void) {
        let mine = mines[index]
        mine.tapped = true
        
        if mine.type == .mine {
            state = .failure
        } else {
            let (mineCount, normalCount) = check()
            if mineCount == config.mines && normalCount == config.normal {
                state = .success
            } else {
                state = .next
            }
        }
        completion(state)
    }
    
    /// transverse surrounded mines and corresponding cells at selected index, RECURSIVELY
    /// if it is normal item, and no mines at its surrounded at all, then show it
    func transverse(at index: Int, completion: (([Int]) -> Void)) {
        var adjacents: Queue<Int> = Queue()
        var finalIndexs: [Int] = []
        adjacents.enqueue(index)
        while adjacents.count > 0 {
            let index: Int = adjacents.dequeue()!
            adjacents.enqueue(adjacentSafes(at: index))
            finalIndexs.append(index)
        }
        completion(finalIndexs)
    }
    
    func item(at index: Int) -> MineItem? {
        if index < 0 || index > config.total {
            return nil
        }
        return mines[index]
    }
    
    func count() -> Int {
        return mines.count
    }
    
    func increaseSeconds() {
        seconds += 1
    }
    
    // 初始化所有地雷，以及类型信息，还有周围地雷数量
    private func prepare() {
        let mineIndexs = randomIndexs(count: config.mines, max: config.total)
        let mines: [MineItem] = MineGenerator.generate(config: config)

        for index in mineIndexs {
            mines[index].type = MineType.mine
        }
        self.mines = mines
    }
    
    // 计算每个坐标周围的地雷总数量，并赋值给响应坐标
    private func compute() {
        for index in 0..<config.total {
            self.mines[index].aroundMineCount = mineCount(at: index)
        }
    }
    
    /// adjacent mine items whoes `aroundMineCount` is equal to zero.
    private func adjacentSafes(at index: Int) -> [Int] {
        let adjacentIndexs: [Int] = adjacentIndexs(at: index)
        let items: [Int] = adjacentIndexs.map { mines[$0] }.filter { (item : MineItem) in
            let canFlip: Bool = item.canFlip()
            if canFlip {
                item.visited = true
                item.tapped = true
            }
           return canFlip
        }.map { (item: MineItem) in
            mines.firstIndex(of: item)!
        }
        return items
    }
    
    private func adjacentIndexs(at index: Int) -> [Int] {
        var indexs: [Int] = []
        let position: MinePosition = position(at: index)
        switch position {
        case .topLeftCorner:
            indexs = [1, config.cols]
        case .topRightCorner:
            indexs = [index-1, index+config.cols]
        case .bottomLeftCorner:
            indexs = [index-config.cols, index+1]
        case .bottomRightCorner:
            indexs = [index-config.cols, index-1]
        case .topEdge:
            indexs = [index-1, index+1, index+config.cols]
        case .leftEdge:
            indexs = [index-config.cols, index+1, index+config.cols]
        case .rightEdge:
            indexs = [index-config.cols, index-1, index+config.cols]
        case .bottomEdge:
            indexs = [index-config.cols, index-1, index+1]
        case .inside:
            indexs = [index-config.cols, index-1, index+1, index+config.cols]
        }
        
        return indexs
    }
    
    private func position(at index: Int) -> MinePosition {
        let xy = (index / config.cols, index % config.cols)
        var position: MinePosition
        switch xy {
        case (0, 0):
            position = .topLeftCorner
        case (0, config.cols-1):
            position = .topRightCorner
        case (config.rows-1, 0):
            position = .bottomLeftCorner
        case (config.rows-1, config.cols-1):
            position = .bottomRightCorner
        case (0, 1..<config.cols-1):
            position = .topEdge
        case (1..<config.rows-1, 0):
            position = .leftEdge
        case (1..<config.rows-1, config.cols-1):
            position = .rightEdge
        case (config.rows-1, 1..<config.cols-1):
            position = .bottomEdge
        default:
            position = .inside
        }
        return position
    }
    
    private func check() -> (Int, Int) {
        var mineCount: Int = 0
        var normalCount: Int = 0
        for mine in mines {
            if !mine.tapped && mine.type == .mine {
                mineCount += 1
            }
            if mine.tapped && mine.type == .normal {
                normalCount += 1
            }
        }
        return (mineCount, normalCount)
    }
    
    private func mineCount(at index: Int) -> Int {
        let cols: Int = config.cols
        let rows: Int = config.rows
        var count: Int = 0
        let position = position(at: index)
        
        switch position {
        case .topLeftCorner:
            count += mines[index+1].intValue()
            count += mines[index+cols].intValue()
            count += mines[index+cols+1].intValue()
        case .topRightCorner:
            count += mines[index-1].intValue()
            count += mines[index+rows].intValue()
            count += mines[index+rows-1].intValue()
        case .bottomLeftCorner:
            count += mines[index-cols].intValue()
            count += mines[index-cols+1].intValue()
            count += mines[index+1].intValue()
        case .bottomRightCorner:
            count += mines[index-1].intValue()
            count += mines[index-cols].intValue()
            count += mines[index-cols-1].intValue()
        case .topEdge:
            count += mines[index-1].intValue()
            count += mines[index+1].intValue()
            for i in -1...1 {
                count += mines[index+cols+i].intValue()
            }
        case .leftEdge:
            count += mines[index-cols].intValue()
            count += mines[index+cols].intValue()
            for i in -1...1 {
                count += mines[index+1+i*cols].intValue()
            }
        case .rightEdge:
            count += mines[index-cols].intValue()
            count += mines[index+cols].intValue()
            for i in -1...1 {
                count += mines[index-1+i*cols].intValue()
            }
        case .bottomEdge:
            count += mines[index-1].intValue()
            count += mines[index+1].intValue()
            for i in -1...1 {
                count += mines[index-cols+i].intValue()
            }
        case .inside:
            for i in -1...1 {
                for j in -1...1 {
                    if i != 0 || j != 0 {
                        count += mines[index+(i*cols)+j].intValue()
                    }
                }
            }
        }
        
        return count
    }
    
    var seconds: Int = 0
    var secondsSinceStart: String {
        return String(format: "⏰ %03d", seconds)
    }
    
}

extension MineSweeper {
    func randomIndexs(count: Int, max: Int) -> [Int] {
        var count = count
        var indexs: [Int] = []
        while count > 0 {
            let cur = (Int(arc4random()) % max)
            if indexs.firstIndex(of: cur) == nil {
                indexs.append(cur)
                count -= 1
            }
        }
        return indexs
    }
}
