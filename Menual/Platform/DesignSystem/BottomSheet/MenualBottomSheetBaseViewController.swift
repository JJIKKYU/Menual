//
//  MenualBottomSheet.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import Foundation
import Then
import SnapKit

enum MenualBottomSheetRightBtnType {
    case close
    case check
}

enum MenualBottomSheetRightBtnIsActivate {
    case activate
    case unActivate
    case _default
}

enum MenualBottomSheetType {
    case weather
    case place
    case menu
    case calender
    case reminder
    case filter
}

protocol MenualBottomSheetBaseDelegate {
    // 애니메이션이 모두 끝나고 dismissed 될때 호출
    func dismissedBottomSheet()
}

class MenualBottomSheetBaseViewController: UIViewController {
    internal var bottomSheetTitle: String = "" {
        didSet { layoutUpdate() }
    }
    
    internal var menualBottomSheetRightBtnType: MenualBottomSheetRightBtnType = .close {
        didSet { layoutUpdate() }
    }
    
    internal var menualBottomSheetRightBtnIsActivate: MenualBottomSheetRightBtnIsActivate = .unActivate {
        didSet { layoutUpdate() }
    }
    
    internal var menualBottomSheetType: MenualBottomSheetType = .weather {
        didSet { menualBottomSheetTypeLayoutUpdate() }
    }
    
    lazy private var dimmedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.withAlphaComponent(0.7)
        $0.alpha = 0
        
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        $0.addGestureRecognizer(dimmedTap)
        $0.isUserInteractionEnabled = true
    }
    
    internal let bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = "날씨를 선택해 주세요"
    }
    
    internal var rightBtn = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
    }
    
    private let divider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    public var bottomSheetHeight: CGFloat = 400
    private var originalBottomSheetHieght: CGFloat = 0
    
    var delegate: MenualBottomSheetBaseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        
        self.isModalInPresentation = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    private func setViews() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(titleLabel)
        bottomSheetView.addSubview(rightBtn)
        bottomSheetView.addSubview(divider)
        
        dimmedView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().inset(26)
            make.height.equalTo(20)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(24)
        }
        
        divider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(1)
        }
    }
    
    @objc
    internal func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    internal func hideBottomSheetAndGoBack() {
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] isShow in
            guard let self = self else { return }
            print("bottomSheet isHide!")
            self.delegate?.dismissedBottomSheet()
        }
    }
    
    internal func showBottomSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom
        print("safeAreaHeight = \(safeAreaHeight), bottomPadding = \(bottomPadding)")
        
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).inset(bottomSheetHeight)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 0.1
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("bottomSheet isShow!")
        }
    }
    
    func layoutUpdate() {
        titleLabel.text = bottomSheetTitle
        
        switch menualBottomSheetRightBtnType {
        case .close:
            rightBtn.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
        case .check:
            rightBtn.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        switch menualBottomSheetRightBtnIsActivate {
        case .unActivate:
            rightBtn.tintColor = Colors.grey.g600
            
        case .activate:
            rightBtn.tintColor = Colors.tint.sub.n400
            
        case ._default:
            rightBtn.tintColor = Colors.grey.g600
        }
    }
    
    func menualBottomSheetTypeLayoutUpdate() {
        print("!!! \(menualBottomSheetType)")
        switch menualBottomSheetType {
        case .weather:
            bottomSheetTitle = "날씨를 선택해 주세요"
            bottomSheetHeight = 130
            
        case .place:
            bottomSheetTitle = "장소를 선택해 주세요"
            bottomSheetHeight = 130

        case .calender:
            bottomSheetTitle = "날짜"
            bottomSheetHeight = 375
            
        case .filter:
            bottomSheetTitle = "필터"
            bottomSheetHeight = 392
            
        case .menu:
            bottomSheetTitle = "메뉴"
            bottomSheetHeight = 328
            
        case .reminder:
            bottomSheetTitle = "리마인더 알림"
            bottomSheetHeight = 592
        }
    }
}
