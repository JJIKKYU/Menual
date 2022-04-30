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
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    func sendWeatherModel(model: WeatherModel)
    func sendPlaceModel(model: PlaceModel)
    // func diaryBottomSheetPressedWriteBtn(weather: Weather, place: Place)
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {

    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    
    var weatherModel: WeatherModel?
    var placeModel: PlaceModel?
    
    let weatherOb = BehaviorRelay<WeatherModel>(value: WeatherModel(uuid: "", weather: .sun, detailText: ""))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryBottomSheetPresentable,
        weatherModel: WeatherModel,
        placeModel: PlaceModel
    ) {
        self.weatherModel = weatherModel
        self.placeModel = placeModel
        print("인터랙터에서도 받았을까요? \(weatherModel)")
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        guard let weatherModel = weatherModel,
              let placeModel = placeModel else {
            return
        }
        print("weatherModel = \(weatherModel)")
        presenter.setViewsWithWeatherModel(model: weatherModel)
        presenter.setViewsWithPlaceMOdel(model: placeModel)
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
        listener?.sendWeatherModel(model: weatherModel ?? WeatherModel(uuid: "", weather: nil, detailText: ""))
        listener?.sendPlaceModel(model: placeModel ?? PlaceModel(uuid: "", place: nil, detailText: ""))
    }
    
    // MARK: - Weather(날씨)
    func updateWeather(weather: Weather) {
        guard let weatherModel = weatherModel else {
            return
        }
        let newWeatherModel = WeatherModel(uuid: weatherModel.uuid,
                                           weather: weather,
                                           detailText: weatherModel.detailText
        )
        self.weatherModel = newWeatherModel
        print("update된 weatherModel = \(weatherModel)")
    }
    
    func updateWeatherDetailText(text: String) {
        guard let weatherModel = weatherModel else {
            return
        }
        let newWeatherModel = WeatherModel(uuid: weatherModel.uuid,
                                           weather: weatherModel.weather,
                                           detailText: text
        )
        self.weatherModel = newWeatherModel
        print("update된 weatherModel = \(weatherModel)")
    }
    
    // MARK: - Place(장소)
    func updatePlaceDetailText(text: String) {
        guard let placeModel = placeModel else {
            return
        }
        let newPlaceModel = PlaceModel(uuid: placeModel.uuid,
                                       place: placeModel.place,
                                       detailText: text
        )
        self.placeModel = newPlaceModel
        print("update된 placeModel = \(placeModel)")
    }
    
    func updatePlace(place: Place) {
        guard let placeModel = placeModel else {
            return
        }
        let newPlaceModel = PlaceModel(uuid: placeModel.uuid,
                                       place: place,
                                       detailText: placeModel.detailText
        )
        self.placeModel = newPlaceModel
        print("update된 placeModel = \(placeModel)")
    }
}
