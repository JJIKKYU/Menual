//
//  MenualBottomSheetFilterComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/09/10.
//

import UIKit
import SnapKit
import Then

class MenualBottomSheetFilterComponentView: UIView {
    
    public lazy var weatherTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("날씨", for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.marginImageWithText(margin: 4)
//        $0.isUserInteractionEnabled = true
    }
    
    private let weatherSelectNumTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_1)
        $0.textColor = Colors.grey.g500
        $0.text = "0개 선택"
    }
    
    private lazy var weatherSelectView = WeatherPlaceSelectView(type: .weather).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.isUserInteractionEnabled = true
        $0.delegate = self
    }
    
    private let placeTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("장소", for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.marginImageWithText(margin: 4)
    }
    
    private let placeSelectNumTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_1)
        $0.textColor = Colors.grey.g500
        $0.text = "0개 선택"
    }
    
    private let placeSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.isUserInteractionEnabled = false
    }
    
    private let resetBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("초기화", for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.tint.main.v500, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v500
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Colors.tint.main.v600.cgColor
        $0.AppCorner(._4pt)
        $0.marginImageWithText(margin: 4)
    }
    
    public lazy var filterBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then {
        $0.title = "텍스트"
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(weatherTitleBtn)
        addSubview(weatherSelectView)
        addSubview(weatherSelectNumTitle)
        
        addSubview(placeTitleBtn)
        addSubview(placeSelectView)
        addSubview(placeSelectNumTitle)
        
        addSubview(resetBtn)
        addSubview(filterBtn)
        
        weatherTitleBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview()
            make.height.equalTo(24)
        }
        
        weatherSelectNumTitle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(weatherTitleBtn)
        }
        
        weatherSelectView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(weatherTitleBtn.snp.bottom).offset(15)
            make.height.equalTo(32)
        }
        
        placeTitleBtn.snp.makeConstraints { make in
            make.top.equalTo(weatherSelectView.snp.bottom).offset(19)
            make.leading.equalToSuperview().offset(24)
            make.height.equalTo(24)
        }
        
        placeSelectNumTitle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(placeTitleBtn)
        }
        
        placeSelectView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(placeTitleBtn.snp.bottom).offset(15)
            make.height.equalTo(32)
        }
        
        resetBtn.snp.makeConstraints { make in
            make.top.equalTo(placeSelectView.snp.bottom).offset(59)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(104)
            make.height.equalTo(48)
        }
        
        filterBtn.snp.makeConstraints { make in
            make.top.equalTo(placeSelectView.snp.bottom).offset(59)
            make.leading.equalTo(resetBtn.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}

// MARK: - WeatherPlaceSelectViewDelegate
extension MenualBottomSheetFilterComponentView: WeatherPlaceSelectViewDelegate{
    func isSelected(_ isSelected: Bool) {
        print("isSelected!")
    }
    
    func weatherSendData(weatherType: Weather) {
        print("weatherSendData! - \(weatherType)")
    }
    
    func placeSendData(placeType: Place) {
        print("placeSendData! - \(placeType)")
    }
    
    
}
