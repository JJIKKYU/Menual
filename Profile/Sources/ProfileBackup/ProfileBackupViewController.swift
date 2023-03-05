//
//  ProfileBackupViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit
import DesignSystem
import MenualEntity

public protocol ProfileBackupPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func saveZip()
    func addOrUpdateBackupHistory()
    
    func checkIsBackupEnabled() -> Bool
    var backupHistoryModelRealm: BackupHistoryModelRealm? { get }
}

final class ProfileBackupViewController: UIViewController, ProfileBackupViewControllable {

    weak var listener: ProfileBackupPresentableListener?
    private let disposeBag = DisposeBag()
    
    private let naviView = MenualNaviView(type: .backup)
    private let bottomBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    private let scrollView = UIScrollView(frame: .zero)
    private let noticeTextView = UITextView(frame: .zero)
    private let noticeLabel = UILabel(frame: .zero)
    private let backupOrderTitleLabel = UILabel(frame: .zero)
    private let backupOrderLabel = UILabel(frame: .zero)
    private let currentBackupTitleLabel = UILabel(frame: .zero)
    private let currentBackupStatusView = CurrentBackupStatusView(type: .backup)
    
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
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setViews()
        configueBackupHistoryUI()
    }
    
    func setViews() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }

        bottomBoxButton.do {
            $0.title = "메뉴얼 백업하기"
            $0.addTarget(self, action: #selector(pressedBackupBtn), for: .touchUpInside)
        }
        
        scrollView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        noticeTextView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text =
            """
            ・현재까지 작성하신 모든 메뉴얼을 백업할 수 있어요.
            ・아이폰에 백업할 경우, 남은 저장 공간이 충분한지 확인해주세요.
            ・아이클라우드에 백업할 경우, 인터넷이 제대로 연결되어 있는지 확인해주세요.
            """
            $0.attributedText = UIFont.AppBodyWithText(.body_2, Colors.grey.g300, text: $0.text)
            $0.textColor = Colors.grey.g300
        }
        
        noticeLabel.do {
            $0.lineBreakStrategy = .hangulWordPriority
            $0.numberOfLines = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text =
            """
            ・ 현재까지 작성하신 모든 메뉴얼을 백업할 수 있어요.
            ・ 아이폰에 백업할 경우, 남은 저장 공간이 충분한지 확인해주세요.
            ・ 아이클라우드에 백업할 경우, 인터넷이 제대로 연결되어 있는지 확인해주세요.
            """
            $0.setLineHeight(lineHeight: 1.44)
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g300
        }
        
        backupOrderTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "메뉴얼 백업 순서"
            $0.font = UIFont.AppTitle(.title_3)
            $0.textColor = Colors.grey.g100
        }
        
        backupOrderLabel.do {
            $0.lineBreakStrategy = .hangulWordPriority
            $0.numberOfLines = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text =
            """
            1. 하단의 [백업 시작하기] 버튼을 눌러주세요.
            2. 팝업창에서 ‘파일에 저장' 항목을 선택해주세요.
            3. 원하는 위치에 메뉴얼 백업 파일을 저장해주세요.
            4. 메뉴얼 백업이 완료됐어요 :)
            """
            $0.setLineHeight(lineHeight: 1.44)
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g300
        }
        
        currentBackupTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "최근 백업한 메뉴얼 정보"
            $0.font = UIFont.AppTitle(.title_3)
            $0.textColor = Colors.grey.g100
        }
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(noticeTextView)
        scrollView.addSubview(noticeLabel)
        scrollView.addSubview(backupOrderTitleLabel)
        scrollView.addSubview(backupOrderLabel)
        scrollView.addSubview(currentBackupTitleLabel)
        scrollView.addSubview(currentBackupStatusView)

        self.view.addSubview(bottomBoxButton)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        bottomBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(56)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom)
            make.leading.width.bottom.equalToSuperview()
        }
        
        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(24)
        }
        
        backupOrderTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(noticeLabel.snp.bottom).offset(40)
        }
        
        backupOrderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(backupOrderTitleLabel.snp.bottom).offset(8)
        }
        
        currentBackupTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(backupOrderLabel.snp.bottom).offset(40)
        }
        
        
        currentBackupStatusView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(currentBackupTitleLabel.snp.bottom).offset(8)
        }
    }
    
    func configueBackupHistoryUI() {
        // backupHistory가 있을 경우
        if let backupHistoryModelRealm = listener?.backupHistoryModelRealm {
            currentBackupStatusView.isVaildBackupStatus = true
            currentBackupStatusView.backupHistoryModelRealm = backupHistoryModelRealm
        } else {
            currentBackupStatusView.isVaildBackupStatus = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
}

// MARK: - ProfileBacupPresentable
extension ProfileBackupViewController: ProfileBackupPresentable {
    
}

// MARK: - IBAction
extension ProfileBackupViewController {
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func pressedBackupBtn() {
        guard let isEnable = listener?.checkIsBackupEnabled() else { return }
        switch isEnable {
        // 백업할 파일이 있을 경우 백업 진행
        case true:
            listener?.saveZip()
        
        // 백업할 파일이 없을 경우 팝업
        case false:
            show(size: .medium,
                 buttonType: .oneBtn,
                 titleText: "백업할 수 있는 메뉴얼이 없어요",
                 subTitleText: "메뉴얼을 작성하고 백업을 진행해주세요.",
                 confirmButtonText: "확인"
            )
        }
    }
}

// MARK: - 파일 공유
extension ProfileBackupViewController {
    @objc func showShareSheet(path: String) {
        print("ProfileHome :: path! = \(path)")
        let fileURL = NSURL(fileURLWithPath: path)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { [weak self] activity, success, items, error in
            guard let self = self else { return }
            print("ProfileBackup :: activity: \(activity), success: \(success), items: \(items), error: \(error)")
            // 저장에 성공했을 때만 DB에 저장
            if success {
                self.listener?.addOrUpdateBackupHistory()
            }
        }
    

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - Dialog
extension ProfileBackupViewController: DialogDelegate {
    func action(titleText: String) {
        
    }
    
    func exit(titleText: String) {
        
    }
}
