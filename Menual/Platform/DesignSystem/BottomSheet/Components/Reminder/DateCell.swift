//
//  DateCell.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit

class DateCell: UICollectionViewCell {
    
    public var index: Int = 0
    
    public var date: String = "0" {
        didSet { setNeedsLayout() }
    }
    
    public var labelColor: UIColor = Colors.grey.g600 {
        didSet { setNeedsLayout() }
    }
    
    override var isSelected: Bool {
        didSet { setNeedsLayout() }
    }
    
    public override var isUserInteractionEnabled: Bool {
        didSet { setNeedsLayout() }
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_2)
        $0.textColor = Colors.grey.g600
        $0.text = "1"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setViews()
        // 여기서 init 진행
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setViews() {
        addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.text = date
        dateLabel.textColor = labelColor
        
        print("Reminder :: cell -> isSelected! = \(isSelected)")
        
        switch isUserInteractionEnabled {
        case true:
            switch isSelected {
            case true:
                dateLabel.textColor = .red

            case false:
                dateLabel.textColor = Colors.grey.g200
            }
            
        case false:
            dateLabel.textColor = Colors.grey.g600
        }
    }
}
