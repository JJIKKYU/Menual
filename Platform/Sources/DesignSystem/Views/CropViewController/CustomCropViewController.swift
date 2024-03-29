//
//  CustomCropViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/10/22.
//

import UIKit
import CropViewController
import Then
import SnapKit
import MenualUtil

public class CustomCropViewController: CropViewController {
    
    let notificationIdentifier: String = "StartCamera"
    
    public enum CropVCNaviViewType {
        case backArrow
        case close
    }
    
    public enum CropVCButtonType {
        case add
        case edit
    }
    
    public var cropVCNaviViewType: CropVCNaviViewType = .backArrow {
        didSet { setNaviViewType() }
    }
    
    public var cropVCButtonType: CropVCButtonType = .add {
        didSet { setButtonType() }
    }
    
    private lazy var naviView = MenualNaviView(type: .writePicture).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.rightButton1.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    private let doneButtonBackgorundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background
    }
    
    public lazy var customDoneButton = BoxButton(frame: .zero, btnStatus: .active, btnSize: .large).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.uploadimage_title_add
        $0.addTarget(self, action: #selector(pressedDoneBtn), for: .touchUpInside)
    }
    
    private let toolbarLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = MenualString.uploadimage_desc_thumb
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g200
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
    }
    
    func setViews() {
        // cropOverlayView.isUserInteractionEnabled = false
        
        aspectRatioPreset = .presetCustom
        customAspectRatio = CGSize(width: 335, height: 90)
        resetButtonHidden = true
        rotateButtonsHidden = true
        aspectRatioPickerButtonHidden = true
        aspectRatioLockEnabled = true
        // cropView.isUserInteractionEnabled = false
        doneButtonHidden = true
        cancelButtonHidden = true
        modalTransitionStyle = .coverVertical
        
        cropUIView.addSubview(naviView)
        doneButtonBackgorundView.addSubview(customDoneButton)
        cropUIView.addSubview(doneButtonBackgorundView)
        cropView.gridOverlayView.addSubview(toolbarLabel)
        // cropView.addSubview(doneButtonBackgorundView)
        // super.view.addSubview(naviView)
        print("이거? - \(self.presentingViewController)")
        
        cropView.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        doneButtonBackgorundView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(107)
        }
        
        customDoneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(48)
            make.top.equalToSuperview().offset(24)
        }
        
        toolbarLabel.snp.makeConstraints { make in
            make.top.equalTo(cropView.gridOverlayView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }

    func setNaviViewType() {
        DispatchQueue.main.async {
            switch self.cropVCNaviViewType {
            case .backArrow:
                self.naviView.naviViewType = .writePicture

            case .close:
                self.naviView.naviViewType = .writePictureClose
            }
            
            self.naviView.setNaviViewType()
        }
    }
    
    func setButtonType() {
        DispatchQueue.main.async {
            switch self.cropVCButtonType {
            case .add:
                self.customDoneButton.title = MenualString.uploadimage_button_select
            case .edit:
                self.customDoneButton.title = MenualString.uploadimage_button_edit
            }
        }
        
    }
}

// MARK: - IBAction
extension CustomCropViewController {
    @objc
    func pressedBackBtn() {
        // dismiss(animated: true)
        switch cropVCNaviViewType {
        case .backArrow:
            navigationController?.popViewController(animated: true)
        case .close:
            dismiss(animated: true)
        }
        
    }
    
    @objc
    func pressedDoneBtn() {
        print("pressedDoneBtn")
        doneButtonTappedSwift()
        
    }
}
