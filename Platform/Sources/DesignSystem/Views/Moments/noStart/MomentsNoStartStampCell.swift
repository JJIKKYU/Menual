//
//  MomentsNoStartStampCell.swift
//  Menual
//
//  Created by 정진균 on 2023/01/05.
//

import UIKit
import Then
import SnapKit
import DesignSystem

class MomentsNoStartStampCell: UICollectionViewCell {
    
    enum StampStatus {
        case active
        case unactive
    }
    
    public var stampStatus: StampStatus = .unactive {
        didSet { setNeedsLayout() }
    }
    
    public var number: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    public var dateString: String = "??/??" {
        didSet { setNeedsLayout() }
    }
    
    private let stampNumberView = UIView().then {
        $0.layer.cornerRadius = 9
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.tint.main.v800
    }
    
    private let stampNumberLabel = UILabel().then {
        $0.textAlignment = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.tint.main.v600
        $0.text = "1"
        $0.font = UIFont.AppHead(.head_1)
    }
    
    private let stampView = UIView().then {
        $0.layer.masksToBounds = true
        $0.layer.borderColor = Colors.tint.main.v800.cgColor
        $0.layer.borderWidth = 2
        $0.backgroundColor = Colors.tint.main.v500
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let imageView = UIImageView().then {
        $0.image = Asset._16px.symbol.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.tint.main.v800
        $0.layer.masksToBounds = true
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.AppHead(.head_1)
        $0.textColor = Colors.tint.main.v600
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "??/??"
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
        addSubview(stampView)
        addSubview(stampNumberView)
        stampNumberView.addSubview(stampNumberLabel)
        stampView.addSubview(imageView)
        addSubview(dateLabel)
        
        stampView.layer.cornerRadius = 26
        stampView.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        stampNumberView.snp.makeConstraints { make in
            make.width.height.equalTo(18)
            make.leading.equalToSuperview().inset(-3)
            make.top.equalToSuperview().inset(-3)
        }
        
        stampNumberLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(stampView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.leading.width.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stampNumberLabel.text = "\(number)"
        
        switch stampStatus {
        case .active:
            stampNumberLabel.textColor = Colors.tint.main.v800
            dateLabel.text = dateString
            stampNumberView.backgroundColor = Colors.tint.sub.n400
            stampView.backgroundColor = Colors.tint.main.v800
            stampView.layer.borderColor = Colors.tint.main.v100.cgColor
            imageView.tintColor = Colors.tint.main.v100
            dateLabel.textColor = Colors.tint.main.v100
        
            
        case .unactive:
            stampNumberLabel.textColor = Colors.tint.main.v600
            dateLabel.text = "??/??"
            stampNumberView.backgroundColor = Colors.tint.main.v800
            stampView.backgroundColor = Colors.tint.main.v500
            stampView.layer.borderColor = Colors.tint.main.v800.cgColor
            imageView.tintColor = Colors.tint.main.v800
            dateLabel.textColor = Colors.tint.main.v600
        }
    }
}
