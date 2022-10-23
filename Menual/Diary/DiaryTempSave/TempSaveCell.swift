//
//  TempSaveCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import UIKit
import SnapKit
import Then

class TempSaveCell: UITableViewCell {
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var date: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var imageEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isWriting: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isDeleteMode: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isDeleteSelected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "테스트입니다"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g200
        $0.font = UIFont.AppTitle(.title_2)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "날짜입니다"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
    }
    
    // '작성중' 라벨
    private let writingLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.tint.sub.n400
        $0.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
        $0.text = "작성중"
    }
    
    private let imageEnableView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.picture.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g200
        $0.isHidden = true
    }
    
    private let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
    }
    
    private let delCheckBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Circle.Check.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .selected)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.text = title
        dateLabel.text = date
        print("TempSave :: Cell isDeleteSelected = \(isDeleteSelected)")
        
        var margin: CGFloat = 20
        switch isDeleteMode {
        case true:
            delCheckBtn.isHidden = false
            delCheckBtn.isSelected = isDeleteSelected
            if isDeleteSelected {
                delCheckBtn.tintColor = Colors.tint.sub.n400
            } else {
                delCheckBtn.tintColor = Colors.grey.g200
            }
            
            margin = 64

        case false:
            delCheckBtn.isSelected = false
            delCheckBtn.isHidden = true
            margin = 20
        }
        
        switch isWriting {
        case true:
            divider.isHidden = false
            writingLabel.isHidden = false
            
        case false:
            divider.isHidden = true
            writingLabel.isHidden = true
        }
        
        switch imageEnabled {
        case true:
            imageEnableView.isHidden = false

            imageEnableView.snp.removeConstraints()
            imageEnableView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(14)
                make.width.height.equalTo(24)
            }
            
            titleLabel.snp.removeConstraints()
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(imageEnableView.snp.trailing).offset(2)
                make.centerY.equalTo(imageEnableView)
                make.width.equalToSuperview().inset(margin)
            }
            
        case false:
            imageEnableView.isHidden = true
            imageEnableView.snp.removeConstraints()
            
            titleLabel.snp.removeConstraints()
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(17)
                make.width.equalToSuperview().inset(margin)
            }
        }
    }
    
    func setViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(imageEnableView)
        addSubview(divider)
        addSubview(writingLabel)
        addSubview(delCheckBtn)
        
        imageEnableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageEnableView.snp.trailing).offset(2)
            make.centerY.equalTo(imageEnableView)
            make.width.equalToSuperview().inset(20)
        }

        titleLabel.sizeToFit()
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        dateLabel.sizeToFit()
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(8)
            make.width.equalTo(1)
            make.height.equalTo(15)
            make.centerY.equalTo(dateLabel)
        }
        
        writingLabel.snp.makeConstraints { make in
            make.leading.equalTo(divider.snp.trailing).offset(8)
            make.centerY.equalTo(divider)
        }
        
        delCheckBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
    }
}
