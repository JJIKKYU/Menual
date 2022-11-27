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
    func attachBottomSheet(weatherModelOb: BehaviorRelay<WeatherModel?>, placeModelOb: BehaviorRelay<PlaceModel?>, bottomSheetType: MenualBottomSheetType)
    func detachBottomSheet()
    
    func attachDiaryTempSave(tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModel?>)
    func detachDiaryTempSave(isOnlyDetach: Bool)
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
    func setWeatherView(model: WeatherModel)
    func setPlaceView(model: PlaceModel)
    
    // 다이어리 수정 모드로 변경
    func setDiaryEditMode(diaryModel: DiaryModel)
    func setTempSaveModel(tempSaveModel: TempSaveModel)
}

protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType)
}

protocol DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {

    var page: Int
    
    enum DiaryWritingMode {
        case writing
        case edit
        case none
    }

    var diaryWritingMode: DiaryWritingMode = .writing

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    
    private let dependency: DiaryWritingInteractorDependency
    private var disposebag: DisposeBag
    
    // - 미사용 시작
    
    // - 미사용 끝
    
    var weatherModelValue: WeatherModel {
        weatherModelRelay.value ?? WeatherModel(uuid: "", weather: nil, detailText: "")
    }
    
    var placeModelValue: PlaceModel {
        placeModelRelay.value ?? PlaceModel(uuid: "", place: nil, detailText: "")
    }
    
    private let weatherModelRelay = BehaviorRelay<WeatherModel?>(value: nil)
    private let placeModelRelay = BehaviorRelay<PlaceModel?>(value: nil)
    
    // 수정하기일 경우에는 내용을 세팅해야하기 때문에 릴레이에 작접 accept 해줌
    private let diaryModelRelay = BehaviorRelay<DiaryModel?>(value: nil)
    
    // TempSave -> DiaryWrtiting으로 전달하기 위한 Relay
    private let tempSaveDiaryModelRelay = BehaviorRelay<TempSaveModel?>(value: nil)
    
    // 이미지 업로드 후 updateDiary 하기 위해 관리하는 Relay
    private let updateDiaryModelRelay = BehaviorRelay<DiaryModel?>(value: nil)
    
    // 이미지를 저장할 경우 모두 저장이 되었는지 확인하는 Relay
    // 1. croppedImage, 2. originalImage
    // 저장이 모두 완료되었을 경우 true
    private let imageSaveRelay = BehaviorRelay<(Bool, Bool)>(value: (false, false))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryWritingPresentable,
        dependency: DiaryWritingInteractorDependency,
        diaryModel: DiaryModel?,
        page: Int
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        if let diaryModel = diaryModel {
            self.diaryModelRelay.accept(diaryModel)
        }
        self.page = page
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
        
        /*
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
        */
        
        diaryModelRelay
            .subscribe(onNext: { [weak self] diaryModel in
                guard let self = self,
                      let diaryModel = diaryModel
                else { return }
                
                print("수정하기 모드로 바꿔야 할걸? = \(diaryModel)")
                self.diaryWritingMode = .edit
                self.presenter.setDiaryEditMode(diaryModel: diaryModel)
            })
            .disposed(by: disposebag)
        
        Observable.combineLatest (
            imageSaveRelay,
            updateDiaryModelRelay
        )
            .subscribe(onNext: { [weak self] imageSaveFlags, newDiary in
                guard let self = self,
                      let newDiary = newDiary else { return }
                let croppedImageIsSaved = imageSaveFlags.0
                let originalImageIsSaved = imageSaveFlags.1
                print("DiaryWriting :: 최종 저장 로직")

                if croppedImageIsSaved && originalImageIsSaved {
                    print("DiaryWriting :: 모두 저장이 완료되었습니다.")
                    self.listener?.diaryWritingPressedBackBtn(isOnlyDetach: false, isNeedToast: true, mode: .edit)
                    self.dependency.diaryRepository
                                .updateDiary(info: newDiary)
                }
                else if croppedImageIsSaved || originalImageIsSaved {
                    print("DiaryWriting :: 둘 중 하나가 저장이 안되었습니다.")
                }
            })
            .disposed(by: disposebag)
        
        tempSaveDiaryModelRelay
            .subscribe(onNext: { [weak self] tempSaveModel in
                guard let self = self,
                      let tempSaveModel = tempSaveModel
                else { return }

                print("DiaryWriting :: tempSaveDiaryModelRelay! = \(tempSaveModel)")
                self.presenter.setTempSaveModel(tempSaveModel: tempSaveModel)
            })
            .disposed(by: disposebag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: isOnlyDetach, isNeedToast: false, mode: .none)
    }
    
    // 글 작성할 때
    func writeDiary(info: DiaryModel) {
        // print("DiaryWritingInteractor :: writeDiary! info = \(info)")
        
        let newDiaryModel = DiaryModel(uuid: info.uuid,
                                       pageNum: info.pageNum,
                                       title: info.title,
                                       weather: info.weather,
                                       place: info.place,
                                       description: info.description,
                                       image: info.image,
                                       originalImage: info.originalImage,
                                       readCount: info.readCount,
                                       createdAt: info.createdAt,
                                       replies: info.replies,
                                       isDeleted: info.isDeleted,
                                       isHide: info.isHide
        )
        
        dependency.diaryRepository
            .addDiary(info: newDiaryModel)
        
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: false, isNeedToast: true, mode: .writing)
    }
    
    // 글 수정할 때
    func updateDiary(info: DiaryModel, edittedImage: Bool) {
        print("DiaryWriting :: interactor! updateDiary!")

        // 수정하기 당시에 들어왔던 오리지널 메뉴얼
        guard let originalDiaryModel = diaryModelRelay.value else { return }

        let newDiaryModel = DiaryModel(uuid: originalDiaryModel.uuid,
                                       pageNum: originalDiaryModel.pageNum,
                                       title: info.title,
                                       weather: info.weather,
                                       place: info.place,
                                       description: info.description,
                                       image: info.image,
                                       originalImage: info.originalImage,
                                       readCount: originalDiaryModel.readCount,
                                       createdAt: originalDiaryModel.createdAt,
                                       replies: originalDiaryModel.replies,
                                       isDeleted: originalDiaryModel.isDeleted,
                                       isHide: originalDiaryModel.isHide
        )
        print("newDiaryModel = \(newDiaryModel)")
        
        updateDiaryModelRelay.accept(newDiaryModel)
        
        // 이미지 저장을 할 필요가 없으므로, true를 보내줌
        if edittedImage == false {
            imageSaveRelay.accept((true, true))
        }
        
//        dependency.diaryRepository
//            .updateDiary(info: newDiaryModel)
//
//        diaryModelRelay.accept(newDiaryModel)
//
//        if edittedImage == false {
//            listener?.diaryWritingPressedBackBtn(isOnlyDetach: false)
//        }
    }
    
    func testSaveImage(imageName: String, image: UIImage) {
        print("testSaveImage")
//        dependency.diaryRepository
//            .saveImageToDocumentDirectory(imageName: imageName, image: image)
    }
    
    func saveCropImage(diaryUUID: String, imageData: Data) {
        print("DiaryWriting :: interactor -> saveCropImage!")

        // cropImage는 uuid가 imageName
        let imageName: String = diaryUUID
        print("DiaryWriting :: interactor -> imageName = \(imageName)")
        dependency.diaryRepository
            .saveImageToDocumentDirectory(imageName: imageName, imageData: imageData) { isSaved in
                print("DiaryWriting :: interactor -> 저장완료! \(isSaved)")
                self.imageSaveRelay.accept((isSaved, self.imageSaveRelay.value.1))
            }
    }

    func saveOriginalImage(diaryUUID: String, imageData: Data) {
        print("DiaryWriting :: interactor -> saveOriginalImage!")
        
        // originalImage는 {uuid}Original이 imageName
        let imageName: String = diaryUUID + "Original"
        print("DiaryWriting :: interactor -> imageName = \(imageName)")
        dependency.diaryRepository
            .saveImageToDocumentDirectory(imageName: imageName, imageData: imageData) { isSaved in
                print("DiaryWriting :: interactor -> 저장완료! \(isSaved)")
                self.imageSaveRelay.accept((self.imageSaveRelay.value.0, isSaved))
            }
    }
    
    // MARK: - DiaryBottomSheet
    func diaryBottomSheetPressedCloseBtn() {
        print("diaryBottomSheetPressedCloseBtn")
        router?.detachBottomSheet()
    }
    
    // MARK: - diaryTempSave
    
    func pressedTempSaveBtn() {
        router?.attachDiaryTempSave(tempSaveDiaryModelRelay: tempSaveDiaryModelRelay)
    }
    
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryTempSave(isOnlyDetach: isOnlyDetach)
    }
    
    // tempSaveRealm에 저장
    func saveTempSave(diaryModel: DiaryModel) {
        print("DiaryWriting :: interactor -> tempsave!")
        dependency.diaryRepository
            .addTempSave(diaryModel: diaryModel)
        
    }
}

// MARK: - 미사용
extension DiaryWritingInteractor {
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place]) { }
    func filterWithWeatherPlacePressedFilterBtn() { }
    func reminderCompViewshowToast(isEding: Bool) { }
    func filterDatePressedFilterBtn(yearDateFormatString: String) {}
}
