//
//  MenualBottomSheetCell.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import UIKit
import SnapKit
import Then

class MenualBottomSheetCell: UICollectionViewCell {
    var weatherIconType: Weather? {
        didSet {
            layoutSubviews()
        }
    }
    
    var placeIconType: Place? {
        didSet {
            layoutSubviews()
        }
    }
    
    var cellIsSelected: Bool = false
    
    var iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if cellIsSelected {
                if isHighlighted {
                    selectedView.backgroundColor = Colors.grey.g700
                    iconView.tintColor = Colors.grey.g400
                    selectedView.layer.borderWidth = 1
                } else {
                    selected()
                }
            } else {
                if isHighlighted {
                    selectedView.backgroundColor = Colors.grey.g700
                    iconView.tintColor = Colors.grey.g400
                    selectedView.layer.borderWidth = 1
                } else {
                    unSelected()
                }
            }
            
            
        }
    }
    
    let selectedView = UIView().then {
        $0.layer.borderColor = Colors.grey.g600.cgColor
        $0.AppCorner(._4pt)
        $0.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    func setViews() {
        print("MenualBottomSheetCell setViews!")
        
        addSubview(iconView)
        addSubview(selectedView)
        bringSubviewToFront(iconView)
        
        selectedView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("suvViews!")
        setIconView()
        print("weatherIconType = \(weatherIconType)")
    }
    
    func setIconView() {
        if let weatherIconType = weatherIconType {
            switch weatherIconType {
            case .cloud:
                iconView.image = Asset._24px.Weather.cloud.image.withRenderingMode(.alwaysTemplate)
            case .rain:
                iconView.image = Asset._24px.Weather.rain.image.withRenderingMode(.alwaysTemplate)
            case .snow:
                iconView.image = Asset._24px.Weather.snow.image.withRenderingMode(.alwaysTemplate)
            case .thunder:
                iconView.image = Asset._24px.Weather.thunder.image.withRenderingMode(.alwaysTemplate)
            case .sun:
                iconView.image = Asset._24px.Weather.sun.image.withRenderingMode(.alwaysTemplate)
            case .wind:
                iconView.image = Asset._24px.Weather.wind.image.withRenderingMode(.alwaysTemplate)
            }
        }
        
        
        if let placeIconType = placeIconType {
            switch placeIconType {
            case .car:
                iconView.image = Asset._24px.Place.car.image.withRenderingMode(.alwaysTemplate)
                
            case .company:
                iconView.image = Asset._24px.Place.company.image.withRenderingMode(.alwaysTemplate)
                
            case .home:
                iconView.image = Asset._24px.Place.home.image.withRenderingMode(.alwaysTemplate)
                
            case .place:
                iconView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
                
            case .school:
                iconView.image = Asset._24px.Place.school.image.withRenderingMode(.alwaysTemplate)
                
            case .bus:
                iconView.image = Asset._20px.Place.bus.image.withRenderingMode(.alwaysTemplate)
                
            case .subway:
                iconView.image = Asset._20px.Place.subway.image.withRenderingMode(.alwaysTemplate)
                
            case .store:
                iconView.image = Asset._20px.Place.store.image.withRenderingMode(.alwaysTemplate)
                
            case .travel:
                iconView.image = Asset._20px.Place.luggage.image.withRenderingMode(.alwaysTemplate)
            }
        }
        
    }
    
    func selected() {
        iconView.tintColor = Colors.tint.sub.n400
        selectedView.isHidden = false
        selectedView.layer.borderWidth = 0
        selectedView.backgroundColor = Colors.grey.g700
        cellIsSelected = true
    }
    
    func unSelected() {
        iconView.tintColor = Colors.grey.g400
        selectedView.isHidden = false
        selectedView.layer.borderWidth = 1
        selectedView.backgroundColor = .clear
        cellIsSelected = false
    }
}
