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
import MenualRepository

public protocol DiaryWritingRouting: ViewableRouting {
    func attachDiaryTempSave(tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>, tempSaveResetRelay: BehaviorRelay<Bool>)
    func detachDiaryTempSave(isOnlyDetach: Bool)
}

public protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    
    func setWeatherView(model: WeatherModelRealm)
    func setPlaceView(model: PlaceModelRealm)
    func setUI(writeType: WritingType)
}

public protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: ShowToastType)
}

public protocol DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {

    var page: Int
    
    var diaryWritingMode: WritingType = .writing

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    
    let dependency: DiaryWritingInteractorDependency
    var disposebag: DisposeBag
    
    // Editing 일때 ViewController를 세팅하기 위한 Relay
    let weatherModelRelay = BehaviorRelay<WeatherModelRealm?>(value: nil)
    let placeModelRelay = BehaviorRelay<PlaceModelRealm?>(value: nil)
    
    // 수정하기일 경우에는 내용을 세팅해야하기 때문에 릴레이에 작접 accept 해줌
    let diaryModelRelay = BehaviorRelay<DiaryModelRealm?>(value: nil)
    
    // TempSave <-> DiaryWrtiting으로 전달하기 위한 Relay
    let tempSaveDiaryModelRelay = BehaviorRelay<TempSaveModelRealm?>(value: nil)
    // TempSave 적용되었던 메뉴얼을 초기화해야 할 경우
    let tempSaveResetRelay = BehaviorRelay<Bool>(value: false)
    
    // 이미지 업로드 후 updateDiary 하기 위해 관리하는 Relay
    let updateDiaryModelRelay = BehaviorRelay<DiaryModelRealm?>(value: nil)
    
    // 다이어리 작성 값 바인딩
    let titleRelay = BehaviorRelay<String>(value: "")
    let descRelay = BehaviorRelay<String>(value: "")
    let placeDescRelay = BehaviorRelay<String>(value: "")
    let placeRelay = BehaviorRelay<Place?>(value: nil)
    var placeModelRealm: PlaceModelRealm?
    let weatherDescRelay = BehaviorRelay<String>(value: "")
    let weatherRelay = BehaviorRelay<Weather?>(value: nil)
    var weatherModelRealm: WeatherModelRealm?
    let originalImageDataRelay = BehaviorRelay<Data?>(value: nil)
    let thumbImageDataRelay = BehaviorRelay<Data?>(value: nil)
    var isImage: Bool  = true

//    {
//        cropImageDataRelay.value == nil ? false : true
//    }
    
    // 이미지를 저장할 경우 모두 저장이 되었는지 확인하는 Relay
    // 1. croppedImage, 2. originalImage
    // 저장이 모두 완료되었을 경우 true
    let imageSaveRelay = BehaviorRelay<(Bool, Bool, Bool)>(value: (false, false, false))

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

        Observable.combineLatest(
            diaryModelRelay,
            tempSaveDiaryModelRelay
        )
        .filter { $0 != nil || $1 != nil }
        .subscribe(onNext: { [weak self] diaryModel, tempSaveModel in
            guard let self = self else { return }
            var title: String = ""
            var weather: Weather?
            var weatherDesc: String = ""
            var place: Place?
            var placeDesc: String = ""
            var desc: String = ""
            var writingType: WritingType = .writing

            // 다이어리 수정 모드
            if let diaryModel = diaryModel {
                print("DiaryWriting :: 다이어리 수정모드입니다.")
                if diaryModel.image == true {
                    guard let originalImage = diaryModel.originalImage,
                          let cropImage = diaryModel.cropImage,
                          let thumbImage = diaryModel.thumbImage else { return }
                    self.originalImageDataRelay.accept(originalImage)
                    self.thumbImageDataRelay.accept(thumbImage)
                }
                title = diaryModel.title
                weather = diaryModel.weather?.weather
                weatherDesc = diaryModel.weather?.detailText ?? ""
                place = diaryModel.place?.place
                placeDesc = diaryModel.place?.detailText ?? ""
                desc = diaryModel.desc
                writingType = .edit
            }

            // 임시 저장에서 데이터를 받아왔을 경우
            if let tempSaveModel = tempSaveModel {
                print("DiaryWriting :: 임시저장 불러오기.")
                if tempSaveModel.image == true {
                    guard let originalImage = tempSaveModel.originalImage,
                          let cropImage = tempSaveModel.cropImage,
                          let thumbImage = tempSaveModel.thumbImage else { return }
                    self.originalImageDataRelay.accept(originalImage)
                    self.thumbImageDataRelay.accept(thumbImage)
                }
                title = tempSaveModel.title
                weather = tempSaveModel.weather
                weatherDesc = tempSaveModel.weatherDetailText ?? ""
                place = tempSaveModel.place
                placeDesc = tempSaveModel.placeDetailText ?? ""
                desc = tempSaveModel.desc
                writingType = .tempSave
            }
            
            self.titleRelay.accept(title)
            self.weatherRelay.accept(weather)
            self.placeRelay.accept(place)
            self.weatherDescRelay.accept(weatherDesc)
            self.placeDescRelay.accept(placeDesc)
            self.descRelay.accept(desc)
            self.presenter.setUI(writeType: writingType)
            self.diaryWritingMode = writingType
        })
        .disposed(by: disposebag)
        
        tempSaveResetRelay
            .subscribe(onNext: { [weak self] needReset in
                guard let self = self else { return }
                
                switch needReset {
                case true:
                    self.titleRelay.accept("")
                    self.weatherRelay.accept(nil)
                    self.placeRelay.accept(nil)
                    self.weatherDescRelay.accept("")
                    self.placeDescRelay.accept("")
                    self.descRelay.accept("")
                    self.presenter.setUI(writeType: .tempSave)

                case false:
                    break
                }
            })
            .disposed(by: disposebag)
        
        Observable.combineLatest(
            weatherRelay,
            weatherDescRelay
        )
        .subscribe(onNext: { [weak self] weather, desc in
            guard let self = self else { return }
            self.weatherModelRealm = WeatherModelRealm(weather: weather, detailText: desc)
        })
        .disposed(by: disposebag)
        
        Observable.combineLatest(
            placeRelay,
            placeDescRelay
        )
        .subscribe(onNext: { [weak self] place, desc in
            guard let self = self else { return }
            self.placeModelRealm = PlaceModelRealm(place: place, detailText: desc)
        })
        .disposed(by: disposebag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: isOnlyDetach, isNeedToast: false, mode: .none)
    }
}

// MARK: - Write, Update Diary
extension DiaryWritingInteractor {
    /// 글 작성 함수
    /// - 글 작성에 필요한 변수는 Interactor의 Relay에 담겨있음
    func writeDiary() {
        guard let weatherModel = self.weatherModelRealm,
              let placeModel = self.placeModelRealm else { return }
        
        let title = titleRelay.value.count == 0 ? Date().toString() : titleRelay.value
        let diaryModelRealm = DiaryModelRealm(
            pageNum: 0,
                                              title: title,
                                              weather: weatherModel,
                                              place: placeModel,
                                              desc: descRelay.value,
                                              image: isImage,
                                              createdAt: Date()
        )
        
        let uuid: String = diaryModelRealm.uuid
        saveImage(uuid: uuid)
        
        dependency.diaryRepository
            .addDiary(info: diaryModelRealm)
        
        // 임시 저장된 메뉴얼이 있을 경우 삭제
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
        
        listener?.diaryWritingPressedBackBtn(isOnlyDetach: false,
                                             isNeedToast: true,
                                             mode: .writing
        )
    }
    
    /// cropImage, originalIamge, ThumbImage 저장
    /// TODO : - 쓰레드 변경해서 ThreadSafe하게 저장할 수 있도록 수정
    func saveImage(uuid: String) {
        if isImage == false { return }
        guard let originalImage = originalImageDataRelay.value,
              let thumbImage = thumbImageDataRelay.value else { return }

        saveOriginalImage(diaryUUID: uuid, imageData: originalImage)
        saveThumbImage(diaryUUID: uuid, imageData: thumbImage)
    }
    
    /// 글 수정할 때
    /// - DiaryModelRelay에 있는 값이 수정할 DiaryModel
    func updateDiary(isUpdateImage: Bool) {
        print("DiaryWriting :: interactor! updateDiary!")

        // 수정하기 당시에 들어왔던 오리지널 메뉴얼
        guard let originalDiaryModel = diaryModelRelay.value,
              let weatherModel = weatherModelRealm,
              let placeModel = placeModelRealm
        else { return }

        let title = titleRelay.value.count == 0 ? Date().toString() : titleRelay.value
        let newDiaryModel = DiaryModelRealm(pageNum: originalDiaryModel.pageNum,
                                            title: title,
                                            weather: weatherModel,
                                            place: placeModel,
                                            desc: descRelay.value,
                                            image: isImage,
                                            readCount: originalDiaryModel.readCount,
                                            createdAt: originalDiaryModel.createdAt,
                                            replies: originalDiaryModel.repliesArr,
                                            isDeleted: originalDiaryModel.isDeleted,
                                            isHide: originalDiaryModel.isHide
        )
        
        // 이미지가 업데이트 된 경우
        if isUpdateImage {
            saveImage(uuid: originalDiaryModel.uuid)
            print("DiaryWriting :: image가 변경되었습니다.")
        } else {
            imageSaveRelay.accept((true, true, true))
        }
        updateDiaryModelRelay.accept(newDiaryModel)
    }
}

// MARK: - Save/Delete Image
extension DiaryWritingInteractor {
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
}

// MARK: - TempSave
extension DiaryWritingInteractor {
    func pressedTempSaveBtn() {
        router?.attachDiaryTempSave(tempSaveDiaryModelRelay: tempSaveDiaryModelRelay,
                                    tempSaveResetRelay: tempSaveResetRelay
        )
    }
    
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryTempSave(isOnlyDetach: isOnlyDetach)
    }
    
    /// 임시저장 데이터로 변경하기 위한 함수
    func zipDiaryModelForTempSave() -> DiaryModelRealm? {
        // 만약 타이틀을 하나도 안썼을 경우, 쓰려고 했다가 모두 지워서 하나도 안쓴 것처럼 되었을 경우
        // 날짜가 기본으로 입력되도록
        var fixedTitle: String = titleRelay.value
        if titleRelay.value.count == 0 {
            fixedTitle = Date().toString()
        }
        
        guard let weatherModel = weatherModelRealm,
              let placeModel = placeModelRealm else { return nil }
        
        let diaryModelRealm = DiaryModelRealm(pageNum: 0,
                                              title: fixedTitle,
                                              weather: weatherModel,
                                              place: placeModel,
                                              desc: descRelay.value,
                                              image: isImage,
                                              createdAt: Date()
        )
        
        return diaryModelRealm
    }
    
    // tempSaveRealm에 저장
    func saveTempSave() {
        guard let diaryModel = zipDiaryModelForTempSave() else { return }
        // 임시저장 이미지를 위해서 uuid를 미리 알고 있어야함
        let uuid: String = UUID().uuidString
        
        saveImage(uuid: uuid)
        // 이미 임시저장이 있을 경우 임시저장 데이터에 업데이트
        if let tempSaveModel = tempSaveDiaryModelRelay.value {
            print("DiaryWriting :: interactor -> TempSaveModel이 이미 있으므로 업데이트합니다. \(diaryModel.desc)")
            dependency.diaryRepository
                .updateTempSave(diaryModel: diaryModel, tempSaveUUID: tempSaveModel.uuid)
        }
        // 임시저장 데이터가 없을 경우 새로 저장
        else {
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
    func reminderCompViewshowToast(type: ReminderToastType) { }
}
