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

// MARK: - ProfileHomeCell Delegate

public protocol ProfileHomeCellDelegate: AnyObject {
    func pressedToggleBtn(menuType: ProfileHomeMenuType, section: ProfileHomeSection)
}

// MARK: - ProfileHomeCell

public class ProfileHomeCell: UITableViewCell {
    
    public var profileHomeCellType: ProfileHomeCellType = .arrow {
        didSet { setNeedsLayout() }
    }
    
    public var section: ProfileHomeSection?
    public var menuType: ProfileHomeMenuType?
    public weak var delegate: ProfileHomeCellDelegate?
    
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
        $0.distribution = .fill
        $0.alignment = .fill
        $0.layoutMargins = UIEdgeInsets(top: 20, left: .zero, bottom: 20, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
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
    
    lazy var switchWrapperBtn: UIButton = .init().then {
        $0.addTarget(self, action: #selector(pressedToggleBtn), for: .touchUpInside)
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .clear
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
//        stackView.layoutIfNeeded()
//        stackView.sizeToFit()
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
        contentView.addSubview(switchWrapperBtn)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.equalToSuperview().inset(60)
            make.bottom.equalToSuperview()
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
        
        switchWrapperBtn.snp.makeConstraints { make in
            make.edges.equalTo(switchBtn)
        }
    }
    
    override public func layoutSubviews() {
        titleLabel.text = title
        let desc: String = self.desc ?? ""
        descLabel.isHidden = desc.isEmpty ? true : false
        descLabel.text = desc

        switch profileHomeCellType {
        case .arrow:
            arrowImageView.isHidden = false
            switchBtn.isHidden = true
            stackView.spacing = 1
            
        case .toggle:
            switchBtn.isOn = switchIsOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            stackView.spacing = 1
            
        case .toggleWithDescription:
            switchBtn.isOn = switchIsOn
            // Toggle On은 셀을 직접 클릭해야만 활성화할 수 있음 (서비스에서 변경)
            switchWrapperBtn.isUserInteractionEnabled = switchBtn.isOn
            arrowImageView.isHidden = true
            switchBtn.isHidden = false
            stackView.spacing = 4
        }
        
        guard let menuType: ProfileHomeMenuType = menuType else { return }
        if case .setting1(let profileHomeSetting1) = menuType {
            switch profileHomeSetting1 {
            case .guide, .passwordChange, .alarm:
                break

            case .password:
                switchBtn.isUserInteractionEnabled = false
            }
        }
    }
}

// MARK: - IBAction

extension ProfileHomeCell {
    @objc
    func pressedToggleBtn() {
        guard let menuType: ProfileHomeMenuType = menuType,
              let section: ProfileHomeSection = section
        else { return }

        delegate?.pressedToggleBtn(
            menuType: menuType,
            section: section
        )
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
