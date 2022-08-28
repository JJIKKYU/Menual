//
//  WeatherPlaceSelectViewCell.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import Then
import SnapKit

class WeatherPlaceSelectViewCell: UICollectionViewCell {
    
    var weatherPlaceSelectViewCellType: WeatherPlaceSelectView.WeatherPlaceType = .place {
        didSet { setNeedsLayout() }
    }
    
    var placeIconType: Place? {
        didSet { setNeedsLayout() }
    }
    
    var weatherIconType: Weather? {
        didSet { setNeedsLayout() }
    }
    
    override var isSelected: Bool {
        didSet { setNeedsLayout() }
    }
    
    var image = UIImage() {
        didSet { setNeedsLayout() }
    }
    
    private let buttonImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._24px.Weather.cloud.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Colors.grey.g500
    }
    
    private let wrappedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
        $0.AppCorner(._4pt)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        setViews()
        // 여기서 init 진행
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setViews() {
        addSubview(wrappedView)
        addSubview(buttonImageView)
        
        wrappedView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
        
        buttonImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonImageView.image = image
        
        switch isSelected {
        case true:
            buttonImageView.tintColor = Colors.grey.g800
            wrappedView.backgroundColor = Colors.tint.sub.n400
        case false:
            buttonImageView.tintColor = Colors.grey.g500
            wrappedView.backgroundColor = Colors.grey.g700
        }
        
        if weatherPlaceSelectViewCellType == .place,
           let placeIconType = placeIconType {

            print("WeatherPlaceSelectViewCell :: placeIconType = \(placeIconType)")
            self.placeIconType = placeIconType
            switch placeIconType {
            case .place:
                buttonImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
            case .car:
                buttonImageView.image = Asset._24px.Place.car.image.withRenderingMode(.alwaysTemplate)
            case .company:
                buttonImageView.image = Asset._24px.Place.company.image.withRenderingMode(.alwaysTemplate)
            case .home:
                buttonImageView.image = Asset._24px.Place.home.image.withRenderingMode(.alwaysTemplate)
            case .school:
                buttonImageView.image = Asset._24px.Place.school.image.withRenderingMode(.alwaysTemplate)
            }
        }
        
        if weatherPlaceSelectViewCellType == .weather,
           let weatherIconType = weatherIconType {

            print("WeatherPlaceSelectViewCell :: weatherIconType = \(weatherIconType)")
            switch weatherIconType {
            case .sun:
                buttonImageView.image = Asset._24px.Weather.sun.image.withRenderingMode(.alwaysTemplate)
            case .rain:
                buttonImageView.image = Asset._24px.Weather.rain.image.withRenderingMode(.alwaysTemplate)
            case .cloud:
                buttonImageView.image = Asset._24px.Weather.cloud.image.withRenderingMode(.alwaysTemplate)
            case .snow:
                buttonImageView.image = Asset._24px.Weather.snow.image.withRenderingMode(.alwaysTemplate)
            case .thunder:
                buttonImageView.image = Asset._24px.Weather.thunder.image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
