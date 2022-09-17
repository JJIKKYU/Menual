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

enum MenualBottomSheetRightBtnType {
    case close
    case check
}

enum MenualBottomSheetRightBtnIsActivate {
    case activate
    case unActivate
    case _default
}

enum MenualBottomSheetType {
    case weather
    case place
    case menu
    case calender
    case reminder
    case filter
    case dateFilter
}

protocol DiaryBottomSheetPresentableListener: AnyObject {
    var weatherFilterSelectedArrRelay: BehaviorRelay<[Weather]> { get set }
    var placeFilterSelectedArrRelay: BehaviorRelay<[Place]> { get set }
    
    func pressedCloseBtn()

    // weather
    func updateWeatherDetailText(text: String)
    func updateWeather(weather: Weather)
    
    // place
    func updatePlaceDetailText(text: String)
    func updatePlace(place: Place)

    func pressedWriteBtn()
}

final class DiaryBottomSheetViewController: UIViewController, DiaryBottomSheetPresentable, DiaryBottomSheetViewControllable {
    
    weak var listener: DiaryBottomSheetPresentableListener?
    var disposeBag = DisposeBag()
    var keyHeight: CGFloat?
    public var bottomSheetHeight: CGFloat = 400
    
    // Filter 선택시 필터링된 메뉴얼 개수 넘겨주는 Relay
    var filteredMenaulCountsRelay = BehaviorRelay<Int>(value: 0)
    
    var bottomSheetTitle: String = "" {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetRightBtnType: MenualBottomSheetRightBtnType = .close {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetRightBtnIsActivate: MenualBottomSheetRightBtnIsActivate = .unActivate {
        didSet { layoutUpdate() }
    }
    
    var menualBottomSheetType: MenualBottomSheetType = .weather {
        didSet { menualBottomSheetTypeLayoutUpdate() }
    }
    
    lazy private var dimmedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background.withAlphaComponent(0.7)
        $0.alpha = 0
        
        // let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        // $0.addGestureRecognizer(dimmedTap)
        $0.isUserInteractionEnabled = true
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g100
        $0.text = "날씨를 선택해 주세요"
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
    
    var rightBtn = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    let divider = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g700
    }
    
    let bottomSheetView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var weatherPlaceSelectView = WeatherPlaceSelectView(type: .place).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.isHidden = true
    }
    
    // 메뉴 컴포넌트
    private lazy var menuComponentView = MenualBottomSheetMenuComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = true
        $0.isHidden = true
    }
    
    // 필터 컴포넌트
    private lazy var filterComponentView = MenualBottomSheetFilterComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.isUserInteractionEnabled = false
        $0.delegate = self
        $0.bind()
        $0.isHidden = true
        $0.weatherTitleBtn.addTarget(self, action: #selector(pressedWeatherTitleBtn), for: .touchUpInside)
        $0.filterBtn.addTarget(self, action: #selector(pressedWeatherTitleBtn), for: .touchUpInside)
        // $0.delegate = self
    }
    
    // 날짜 필터 컴포넌트
    private lazy var dateFilterComponentView = MenualDateFilterComponentView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        bind()
        bottomSheetView.backgroundColor = Colors.background
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // showBottomSheet()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // super.delegate = nil
        weatherPlaceSelectView.delegate = nil
        listener?.pressedCloseBtn()
        filterComponentView.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        showBottomSheet()
    }
    
    func setViews() {
        // super.delegate = self
        
        // 기본 컴포넌트 SetViews
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(titleLabel)
        bottomSheetView.addSubview(rightBtn)
        bottomSheetView.addSubview(divider)
        
        dimmedView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
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
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(2)
        }
        
        // 타입별 컴포넌트 SetViews
//        bottomSheetView.addSubview(weatherPlaceSelectView)
        bottomSheetView.addSubview(menuComponentView)
        bottomSheetView.addSubview(filterComponentView)
//        bottomSheetView.addSubview(dateFilterComponentView)

//        weatherPlaceSelectView.snp.makeConstraints { make in
//            make.leading.width.equalToSuperview()
//            make.height.equalTo(32)
//            make.top.equalTo(self.divider.snp.bottom).offset(16)
//        }

        menuComponentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(self.divider.snp.bottom).offset(20)
        }
//
        filterComponentView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(self.divider.snp.bottom).offset(27)
            make.height.equalTo(260)
        }
//
//        dateFilterComponentView.snp.makeConstraints { make in
//            make.top.equalTo(self.divider.snp.bottom).offset(64)
//            make.leading.equalToSuperview().offset(20)
//            make.width.equalToSuperview().inset(20)
//        }
    }
    
    func bind() {
        
    }
    
    func setViewsWithWeatherModel(model: WeatherModel) {
        // 재진입 할 경우 이전에 선택했던 정보 세팅

    }
    
    func setViewsWithPlaceMOdel(model: PlaceModel) {
        
    }
    
    @objc
    func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
         hideBottomSheetAndGoBack()
         resignFirstResponder()
    }
    
    func setViews(type: MenualBottomSheetType) {
        print("menualBottomSheetType = \(type)")
        menualBottomSheetType = type
        
        switch menualBottomSheetType {
        case .weather:
            weatherPlaceSelectView.isHidden = false
            weatherPlaceSelectView.weatherPlaceType = .weather
            rightBtn.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
            rightBtn.isHidden = false
            
        case .place:
            weatherPlaceSelectView.isHidden = false
            weatherPlaceSelectView.weatherPlaceType = .place
            rightBtn.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
            rightBtn.isHidden = false
            
        case .reminder:
            bottomSheetTitle = "리마인더 알림"
            
        case .menu:
            bottomSheetTitle = "메뉴"
            print("bottomsheet :: 메뉴입니다.")
            menuComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .filter:
            filterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .dateFilter:
            dateFilterComponentView.isHidden = false
            menualBottomSheetRightBtnType = .close
            rightBtn.addTarget(self, action: #selector(closeBottomSheet), for: .touchUpInside)
            
        case .calender:
            bottomSheetTitle = "날짜"
            
        
        }
    }
    
    func layoutUpdate() {
        titleLabel.text = bottomSheetTitle
        
        switch menualBottomSheetRightBtnType {
        case .close:
            rightBtn.tintColor = Colors.grey.g200
            rightBtn.isHidden = false
            rightBtn.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
            switch menualBottomSheetRightBtnIsActivate {
            // Close 버튼은 항상 활성화 되어 있어야 하므로 항상 true
            case .unActivate, ._default:
                rightBtn.tintColor = Colors.grey.g200
                rightBtn.isUserInteractionEnabled = true
                
            case .activate:
                rightBtn.tintColor = Colors.tint.sub.n400
                rightBtn.isUserInteractionEnabled = true
            }
            
        case .check:
            rightBtn.isHidden = false
            rightBtn.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            
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
        }
    }
}

// MARK: - MenualBottomSheetBaseDelegate
extension DiaryBottomSheetViewController {
    // 부모 뷰가 애니메이션이 모두 끝났을 경우 Delegate 전달 받으면 그때 Router에서 RIB 해제
    func dismissedBottomSheet() {
        print("이때 라우터 호출할래?")
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
        // super.delegate = nil
        weatherPlaceSelectView.delegate = nil

        hideBottomSheetAndGoBack()
        resignFirstResponder()
        listener?.pressedWriteBtn()
    }
    
    @objc
    func closeBottomSheet() {
        hideBottomSheetAndGoBack()
    }
}

// MARK: - UITextFieldDelegate
extension DiaryBottomSheetViewController: UITextFieldDelegate {
    
}

// MARK: - WeatherPlaceSelectViewDelegate
extension DiaryBottomSheetViewController: WeatherPlaceSelectViewDelegate {
    func isSelected(_ isSelected: Bool) {
        // 선택 유무로 체크표시 변경
        print("isSelected! = \(isSelected)")
        switch isSelected {
        case true:
            menualBottomSheetRightBtnIsActivate = .activate
        case false:
            menualBottomSheetRightBtnIsActivate = .unActivate
        }
    }
    
    // weather 선택시 넘어오는 정보
    func weatherSendData(weatherType: Weather, isSelected: Bool) {
        listener?.updateWeather(weather: weatherType)
    }
    
    // place 선택시 넘어는 정보
    func placeSendData(placeType: Place, isSelected: Bool) {
        
        print("placeSendData = \(placeType)")
        listener?.updatePlace(place: placeType)
    }
}

// MARK: - Bottom Sheet 기본 컴포넌트
extension DiaryBottomSheetViewController {
    func hideBottomSheetAndGoBack() {
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] isShow in
            guard let self = self else { return }
            print("bottomSheet isHide!")
            // self.delegate?.dismissedBottomSheet()
            self.dismissedBottomSheet()
        }
    }
    
    func showBottomSheet() {
        let safeAreaHeight: CGFloat = view.safeAreaLayoutGuide.layoutFrame.height
        let bottomPadding: CGFloat = view.safeAreaInsets.bottom
        print("safeAreaHeight = \(safeAreaHeight), bottomPadding = \(bottomPadding)")
        bottomSheetView.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).inset(bottomSheetHeight)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.dimmedView.alpha = 0.1
            self.view.layoutIfNeeded()
        } completion: { isShow in
            print("bottomSheet isShow!")
        }
    }
    
    func menualBottomSheetTypeLayoutUpdate() {
        print("!!! \(menualBottomSheetType)")
        switch menualBottomSheetType {
        case .weather:
            bottomSheetTitle = "날씨를 선택해 주세요"
            bottomSheetHeight = 130
            
        case .place:
            bottomSheetTitle = "장소를 선택해 주세요"
            bottomSheetHeight = 130

        case .calender:
            bottomSheetTitle = "날짜"
            bottomSheetHeight = 375
            
        case .filter, .dateFilter:
            bottomSheetTitle = "필터"
            bottomSheetHeight = 392
            
        case .menu:
            bottomSheetTitle = "메뉴"
            bottomSheetHeight = 328
            
        case .reminder:
            bottomSheetTitle = "리마인더 알림"
            bottomSheetHeight = 592
        }
    }

}

// MARK: - MenualBottomSheetFilterComponentView
extension DiaryBottomSheetViewController: MenualBottomSheetFilterComponentDelegate {
    var filterWeatherSelectedArrRelay: BehaviorRelay<[Weather]> {
        listener?.weatherFilterSelectedArrRelay ?? BehaviorRelay<[Weather]>(value: [])
    }
    
    var filterPlaceSelectedArrRelay: BehaviorRelay<[Place]> {
        listener?.placeFilterSelectedArrRelay ?? BehaviorRelay<[Place]>(value: [])
    }
    
    var filteredMenaulCountsObservable: Observable<Int> {
        return filteredMenaulCountsRelay.asObservable()
    }
    
    @objc
    func pressedWeatherTitleBtn() {
        print("pressedWeatherTitleBtn")
        filteredMenaulCountsRelay.accept(999)
    }
}


// MARK: - Debugging
extension DiaryBottomSheetViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
    }
}
