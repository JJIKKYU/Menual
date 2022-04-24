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
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    func sendWeatherModel(model: WeatherModel)
    // func diaryBottomSheetPressedWriteBtn(weather: Weather, place: Place)
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {

    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    
    var weatherModel: WeatherModel?
    
    let weatherOb = BehaviorRelay<WeatherModel>(value: WeatherModel(uuid: "", weather: .sun, detailText: ""))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryBottomSheetPresentable,
        weatherModel: WeatherModel
    ) {
        self.weatherModel = weatherModel
        print("인터랙터에서도 받았을까요? \(weatherModel)")
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        guard let weatherModel = weatherModel else {
            return
        }
        print("weatherModel = \(weatherModel)")
        presenter.setViewsWithWeatherModel(model: weatherModel)
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
        guard let weatherModel = weatherModel else {
            return
        }
        listener?.diaryBottomSheetPressedCloseBtn()
        listener?.sendWeatherModel(model: weatherModel)
    }
    
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
}
