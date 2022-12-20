//
//  DiarySearchView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import UIKit
import SnapKit
import Then
import RxSwift

class DiarySearchView: UIView {
    
    private var disposeBag = DisposeBag()
    
    private let defaultPlaceHolderText: String = "찾으려는 메뉴얼의 제목, 내용을 입력해주세요."
    
    lazy var textField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "메뉴얼의 제목 또는 내용을 입력해 주세요"
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g100
        $0.tintColor = Colors.tint.main.v200
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 24))
        $0.rightViewMode = .always
        $0.attributedPlaceholder = NSAttributedString(string: defaultPlaceHolderText,
                                                      attributes: [NSAttributedString.Key.foregroundColor : Colors.grey.g500])
    }
    
    private let searchImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = Asset._24px.search.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g300
        $0.contentMode = .scaleAspectFit
    }
    
    lazy var deleteBtn = UIButton().then {
        $0.actionName = "delete"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v400
        $0.isHidden = true
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
        addSubview(searchImageView)
        addSubview(textField)
        addSubview(deleteBtn)
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = Colors.tint.main.v400.cgColor
        clipsToBounds = true
        backgroundColor = Colors.grey.g800

        searchImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(24)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalTo(searchImageView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.height.equalTo(15)
            make.width.equalToSuperview().inset(20)
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    func bind() {
        textField.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { text in
                let count = text?.count ?? 0
                if count == 0 {
                    self.deleteBtn.isHidden = true
                } else {
                    self.deleteBtn.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
