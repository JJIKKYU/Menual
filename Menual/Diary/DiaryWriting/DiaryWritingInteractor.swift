//
//  DiaryWritingInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RealmSwift
import RxRelay

protocol DiaryWritingRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachBottomSheet(weatherModelOb: BehaviorRelay<WeatherModel?>, placeModelOb: BehaviorRelay<PlaceModel?>)
    func detachBottomSheet()
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
    func setWeatherView(model: WeatherModel)
    func setPlaceView(model: PlaceModel)
}

protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryWritingPressedBackBtn()
}

protocol DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {
    
    var weatherHistoryModel: BehaviorRelay<[WeatherHistoryModel]> {
        dependency.diaryRepository.weatherHistory
    }
    var plcaeHistoryModel: BehaviorRelay<[PlaceHistoryModel]> {
        dependency.diaryRepository.placeHistory
    }
    

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    
    private let dependency: DiaryWritingInteractorDependency
    private var disposebag: DisposeBag
    
    var weatherModelValue: WeatherModel {
        weatherModelRelay.value ?? WeatherModel(uuid: "", weather: nil, detailText: "")
    }
    
    var placeModelValue: PlaceModel {
        placeModelRelay.value ?? PlaceModel(uuid: "", place: nil, detailText: "")
    }
    
    private let weatherModelRelay = BehaviorRelay<WeatherModel?>(value: nil)
    private let placeModelRelay = BehaviorRelay<PlaceModel?>(value: nil)

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryWritingPresentable,
        dependency: DiaryWritingInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        weatherModelRelay
            .subscribe(onNext: { [weak self] model in
                guard let self = self,
                      let model = model
                else { return }
                print("weatherModelRealy: model = \(model)")
                self.presenter.setWeatherView(model: model)
            })
            .disposed(by: disposebag)
        
        placeModelRelay
            .subscribe(onNext: { [weak self] model in
                guard let self = self,
                      let model = model
                else { return }
                print("placeModelRelay: model = \(model)")
                self.presenter.setPlaceView(model: model)
            })
            .disposed(by: disposebag)
        
        dependency.diaryRepository
            .weatherHistory
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                print("DiaryWritingInteractor :: weatherHistory = \(model)")
            })
            .disposed(by: disposebag)
        
        dependency.diaryRepository
            .placeHistory
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                print("DiaryWritingInteractor :: placeHistory = \(model)")
            })
            .disposed(by: disposebag)
    }
    
    func pressedBackBtn() {
        listener?.diaryWritingPressedBackBtn()
    }
    
    func writeDiary(info: DiaryModel) {
        // print("DiaryWritingInteractor :: writeDiary! info = \(info)")
        
        let newDiaryModel = DiaryModel(uuid: info.uuid,
                                       title: info.title,
                                       weather: weatherModelValue,
                                       place: placeModelValue,
                                       description: info.description,
                                       image: info.image,
                                       readCount: info.readCount,
                                       createdAt: info.createdAt
        )
        
        dependency.diaryRepository
            .addDiary(info: newDiaryModel)
        
        // weather, place가 Optional이므로, 존재할 경우에만 History 저장
        if let place = placeModelValue.place {
            let placeHistoryModel = PlaceHistoryModel(uuid: NSUUID().uuidString,
                                                      selectedPlace: place,
                                                      info: placeModelValue.detailText,
                                                      createdAt: info.createdAt,
                                                      isDeleted: false
            )
            dependency.diaryRepository
                .addPlaceHistory(info: placeHistoryModel)
        }
        
        if let weather = weatherModelValue.weather {
            let weatherHistoryModel = WeatherHistoryModel(uuid: NSUUID().uuidString,
                                                          selectedWeather: weather,
                                                          info: weatherModelValue.detailText,
                                                          createdAt: info.createdAt,
                                                          isDeleted: false
            )
            dependency.diaryRepository
                .addWeatherHistory(info: weatherHistoryModel)
        }
        
        listener?.diaryWritingPressedBackBtn()
    }
    
    func testSaveImage(imageName: String, image: UIImage) {
        print("testSaveImage")
        dependency.diaryRepository
            .saveImageToDocumentDirectory(imageName: imageName, image: image)
    }
    
    // MARK: - DiaryBottomSheet
    
    func pressedWeatherPlaceAddBtn(type: BottomSheetSelectViewType) {
        // 이미 선택한 경우에 다시 선택했다면 뷰를 세팅해주어야 하기 때문
        // switch로 진행한 이유는 첫 뷰 세팅을 위해서
        switch type {
        case .place:
            router?.attachBottomSheet(weatherModelOb: weatherModelRelay, placeModelOb: placeModelRelay)
        case .weather:
            router?.attachBottomSheet(weatherModelOb: weatherModelRelay, placeModelOb: placeModelRelay)
        }
    }
    
    func diaryBottomSheetPressedCloseBtn() {
        print("diaryBottomSheetPressedCloseBtn")
        router?.detachBottomSheet()
    }
}
