//
//  ProfileBackupViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit

public protocol ProfileBackupPresentableListener: AnyObject {

}

final class ProfileBackupViewController: UIViewController, ProfileBackupPresentable, ProfileBackupViewControllable {

    weak var listener: ProfileBackupPresentableListener?
    
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
    }
}

// MARK: - 파일 공유
extension ProfileBackupViewController: UIDocumentPickerDelegate {
    func showShareSheet(path: String) {
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
