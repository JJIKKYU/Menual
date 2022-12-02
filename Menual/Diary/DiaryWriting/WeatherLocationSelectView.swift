//
//  WeatherLocationSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import SnapKit
import Then
import RxSwift

enum SelectedWeatherLocationType {
    case weather
    case location
}

class WeatherLocationSelectView: UIView {
    
    private let disposeBag = DisposeBag()
    
    var selected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    var selectedPlaceType: Place? {
        didSet { setNeedsLayout() }
    }
    
    var selectedWeatherType: Weather? {
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
    
    var isDeleteBtnEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    
    private let selectImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    
    var selectTextView = UITextView().then {
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.textContainerInset = UIEdgeInsets.zero
        $0.textContainer.maximumNumberOfLines = 1
    }
    
    public lazy var deleteBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Circle.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g700
    }
    
    private let selectLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type: SelectedWeatherLocationType) {
        self.init()
        print("WeatherLocationSelectView :: init! type = \(type)")
        self.selectedWeatherLocationType = type
        print("!! selectedWeatherLocationType \(selectedWeatherLocationType)")
    }
    
    func setViews() {
        addSubview(selectImageView)
        // addSubview(selectLabel)
        addSubview(selectTextView)
        addSubview(deleteBtn)
        
        selectImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        /*
        selectLabel.snp.makeConstraints { make in
            make.leading.equalTo(selectImageView.snp.trailing).offset(8)
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
         */
        
        selectTextView.snp.makeConstraints { make in
            make.leading.equalTo(selectImageView.snp.trailing).offset(8)
            make.height.equalTo(24)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
    }
    
    func bind() {
        selectTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.selectTitle = text
            })
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch selectedWeatherLocationType {
        case .weather:
            switch selected {
            case true:
                selectImageView.image = selectImage.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.tint.sub.n800
                // selectLabel.textColor = Colors.grey.g400
                selectTextView.textColor = Colors.grey.g400
                /*
                if selectTitle.isEmpty {
                    selectTextView.text = selectedWeatherType?.rawValue
                } else {
                    selectTextView.text = selectTitle
                }
                 */
                
                selectTextView.text = selectTitle
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
                
            case false:
                selectImageView.image = Asset._24px.weather.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                // selectLabel.textColor = Colors.grey.g600
                selectTextView.textColor = Colors.grey.g600
                // selectTextView.text = "오늘 날씨는 어땠나요?"
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
            }
            
        case .location:
            switch selected {
            case true:
                selectImageView.image = selectImage.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.tint.sub.n800
                // selectLabel.textColor = Colors.grey.g400
                selectTextView.textColor = Colors.grey.g400
                /*
                if selectTitle.isEmpty {
                    selectTextView.text = selectedPlaceType?.rawValue
                } else {
                    selectTextView.text = selectTitle
                }
                 */
                selectTextView.text = selectTitle
                
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
                
            case false:
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                // selectLabel.textColor = Colors.grey.g600
                selectTextView.textColor = Colors.grey.g600
                // selectTextView.text = "지금 장소는 어디신가요?"
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
            }
        }
        
        if let selectedPlaceType = selectedPlaceType {
            selectLabel.text = Place().getPlaceText(place: selectedPlaceType)
            switch selectedPlaceType {
            case .place:
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
            case .car:
                selectImageView.image = Asset._24px.Place.car.image.withRenderingMode(.alwaysTemplate)
            case .company:
                selectImageView.image = Asset._24px.Place.company.image.withRenderingMode(.alwaysTemplate)
            case .home:
                selectImageView.image = Asset._24px.Place.home.image.withRenderingMode(.alwaysTemplate)
            case .school:
                selectImageView.image = Asset._24px.Place.school.image.withRenderingMode(.alwaysTemplate)
            }
        }
        
        if let selectedWeatherType = selectedWeatherType {
            selectLabel.text = Weather().getWeatherText(weather: selectedWeatherType)
            switch selectedWeatherType {
            case .sun:
                selectImageView.image = Asset._24px.Weather.sun.image.withRenderingMode(.alwaysTemplate)
            case .rain:
                selectImageView.image = Asset._24px.Weather.rain.image.withRenderingMode(.alwaysTemplate)
            case .cloud:
                selectImageView.image = Asset._24px.Weather.cloud.image.withRenderingMode(.alwaysTemplate)
            case .snow:
                selectImageView.image = Asset._24px.Weather.snow.image.withRenderingMode(.alwaysTemplate)
            case .thunder:
                selectImageView.image = Asset._24px.Weather.thunder.image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
