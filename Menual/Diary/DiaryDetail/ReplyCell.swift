//
//  ReplyCell.swift
//  Menual
//
//  Created by 정진균 on 2022/07/10.
//

import UIKit
import SnapKit
import Then

class ReplyCell: UITableViewCell {
    
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
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.text = "testestestsetseestsetsetsetsetstsetse"
        $0.backgroundColor = Colors.grey.g800
        $0.isScrollEnabled = false
        $0.textContainerInset = UIEdgeInsets(top: 14, left: 16, bottom: 16, right: 16)
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,

        ]
        $0.clipsToBounds = true
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g300
    }
    
    let testLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "test | test"
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }
    
    let moreBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.more.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
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
        backgroundColor = .brown
        contentView.addSubview(replyTextView)
        contentView.addSubview(testLabel)
        contentView.addSubview(moreBtn)
        
        replyTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
//            make.height.equalTo(80)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        testLabel.snp.makeConstraints { make in
            make.top.equalTo(replyTextView.snp.bottom).offset(9)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
        
        moreBtn.snp.makeConstraints { make in
            make.top.equalTo(testLabel)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        replyTextView.text = replyText
//         replyTextView.sizeThatFits(replyTextView.frame.size)
//        replyTextView.sizeToFit()
//        replyTextView.frame = CGRect(x: 20,
//                                     y: 0,
//                                     width: frame.size.width - 40,
//                                     height: replyTextView.frame.height
//        )
////
//        print("DiaryDetail :: cell's height = \(replyTextView.frame.height)")
//        replyTextView.snp.updateConstraints { make in
//            make.height.equalTo(replyTextView.frame.height)
//        }
//
        print("createdAT= \(createdAt.toString())")
        testLabel.text = createdAt.toString() + "  |  " + "P. \(pageNum)-\(String(replyNum))"
    }
}
