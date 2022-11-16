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
    func setFilterBtnCount(count: Int)
    func setViews(type: MenualBottomSheetType)
    func setCurrentFilteredBtn(weatherArr: [Weather], placeArr: [Place])
}

protocol DiaryBottomSheetListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryBottomSheetPressedCloseBtn()
    
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place])
    func filterWithWeatherPlacePressedFilterBtn()
    func reminderCompViewshowToast(isEding: Bool)
}

final class DiaryBottomSheetInteractor: PresentableInteractor<DiaryBottomSheetPresentable>, DiaryBottomSheetInteractable, DiaryBottomSheetPresentableListener {
    
    weak var router: DiaryBottomSheetRouting?
    weak var listener: DiaryBottomSheetListener?
    var disposeBag = DisposeBag()
    
    var weatherModel: WeatherModel = WeatherModel(uuid: "", weather: nil, detailText: "")
    var placeModel: PlaceModel = PlaceModel(uuid: "", place: nil, detailText: "")
    var bottomSheetType: MenualBottomSheetType = .weather
    
    // FilterComponentView에서 사용되는 Weather/Place Filter Selected Arr
    // var weatherFilterSelectedArrRelay = BehaviorRelay<[Weather]>(value: [])
    // var placeFilterSelectedArrRelay = BehaviorRelay<[Place]>(value: [])
    var menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    
    var reminderRequestDateRelay: BehaviorRelay<DateComponents?>?

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
//        Observable.combineLatest(
//            weatherFilterSelectedArrRelay,
//            placeFilterSelectedArrRelay
//        )
//        .subscribe(onNext: { [weak self] weatherArr, placeArr in
//            guard let self = self else { return }
//
//            print("!!! \(weatherArr), \(placeArr)")
//            self.listener?.filterWithWeatherPlace(weatherArr: weatherArr, placeArr: placeArr)
//        })
//        .disposed(by: disposeBag)
    }
    
    func setFilteredDiaryCountRelay(relay: BehaviorRelay<Int>?) {
        print("DiaryBottomSheet :: setFilteredDiaryCountRelay! = \(relay)")
        filteredDiaryCountRelay = relay
        filteredDiaryCountRelay?
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                print("DiaryBottomSheet = setFilterCount! count = \(count)")
                self.presenter.setFilterBtnCount(count: count)
            })
            .disposed(by: disposeBag)
    }
    
    func setFilteredWeatherPlaceArrRelay(weatherArrRelay: BehaviorRelay<[Weather]>?, placeArrRelay: BehaviorRelay<[Place]>?) {
        print("DiaryBottomSheet :: setFilteredWeatherPlaceArrRelay!")
        self.filteredWeatherArrRelay = weatherArrRelay
        self.filteredPlaceArrRelay = placeArrRelay
        self.presenter.setCurrentFilteredBtn(weatherArr: [], placeArr: [])
        // self.presenter.setCurrentFilteredBtn(weatherArr: <#T##[Weather]#>, placeArr: <#T##[Place]#>)
//        self.presenter.setCurrentFilteredBtn(weatherArr: weatherArrRelay?.value ?? [], placeArr: placeArrRelay?.value ?? [])
        
        guard let weatherArrRelay = weatherArrRelay,
              let placeArrRelay = placeArrRelay else {
            return
        }
//
//        self.filteredWeatherArrRelay = weatherArrRelay
//        self.filteredPlaceArrRelay = placeArrRelay
//
//
        Observable.combineLatest(
            weatherArrRelay,
            placeArrRelay
        )
        .subscribe(onNext: { [weak self] weatherArr, placeArr in
            guard let self = self else { return }

            print("DiaryBottomSheet :: !!! \(weatherArr), \(placeArr)")
            self.listener?.filterWithWeatherPlace(weatherArr: weatherArr, placeArr: placeArr)
        })
        .disposed(by: disposeBag)
        
        /*
        self.filteredWeatherArrRelay?
            .subscribe(onNext: { [weak self] filteredWeatherArr in
                guard let self = self else { return }
                print("DiaryBottomSheet :: filteredWeatherArr = \(filteredWeatherArr)")
            })
            .disposed(by: disposeBag)
        
        self.filteredPlaceArrRelay?
            .subscribe(onNext: { [weak self] filteredPlaceArr in
                guard let self = self else { return }
                self.presenter.setCurrentFilteredBtn(weatherArr: [], placeArr: filteredPlaceArr)
            })
            .disposed(by: disposeBag)
         */
    }
    
    func setReminderRequestDate(relay: BehaviorRelay<DateComponents?>?) {
        self.reminderRequestDateRelay = relay
        self.reminderRequestDateRelay?
            .subscribe(onNext : { [weak self] date in
                guard let self = self else { return }
                print("DiaryBottomSheet :: 나중에 수정 만들때 하면 될듯")
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
    
    // MARK: - Place/Weahter Filter
    func filterWithWeatherPlacePressedFilterBtn() {
        listener?.filterWithWeatherPlacePressedFilterBtn()
    }
    
    // MARK: - DiaryWritingVC
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool) {
        print("diaryWritingPressedBackBtn!")
    }
    
    // MARK: - ReminderComponentView
    func reminderCompViewshowToast(isEding: Bool) {
        listener?.reminderCompViewshowToast(isEding: isEding)
    }

    func reminderCompViewSetReminder(requestDateComponents: DateComponents, requestDate: Date) {
        self.reminderRequestDateRelay?.accept(requestDateComponents)
    }
}

// MARK: - 미사용
extension DiaryBottomSheetInteractor {
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryWritingInteractor.DiaryWritingMode) {
        
    }
}
