//
//  MineSweeperBoard.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/10/28.
//

import UIKit

class MineSweeperPanel: UIView {
    var flagged: Bool = false {
        didSet {
            flagButton.isEnabled = !flagged
            flagButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: flagged ? 36 : 24)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(minesLabel)
        addSubview(stateLabel)
        addSubview(timeLabel)
        addSubview(flagButton)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let y: CGFloat = (frame.height/2 - 20.0)/2
        minesLabel.frame = CGRect.init(x: 0, y: y, width: 100.0, height: 22.0)
        stateLabel.frame = CGRect.init(x: (frame.width-100)/2, y: y, width: 100, height: 22.0)
        timeLabel.frame = CGRect.init(x: frame.width-100, y: y, width: 100, height: 22.0)
        flagButton.frame = CGRect.init(x: 0, y: frame.height/2+8, width: frame.width, height: frame.height/2-16)
    }
    
    func reset(mines: Int) {
        minesLabel.text = "💣 \(mines)"
        stateLabel.text = "😄"
        timeLabel.text = "⏰ 000"
    }
    func update(mineSwpeeper: MineSweeper) {
        timeLabel.text = mineSwpeeper.secondsSinceStart
        stateLabel.text = mineSwpeeper.state.rawValue
    }
    
    private lazy var minesLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    private lazy var stateLabel:UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28.0)
        return label
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        label.textAlignment = .right
        return label
    }()
    private lazy var flagButton: UIButton = {
        let button = UIButton.init(type: .roundedRect)
        button.setTitle("🚩", for: .normal)
        button.addTarget(self, action: #selector(flagClick), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        return button
    }()
    
    @objc private func flagClick(_ : UIButton) {
        flagged = !flagged
    }
}
