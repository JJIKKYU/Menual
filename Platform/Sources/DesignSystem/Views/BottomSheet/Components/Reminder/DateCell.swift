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
    
    public var isToday: Bool = false {
        didSet { setNeedsLayout() }
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_2)
        $0.textColor = Colors.grey.g600
        $0.text = "1"
        $0.textAlignment = .center
    }
    
    private let todayCircleView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderColor = Colors.grey.g700.cgColor
        $0.layer.borderWidth = 1.5
        $0.isHidden = true
    }

    private let selectedCircleView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.sub.n400
        $0.isHidden = true
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
        addSubview(selectedCircleView)
        addSubview(dateLabel)
        addSubview(todayCircleView)
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        todayCircleView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.bounds.width * 0.66)
        }
        
        selectedCircleView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.bounds.width * 0.66)
        }
        layoutIfNeeded()
        todayCircleView.layer.cornerRadius = todayCircleView.bounds.width / 2
        selectedCircleView.layer.cornerRadius = selectedCircleView.bounds.width / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.text = date
        dateLabel.textColor = labelColor
        dateLabel.sizeToFit()
        
        layoutIfNeeded()
        
        switch isUserInteractionEnabled {
        case true:
            switch isSelected {
            case true:
                dateLabel.textColor = Colors.grey.g800
                selectedCircleView.isHidden = false

            case false:
                dateLabel.textColor = Colors.grey.g200
                selectedCircleView.isHidden = true
            }
            
        case false:
            dateLabel.textColor = Colors.grey.g600
            selectedCircleView.isHidden = true
        }
        
        switch isToday {
        case true:
            todayCircleView.isHidden = false

        case false:
            todayCircleView.isHidden = true
        }
        
        selectedCircleView.snp.remakeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.bounds.width * 0.66)
        }
        layoutIfNeeded()
        todayCircleView.layer.cornerRadius = todayCircleView.bounds.width / 2
        selectedCircleView.layer.cornerRadius = selectedCircleView.bounds.width / 2
    }
}
