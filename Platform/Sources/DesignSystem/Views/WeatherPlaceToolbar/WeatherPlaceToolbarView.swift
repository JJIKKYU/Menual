//
//  WeatherPlcaeToolbarView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then
import FirebaseAnalytics
import MenualEntity
import MenualUtil

public protocol WeatherPlaceToolbarViewDelegate: AnyObject {
    func weatherSendData(weatherType: Weather)
    func placeSendData(placeType: Place)
    func close()
}

public class WeatherPlaceToolbarView: UIView {
    
    public weak var delegate: WeatherPlaceToolbarViewDelegate?
    
    public var weatherPlaceType: WeatherPlaceSelectView.WeatherPlaceType = .weather {
        didSet { setNeedsLayout() }
    }
    
    public var selectedWeatherType: Weather? {
        didSet { setNeedsLayout() }
    }
    public var selectedPlaceType: Place? {
        didSet { setNeedsLayout() }
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = "날씨를 선택해 주세요"
    }
    private let divider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    private lazy var weatherPlaceSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
    }

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.background
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addSubview(titleLabel)
        // addSubview(rightBtn)
        addSubview(divider)
        addSubview(weatherPlaceSelectView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().inset(26)
            make.height.equalTo(20)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        switch weatherPlaceType {
        case .weather:
            print("WeatherPlcaeToolbarView :: .weather")
            weatherPlaceSelectView.weatherPlaceType = .weather
            titleLabel.text = "날씨를 선택해주세요"
            if let selectedWeatherType = selectedWeatherType {
                print("WeatherPlcaeToolbarView :: weather를 선택한 적이 있습니다.")
                weatherPlaceSelectView.selectedWeatherType = selectedWeatherType
            }
        case .place:
            print("WeatherPlcaeToolbarView :: .place")
            weatherPlaceSelectView.weatherPlaceType = .place
            titleLabel.text = "장소를 선택해주세요"
            if let selectedPlaceType = selectedPlaceType {
                print("WeatherPlcaeToolbarView :: place를 선택한 적이 있습니다.")
                weatherPlaceSelectView.selectedPlaceType = selectedPlaceType
            }
        }
    }
    
    @objc
    func pressedCloseBtn() {
        delegate?.close()
    }

}

extension WeatherPlaceToolbarView: WeatherPlaceSelectViewDelegate {
    public func isSelected(_ isSelected: Bool) {
        print("isSelected!")
    }
    
    public func weatherSendData(weatherType: Weather, isSelected: Bool) {
        print("weatherSendData! - \(weatherType)")
        MenualLog.logEventAction("writing_weather", parameter: ["weather" : "\(weatherType)"])
        delegate?.weatherSendData(weatherType: weatherType)
    }
    
    public func placeSendData(placeType: Place, isSelected: Bool) {
        print("placeSendData! - \(placeType)")
        MenualLog.logEventAction("writing_place", parameter: ["place" : "\(placeType)"])
        delegate?.placeSendData(placeType: placeType)
    }
}
