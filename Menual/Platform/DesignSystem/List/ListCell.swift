//
//  ListCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import UIKit
import Then
import SnapKit

enum ListType {
    case text
    // case textReview
    case textAndImage
    // case textAndImageReview
    case hide
}

class ListCell: UITableViewCell {
    
    var listType: ListType = .text {
        didSet { setNeedsLayout() }
    }
    
    var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var dateAndTime: String = "" {
        didSet { setNeedsLayout() }
    }
    
    var pageAndReview: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let lockImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.lock.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g500
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g200
        $0.font = UIFont.AppTitle(.title_2)
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 1
    }
    
    private let menualImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
        $0.contentMode = .scaleAspectFit
        $0.AppCorner(._2pt)
    }
    
    private let dateAndTimeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
    }
    
    private let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
    }
    
    private let pageAndReviewLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g600
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
        backgroundColor = Colors.background.black
        addSubview(lockImageView)
        addSubview(titleLabel)
        addSubview(menualImageView)
        addSubview(dateAndTimeLabel)
        addSubview(divider)
        addSubview(pageAndReviewLabel)
        
        lockImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }
        
        menualImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(lockImageView.snp.trailing).offset(2)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(80)
        }
        
        dateAndTimeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(17)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalTo(dateAndTimeLabel.snp.trailing).offset(8)
            make.width.equalTo(0.5)
            make.top.equalTo(dateAndTimeLabel)
            make.bottom.equalTo(dateAndTimeLabel)
        }
        
        pageAndReviewLabel.snp.makeConstraints { make in
            make.leading.equalTo(divider.snp.trailing).offset(8)
            make.top.equalTo(divider)
            make.bottom.equalTo(divider)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.text = title
        dateAndTimeLabel.text = dateAndTime
        pageAndReviewLabel.text = pageAndReview
        
        switch listType {
        case .text:
            menualImageView.isHidden = true
            lockImageView.isHidden = true
            lockImageView.snp.removeConstraints()
            titleLabel.textColor = Colors.grey.g200
            titleLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(19)
            }
            lockImageView.snp.removeConstraints()
        case .textAndImage:
            menualImageView.isHidden = false
            lockImageView.isHidden = true
            titleLabel.textColor = Colors.grey.g200
            titleLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(80)
            }
            lockImageView.snp.removeConstraints()
        case .hide:
            menualImageView.isHidden = true
            lockImageView.isHidden = false
            titleLabel.text = "숨긴 메뉴얼이에요."
            titleLabel.textColor = Colors.grey.g500
            menualImageView.snp.removeConstraints()
            titleLabel.snp.remakeConstraints { make in
                make.leading.equalTo(lockImageView.snp.trailing).offset(2)
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(19)
            }
            lockImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(12)
                make.width.height.equalTo(24)
            }
        }
    }
}
