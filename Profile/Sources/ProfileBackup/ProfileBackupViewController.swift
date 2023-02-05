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

public protocol ProfileBackupPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func saveZip()
}

final class ProfileBackupViewController: UIViewController, ProfileBackupViewControllable {

    weak var listener: ProfileBackupPresentableListener?
    private let disposeBag = DisposeBag()
    
    lazy var naviView = MenualNaviView(type: .backup)
    lazy var tempBoxButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large)
    
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
    
    func setViews() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }

        tempBoxButton.do {
            $0.title = "메뉴얼 백업하기"
            $0.addTarget(self, action: #selector(pressedBackupBtn), for: .touchUpInside)
        }

        self.view.addSubview(naviView)
        self.view.addSubview(tempBoxButton)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        tempBoxButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(100)
            make.height.equalTo(56)
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
        listener?.saveZip()
    }
}

// MARK: - 파일 공유
extension ProfileBackupViewController: UIDocumentPickerDelegate {
    @objc func showShareSheet(path: String) {
        print("ProfileHome :: path! = \(path)")
        let fileURL = NSURL(fileURLWithPath: path)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
