//
//  DiaryWritingInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RealmSwift

protocol DiaryWritingRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachBottomSheet(weatherModel: WeatherModel, placeModel: PlaceModel)
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

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    
    private let dependency: DiaryWritingInteractorDependency
    private var disposebag: DisposeBag
    
    var weatherModel = WeatherModel(uuid: "", weather: nil, detailText: "")
    var placeModel = PlaceModel(uuid: "", place: nil, detailText: "")

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
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn() {
        listener?.diaryWritingPressedBackBtn()
    }
    
    func writeDiary(info: DiaryModel) {
        // print("DiaryWritingInteractor :: writeDiary! info = \(info)")
        
        let newDiaryModel = DiaryModel(uuid: info.uuid,
                                       title: info.title,
                                       weather: weatherModel,
                                       place: placeModel,
                                       description: info.description,
                                       image: info.image,
                                       readCount: info.readCount,
                                       createdAt: info.createdAt
        )
        
        dependency.diaryRepository
            .addDiary(info: newDiaryModel)
        
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
            router?.attachBottomSheet(weatherModel: weatherModel, placeModel: placeModel)
        case .weather:
            router?.attachBottomSheet(weatherModel: weatherModel, placeModel: placeModel)
        }
    }
    
    func diaryBottomSheetPressedCloseBtn() {
        print("diaryBottomSheetPressedCloseBtn")
        router?.detachBottomSheet()
    }
    
    func sendWeatherModel(model: WeatherModel) {
        weatherModel = model
        print("weatherModel을 받아왔습니다! model = \(model)")
        presenter.setWeatherView(model: model)
    }
    
    func sendPlaceModel(model: PlaceModel) {
        placeModel = model
        print("placeModel을 받아왔답니다! model = \(model)")
        presenter.setPlaceView(model: model)
    }
}
