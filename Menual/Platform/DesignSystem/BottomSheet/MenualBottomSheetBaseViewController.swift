//
//  MenualBottomSheet.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import Foundation
import Then
import SnapKit

protocol MenualBottomSheetBaseDelegate {
    // 애니메이션이 모두 끝나고 dismissed 될때 호출
    func dismissedBottomSheet()
}

class MenualBottomSheetBaseViewController: UIViewController {
    lazy private var dimmedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.withAlphaComponent(0.7)
        $0.alpha = 0
        
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        $0.addGestureRecognizer(dimmedTap)
        $0.isUserInteractionEnabled = true
    }
    
    public let bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
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
        
        dimmedView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let topConstant = view.safeAreaInsets.bottom + view.safeAreaLayoutGuide.layoutFrame.height
        bottomSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        print("topConstatn = \(topConstant)")
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
            make.top.equalTo(view.snp.bottom).inset(350)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 0.1
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("bottomSheet isShow!")
        }

        
    }
}
