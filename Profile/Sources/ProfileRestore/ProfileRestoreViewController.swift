//
//  ProfileRestoreViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit
import Foundation
import DesignSystem

public protocol ProfileRestorePresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedBackupBtn(url: URL?)
}

final class ProfileRestoreViewController: UIViewController, ProfileRestoreViewControllable {

    weak var listener: ProfileRestorePresentableListener?
    private let disposeBag = DisposeBag()

    lazy var naviView = MenualNaviView(type: .restore)
    lazy var bottomBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    private let scrollView = UIScrollView(frame: .zero)
    private let noticeLabel = UILabel(frame: .zero)
    private let restoreOrderTitleLabel = UILabel(frame: .zero)
    private let restoreOrderLabel = UILabel(frame: .zero)
    
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
}

// MARK: - UI
extension ProfileRestoreViewController {
    func setViews() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }

        bottomBoxButton.do {
            $0.title = "가져올 파일 선택하기"
            $0.addTarget(self, action: #selector(pressedRestoreBtn), for: .touchUpInside)
        }
        
        scrollView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        noticeLabel.do {
            $0.lineBreakStrategy = .hangulWordPriority
            $0.numberOfLines = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text =
            """
            ・ 메뉴얼을 불러오면 이전에 기록한 메뉴얼들은 모두 삭제돼요.
            ・ 삭제된 메뉴얼은 복원할 수 없어요. 백업 파일을 확인하고 메뉴얼 가져오기를 진행해주세요.
            ・ 아이클라우드에서 파일을 불러올 경우 인터넷 연결 상태를 확인해주세요.
            """
            $0.setLineHeight(lineHeight: 1.44)
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g300
        }
        
        restoreOrderTitleLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "메뉴얼 가져오기 순서"
            $0.font = UIFont.AppTitle(.title_3)
            $0.textColor = Colors.grey.g100
        }
        
        restoreOrderLabel.do {
            $0.lineBreakStrategy = .hangulWordPriority
            $0.numberOfLines = 0
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text =
            """
            1. 하단의 [파일 선택하기] 버튼을 눌러주세요.
            2. 팝업창에서 불러올 파일을 선택해주세요
               메뉴얼의 백업 파일은 '.zip' 형식이에요.
            3. [메뉴얼 가져오기] 버튼을 눌러 불러오기를 진행해주세요.
            4. 메뉴얼 가져오기가 완료됐어요 :)
            """
            $0.setLineHeight(lineHeight: 1.44)
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g300
        }

        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(noticeLabel)
        scrollView.addSubview(restoreOrderTitleLabel)
        scrollView.addSubview(restoreOrderLabel)

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
        
        restoreOrderTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(noticeLabel.snp.bottom).offset(40)
        }
        
        restoreOrderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(restoreOrderTitleLabel.snp.bottom).offset(8)
        }
    }
}

// MARK: - IBAction
extension ProfileRestoreViewController {
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func pressedRestoreBtn() {
        listener?.pressedBackupBtn(url: nil)
        /*
        DispatchQueue.main.async {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
            
            documentPicker.delegate = self
            // documentPicker.directoryURL = .homeDirectory
            self.present(documentPicker, animated: true, completion: nil)
        }
         */

    }
}

// MARK: - UIDocumentPickerViewControllerDelegate
extension ProfileRestoreViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("ProfileRestore :: cancelled!")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("ProfileRestore :: picker!")
        guard let fileURL = urls.first else { return }

        // Start accessing a security-scoped resource.
        guard fileURL.startAccessingSecurityScopedResource() else {
            return
        }

        print("ProfileRestore :: url = \(fileURL)")
        listener?.pressedBackupBtn(url: fileURL)
        
        // Make sure you release the security-scoped resource when you finish.
        fileURL.stopAccessingSecurityScopedResource()
    }
}

// MARK: - DialogDelegate
extension ProfileRestoreViewController: DialogDelegate {
    func exit(titleText: String) {
        
    }
    
    func action(titleText: String) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
