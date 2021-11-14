//
//  SweeperViewController.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/10/27.
//

import UIKit

class MineSweeperController: UIViewController, MineSweeperDelegate {
    private var game = MineSweeperGame.init(frame: .zero)
    private var level = MineSweeperLevel.base
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addComponents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.game.frame = CGRect.init(x: 0, y: 100, width: view.bounds.width, height: view.bounds.height-100)
    }
    
    private func addComponents() {
        title = "MineSweeper"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "更多", style: .plain, target: self, action: #selector(self.showMore))
        view.addSubview(game)
        game.delegate = self
    }
    
    func mineSweeperGame(_ game: MineSweeperGame, turnInto result: MineResult) {
        switch result {
        case .failure:
            navigationController?.present(failure, animated: true) {
                print("you are failure")
            }
        case .next:
            print("and next")
        case .success:
            navigationController?.present(success, animated: true) {
                print("congratuations, you are an winner!")
            }
        }
    }
    
    @objc private func showMore() {
        navigationController?.present(moreSheet, animated: true, completion: nil)
    }

    private func alertActionFor(level: MineSweeperLevel!, again: Bool = false) -> UIAlertAction {
        UIAlertAction.init(title: again ? "重新开始" : level.rawValue, style: .default) { action in
            if again {
                self.game.update(level: self.level)
            } else {
                self.game.update(level: level)
                self.level = level
            }
            
        }
    }
    
    lazy var moreSheet: UIAlertController = {
        let alert = UIAlertController.init(title: "More", message: "settings for", preferredStyle: .actionSheet)
        alert.addAction(alertActionFor(level: nil, again: true))
        alert.addAction(alertActionFor(level: .base))
        alert.addAction(alertActionFor(level: .middle))
        alert.addAction(alertActionFor(level: .high))
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        return alert
    }()
    lazy var failure: UIAlertController = {
        let alert = UIAlertController.init(title: "踩雷了", message: "💣", preferredStyle: .alert)
        alert.addAction(alertActionFor(level: self.level, again: true))
        return alert
    }()
    lazy var success: UIAlertController = {
        let alert = UIAlertController.init(title: "祝贺", message: "🎉", preferredStyle: .alert)
        alert.addAction(alertActionFor(level: self.level, again: true))
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        return alert
    }()
}
