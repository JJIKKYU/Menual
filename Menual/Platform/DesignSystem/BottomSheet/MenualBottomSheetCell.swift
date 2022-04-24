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
    
    var iconView = UIImageView().then {
        $0.tintColor = Colors.tint.sub.n400
        $0.contentMode = .scaleAspectFit
    }
    
    let selectedView = UIView().then {
        $0.backgroundColor = Colors.grey.g800
        $0.layer.cornerRadius = 8
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
            }
        }
        
    }
    
    func selected() {
        selectedView.isHidden = false
    }
    
    func unSelected() {
        selectedView.isHidden = true
    }
}
