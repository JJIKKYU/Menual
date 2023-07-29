//
//  ListHeader.swift
//  Menual
//
//  Created by 정진균 on 2022/05/22.
//

import UIKit
import SnapKit
import Then
import MenualUtil

public enum ListHeaderType {
    case textandicon
    case text
    case datepageandicon
    case search

    case main
    case myPage
}

public enum DetailType {
    case none
    case arrow
    case searchDelete
    
    // 공통
    case empty
}

public final class ListHeader: UIView {
    
    private var type: ListHeaderType = .datepageandicon {
        didSet { setNeedsLayout() }
    }
    
    private var detailType: DetailType = .none {
        didSet { setNeedsLayout() }
    }
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var pageNumber: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    public let titleLabel: UILabel = .init()
    public let rightArrowBtn: BaseButton = .init()
    public let rightTextBtn: BaseButton = .init()

    public init(type: ListHeaderType, rightIconType: DetailType) {
        self.type = type
        self.detailType = rightIconType
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        configureUI()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        rightArrowBtn.do {
            $0.setImage(Asset._24px.Arrow.right.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g400
            $0.contentMode = .scaleAspectFit
            $0.contentHorizontalAlignment = .fill
            $0.contentVerticalAlignment = .fill
        }

        rightTextBtn.do {
            $0.setTitle(MenualString.search_button_delete_all_search_menual, for: .normal)
            $0.titleLabel?.font = .AppBodyOnlyFont(.body_2).withSize(12)
            $0.setTitleColor(Colors.grey.g500, for: .normal)
        }
    }
    
    private func setViews() {
        addSubview(titleLabel)
        addSubview(rightArrowBtn)
        addSubview(rightTextBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.height.equalTo(22)
        }
        titleLabel.sizeToFit()
        
        rightArrowBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalTo(titleLabel)
            // make.top.bottom.equalToSuperview()
        }
        
        rightTextBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(90)
            make.height.equalTo(15)
        }
        rightTextBtn.sizeToFit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.text = title

        switch type {
        case .text:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            
        case .textandicon:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400
            
        case .datepageandicon:
            titleLabel.isHidden = false
            
            titleLabel.font = UIFont.AppHead(.head_4)
            titleLabel.textColor = Colors.grey.g600

        case .search:
            titleLabel.isHidden = false
            
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g500
            
            if title.count > 6 {
                let attributedString = NSMutableAttributedString(string: title)
                let range = title.count - 6
                let number = (title as NSString).substring(with: NSMakeRange(6, range))

                attributedString.addAttribute(.foregroundColor, value: Colors.tint.main.v600, range: (title as NSString).range(of: number))
                titleLabel.attributedText = attributedString
            }

            
        // 메인 홈
        case .main:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g400

            // pageNumber가 0, 즉 작성한 메뉴얼이 없을 경우
            if pageNumber == 0 {
                titleLabel.text = title
            } else {
                titleLabel.text = title + " P. \(pageNumber)"
                guard let text = titleLabel.text else { return }
                
                let attributedString = NSMutableAttributedString(string: text)
                // MY MENUAL의 타이틀의 카운트로 한 거니까, 다국어 지원 할 경우에는 코드 변경 필요

                var range = 0
                var number = ""
                switch title {
                case MenualString.home_title_my_menual:
                    range = text.count - 10
                    // MY MENUAL ''P.00]''
                    number = (text as NSString).substring(with: NSMakeRange(10, range))
                case MenualString.home_title_total_page:
                    range = text.count - 6
                    number = (text as NSString).substring(with: NSMakeRange(6, range))
                default:
                    range = text.count
                    number = ""
                }

                attributedString.addAttribute(.foregroundColor,
                                              value: Colors.tint.main.v600,
                                              range: (text as NSString).range(of: number))
                titleLabel.attributedText = attributedString
            }

        case .myPage:
            titleLabel.isHidden = false
            titleLabel.font = UIFont.AppHead(.head_5)
            titleLabel.textColor = Colors.grey.g500
            
        }
        
        switch detailType {
        case .none:
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true

        case .arrow:
            rightArrowBtn.isHidden = false
            rightTextBtn.isHidden = true
            
        case .searchDelete:
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = false

        case .empty:
            break
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout, body: {
    let listHeader = ListHeader(type: .text, rightIconType: .arrow)
    listHeader.title = "안녕하세요!"
    return listHeader
})
