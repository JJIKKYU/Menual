//
//  DiaryMomentsViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/03.
//

import RIBs
import RxSwift
import UIKit

protocol DiaryMomentsPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn()
}

final class DiaryMomentsViewController: UIViewController, DiaryMomentsPresentable, DiaryMomentsViewControllable {
    
    weak var listener: DiaryMomentsPresentableListener?
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.Arrow.back.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedBackBtn)
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
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    func setViews() {
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        title = MenualString.title_moments
        navigationItem.leftBarButtonItem = leftBarButtonItem
        view.backgroundColor = .gray
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn()
    }
}
