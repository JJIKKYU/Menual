//
//  ProfileDeveloperViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit
import RxRelay


protocol ProfileDeveloperPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
    
    var tempMenualSetRelay: BehaviorRelay<Bool?> { get }
    var reminderDataCallRelay: BehaviorRelay<Bool?> { get }
}

final class ProfileDeveloperViewController: UIViewController, ProfileDeveloperPresentable, ProfileDeveloperViewControllable {
    
    private let tableviewDataArr = [
        "테스트 게시글 30개 세팅",
        "리마인더 적용 데이터 목록"
    ]

    weak var listener: ProfileDeveloperPresentableListener?
    private let disposeBag = DisposeBag()
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "개발자 도구"
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    lazy var textView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
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
        view.backgroundColor = Colors.background
        setViews()
        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(tableView)
        self.view.addSubview(textView)
        // self.view.addSubview(scrollView)
        
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.bottom.equalTo(textView.snp.top)
        }
        
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview()
        }
    }
    
    func bind() {
        listener?.tempMenualSetRelay
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                guard let data = data else { return }

                // 완료되었다
                if data == false {
                    self.textView.text = "테스트 게시글 세팅을 요청합니다 -> 완료되었습니다."
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - UITableviewDelegate
extension ProfileDeveloperViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableviewDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(tableviewDataArr[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? UITableViewCell else { return }
        
        guard let text: String = cell.textLabel?.text else { return }
        
        // 테스트 게시글 30개 세팅
        if text == tableviewDataArr[0] {
            textView.text = "테스트 게시글 세팅을 요청합니다"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.listener?.tempMenualSetRelay.accept(true)
            }
            
        }
        // Reminder 목록 호출
        else if text == tableviewDataArr[1] {
            
        }
    }
}
