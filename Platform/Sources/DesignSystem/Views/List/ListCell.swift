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
import GoogleMobileAds

public enum ListScreen {
    case home
    case search
}

public enum ListType {
    case normal
    // case textReview
    case textAndImage
    // case textAndImageReview
    case bodyText
    case bodyTextImage
    case hide
    case adBodyTextImage
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

    public var listScreen: ListScreen = .home {
        didSet { setNeedsLayout() }
    }
    
    public var searchKeyword: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var adText: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var nativeAd: GADNativeAd? {
        didSet {
            adView.nativeAd = nativeAd
        }
    }
    
    public var adViewHeight: CGFloat = 0
    
    public lazy var adView: ADListView = .init().then {
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.callToActionView = self.contentView
    }
       
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

    private let menualImageView = ListCellImageView().then {
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
    
    public let adViewDivider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
        $0.isHidden = true
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
        addSubview(adView)
        addSubview(listTitleView)
        addSubview(menualImageView)
        addSubview(listInfoView)
        addSubview(listBodyView)
        addSubview(divider)
        addSubview(adViewDivider)

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
        
        adView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
        }

        adViewDivider.snp.makeConstraints { make in
//            make.top.equalTo(adView.snp.bottom).offset(14)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        adView.isHidden = true
        removeSectionSeparators()
        
        listTitleView.isHidden = false
        listTitleView.titleText = title
        
        listBodyView.isHidden = false
        listBodyView.bodyText = body
        
        listInfoView.isHidden = false
        listInfoView.date = date
        listInfoView.time = time
        listInfoView.pageCount = pageCount
        listInfoView.reviewCount = reviewCount
        listInfoView.infoType = .info
        
        if reviewCount != "" {
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
                DispatchQueue.main.async {
                    self.menualImageView.image = image
                    self.menualImageView.imageCount = self.testModel?.imageCount
                }
            }
            menualImageView.snp.remakeConstraints { make in
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
            switch listScreen {
            case .home:
                listBodyView.isHidden = true
                listInfoView.isHidden = false
                listInfoView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(20)
                    make.top.equalTo(listTitleView.snp.bottom).offset(6)
                    make.width.equalToSuperview().inset(20)
                    make.height.equalTo(15)
                }
                
            case .search:
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
                DispatchQueue.main.async {
                    self.menualImageView.image = image
                    self.menualImageView.imageCount = self.testModel?.imageCount
                }
            }
            menualImageView.snp.remakeConstraints { make in
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
            
        case .adBodyTextImage:
            adView.isHidden = false
            listTitleView.isHidden = true
            listBodyView.isHidden = true
            menualImageView.isHidden = true
            listInfoView.isHidden = true
            divider.isHidden = true
            adViewDivider.isHidden = false

            adView.image = image
            adView.title = title
            adView.body = body
            adView.adText = adText
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
