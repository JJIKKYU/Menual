//
//  ProfileHomeCell.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import UIKit
import SnapKit
import Then

enum ProfileHomeCellType {
    case toggle
    case arrow
}

class ProfileHomeCell: UITableViewCell {
    
    var profileHomeCellType: ProfileHomeCellType = .arrow {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.textColor = Colors.grey.g200
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
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(arrowImageView)
        addSubview(switchBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(60)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
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
    }
    
    override func layoutSubviews() {
        titleLabel.text = title
        switch profileHomeCellType {
        case .arrow:
            arrowImageView.isHidden = false
            switchBtn.isHidden = true
        case .toggle:
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
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
