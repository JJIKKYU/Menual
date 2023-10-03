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
import MenualEntity
import FlexLayout
import PinLayout
import MenualUtil

// MARK: - SelectedWeatherLocationType

public enum SelectedWeatherLocationType {
    case weather
    case location
}

// MARK: - WeatherLocationSelectView

public class WeatherLocationSelectView: UIView {
    
    fileprivate let rootFlexContainer = UIView()
    private let disposeBag = DisposeBag()
    
    public var selected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var selectedPlaceType: Place? {
        didSet { setNeedsLayout() }
    }
    
    public var selectedWeatherType: Weather? {
        didSet { setNeedsLayout() }
    }
    
    public var selectedWeatherLocationType: SelectedWeatherLocationType = .weather {
        didSet { setNeedsLayout() }
    }
    
    public var selectImage: UIImage = UIImage() {
        didSet { setNeedsLayout() }
    }
    
    public var selectTitle: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var isDeleteBtnEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }

    private let selectImageView: UIImageView = .init()
    public var selectTextView: UITextView = .init()
    public let deleteBtn: BaseButton = .init()
    private let selectLabel: UILabel = .init()

    public init() {
        super.init(frame: CGRect.zero)

        configureUI()
        setViews()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(type: SelectedWeatherLocationType) {
        self.init()
        self.selectedWeatherLocationType = type
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

    private func configureUI() {
        selectImageView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
        }

        selectTextView.do {
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.textContainerInset = UIEdgeInsets.zero
            $0.textContainer.maximumNumberOfLines = 1
        }

        deleteBtn.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(Asset._24px.Circle.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g700
        }

        selectLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.AppBodyOnlyFont(.body_2).withSize(12)
        }
    }

    private func setViews() {
        addSubview(rootFlexContainer)

        rootFlexContainer.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            // .alignContent(.center)
            .alignItems(.center)
            // .alignSelf(.center)
            // .wrap(.noWrap)
            .define { flex in
                flex.addItem(selectImageView)
                    .width(24)
                    .height(24)
                    .grow(0)

                flex.addItem(selectTextView)
                    .marginLeft(8)
                    .grow(1)

                flex.addItem(deleteBtn)
                    .width(24)
                    .height(24)
                    .right(0)
                    .grow(0)
            }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
        rootFlexContainer.pin.all()
        rootFlexContainer.flex
            .layout(mode: .fitContainer)

        switch selectedWeatherLocationType {
        case .weather:
            switch selected {
            case true:
                selectImageView.image = selectImage.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.tint.sub.n800
                selectTextView.textColor = Colors.grey.g400
                selectTextView.text = selectTitle
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
                
            case false:
                selectImageView.image = Asset._24px.weather.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                selectTextView.textColor = Colors.grey.g600
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
            }
            
        case .location:
            switch selected {
            case true:
                selectImageView.image = selectImage.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.tint.sub.n800
                selectTextView.textColor = Colors.grey.g400
                selectTextView.text = selectTitle
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
                
            case false:
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
                selectTextView.textColor = Colors.grey.g600
                selectTextView.centerVerticalText()
                deleteBtn.isHidden = !isDeleteBtnEnabled
            }
        }
        
        if let selectedPlaceType = selectedPlaceType {
            selectLabel.text = Place().getPlaceText(place: selectedPlaceType)
            switch selectedPlaceType {
            case .place:
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
            case .company:
                selectImageView.image = Asset._24px.Place.company.image.withRenderingMode(.alwaysTemplate)
            case .home:
                selectImageView.image = Asset._24px.Place.home.image.withRenderingMode(.alwaysTemplate)
            case .school:
                selectImageView.image = Asset._24px.Place.school.image.withRenderingMode(.alwaysTemplate)
            case .travel:
                selectImageView.image = Asset._24px.Place.luggage.image.withRenderingMode(.alwaysTemplate)
            }
        } else {
            if selectedWeatherLocationType == .location {
                selectImageView.image = Asset._24px.place.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
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
            case .wind:
                selectImageView.image = Asset._24px.Weather.wind.image.withRenderingMode(.alwaysTemplate)
            }
        } else {
            if selectedWeatherLocationType == .weather {
                selectImageView.image = Asset._24px.weather.image.withRenderingMode(.alwaysTemplate)
                selectImageView.tintColor = Colors.grey.g700
            }
        }
    }
}
