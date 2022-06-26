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
    
    lazy var addBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitle("날씨 추가하기", for: .normal)
        $0.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.backgroundColor = Colors.tint.sub.n400
        $0.AppCorner(.tiny)
    }
    
    private lazy var weatherPlaceSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
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
        
        super.delegate = nil
        weatherPlaceSelectView.delegate = nil
        listener?.pressedCloseBtn()
    }
    
    func setViews() {
        super.delegate = self
        
        view.addSubview(weatherPlaceSelectView)
        
        weatherPlaceSelectView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.height.equalTo(32)
            make.top.equalTo(super.divider.snp.bottom).offset(16)
        }

    }
    
    func bind() {

    }
    
    func setViewsWithWeatherModel(model: WeatherModel) {
        // 재진입 할 경우 이전에 선택했던 정보 세팅

    }
    
    func setViewsWithPlaceMOdel(model: PlaceModel) {
        
    }
    
    @objc
    override func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
         hideBottomSheetAndGoBack()
         resignFirstResponder()
    }
    
    func setViews(type: MenualBottomSheetType) {
        print("menualBottomSheetType = \(type)")
        menualBottomSheetType = type
        
        switch menualBottomSheetType {
        case .weather:
            break
            
        case .place:
            break
            
        case .reminder:
            break
            
        case .menu:
            break
            
        case .filter:
            break
            
        case .calender:
            break
        }
    }
}

// MARK: - MenualBottomSheetBaseDelegate
extension DiaryBottomSheetViewController: MenualBottomSheetBaseDelegate {
    // 부모 뷰가 애니메이션이 모두 끝났을 경우 Delegate 전달 받으면 그때 Router에서 RIB 해제
    func dismissedBottomSheet() {
        print("이때 라우터 호출할래?")
        super.delegate = nil
        weatherPlaceSelectView.delegate = nil
        listener?.pressedCloseBtn()
    }
}

// MARK: - IBAction
extension DiaryBottomSheetViewController {
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
    func pressedAddBtn() {
        print("TODO :: pressedAddBtn!!")
        hideBottomSheetAndGoBack()
        resignFirstResponder()
        listener?.pressedWriteBtn()
    }
}

// MARK: - UITextFieldDelegate
extension DiaryBottomSheetViewController: UITextFieldDelegate {
    
}

// MARK: - BottomSheetSelectDelegate
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

// MARK: - WeatherPlaceSelectViewDelegate
extension DiaryBottomSheetViewController: WeatherPlaceSelectViewDelegate {
    func isSelected(_ isSelected: Bool) {
        // 선택 유무로 체크표시 변경
        print("isSelected! = \(isSelected)")
        switch isSelected {
        case true:
            super.menualBottomSheetRightBtnIsActivate = .activate
        case false:
            super.menualBottomSheetRightBtnIsActivate = .unActivate
        }
    }
}
