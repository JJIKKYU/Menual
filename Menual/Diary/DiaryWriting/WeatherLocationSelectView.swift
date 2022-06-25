//
//  WeatherLocationSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then

enum SelectedWeatherLocationType {
    case weather
    case location
}

class WeatherLocationSelectView: UIView {
    
    var selected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    var selectedWeatherLocationType: SelectedWeatherLocationType = .weather {
        didSet { setNeedsLayout() }
    }
    
    var selectImage: UIImage = UIImage() {
        didSet { setNeedsLayout() }
    }
    
    var selectTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    
    private let selectImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    
    private let selectLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
    }
    
    private lazy var deleteBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedDeleteBtn), for: .touchUpInside)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type: SelectedWeatherLocationType) {
        self.init()
        self.selectedWeatherLocationType = type
    }
    
    func setViews() {
        addSubview(selectImageView)
        addSubview(selectLabel)
        addSubview(deleteBtn)
        
        selectImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        selectLabel.snp.makeConstraints { make in
            make.leading.equalTo(selectImageView.snp.trailing).offset(8)
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch selectedWeatherLocationType {
        case .weather:
            switch selected {
            case true:
                selectImageView.image = selectImage
                selectImageView.tintColor = Colors.tint.sub.n800
                selectLabel.textColor = Colors.grey.g400
                selectLabel.text = selectTitle
                deleteBtn.isHidden = false
                
            case false:
                selectImageView.image = Asset._24px.weather.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                selectLabel.textColor = Colors.grey.g600
                selectLabel.text = "오늘 날씨는 어땠나요?"
                deleteBtn.isHidden = true
            }
            
        case .location:
            switch selected {
            case true:
                selectImageView.image = selectImage
                selectImageView.tintColor = Colors.tint.sub.n800
                selectLabel.textColor = Colors.grey.g400
                selectLabel.text = selectTitle
                deleteBtn.isHidden = false
                
            case false:
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                selectLabel.textColor = Colors.grey.g600
                selectLabel.text = "지금 장소는 어디신가요?"
                deleteBtn.isHidden = true
            }
        }
    }
    
    @objc
    func pressedDeleteBtn() {
        selected = false
    }
}
