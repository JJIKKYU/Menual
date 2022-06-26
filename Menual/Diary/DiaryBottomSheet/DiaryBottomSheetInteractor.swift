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
    
    var weatherHistoryModel: BehaviorRelay<[WeatherHistoryModel]> { get }
    var plcaeHistoryModel: BehaviorRelay<[PlaceHistoryModel]> { get }
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {
    var weatherHistoryModel: BehaviorRelay<[WeatherHistoryModel]> {
        return listener!.weatherHistoryModel
    }
    
    var plcaeHistoryModel: BehaviorRelay<[PlaceHistoryModel]> {
        listener!.plcaeHistoryModel
    }
    

    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    
    var weatherModel: WeatherModel = WeatherModel(uuid: "", weather: nil, detailText: "")
    var placeModel: PlaceModel = PlaceModel(uuid: "", place: nil, detailText: "")
    var bottomSheetType: MenualBottomSheetType = .weather
    
    // DiaryInteractor에서 받은 Relay
    var weatherModelOb: BehaviorRelay<WeatherModel?>
    var placeModelOb: BehaviorRelay<PlaceModel?>
    
    let weatherOb = BehaviorRelay<WeatherModel>(value: WeatherModel(uuid: "", weather: .sun, detailText: ""))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryBottomSheetPresentable,
        weatherModelOb: BehaviorRelay<WeatherModel?>,
        placeModelOb: BehaviorRelay<PlaceModel?>,
        bottomSheetType: MenualBottomSheetType
    ) {
        self.weatherModelOb = weatherModelOb
        self.placeModelOb = placeModelOb
        self.bottomSheetType = bottomSheetType
        print("menualBottomSheetType = \(bottomSheetType)")
        super.init(presenter: presenter)
        presenter.listener = self
        presenter.setViews(type: bottomSheetType)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        guard let weatherModel = weatherModelOb.value,
              let placeModel = placeModelOb.value else {
            return
        }
        print("weatherModel = \(weatherModel)")
        
//        presenter.setViewsWithWeatherModel(model: weatherModel)
//        presenter.setViewsWithPlaceMOdel(model: placeModel)
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedCloseBtn() {
        print("pressedCloseBtn")
        listener?.diaryBottomSheetPressedCloseBtn()
    }
    
    func pressedWriteBtn() {
        listener?.diaryBottomSheetPressedCloseBtn()
        self.weatherModelOb
            .accept(weatherModel)
        
        self.placeModelOb
            .accept(placeModel)
    }
    
    // MARK: - Weather(날씨)
    func updateWeather(weather: Weather) {
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
        let newPlaceModel = PlaceModel(uuid: placeModel.uuid,
                                       place: place,
                                       detailText: placeModel.detailText
        )
        self.placeModel = newPlaceModel
    }
}
