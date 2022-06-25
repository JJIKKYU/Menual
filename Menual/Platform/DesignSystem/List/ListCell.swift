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

enum ListStatus {
    case default_
    case highlighed
    case pressed
}

class ListCell: UITableViewCell {
    
    // 현재 정보를 담고 있는 게시글의 UUID
    // Search 후에 필요한 정보를 임시로 담고 있도록
    var uuid: String = ""
    
    var listType: ListType = .text {
        didSet { setNeedsLayout() }
    }
    
    var listStatus: ListStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    var searchKeyword: String = "" {
        didSet { setNeedsLayout() }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
        listStatus = selected ? .pressed : .default_
   }
       
   override func setHighlighted(_ highlighted: Bool, animated: Bool) {
       super.setHighlighted(highlighted, animated: animated)
       listStatus = highlighted ? .highlighed : .default_
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
    
    func setViews() {
        backgroundColor = Colors.background
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
        
        removeSectionSeparators()
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
        
        switch listStatus {
        case .default_:
            backgroundColor = Colors.background
        case .pressed:
            backgroundColor = Colors.grey.g700
        case .highlighed:
            backgroundColor = Colors.grey.g800
        }
        
        highlightText(keyword: searchKeyword)
    }
    
    func highlightText(keyword: String) {
        print("keyword = \(keyword)")
        // 타이틀
        let titleAtrString = NSMutableAttributedString(string: title)
        titleAtrString.addAttribute(.foregroundColor, value: Colors.tint.main.v400, range: (title as NSString).range(of: keyword))
        titleLabel.attributedText = titleAtrString
        
        // TODO: - 내용도 하이라이트 될 수 있도록 추가할 것
        /*
        let descAtrString = NSMutableAttributedString(string: desc)
        descAtrString.addAttribute(.foregroundColor, value: UIColor.blue, range: (desc as NSString).range(of: text))
        descriptionLabel.attributedText = descAtrString
        */
    }
}
