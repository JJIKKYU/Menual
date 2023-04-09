//
//  ListCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import UIKit
import Then
import SnapKit
import MenualUtil
import MenualEntity

public enum ListType {
    case normal
    // case textReview
    case textAndImage
    // case textAndImageReview
    case bodyText
    case bodyTextImage
    case hide
}

public enum ListStatus {
    case default_
    case highlighed
    case pressed
}

public class ListCell: UITableViewCell {
    
    public var testModel: DiaryModelRealm?
    
    // 현재 정보를 담고 있는 게시글의 UUID
    // Search 후에 필요한 정보를 임시로 담고 있도록
    public var uuid: String = ""
    
    public var listType: ListType = .normal {
        didSet { setNeedsLayout() }
    }
    
    public var listStatus: ListStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    public var searchKeyword: String = "" {
        didSet { setNeedsLayout() }
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//       super.setSelected(selected, animated: animated)
//        listStatus = selected ? .pressed : .default_
//   }
       
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
       super.setHighlighted(highlighted, animated: animated)
       listStatus = highlighted ? .highlighed : .default_
   }
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var date: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var time: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var pageCount: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var reviewCount: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var image: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    public var body: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let listTitleView = ListTitleView(type: .title).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let menualImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.AppCorner(._2pt)
        $0.isHidden = true
    }
    
    private let listInfoView = ListInfoView(type: .time).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let listBodyView = ListTitleView(type: .titleBodyText).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    public let divider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.background
        addSubview(listTitleView)
        addSubview(menualImageView)
        addSubview(listInfoView)
        addSubview(listBodyView)
        addSubview(divider)

        menualImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }

        listTitleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(18)
        }
        
        listBodyView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(listTitleView)
            make.top.equalTo(listTitleView.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        
        listInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listBodyView.snp.bottom).offset(6)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(15)
        }
        
        divider.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        removeSectionSeparators()
        listTitleView.titleText = title
        listBodyView.bodyText = body
        listInfoView.date = date
        listInfoView.time = time
        listInfoView.pageCount = pageCount
        listInfoView.reviewCount = reviewCount
        listInfoView.infoType = .info
        
        if reviewCount != "" {
            print("revieCount = \(reviewCount)")
            listInfoView.infoType = .infoReview
        }
        
        switch listType {
        case .normal:
            menualImageView.isHidden = true
            listTitleView.listTitleType = .title
            listTitleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(18)
            }
            listInfoView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(listTitleView.snp.bottom).offset(6)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(15)
            }
//            lockImageView.snp.removeConstraints()
        case .textAndImage:
            listTitleView.listTitleType = .title
            menualImageView.isHidden = false
            if let image = image {
                menualImageView.image = image
            }
            menualImageView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(20)
                make.top.equalToSuperview().offset(12)
                make.width.height.equalTo(48)
            }
            listTitleView.isHidden = false
            listTitleView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(80)
                make.height.equalTo(18)
            }
            listBodyView.isHidden = false
            listBodyView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().inset(80)
                make.top.equalTo(listTitleView.snp.bottom).offset(6)
                make.height.equalTo(18)
            }
            listInfoView.isHidden = false
            listInfoView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(listBodyView.snp.bottom).offset(6)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(15)
            }
        case .hide:
            listTitleView.isHidden = false
            listTitleView.listTitleType = .titleHide
            listBodyView.isHidden = true
            menualImageView.isHidden = true
            listInfoView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(listTitleView.snp.bottom).offset(6)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(15)
                // make.bottom.equalToSuperview().inset(18)
            }

        case .bodyText:
            listBodyView.isHidden = false
            menualImageView.isHidden = true
            listTitleView.listTitleType = .title
            listTitleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(18)
            }
            listBodyView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.width.equalToSuperview().inset(20)
                make.top.equalTo(listTitleView.snp.bottom).offset(6)
                make.height.equalTo(18)
            }
            listInfoView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(listBodyView.snp.bottom).offset(8)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(15)
            }
            // menualImageView.snp.removeConstraints()

        case .bodyTextImage:
            listBodyView.isHidden = false
            menualImageView.isHidden = false
            listTitleView.listTitleType = .title
            if let image = image {
                menualImageView.image = image
            }
            menualImageView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(20)
                make.top.equalToSuperview().offset(12)
                make.width.height.equalTo(48)
            }
            listBodyView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().inset(80)
                make.top.equalTo(listTitleView.snp.bottom).offset(6)
                make.height.equalTo(18)
            }
            listTitleView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().inset(80)
                make.height.equalTo(18)
            }
            listInfoView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.top.equalTo(listBodyView.snp.bottom).offset(8)
                make.width.equalToSuperview().inset(20)
                make.height.equalTo(15)
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
     
        listTitleView.searchKeyword = searchKeyword
        listBodyView.searchKeyword = searchKeyword
    }
}
