//
//  DiaryBottomSheetInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift

protocol DiaryBottomSheetRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryBottomSheetPresentable: Presentable {
    var listener: DiaryBottomSheetPresentableListener? { get set }
    
    func setViewsWithWeatherModel(model: WeatherModel)
    func setViewsWithPlaceMOdel(model: PlaceModel)
    
    func setViews(type: MenualBottomSheetType)
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place])
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {

    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    var disposeBag = DisposeBag()
    
    var weatherModel: WeatherModel = WeatherModel(uuid: "", weather: nil, detailText: "")
    var placeModel: PlaceModel = PlaceModel(uuid: "", place: nil, detailText: "")
    var bottomSheetType: MenualBottomSheetType = .weather
    
    // FilterComponentView에서 사용되는 Weather/Place Filter Selected Arr
    var weatherFilterSelectedArrRelay = BehaviorRelay<[Weather]>(value: [])
    var placeFilterSelectedArrRelay = BehaviorRelay<[Place]>(value: [])
    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    
    let weatherOb = BehaviorRelay<WeatherModel>(value: WeatherModel(uuid: "", weather: .sun, detailText: ""))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryBottomSheetPresentable,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) {
        self.bottomSheetType = bottomSheetType
        if let menuComponentRelay = menuComponentRelay {
            self.menuComponentRelay = menuComponentRelay
        }
        print("menualBottomSheetType = \(bottomSheetType)")
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.setViews(type: bottomSheetType)
        bind()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        print("weatherModel = \(weatherModel)")
        
//        presenter.setViewsWithWeatherModel(model: weatherModel)
//        presenter.setViewsWithPlaceMOdel(model: placeModel)
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        Observable.combineLatest(
            weatherFilterSelectedArrRelay,
            placeFilterSelectedArrRelay
        )
        .subscribe(onNext: { [weak self] weatherArr, placeArr in
            guard let self = self else { return }
            
            print("!!! \(weatherArr), \(placeArr)")
            self.listener?.filterWithWeatherPlace(weatherArr: weatherArr, placeArr: placeArr)
        })
        .disposed(by: disposeBag)
    }
    
    func pressedCloseBtn() {
        print("pressedCloseBtn")
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    func pressedWriteBtn() {
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    // MARK: - Weather(날씨)
    func updateWeather(weather: Weather) {
        print("updateWeather = \(weather)")

        let newWeatherModel = WeatherModel(uuid: weatherModel.uuid,
                                           weather: weather,
                                           detailText: weatherModel.detailText
        )
        self.weatherModel = newWeatherModel
    }
    
    func updateWeatherDetailText(text: String) {
        let newWeatherModel = WeatherModel(uuid: weatherModel.uuid,
                                           weather: weatherModel.weather,
                                           detailText: text
        )
        self.weatherModel = newWeatherModel
    }
    
    // MARK: - Place(장소)
    func updatePlaceDetailText(text: String) {
        let newPlaceModel = PlaceModel(uuid: placeModel.uuid,
                                       place: placeModel.place,
                                       detailText: text
        )
        self.placeModel = newPlaceModel
    }
    
    func updatePlace(place: Place) {
        print("updatePlace = \(place)")

        let newPlaceModel = PlaceModel(uuid: placeModel.uuid,
                                       place: place,
                                       detailText: placeModel.detailText
        )
        self.placeModel = newPlaceModel
    }
    
    // MARK: - DiaryWritingVC
    func diaryWritingPressedBackBtn() {
        print("diaryWritingPressedBackBtn!")
    }
}
