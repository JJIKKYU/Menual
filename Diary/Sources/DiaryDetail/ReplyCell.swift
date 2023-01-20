//
//  ReplyCell.swift
//  Menual
//
//  Created by 정진균 on 2022/07/10.
//

import UIKit
import SnapKit
import Then
import DesignSystem

class ReplyCell: UITableViewCell {
    
    var replyUUID: String = ""
    
    var replyText: String = " " {
        didSet { setNeedsLayout() }
    }
    
    var createdAt: Date = Date() {
        didSet { setNeedsLayout() }
    }
    
    var replyNum: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    var pageNum: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    private let wrappedContentView = UIView().then {
        $0.backgroundColor = Colors.grey.g800
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner
            
        ]
        $0.clipsToBounds = true
    }
    
    public let replyTextView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
        $0.isScrollEnabled = false
        $0.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 19, right: 16)
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,

        ]
        $0.clipsToBounds = true
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g300
        $0.isEditable = false
    }
    
    let infoLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "test | test"
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }
    
    let closeBtn = UIButton().then {
        $0.actionName = "delete"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
    }
    
    let wrapView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        contentView.addSubview(wrapView)
        wrapView.addSubview(replyTextView)
        wrapView.addSubview(infoLabel)
        wrapView.addSubview(closeBtn)
        
        wrapView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        replyTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
//            make.height.equalTo(80)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(replyTextView.snp.bottom).offset(9)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(20)
            // amake.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        replyTextView.attributedText = UIFont.AppBodyWithText(.body_3,
                                                    Colors.grey.g300,
                                                    text: replyText
        )
        replyTextView.sizeToFit()
        replyTextView.layoutIfNeeded()
        
        print("ReplyCell :: replyTextSize = \(replyTextView.frame.height)")
        infoLabel.text = createdAt.toString() + "  |  " + "P. \(pageNum)-\(String(replyNum))"
    }
}
