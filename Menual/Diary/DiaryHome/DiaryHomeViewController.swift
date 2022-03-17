//
//  DiaryHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol DiaryHomePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {

    weak var listener: DiaryHomePresentableListener?
    
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
        view.backgroundColor = .clear
        print("DiaryHome!")
        
        title = "MENUAL"
        
        // TBD 나중에 따로 변수로 만들어서 제작할 것
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(pressedSearchBtn))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(pressedMyPageBtn))
    }
    
    @objc
    func pressedSearchBtn() {
        print("pressedSearchBtn!")
    }
    
    @objc
    func pressedMyPageBtn() {
        print("pressedMyPageBtn!")
    }
}
