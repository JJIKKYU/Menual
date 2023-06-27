//
//  ProfileHomeCell.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import UIKit
import SnapKit
import Then
import DesignSystem

enum ProfileHomeCellType {
    case toggle
    case toggleWithDescription
    case arrow
}

class ProfileHomeCell: UITableViewCell {
    
    var profileHomeCellType: ProfileHomeCellType = .arrow {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var desc: String? {
        didSet { setNeedsLayout() }
    }
    
    var switchIsOn: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    private let stackView: UIStackView = .init().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 8
        $0.distribution = .fillProportionally
        $0.alignment = .fill
        $0.layoutMargins = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private let bottomSpacer: UIView = .init().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.textColor = Colors.grey.g200
        $0.numberOfLines = 0
    }
    
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g500
        $0.isHidden = true
        $0.numberOfLines = 0
    }
    
    private let arrowImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g200
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var switchBtn = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(selectedSwitchBtn), for: .touchUpInside)
        $0.onTintColor = Colors.tint.main.v400
        $0.tintColor = Colors.grey.g700
        $0.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        addSubview(arrowImageView)
        addSubview(switchBtn)
        addSubview(bottomSpacer)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.equalToSuperview().inset(60)
//            make.bottom.equalToSuperview()
        }
        
//        titleLabel.snp.makeConstraints { make in
//            make.height.equalTo(21)
//            make.bottom.equalToSuperview()
//        }
//
//        descLabel.snp.makeConstraints { make in
//            make.height.equalTo(18)
//            make.bottom.equalToSuperview()
//        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        switchBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(40)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        bottomSpacer.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.leading.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        titleLabel.text = title
        descLabel.text = desc ?? "1"

        switch profileHomeCellType {
        case .arrow:
            arrowImageView.isHidden = false
            switchBtn.isHidden = true
            descLabel.isHidden = true
            
        case .toggle:
            switchBtn.isOn = switchIsOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            descLabel.isHidden = true
            
        case .toggleWithDescription:
            switchBtn.isOn = switchIsOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            descLabel.isHidden = false
        }
    }
}

// MARK: - Toggle
extension ProfileHomeCell {
    @objc
    func selectedSwitchBtn(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            print("isOn!")
        case false:
            print("isOff!")
        }
    }
}
