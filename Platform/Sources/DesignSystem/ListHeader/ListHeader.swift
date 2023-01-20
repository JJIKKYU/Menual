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
    case filter
    case arrow
    case searchDelete
    case filterAndCalender
    
    // 공통
    case empty
}

public class ListHeader: UIView {
    
    private var type: ListHeaderType = .datepageandicon {
        didSet { setNeedsLayout() }
    }
    
    private var detailType: DetailType = .none {
        didSet { setNeedsLayout() }
    }
    
    public var title: String = "        " {
        didSet { setNeedsLayout() }
    }
    
    public var pageNumber: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    public var rightFilterBtnIsEnabled: Bool = false {
        didSet { setFilterIcon() }
    }
    
    public var rightCalendarBtnIsEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let rightArrowBtn = BaseButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Arrow.right.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g400
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    let rightFilterBtnBadge = Badges().then {
        $0.badgeType = .dot
    }
    let rightFilterBtn = BaseButton().then {
        $0.actionName = "filter"
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.filter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }
    
    public let rightTextBtn = BaseButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle(MenualString.search_button_delete_all_search_menual, for: .normal)
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
        $0.setTitleColor(Colors.grey.g500, for: .normal)
    }
    
    let rightCalenderBtnBadge = Badges().then {
        $0.badgeType = .dot
    }
    let rightCalenderBtn = BaseButton().then {
        $0.actionName = "calendarFilter"
        $0.isUserInteractionEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.calendar.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
    }

    public init(type: ListHeaderType, rightIconType: DetailType) {
        self.type = type
        self.detailType = rightIconType
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(rightArrowBtn)
        addSubview(rightFilterBtn)
        rightFilterBtn.addSubview(rightFilterBtnBadge)
        addSubview(rightTextBtn)
        addSubview(rightCalenderBtn)
        rightCalenderBtn.addSubview(rightCalenderBtnBadge)
        
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
        
        rightFilterBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalTo(titleLabel)
            // make.top.bottom.equalToSuperview()
        }
        
        rightFilterBtnBadge.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalTo(4)
        }
        
        rightTextBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(90)
            make.height.equalTo(15)
        }
        rightTextBtn.sizeToFit()
        
        rightCalenderBtnBadge.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.width.height.equalTo(4)
        }
        rightCalenderBtn.snp.makeConstraints { make in
            make.trailing.equalTo(rightFilterBtn.snp.leading).offset(-11)
            make.width.height.equalTo(24)
            make.centerY.equalTo(titleLabel)
        }
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
                let number = (title as NSString).substring(with: NSMakeRange(6, 1))
                
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
                switch title {
                case MenualString.home_title_my_menual:
                    range = text.count - 10
                case MenualString.home_title_total_page:
                    range = text.count - 10
                default:
                    range = text.count
                }

                // MY MENUAL ''P.00]''
                let number = (text as NSString).substring(with: NSMakeRange(10, range))
                
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
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true
            rightCalenderBtn.isHidden = true

        case .arrow:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = false
            rightTextBtn.isHidden = true
            rightCalenderBtn.isHidden = true
            
        case .filter:
            rightFilterBtn.isHidden = false
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true
            rightCalenderBtn.isHidden = true
            
        case .searchDelete:
            rightFilterBtn.isHidden = true
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = false
            rightCalenderBtn.isHidden = true
            
        case .filterAndCalender:
            rightFilterBtn.isHidden = false
            rightArrowBtn.isHidden = true
            rightTextBtn.isHidden = true
            rightCalenderBtn.isHidden = false

        case .empty:
            break
        }
    }
    
    // filter가 되었을 경우 우측 상단에 dot이 표시되도록
    func setFilterIcon() {
        print("ListHeader :: setFilterIcon -> \(rightFilterBtnIsEnabled)")
        switch rightFilterBtnIsEnabled {
        case true:
            rightFilterBtnBadge.show()

        case false:
            rightFilterBtnBadge.hide()
        }
        
        switch rightCalendarBtnIsEnabled {
        case true:
            rightCalenderBtnBadge.show()
        case false:
            rightCalenderBtnBadge.hide()
        }
    }
}
