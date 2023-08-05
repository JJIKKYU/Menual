//
//  MenualBottomSheetFilterComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/09/10.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay
import MenualEntity
import MenualUtil

public protocol MenualBottomSheetFilterComponentDelegate: AnyObject {
    var filterWeatherSelectedArrRelay: BehaviorRelay<[Weather]>? { get }
    var filterPlaceSelectedArrRelay: BehaviorRelay<[Place]>? { get }
}

public class MenualBottomSheetFilterComponentView: UIView {

    public weak var delegate: MenualBottomSheetFilterComponentDelegate?
    var disposeBag = DisposeBag()
    
    public var filteredCount: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    public lazy var weatherTitleBtn = UIButton().then {
        $0.actionName = "weatherTitle"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle(MenualString.filter_title_weather, for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.marginImageWithText(margin: 4)
        $0.addTarget(self, action: #selector(pressedWeatherTitleBtn), for: .touchUpInside)
    }
    
    private let weatherSelectNumTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_1)
        $0.textColor = Colors.tint.sub.n400
        $0.text = "0개 선택"
        $0.isHidden = true
    }
    
    private lazy var weatherSelectView = WeatherPlaceSelectView(type: .weather).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.selectionLimit = Weather().getVariation().count
    }
    
    private lazy var placeTitleBtn = UIButton().then {
        $0.actionName = "placeTitle"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle(MenualString.filter_title_place, for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.marginImageWithText(margin: 4)
        $0.addTarget(self, action: #selector(pressedPlaceTitleBtn), for: .touchUpInside)
    }
    
    private let placeSelectNumTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_1)
        $0.textColor = Colors.tint.sub.n400
        $0.text = "0개 선택"
        $0.isHidden = true
    }
    
    private lazy var placeSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.selectionLimit = Place().getVariation().count
    }
    
    private lazy var resetBtn = UIButton().then {
        $0.actionName = "reset"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle(MenualString.filter_button_reset, for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.tint.main.v500, for: .normal)
        $0.setTitleColor(Colors.tint.main.v800, for: .highlighted)
        $0.setTitleColor(Colors.grey.g600, for: .disabled)
        $0.setImage(Asset._24px.Circle.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.tint.main.v500
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Colors.tint.main.v600.cgColor
        $0.AppCorner(._4pt)
        $0.marginImageWithText(margin: 4)
        $0.addTarget(self, action: #selector(pressedResetFilterBtn), for: .touchUpInside)
    }
    
    public lazy var filterBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .large).then {
        $0.actionName = "confirm"
        $0.title = MenualString.filter_button_all_menual
        $0.isEnabled = true
    }

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bind() {
        delegate?.filterWeatherSelectedArrRelay?
            .subscribe(onNext: { [weak self] weatherArr in
                guard let self = self else { return }
                self.weatherSelectView.selectedWeatherTypes = weatherArr
                self.weatherSelectView.selectCells()
                self.setNeedsLayout()
            })
            .disposed(by: disposeBag)
        
        delegate?.filterPlaceSelectedArrRelay?
            .subscribe(onNext: { [weak self] placeArr in
                guard let self = self else { return }
                self.placeSelectView.selectedPlaceTypes = placeArr
                self.placeSelectView.selectCells()
                self.setNeedsLayout()
            })
            .disposed(by: disposeBag)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let weatherSelectedArr = delegate?.filterWeatherSelectedArrRelay?.value,
              let placeSelectedArr = delegate?.filterPlaceSelectedArrRelay?.value
        else { return }

        weatherSelectNumTitle.isHidden = weatherSelectedArr.count == 0 ? true : false
        weatherSelectNumTitle.text = String(format: MenualString.filter_button_select_with_count, weatherSelectedArr.count)
        
        placeSelectNumTitle.isHidden = placeSelectedArr.count == 0 ? true : false
        placeSelectNumTitle.text = String(format: MenualString.filter_button_select_with_count, placeSelectedArr.count)
        
        // 초기화 버튼, 필터 버튼 변환 로직
        // 하나라도 선택될 경우 초기화 버튼 활성화
        if weatherSelectedArr.count > 0 || placeSelectedArr.count > 0 {
            resetBtn.isEnabled = true
            resetBtn.layer.borderColor = Colors.tint.main.v600.cgColor
            resetBtn.tintColor = Colors.tint.main.v500
        }
        // 아무것도 선택되지 않았을 경우 버튼 비활성화
        else if weatherSelectedArr.count == 0 || placeSelectedArr.count == 0 {
            resetBtn.isEnabled = false
            resetBtn.layer.borderColor = Colors.grey.g700.cgColor
            resetBtn.tintColor = Colors.grey.g600
        }
        
        // 날씨 전체 선택 버튼 로직
        if weatherSelectedArr.count > 0 {
            weatherTitleBtn.tintColor = Colors.tint.sub.n600
        } else {
            weatherTitleBtn.tintColor = Colors.grey.g600
        }
        
        // 장소 전체 선택 버튼 로직
        if placeSelectedArr.count > 0 {
            placeTitleBtn.tintColor = Colors.tint.sub.n600
        } else {
            placeTitleBtn.tintColor = Colors.grey.g600
        }
        
        // 필터버튼 카운트
        if filteredCount == -1 {
            filterBtn.title = MenualString.filter_button_all_menual
            filterBtn.isEnabled = true
            filterBtn.btnStatus = .active
        } else if filteredCount == 0  {
            filterBtn.title = String(format: MenualString.filter_button_watch_with_menaul_count, filteredCount)
            filterBtn.isEnabled = false
            filterBtn.btnStatus = .inactive
        } else {
            filterBtn.title = String(format: MenualString.filter_button_watch_with_menaul_count, filteredCount)
            filterBtn.isEnabled = true
            filterBtn.btnStatus = .active
        }
    }}

// MARK: - IBAction

extension MenualBottomSheetFilterComponentView {
    @objc
    func pressedWeatherTitleBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        delegate?.filterWeatherSelectedArrRelay?.accept([])
        weatherSelectView.selctAllCells()
        setNeedsLayout()
    }
    
    @objc
    func pressedPlaceTitleBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        delegate?.filterPlaceSelectedArrRelay?.accept([])
        placeSelectView.selctAllCells()
        setNeedsLayout()
    }
    
    @objc
    func pressedResetFilterBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        delegate?.filterWeatherSelectedArrRelay?.accept([])
        delegate?.filterPlaceSelectedArrRelay?.accept([])
        weatherSelectView.resetCells()
        placeSelectView.resetCells()
        setNeedsLayout()
    }
}

// MARK: - WeatherPlaceSelectViewDelegate

extension MenualBottomSheetFilterComponentView: WeatherPlaceSelectViewDelegate {
    public func isSelected(_ isSelected: Bool) {
        print("isSelected!")
    }
    
    public func weatherSendData(weatherType: Weather, isSelected: Bool) {
        print("weatherSendData! - \(weatherType), isSelected = \(isSelected)")
        var weatherSelectedArr = delegate?.filterWeatherSelectedArrRelay?.value ?? []

        switch isSelected {
        // 선택되었다면 어레이에 추가
        case true:
            weatherSelectedArr.append(weatherType)
        
        // 해제되었다면 어레이에서 제거
        case false:
            if let idx = weatherSelectedArr.firstIndex(where: { $0 == weatherType }) {
                weatherSelectedArr.remove(at: idx)
            }
        }

        MenualLog.logEventAction("bottomSheet_filter_weather", parameter: ["weather" : "\(weatherType)"])
        delegate?.filterWeatherSelectedArrRelay?.accept(weatherSelectedArr)
        setNeedsLayout()
    }
    
    public func placeSendData(placeType: Place, isSelected: Bool) {
        print("placeSendData! - \(placeType), isSelcted = \(isSelected)")
        var placeSelectedArr = delegate?.filterPlaceSelectedArrRelay?.value ?? []
        
        switch isSelected {
        // 선택되었다면 어레이에 추가
        case true:
            placeSelectedArr.append(placeType)
        
        // 해제되었다면 어레이에서 제거
        case false:
            if let idx = placeSelectedArr.firstIndex(where: { $0 == placeType }) {
                placeSelectedArr.remove(at: idx)
            }
        }

        MenualLog.logEventAction("bottomSheet_filter_place", parameter: ["place" : "\(placeType)"])
        delegate?.filterPlaceSelectedArrRelay?.accept(placeSelectedArr)
        setNeedsLayout()
    }
}
