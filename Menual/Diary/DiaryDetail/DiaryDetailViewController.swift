//
//  DiaryDetailViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol DiaryDetailPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn()
}

final class DiaryDetailViewController: UIViewController, DiaryDetailPresentable, DiaryDetailViewControllable {

    weak var listener: DiaryDetailPresentableListener?
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.Arrow.back.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedBackBtn)
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.black
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.tint.main.v200
        $0.text = "텍스트입ㄴ다"
    }
    
    let testLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.tint.main.v200
        $0.text = "텍스트입ㄴ다"
    }
    
    lazy var descriptionTextLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = .white
        $0.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
        $0.backgroundColor = .red
        $0.numberOfLines = 0

    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(titleLabel)
        self.scrollView.addSubview(testLabel)
        self.scrollView.addSubview(descriptionTextLabel)
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        testLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        
        descriptionTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(testLabel.snp.bottom).offset(40)
        }
    }
    
    func loadDiaryDetail(model: DiaryModel) {
        print("viewcontroller : \(model)")
        self.titleLabel.text = model.title
        self.testLabel.text = "\(model.weather), \(model.location)"
        self.descriptionTextLabel.text = model.description
        self.descriptionTextLabel.setLineHeight()
        descriptionTextLabel.sizeToFit()
    }
    
    @objc
    func pressedBackBtn() {
        print("pressedBackBtn!")
        listener?.pressedBackBtn()
    }
}
