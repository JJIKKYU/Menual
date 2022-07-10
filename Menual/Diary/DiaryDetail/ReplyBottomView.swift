//
//  ReplyBottomView.swift
//  Menual
//
//  Created by 정진균 on 2022/07/10.
//

import UIKit
import SnapKit
import Then
import RxSwift

class ReplyBottomView: UIView {
    
    private let disposeBag = DisposeBag()
    
    var writedText: String = ""
    
    let replyTextView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isScrollEnabled = false
        $0.backgroundColor = Colors.grey.g700
        
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner,

        ]
        $0.clipsToBounds = true
        $0.text = "겹쓸내용을 입력해 주세요"
        $0.textColor = Colors.grey.g500
        $0.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 12, right: 47)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }
    
    let writeBtn = UIButton().then {
        $0.backgroundColor = Colors.tint.sub.n400
        $0.setImage(Asset._20px.write.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g500
//        $0.contentMode = .scaleAspectFit
//        $0.contentHorizontalAlignment = .fill
//        $0.contentVerticalAlignment = .fill
        $0.layer.cornerRadius = 14
    }


    init() {
        super.init(frame: CGRect.zero)
        setViews()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        layer.cornerRadius = 24
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner

        ]
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = Colors.grey.g700.cgColor
        backgroundColor = Colors.grey.g800
        
        AppShadow(.shadow_6)
        
        addSubview(replyTextView)
        addSubview(writeBtn)
        
        replyTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        writeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(replyTextView.snp.trailing).inset(6)
            make.bottom.equalTo(replyTextView.snp.bottom).inset(6)
            make.width.height.equalTo(28)
        }

    }
    
    func bind() {
        replyTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text == "겹쓸내용을 입력해 주세요" {
                    self.writeBtn.backgroundColor = .clear
                    self.writeBtn.isEnabled = false
                    return
                }
                
                self.writedText = text

                if text.count > 0 {
                    self.writeBtn.backgroundColor = Colors.tint.sub.n400
                    self.writeBtn.isEnabled = true
                } else {
                    self.writeBtn.backgroundColor = .clear
                    self.writeBtn.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
