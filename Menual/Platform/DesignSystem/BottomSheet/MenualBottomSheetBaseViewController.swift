//
//  MenualBottomSheet.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import Foundation
import Then
import SnapKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
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
        
        bottomSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(bottomSheetHeight)
            make.height.equalTo(bottomSheetHeight)
        }
    }
    
    @objc
    internal func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
    }
    
    internal func hideBottomSheetAndGoBack() {
        // originalBottomSheetHieght = 0
        bottomSheetView.snp.updateConstraints { make in
            // make.height.equalTo(originalBottomSheetHieght)
            make.bottom.equalToSuperview().offset(originalBottomSheetHieght)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("bottomSheet isHide!")
        }
    }
    
    internal func showBottomSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom
        print("safeAreaHeight = \(safeAreaHeight), bottomPadding = \(bottomPadding)")
        
        originalBottomSheetHieght = bottomSheetHeight
        bottomSheetView.snp.updateConstraints { make in
            make.height.equalTo(originalBottomSheetHieght)
        }
        self.view.layoutIfNeeded()
        
        bottomSheetView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0.1
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("bottomSheet isShow!")
        }

        
    }
}
