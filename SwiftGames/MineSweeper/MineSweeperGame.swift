//
//  MineSweeperView.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/11/13.
//

import UIKit

/**
 * components：
 * - MineItem: pure data model
 * - MineSweeperCell: subclass of UICollectionViewCell, show information for corresponding item.
 * - MineSweeperConfig: configuration for game, such as how much mines and size of background grids.
 * - MineSweeperPanel: showing basic information, current state of game.
 * - MineSweeper: collective model for organizing all corresponding data.
 * - MineSweeperGame: game controller to all components.
 */

class MineSweeperGame: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: MineSweeperDelegate?
    
    override init(frame: CGRect) {
        self.topPanel = MineSweeperPanel.init(frame: .zero)
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder: NSCoder) {
        self.topPanel = MineSweeperPanel.init(frame: .zero)
        super.init(coder: coder)
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topPanel.frame = CGRect.init(x: margin, y: 0, width: bounds.width - 2*margin, height: 96.0)
        collectionView.frame = CGRect(x: margin, y: topPanel.frame.maxY, width: bounds.width - 2*margin, height: bounds.height - 96.0)
    }
    
    func setup() {
        addSubview(topPanel)
        addSubview(collectionView)
        mineSweeper.play()
        topPanel.reset(mines: mineSweeper.config.mines)
        monitor()
    }
    func update(level: MineSweeperLevel) {
        mineSweeper.level = level
        mineSweeper.seconds = 0
        mineSweeper.play()
        collectionView.reloadData()
        collectionView.setCollectionViewLayout(layout(config: mineSweeper.config), animated: false)
        topPanel.reset(mines: mineSweeper.config.mines)
        monitor()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mineSweeper.count()
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MineSweeperCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MineSweeperCell
        let item = mineSweeper.item(at: indexPath.row)
        cell.update(with: item!)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mine: MineItem = mineSweeper.item(at: indexPath.row)!
        let cell: MineSweeperCell = collectionView.cellForItem(at: indexPath) as! MineSweeperCell
        
        if mine.tapped { return }
        
        /// if cell is flagged with 🚩
        if topPanel.flagged {
            mine.flagged = !mine.flagged
            cell.update(with: mine, flagged: true)
            topPanel.flagged = false
            return
        }
        
        /// check and update cells
        at(current: indexPath.row, cell: cell, mine: mine)
        at(adjacents: indexPath.row, mine: mine)
    }
    private func monitor() {
        if let t = timer {
            t.fireDate = .distantPast
        } else {
            timer = Timer.init(timeInterval: 1, repeats: true, block: { _ in
                self.mineSweeper.increaseSeconds()
                self.topPanel.update(mineSwpeeper: self.mineSweeper)
            })
            RunLoop.current.add(timer!, forMode: .default)
        }
        
    }
    private func stopMonitor() {
        timer?.fireDate = .distantFuture
    }
    /// check and update current selected mine item and cell
    private func at(current index: Int, cell: MineSweeperCell, mine: MineItem) {
        // update current item and cell
        mineSweeper.update(at: index) { result in
            topPanel.update(mineSwpeeper: mineSweeper)
            if result == .failure {
                tap(danger: index)
            }
            if result != .next {
                stopMonitor()
            }
            delegate?.mineSweeperGame(self, turnInto: result)
        }
        cell.update(with: mine)
        topPanel.update(mineSwpeeper: mineSweeper)
    }
    
    /// check adjacent cells of current selected, and update them if having no one mine arroundings
    private func at(adjacents index: Int, mine: MineItem) {
        guard mine.couldPlay() else {
            return
        }
        mineSweeper.transverse(at: index) { indexs in
            indexs.forEach { index in
                let mine = mineSweeper.item(at: index)!
                let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as! MineSweeperCell
                _ = mine.couldPlay()
                cell.update(with: mine)
            }
        }
    }
    
    /// show all mines, and indicates current cell at selected index with dangerous color
    private func tap(danger index: Int) {
        (0..<mineSweeper.config.total).forEach({ idx in
            let mine = mineSweeper.item(at: index)!
            if mine.type == .mine {
                mineSweeper.update(at: idx) { _ in
                    let cell = collectionView.cellForItem(at: IndexPath.init(item: index, section: 0)) as! MineSweeperCell
                    cell.update(with: mine, flagged: false, finished: index == idx)
                }
            }
        })
    }
    
    private var timer: Timer?
    private var mineSweeper: MineSweeper = MineSweeper.init(level: .base)
    private var topPanel: MineSweeperPanel = MineSweeperPanel.init(frame: .zero)
    private lazy var collectionView: UICollectionView = {
        let cv: UICollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout(config: mineSweeper.config))
        cv.dataSource = self
        cv.delegate = self
        cv.register(MineSweeperCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return cv
    }()
    
    private func layout(config: MineSweeperConfig) -> UICollectionViewFlowLayout {
        let items: CGFloat = CGFloat(config.cols)
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let itemWidth: CGFloat = ((screenWidth - 2*margin - (items-1)*padding)/items).rounded(.towardZero)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.estimatedItemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.scrollDirection = .vertical
        return layout
    }
    let margin: CGFloat = 16.0
    let padding: CGFloat = 2.0
    let reuseIdentifier = "mineSweeper"
}


protocol MineSweeperDelegate: NSObjectProtocol {
    func mineSweeperGame(_ game: MineSweeperGame, turnInto result: MineResult)
}
