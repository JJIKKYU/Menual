//
//  WeatherPlcaeToolbarView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then

protocol WeatherPlaceToolbarViewDelegate {
    func weatherSendData(weatherType: Weather)
    func placeSendData(placeType: Place)
}

class WeatherPlcaeToolbarView: UIView {
    
    var delegate: WeatherPlaceToolbarViewDelegate?
    
    var menualBottomSheetRightBtnIsActivate: MenualBottomSheetRightBtnIsActivate = .unActivate {
        didSet { setNeedsLayout() }
    }
    
    var weatherPlaceType: WeatherPlaceSelectView.WeatherPlaceType = .weather {
        didSet { setNeedsLayout() }
    }
    
    var selectedWeatherType: Weather? {
        didSet { setNeedsLayout() }
    }
    var selectedPlaceType: Place? {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = "날씨를 선택해 주세요"
    }
    
    private var rightBtn = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
    }
    
    private let divider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    private lazy var weatherPlaceSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = .black
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(titleLabel)
        addSubview(rightBtn)
        addSubview(divider)
        addSubview(weatherPlaceSelectView)
        
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
        
        weatherPlaceSelectView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.height.equalTo(32)
            make.top.equalTo(divider.snp.bottom).offset(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch menualBottomSheetRightBtnIsActivate {
        case .unActivate:
            rightBtn.tintColor = Colors.grey.g600
            rightBtn.isUserInteractionEnabled = false
            
        case .activate:
            rightBtn.tintColor = Colors.tint.sub.n400
            rightBtn.isUserInteractionEnabled = true
            
        case ._default:
            rightBtn.tintColor = Colors.grey.g600
            rightBtn.isUserInteractionEnabled = true
        }
        
        switch weatherPlaceType {
        case .weather:
            print("WeatherPlcaeToolbarView :: .weather")
            weatherPlaceSelectView.weatherPlaceType = .weather
            titleLabel.text = "날씨는 어땠나요?"
            if let selectedWeatherType = selectedWeatherType {
                print("WeatherPlcaeToolbarView :: weather를 선택한 적이 있습니다.")
                weatherPlaceSelectView.selectedWeatherType = selectedWeatherType
            }
        case .place:
            print("WeatherPlcaeToolbarView :: .place")
            weatherPlaceSelectView.weatherPlaceType = .place
            titleLabel.text = "지금 장소는 어디신가요?"
            if let selectedPlaceType = selectedPlaceType {
                print("WeatherPlcaeToolbarView :: place를 선택한 적이 있습니다.")
                weatherPlaceSelectView.selectedPlaceType = selectedPlaceType
            }
        }
    }

}

extension WeatherPlcaeToolbarView: WeatherPlaceSelectViewDelegate {
    func isSelected(_ isSelected: Bool) {
        print("isSelected!")
    }
    
    func weatherSendData(weatherType: Weather, isSelected: Bool) {
        print("weatherSendData! - \(weatherType)")
        delegate?.weatherSendData(weatherType: weatherType)
    }
    
    func placeSendData(placeType: Place, isSelected: Bool) {
        print("placeSendData! - \(placeType)")
        delegate?.placeSendData(placeType: placeType)
    }
}
