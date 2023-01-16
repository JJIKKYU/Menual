//
//  ListInfoView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import UIKit
import SnapKit
import Then
import DesignSystem

class ListInfoView: UIView {
    
    enum InfoType {
        case time
        case timeWriting
        case info
        case infoReview
        case infoWriting
    }
    
    public var infoType: InfoType = .time {
        didSet { setNeedsLayout() }
    }
    
    public var pageCount: String = "999" {
        didSet { setNeedsLayout() }
    }
    
    public var reviewCount: String = "9" {
        didSet { setNeedsLayout() }
    }
    
    public var time: String = "99:99" {
        didSet { setNeedsLayout() }
    }
    
    public var date: String = "2099.99.99" {
        didSet { setNeedsLayout() }
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "P.999"
        $0.isHidden = true
    }
    
    private let reviewIcon = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._16px.rewrite.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g600
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let reviewLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "+9"
        $0.isHidden = true
    }
    
    private let timeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "99:99"
        $0.isHidden = true
    }
    
    private let dateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "2099.99.99."
        $0.isHidden = true
    }
    
    private let verticalDivider1 = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let verticalDivider2 = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let writingLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "작성중"
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.tint.sub.n400
        $0.isHidden = true
    }

    init(type: InfoType) {
        infoType = type
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(verticalDivider1)
        addSubview(pageLabel)
        addSubview(verticalDivider2)
        addSubview(reviewIcon)
        addSubview(reviewLabel)
        addSubview(writingLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        
        verticalDivider1.snp.makeConstraints { make in
            make.leading.equalTo(timeLabel.snp.trailing).offset(8)
            make.width.equalTo(1)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().inset(2)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.leading.equalTo(verticalDivider1.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        verticalDivider2.snp.makeConstraints { make in
            make.leading.equalTo(pageLabel.snp.trailing).offset(8)
            make.width.equalTo(1)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().inset(2)
        }
        
        reviewIcon.snp.makeConstraints { make in
            make.leading.equalTo(verticalDivider2.snp.trailing).offset(8)
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        reviewLabel.snp.makeConstraints { make in
            make.leading.equalTo(reviewIcon.snp.trailing).offset(2)
            make.centerY.equalToSuperview()
        }
        
        writingLabel.snp.makeConstraints { make in
            make.leading.equalTo(verticalDivider2.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.text = date
        timeLabel.text = time
        pageLabel.text = "P. \(pageCount)"
        reviewLabel.text = "+\(reviewCount)"
        
        switch infoType {
        case .time:
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            verticalDivider1.isHidden = true
            writingLabel.isHidden = true
            
        case .timeWriting:
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            verticalDivider1.isHidden = false
            writingLabel.isHidden = false
            writingLabel.snp.remakeConstraints { make in
                make.leading.equalTo(verticalDivider1.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
            
        case .info:
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            verticalDivider1.isHidden = false
            pageLabel.isHidden = false
            verticalDivider2.isHidden = true
            reviewIcon.isHidden = true
            reviewLabel.isHidden = true
            
        case .infoReview:
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            verticalDivider1.isHidden = false
            pageLabel.isHidden = false
            verticalDivider2.isHidden = false
            reviewIcon.isHidden = false
            reviewLabel.isHidden = false
            
        case .infoWriting:
            dateLabel.isHidden = false
            timeLabel.isHidden = false
            verticalDivider1.isHidden = false
            pageLabel.isHidden = false
            verticalDivider2.isHidden = false
            writingLabel.isHidden = false
            writingLabel.snp.remakeConstraints { make in
                make.leading.equalTo(verticalDivider2.snp.trailing).offset(8)
                make.centerY.equalToSuperview()
            }
        }
    }

}
