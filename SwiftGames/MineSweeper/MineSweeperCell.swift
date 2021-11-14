//
//  MineSweeperCell.swift
//  SwiftGames
//
//  Created by Walker Wang on 2021/10/27.
//

import UIKit

class MineSweeperCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 20.0, weight: .bold)
        label.textColor = UIColor.systemBlue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        let y = (frame.height-titleLabel.font.pointSize)/2
        titleLabel.frame = CGRect(x: 0, y: y, width: frame.size.width, height: 22)
    }
    
    func update(with item: MineItem, flagged: Bool = false, finished: Bool = false) {
        /// when flagged, just cover cell with 🚩or uncover it
        if flagged {
            titleLabel.text = item.flagged ? "🚩" : item.content()
            backgroundColor = item.flagged ? .white : .gray
            return
        }
        
        /// else show content and change background color
        titleLabel.text = item.content()
        backgroundColor =  item.tapped ? .white : .gray
        layer.borderColor = item.tapped && item.type == .mine ? UIColor.red.cgColor : UIColor.lightGray.cgColor
        
        /// when game over, if current item is true mine, then indicate background color with red
        if finished && item.type == .mine {
            backgroundColor = .red
        }
    }
    
}
