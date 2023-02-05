//
//  ProfileRestoreViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit
import DesignSystem

public protocol ProfileRestorePresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    
    func restoreDiary(url: URL)
}

final class ProfileRestoreViewController: UIViewController, ProfileRestorePresentable, ProfileRestoreViewControllable {

    weak var listener: ProfileRestorePresentableListener?
    private let disposeBag = DisposeBag()

    lazy var naviView = MenualNaviView(type: .myPage)
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

        tempBoxButton.do {
            $0.title = "메뉴얼 가져오기"
            $0.addTarget(self, action: #selector(pressedRestoreBtn), for: .touchUpInside)
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
}

// MARK: - IBAction
extension ProfileRestoreViewController {
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func pressedRestoreBtn() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
        documentPicker.delegate = self
        // documentPicker.directoryURL = .homeDirectory
        present(documentPicker, animated: true, completion: nil)
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
        
        print("ProfileRestore :: url = \(fileURL)")
        listener?.restoreDiary(url: fileURL)
    }
}
