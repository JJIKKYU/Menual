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
import Foundation
import MenualEntity
import MenualUtil

protocol DiaryWritingRouting: ViewableRouting {
    func attachDiaryTempSave(tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>, tempSaveResetRelay: BehaviorRelay<Bool>)
    func detachDiaryTempSave(isOnlyDetach: Bool)
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func setWeatherView(model: WeatherModelRealm)
    func setPlaceView(model: PlaceModelRealm)
    
    // 다이어리 수정 모드로 변경
    func setDiaryEditMode(diaryModel: DiaryModelRealm)
    func setTempSaveModel(tempSaveModel: TempSaveModelRealm)
    
    // 다이어리 초기화
    func resetDiary()
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
    
    private let weatherModelRelay = BehaviorRelay<WeatherModelRealm?>(value: nil)
    private let placeModelRelay = BehaviorRelay<PlaceModelRealm?>(value: nil)
    
    // 수정하기일 경우에는 내용을 세팅해야하기 때문에 릴레이에 작접 accept 해줌
    private let diaryModelRelay = BehaviorRelay<DiaryModelRealm?>(value: nil)
    
    // TempSave <-> DiaryWrtiting으로 전달하기 위한 Relay
    private let tempSaveDiaryModelRelay = BehaviorRelay<TempSaveModelRealm?>(value: nil)
    // TempSave 적용되었던 메뉴얼을 초기화해야 할 경우
    private let tempSaveResetRelay = BehaviorRelay<Bool>(value: false)
    
    // 이미지 업로드 후 updateDiary 하기 위해 관리하는 Relay
    private let updateDiaryModelRelay = BehaviorRelay<DiaryModelRealm?>(value: nil)
    
    // 이미지를 저장할 경우 모두 저장이 되었는지 확인하는 Relay
    // 1. croppedImage, 2. originalImage
    // 저장이 모두 완료되었을 경우 true
    private let imageSaveRelay = BehaviorRelay<(Bool, Bool, Bool)>(value: (false, false, false))

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryWritingPresentable,
        dependency: DiaryWritingInteractorDependency,
        diaryModel: DiaryModelRealm?,
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
                let thumbImageIsSaved = imageSaveFlags.2
                print("DiaryWriting :: 최종 저장 로직")

                if croppedImageIsSaved && originalImageIsSaved && thumbImageIsSaved {
                    print("DiaryWriting :: 모두 저장이 완료되었습니다.")
                    self.listener?.diaryWritingPressedBackBtn(isOnlyDetach: false, isNeedToast: true, mode: .edit)
                    self.dependency.diaryRepository
                        .updateDiary(info: newDiary, uuid: self.diaryModelRelay.value?.uuid ?? "")
                }
                else if croppedImageIsSaved || originalImageIsSaved || thumbImageIsSaved {
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
        
        tempSaveResetRelay
            .subscribe(onNext: { [weak self] needReset in
                guard let self = self else { return }
                
                switch needReset {
                case true:
                    self.presenter.resetDiary()

                case false:
                    break
                }
            })
            .disposed(by: disposebag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: isOnlyDetach, isNeedToast: false, mode: .none)
    }
    
    // 글 작성할 때
    func writeDiary(info: DiaryModelRealm) {
        // print("DiaryWritingInteractor :: writeDiary! info = \(info)")
        dependency.diaryRepository
            .addDiary(info: info)
        
        // 임시 저장된 메뉴얼이 있을 경우 삭제하고 업로드
        if let tempSaveModel = tempSaveDiaryModelRelay.value {
            print("DiaryWriting :: 임시저장된 메뉴얼이 있습니다. 같이 삭제를 진행합니다.")
            let uuid = tempSaveModel.uuid
            dependency.diaryRepository
                .deleteTempSave(uuidArr: [uuid])
            
            dependency.diaryRepository
                .deleteImageFromDocumentDirectory(diaryUUID: uuid) { isDeleted in
                    print("DiaryWriting :: 삭제가 완료되었습니다.")
                }
        }
        
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: false, isNeedToast: true, mode: .writing)
    }
    
    // 글 수정할 때
    func updateDiary(info: DiaryModelRealm, edittedImage: Bool) {
        print("DiaryWriting :: interactor! updateDiary!")

        // 수정하기 당시에 들어왔던 오리지널 메뉴얼
        guard let originalDiaryModel = diaryModelRelay.value else { return }
        let newDiaryModel = DiaryModelRealm(pageNum: originalDiaryModel.pageNum,
                                            title: info.title,
                                            weather: info.weather,
                                            place: info.place,
                                            desc: info.desc,
                                            image: info.image,
                                            readCount: originalDiaryModel.readCount,
                                            createdAt: originalDiaryModel.createdAt,
                                            replies: originalDiaryModel.repliesArr,
                                            isDeleted: originalDiaryModel.isDeleted,
                                            isHide: originalDiaryModel.isHide
        )
        
        updateDiaryModelRelay.accept(newDiaryModel)
        
        // 이미지 저장을 할 필요가 없으므로, true를 보내줌
        if edittedImage == false {
            imageSaveRelay.accept((true, true, true))
        }
    }

    func saveCropImage(diaryUUID: String, imageData: Data) {
        print("DiaryWriting :: interactor -> saveCropImage!")

        // cropImage는 uuid가 imageName
        let imageName: String = diaryUUID
        print("DiaryWriting :: interactor -> imageName = \(imageName)")
        dependency.diaryRepository
            .saveImageToDocumentDirectory(imageName: imageName, imageData: imageData) { isSaved in
                print("DiaryWriting :: interactor -> 저장완료! \(isSaved)")
                self.imageSaveRelay.accept((isSaved, self.imageSaveRelay.value.1, self.imageSaveRelay.value.2))
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
                self.imageSaveRelay.accept((self.imageSaveRelay.value.0, isSaved, self.imageSaveRelay.value.2))
            }
    }
    
    func saveThumbImage(diaryUUID: String, imageData: Data) {
        print("DiaryWriting :: interactor -> saveThumbImage!")
        let imageName: String = diaryUUID + "Thumb"
        print("DiaryWriting :: interactor -> imageName = \(imageName)")
        dependency.diaryRepository
            .saveImageToDocumentDirectory(imageName: imageName, imageData: imageData) { isSaved in
                print("DiaryWriting :: interactor -> 저장완료! \(isSaved)")
                self.imageSaveRelay.accept((self.imageSaveRelay.value.0, self.imageSaveRelay.value.1 ,isSaved))
            }
    }
    
    func deleteAllImages(diaryUUID: String) {
        print("DiaryWriting :: deleteAllImages!")
        dependency.diaryRepository
            .deleteImageFromDocumentDirectory(diaryUUID: diaryUUID) { isDeleted in
                print("DiaryWriting :: 이미지가 삭제되었습니다.")
            }
    }
    
    // MARK: - diaryTempSave
    func pressedTempSaveBtn() {
        router?.attachDiaryTempSave(tempSaveDiaryModelRelay: tempSaveDiaryModelRelay,
                                    tempSaveResetRelay: tempSaveResetRelay
        )
    }
    
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryTempSave(isOnlyDetach: isOnlyDetach)
    }
    
    // tempSaveRealm에 저장
    func saveTempSave(diaryModel: DiaryModelRealm, originalImageData: Data?, cropImageData: Data?) {
        // 임시저장 이미지를 위해서 uuid를 미리 알고 있어야함
        let uuid: String = UUID().uuidString
        if let cropImageData = cropImageData {
            saveCropImage(diaryUUID: uuid, imageData: cropImageData)
        }
        
        if let originalImageData = originalImageData {
            saveOriginalImage(diaryUUID: uuid, imageData: originalImageData)
        }
        
        print("DiaryWriting :: interactor -> tempsave!")
        if let tempSaveModel = tempSaveDiaryModelRelay.value {
            print("DiaryWriting :: interactor -> TempSaveModel이 이미 있으므로 업데이트합니다.")
            dependency.diaryRepository
                .updateTempSave(diaryModel: diaryModel, tempSaveUUID: tempSaveModel.uuid)
        } else {
            print("DiaryWriting :: interactor -> TempSaveModel이 없으므로 새로 저장합니다.")
            dependency.diaryRepository
                .addTempSave(diaryModel: diaryModel, tempSaveUUID: uuid)
        }
    }
}

// MARK: - 미사용
extension DiaryWritingInteractor {
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place]) { }
    func filterWithWeatherPlacePressedFilterBtn() { }
    func reminderCompViewshowToast(isEding: Bool) { }
    func filterDatePressedFilterBtn(yearDateFormatString: String) {}
}
