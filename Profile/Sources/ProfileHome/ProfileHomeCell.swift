//
//  ProfileHomeCell.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import DesignSystem
import MenualEntity
import SnapKit
import Then
import UIKit

public class ProfileHomeCell: UITableViewCell {
    
    public var profileHomeCellType: ProfileHomeCellType = .arrow {
        didSet { setNeedsLayout() }
    }
    
    public var section: ProfileHomeSection?
    public var menuType: ProfileHomeMenuType?
    
    public  var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var desc: String? {
        didSet { setNeedsLayout() }
    }
    
    public var switchIsOn: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    private let stackView: UIStackView = .init().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .fill
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.font = .AppBodyOnlyFont(.body_4)
        $0.textColor = Colors.grey.g200
        $0.numberOfLines = 1
    }
    
    private let descLabel = UILabel().then {
        $0.font = .AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g500
        $0.isHidden = false
        $0.numberOfLines = 1
    }
    
    private let arrowImageView = UIImageView().then {
        $0.image = Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g200
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var switchBtn = UISwitch().then {
        $0.onTintColor = Colors.tint.main.v400
        $0.tintColor = Colors.grey.g700
        $0.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)
        $0.isUserInteractionEnabled = false
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        stackView.layoutIfNeeded()
        stackView.sizeToFit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setViews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(switchBtn)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(60)
            make.bottom.equalToSuperview().inset(20)
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
    
    override public func layoutSubviews() {
        titleLabel.text = title
        descLabel.text = desc ?? ""

        switch profileHomeCellType {
        case .arrow:
            arrowImageView.isHidden = false
            switchBtn.isHidden = true
            stackView.spacing = 0
            
        case .toggle:
            switchBtn.isOn = switchIsOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            stackView.spacing = 0
            
        case .toggleWithDescription:
            switchBtn.isOn = switchIsOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            stackView.spacing = 8
        }
        
        titleLabel.sizeToFit()
        descLabel.sizeToFit()
        stackView.sizeToFit()
    }
}

// MARK: - Preview

/*
@available(iOS 17.0, *)
#Preview {
    let cell = ProfileHomeCell()
    cell.title = "안녕하세요"
    cell.profileHomeCellType = .toggleWithDescription
    cell.desc = "description입니다."
    return cell
}
*/
