//
//  ProfileHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift
import UIKit

protocol ProfileHomePresentableListener: AnyObject {
    func pressedBackBtn()
}

final class ProfileHomeViewController: UIViewController, ProfileHomePresentable, ProfileHomeViewControllable {

    weak var listener: ProfileHomePresentableListener?
    
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
        view.backgroundColor = .red
        print("ProfileHome!")
        
        title = "MYPAGE"
        
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.Arrow.back.image,
//                                                           style: .done,
//                                                           target: self,
//                                                           action: #selector(pressedBackBtn))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn()
    }
}
