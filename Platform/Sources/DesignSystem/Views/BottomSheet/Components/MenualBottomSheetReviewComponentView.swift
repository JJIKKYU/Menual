//
//  MenualBottomSheetReviewComponentView.swift
//  
//
//  Created by 정진균 on 2023/04/17.
//

import UIKit
import Then
import SnapKit

public protocol MenualBottomSheetReviewComponentViewDelegate: AnyObject {
    func pressedPraiseBtn()
    func pressedInquiryBtn()
}

public class MenualBottomSheetReviewComponentView: UIView {
    
    public weak var delegate: MenualBottomSheetReviewComponentViewDelegate?
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g100
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "메뉴얼 사용은 즐거우신가요?"
    }

    private let imageView = UIImageView().then {
        $0.image = Asset.Illurstration.suggestReview.image
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.numberOfLines = 2
        $0.textColor = Colors.grey.g100
        $0.text = "여러분의 목소리를 통해\n더 나은 메뉴얼을 제공해드릴게요!"
        $0.textAlignment = .center
        $0.setLineHeight(lineHeight: 1.24)
    }
    
    private lazy var reviewBtn = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large).then {
        $0.addTarget(self, action: #selector(pressedReviewBtn), for: .touchUpInside)
        $0.title = "칭찬하기"
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var inquiryBtn = UIButton().then {
        $0.addTarget(self, action: #selector(pressedInquiryBtn), for: .touchUpInside)
        $0.titleLabel?.textColor = Colors.grey.g200
        $0.titleLabel?.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.setTitle("건의하기", for: .normal)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(subTitleLabel)
        addSubview(reviewBtn)
        addSubview(inquiryBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(45)
            make.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(40)
        }
        
        reviewBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(16)
        }
        
        inquiryBtn.snp.makeConstraints { make in
            make.top.equalTo(reviewBtn.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
}

extension MenualBottomSheetReviewComponentView {
    @objc
    func pressedReviewBtn() {
        delegate?.pressedPraiseBtn()
    }
    
    @objc
    func pressedInquiryBtn() {
        delegate?.pressedInquiryBtn()
    }
}
