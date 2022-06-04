//
//  DiaryBottomSheetViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import SnapKit
import RxRelay
import UIKit

protocol DiaryBottomSheetPresentableListener: AnyObject {
    var weatherHistoryModel: BehaviorRelay<[WeatherHistoryModel]> { get }
    var plcaeHistoryModel: BehaviorRelay<[PlaceHistoryModel]> { get }
    
    func pressedCloseBtn()

    // weather
    func updateWeatherDetailText(text: String)
    func updateWeather(weather: Weather)
    
    // place
    func updatePlaceDetailText(text: String)
    func updatePlace(place: Place)

    func pressedWriteBtn()
}

final class DiaryBottomSheetViewController: MenualBottomSheetBaseViewController, DiaryBottomSheetPresentable, DiaryBottomSheetViewControllable {
    
    weak var listener: DiaryBottomSheetPresentableListener?
    var disposeBag = DisposeBag()
    var keyHeight: CGFloat?
    // var selectedCellWeatherType: Weather?
    
    lazy var closeBtn = UIButton().then {
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(dimmedViewTapped), for: .touchUpInside)
        $0.contentMode = .scaleAspectFit
    }
        
    lazy var segmentationView = MenualSegmentationBaseViewController(frame: CGRect.zero).then {
        $0.setButtonTitles(buttonTitles: ["날씨", "장소"])
        $0.backgroundColor = .clear
        $0.delegate = self
    }
    
    lazy var weatherView = BottomSheetSelectView(.weather).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = false
        $0.title = "날씨에 대해 기록해주세요"
        $0.delegate = self
        $0.weatherHistoryModel = listener?.weatherHistoryModel.value ?? []
    }
    
    lazy var placeView = BottomSheetSelectView(.place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.title = "장소에 대해 기록해주세요"
        $0.delegate = self
        $0.placeHistoryModel = listener?.plcaeHistoryModel.value ?? []
    }
    
    lazy var addBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitle("날씨 추가하기", for: .normal)
        $0.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.backgroundColor = Colors.tint.sub.n400
        $0.AppCorner(.tiny)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        bind()
        bottomSheetView.backgroundColor = Colors.background
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        segmentationView.delegate = nil
        weatherView.delegate = nil
        placeView.delegate = nil
    }
    
    func setViews() {
        self.view.addSubview(segmentationView)
        self.view.addSubview(closeBtn)
        self.view.addSubview(addBtn)
        
        self.view.addSubview(weatherView)
        self.view.addSubview(placeView)
        self.view.bringSubviewToFront(addBtn)
        
        segmentationView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading).offset(20)
            make.top.equalTo(bottomSheetView.snp.top).offset(20)
            make.width.equalTo(90)
            make.height.equalTo(32)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(bottomSheetView.snp.trailing).inset(20)
            make.top.equalTo(bottomSheetView.snp.top).offset(20)
            make.width.height.equalTo(24)
        }
        
        weatherView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.top.equalTo(segmentationView.snp.bottom).offset(20)
            make.width.equalTo(bottomSheetView.snp.width)
            make.bottom.equalTo(bottomSheetView.snp.bottom)
        }

        placeView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.top.equalTo(segmentationView.snp.bottom).offset(20)
            make.width.equalTo(bottomSheetView.snp.width)
            make.bottom.equalTo(bottomSheetView.snp.bottom)
        }
        
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(bottomSheetView.snp.bottom).inset(20)
        }
    }
    
    func bind() {
        weatherView.textFieldOb
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] changedText in
                guard let self = self,
                      let changedText = changedText else { return }
                if changedText.count == 0 { return }
                print("weatherView = \(changedText)")
                self.listener?.updateWeatherDetailText(text: changedText)
            })
            .disposed(by: disposeBag)
        
        placeView.textFieldOb
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] changedText in
                guard let self = self,
                      let changedText = changedText else { return }
                if changedText.count == 0 { return }
                self.listener?.updatePlaceDetailText(text: changedText)
                print("placeView = \(changedText)")
            })
            .disposed(by: disposeBag)
    }
    
    func setViewsWithWeatherModel(model: WeatherModel) {
        // 재진입 할 경우 이전에 선택했던 정보 세팅
        weatherView.placeholderText = model.detailText
        weatherView.selectedWeatherType = model.weather
    }
    
    func setViewsWithPlaceMOdel(model: PlaceModel) {
        placeView.placeholderText = model.detailText
        placeView.selectedPlaceType = model.place
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        keyHeight = keyboardHeight

        self.view.frame.size.height -= keyboardHeight
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let keyHeight = keyHeight else {
            return
        }

        self.view.frame.size.height += keyHeight
    }
    
    @objc
    override func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        hideBottomSheetAndGoBack()
        resignFirstResponder()
        listener?.pressedCloseBtn()
        
    }
    
    @objc
    func pressedAddBtn() {
        print("TODO :: pressedAddBtn!!")
        hideBottomSheetAndGoBack()
        resignFirstResponder()
        listener?.pressedWriteBtn()
    }
}

extension DiaryBottomSheetViewController: UITextFieldDelegate {
    
}

extension DiaryBottomSheetViewController: MenualSegmentationDelegate {
    func changeToIdx(index: Int) {
        print("index! \(index)")
        switch index {
        // 날씨
        case 0:
            placeView.isHidden = true
            weatherView.isHidden = false
            self.addBtn.setTitle("날씨 추가하기", for: .normal)
            
        // 장소
        case 1:
            placeView.isHidden = false
            weatherView.isHidden = true
            self.addBtn.setTitle("장소 추가하기", for: .normal)
            
        default:
            break
        }
    }
}

extension DiaryBottomSheetViewController: BottomSheetSelectDelegate {
    func sendData(weatherModel: WeatherModel) {
        print("받았답니다! \(weatherModel)")
        guard let weather = weatherModel.weather else {
            return
        }
        listener?.updateWeather(weather: weather)
        listener?.updateWeatherDetailText(text: weatherModel.detailText)
    }
    
    func sendData(placeModel: PlaceModel) {
        print("받았답니다! \(placeModel)")
        guard let place = placeModel.place else {
            return
        }
        listener?.updatePlace(place: place)
        listener?.updatePlaceDetailText(text: placeModel.detailText)
    }
}
