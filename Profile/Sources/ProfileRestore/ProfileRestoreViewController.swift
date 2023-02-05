//
//  ProfileRestoreViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit

public protocol ProfileRestorePresentableListener: AnyObject {
    
}

final class ProfileRestoreViewController: UIViewController, ProfileRestorePresentable, ProfileRestoreViewControllable {

    weak var listener: ProfileRestorePresentableListener?
    
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
