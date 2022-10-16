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

protocol MenualBottomSheetFilterComponentDelegate {
    var filterWeatherSelectedArrRelay: BehaviorRelay<[Weather]> { get }
    var filterPlaceSelectedArrRelay: BehaviorRelay<[Place]> { get }
    var filteredMenaulCountsObservable: Observable<Int> { get }
}

class MenualBottomSheetFilterComponentView: UIView {
    
    // var weatherSelectedArr: [Weather] = []
    
    var placeSelectedArr: [Place] = []
    
    var delegate: MenualBottomSheetFilterComponentDelegate? {
        didSet {
            print("델리게이트 불림!")
        }
    }
    var disposeBag = DisposeBag()
    
    public lazy var weatherTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("날씨", for: .normal)
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitleColor(Colors.grey.g200, for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.marginImageWithText(margin: 4)
        $0.addTarget(self, action: #selector(pressedWeatherTitleBtn), for: .touchUpInside)
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
        $0.selectionLimit = Weather().getVariation().count
    }
    
    private lazy var placeTitleBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("장소", for: .normal)
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
        $0.textColor = Colors.grey.g500
        $0.text = "0개 선택"
    }
    
    private lazy var placeSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.isUserInteractionEnabled = false
        $0.delegate = self
        $0.selectionLimit = Place().getVariation().count
    }
    
    private lazy var resetBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("초기화", for: .normal)
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
        $0.title = "N개의 메뉴얼 보기"
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // bind는 delegate setting을 한 후에 사용하는 곳에서 직접 수행
    func bind() {
        print("bind!")
        delegate?.filteredMenaulCountsObservable
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                
                print("filteredMenaulCountsObservable 구독! = \(count)")
                let title: String = "\(count)개의 메뉴얼 보기"
                self.filterBtn.title = title
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let weatherSelectedArr = delegate?.filterWeatherSelectedArrRelay.value,
              let placeSelectedArr = delegate?.filterPlaceSelectedArrRelay.value
        else { return }

        weatherSelectNumTitle.text = "\(weatherSelectedArr.count)개 선택"
        placeSelectNumTitle.text = "\(placeSelectedArr.count)개 선택"
        
        // 초기화 버튼, 필터 버튼 변환 로직
        // 하나라도 선택될 경우 초기화 버튼 활성화
        if weatherSelectedArr.count > 0 || placeSelectedArr.count > 0 {
            resetBtn.isEnabled = true
            resetBtn.layer.borderColor = Colors.tint.main.v600.cgColor
            resetBtn.tintColor = Colors.tint.main.v500
            
            filterBtn.btnStatus = .active
        }
        // 아무것도 선택되지 않았을 경우 버튼 비활성화
        else if weatherSelectedArr.count == 0 || placeSelectedArr.count == 0 {
            resetBtn.isEnabled = false
            resetBtn.layer.borderColor = Colors.grey.g700.cgColor
            resetBtn.tintColor = Colors.grey.g600
            
            filterBtn.btnStatus = .inactive
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
    }

}

// MARK: - IBAction
extension MenualBottomSheetFilterComponentView {
    @objc
    func pressedWeatherTitleBtn() {
        print("bottomSheet :: pressedWeatherTitleBtn!")
        delegate?.filterWeatherSelectedArrRelay.accept([])
        weatherSelectView.selctAllCells()
        setNeedsLayout()
    }
    
    @objc
    func pressedPlaceTitleBtn() {
        print("bottomSheet :: pressedPlaceTitleBtn!")
        delegate?.filterPlaceSelectedArrRelay.accept([])
        placeSelectView.selctAllCells()
        setNeedsLayout()
    }
    
    @objc
    func pressedResetFilterBtn() {
        print("bottomSheet :: pressedResetFilterBtn!")
        delegate?.filterWeatherSelectedArrRelay.accept([])
        delegate?.filterPlaceSelectedArrRelay.accept([])
        weatherSelectView.resetCells()
        placeSelectView.resetCells()
        setNeedsLayout()
    }
}

// MARK: - WeatherPlaceSelectViewDelegate
extension MenualBottomSheetFilterComponentView: WeatherPlaceSelectViewDelegate {
    func isSelected(_ isSelected: Bool) {
        print("isSelected!")
    }
    
    func weatherSendData(weatherType: Weather, isSelected: Bool) {
        print("weatherSendData! - \(weatherType), isSelected = \(isSelected)")
        var weatherSelectedArr = delegate?.filterWeatherSelectedArrRelay.value ?? []

        switch isSelected {
        // 선택되었다면 어레이에 추가
        case true:
            // weatherSelectedArr.append(weatherType)
            weatherSelectedArr.append(weatherType)
        
        // 해제되었다면 어레이에서 제거
        case false:
//            if let idx = weatherSelectedArr.firstIndex(where: { $0 == weatherType }) {
//                weatherSelectedArr.remove(at: idx)
//            }
            
            if let idx = weatherSelectedArr.firstIndex(where: { $0 == weatherType }) {
                weatherSelectedArr.remove(at: idx)
            }
        }

        delegate?.filterWeatherSelectedArrRelay.accept(weatherSelectedArr)
        setNeedsLayout()
    }
    
    func placeSendData(placeType: Place, isSelected: Bool) {
        print("placeSendData! - \(placeType), isSelcted = \(isSelected)")
        var placeSelectedArr = delegate?.filterPlaceSelectedArrRelay.value ?? []
        
        switch isSelected {
        // 선택되었다면 어레이에 추가
        case true:
            // placeSelectedArr.append(placeType)
            placeSelectedArr.append(placeType)
        
        // 해제되었다면 어레이에서 제거
        case false:
//            if let idx = placeSelectedArr.firstIndex(where: { $0 == placeType }) {
//                placeSelectedArr.remove(at: idx)
//            }
            
            if let idx = placeSelectedArr.firstIndex(where: { $0 == placeType }) {
                placeSelectedArr.remove(at: idx)
            }
        }
        
        delegate?.filterPlaceSelectedArrRelay.accept(placeSelectedArr)
        setNeedsLayout()
    }
}
