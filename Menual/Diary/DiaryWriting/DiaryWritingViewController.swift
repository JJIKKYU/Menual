//
//  DiaryWritingViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import SnapKit
import UIKit

protocol DiaryWritingPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn()
    func writeDiary(info: DiaryModel)
}

final class DiaryWritingViewController: UIViewController, DiaryWritingPresentable, DiaryWritingViewControllable  {

    weak var listener: DiaryWritingPresentableListener?
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.Arrow.back.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedBackBtn)
    }
    
    lazy var rightBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.check.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedCheckBtn)
    }
    
    lazy var titleTextField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.placeholder = "2022.02.02"
        $0.font = UIFont.AppTitle(.title_5)
    }
    
    lazy var descriptionTextView = UITextView().then {
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .white
        $0.typingAttributes = UIFont.AppBody(.body_4, .lightGray)
        $0.backgroundColor = .gray
        $0.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
        view.backgroundColor = .white
        setViews()
        print("DiaryWriting!")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    func setViews() {
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        title = MenualString.title_menual
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        view.backgroundColor = .black
        
        self.view.addSubview(titleTextField)
        self.view.addSubview(descriptionTextView)
        
        titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }
    }

    @objc
    func pressedBackBtn() {
        print("pressedBackBtn!")
        listener?.pressedBackBtn()
    }
    
    @objc
    func pressedCheckBtn() {
        print("PressedCheckBtn!")
        guard let title = self.titleTextField.text,
              let description = self.descriptionTextView.text
        else { return }
        
        let diaryModel = DiaryModel(title: title,
                                    weather: "웨덩아",
                                    location: description,
                                    description: description,
                                    image: "이미징"
        )
        listener?.writeDiary(info: diaryModel)
    }
}

extension DiaryWritingViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다." {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
            textView.textColor = .lightGray
        }
    }
}
