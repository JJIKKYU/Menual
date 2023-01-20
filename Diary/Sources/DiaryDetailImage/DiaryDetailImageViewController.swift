//
//  DiaryDetailImageViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit
import DesignSystem

public protocol DiaryDetailImagePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
}

final class DiaryDetailImageViewController: UIViewController, DiaryDetailImagePresentable, DiaryDetailImageViewControllable {

    weak var listener: DiaryDetailImagePresentableListener?
    
    lazy var naviView = MenualNaviView(type: .detailImage).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    private let imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .black
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 10.0
        $0.delegate = self
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            print("Navi :: !!?")
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        
        scrollView.delegate = nil
    }
    
    func setViews() {
        view.backgroundColor = .black
    
        view.addSubview(naviView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(54)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func setImage(imageData: Data) {
        print("DiaryDetailImage :: setImage! = \(imageData)")
        imageView.image = UIImage(data: imageData)
    }
}

// MARK: - IBAction
extension DiaryDetailImageViewController {
    @objc
    func pressedBackBtn() {
        print("DiaryDetailImage :: pressedBackBtn")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - ScrollViewDelegate
extension DiaryDetailImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
