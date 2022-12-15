//
//  ProfileDeveloperInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import RxSwift
import RxRelay

protocol ProfileDeveloperRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ProfileDeveloperPresentable: Presentable {
    var listener: ProfileDeveloperPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    
}

protocol ProfileDeveloperListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileDeveloperPressedBackBtn(isOnlyDetach: Bool)
}

protocol ProfileDeveloperInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class ProfileDeveloperInteractor: PresentableInteractor<ProfileDeveloperPresentable>, ProfileDeveloperInteractable, ProfileDeveloperPresentableListener {

    var tempMenualSetRelay = BehaviorRelay<Bool?>(value: nil)
    var reminderDataCallRelay = BehaviorRelay<Bool?>(value: nil)
    
    
    weak var router: ProfileDeveloperRouting?
    weak var listener: ProfileDeveloperListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfileDeveloperInteractorDependency

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfileDeveloperPresentable,
        dependency: ProfileDeveloperInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        tempMenualSetRelay
            .subscribe(onNext: { [weak self] isStarted in
                guard let self = self else { return }
                guard let isStarted = isStarted else { return }
                if isStarted == false { return }
                
                // let diaryModelArr = []
                let intervale: Double = 1200000
                var unixTime = Date().timeIntervalSinceNow - (intervale * 30)
                // var date = Date(timeIntervalSince1970: unixTime)
                
                for idx in 0..<30  {
                    var weatherModel = WeatherModelRealm(weather: nil, detailText: "")
                    var placeModel = PlaceModelRealm(place: nil, detailText: "")
                    let weatherValue = idx % Weather().getVariation().count
                    switch weatherValue {
                    case 0:
                        weatherModel = WeatherModelRealm(weather: .sun, detailText: "디테일 텍스트입니다.")
                        placeModel = PlaceModelRealm(place: .car, detailText: "디테일 디테일 텍스트입니다.")
                    case 1:
                        weatherModel = WeatherModelRealm(weather: .thunder, detailText: "디테일 텍스트입니다.")
                        placeModel = PlaceModelRealm(place: .company, detailText: "디테일 디테일 텍스트입니다.")
                    case 2:
                        weatherModel = WeatherModelRealm(weather: .snow, detailText: "디테일 텍스트입니다.")
                        placeModel = PlaceModelRealm(place: .home, detailText: "디테일 디테일 텍스트입니다.")
                    case 3:
                        weatherModel = WeatherModelRealm(weather: .rain, detailText: "디테일 텍스트입니다.")
                        placeModel = PlaceModelRealm(place: .place, detailText: "디테일 디테일 텍스트입니다.")
                    case 4:
                        placeModel = PlaceModelRealm(place: .school, detailText: "디테일 디테일 텍스트입니다.")
                        weatherModel = WeatherModelRealm(weather: .cloud, detailText: "디테일 텍스트입니다.")
                    default:
                        placeModel = PlaceModelRealm(place: .place, detailText: "디테일 디테일 텍스트입니다.")
                        weatherModel = WeatherModelRealm(weather: .sun, detailText: "디테일 텍스트입니다.")
                    }
                    
                    unixTime += intervale
                    
                    let diaryModel = DiaryModelRealm(
                                                pageNum: 0,
                                                title: "테스트용 게시글입니다 \(idx)",
                                                weather: weatherModel,
                                                place: placeModel,
                                                 desc: "테스트용 디테일 텍스트입니다.",
                                                image: false,
                                                readCount: 0,
                                                createdAt: Date(timeIntervalSinceNow: unixTime),
                                                replies: [],
                                                isDeleted: false,
                                                isHide: false
                    )
                     print("Dev :: \(idx)개 게시글 추가 - \(diaryModel.createdAt)")

                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        print("ProfileDevelper :: !!")
                        self.dependency.diaryRepository.addDiary(info: diaryModel)
                    }
                }
                
                self.tempMenualSetRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.profileDeveloperPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }

    func allMenualRemove() {
        dependency.diaryRepository
            .removeAllDiary()
    }
}
