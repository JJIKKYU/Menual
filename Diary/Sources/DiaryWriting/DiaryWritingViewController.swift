//
//  DiaryWritingViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxCocoa
import RxSwift
import RxRelay
import SnapKit
import UIKit
import PhotosUI
import CropViewController
import FirebaseAnalytics
import MenualEntity
import MenualUtil
import DesignSystem

public protocol DiaryWritingPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func writeDiary()
    func updateDiary(isUpdateImage: Bool)
    func saveTempSave()
    func pressedTempSaveBtn()

    var page: Int { get }

    var titleRelay: BehaviorRelay<String> { get }
    var descRelay: BehaviorRelay<String> { get }
    var placeDescRelay: BehaviorRelay<String> { get }
    var placeRelay: BehaviorRelay<Place?> { get }
    var weatherDescRelay: BehaviorRelay<String> { get }
    var weatherRelay: BehaviorRelay<Weather?> { get }
    var originalImageDataRelay: BehaviorRelay<Data?> { get }
    var thumbImageDataRelay: BehaviorRelay<Data?> { get }
    var uploadImagesRelay: BehaviorRelay<[Data]> { get }
}

public enum WritingType {
    case writing
    case edit
    case tempSave
}

final class DiaryWritingViewController: UIViewController, DiaryWritingViewControllable {

    private let TITLE_TEXT_MAX_COUNT: Int = 40
    private let WEATHER_PLACE_TEXT_MAX_COUNT: Int = 25

    enum TextViewType: Int {
        case title = 0
        case weather = 1
        case location = 2
        case description = 3
    }

    weak var listener: DiaryWritingPresentableListener?
    private let isEditBeginRelay = BehaviorRelay<Bool>(value: false)

    // 유저가 선택 후 기본 선택 되어있도록
    private var selectedWeatherType: Weather?
    private var selectedPlaceType: Place?

    private var disposeBag = DisposeBag()

    private var writingType: WritingType = .writing

    // 수정하기 상태에서 이미지를 수정했을때만 저장할 수 있도록 하는 플래그
    private var isEdittedIamge: Bool = false
    // 업로드할 오리지날 이미지
    private var selectedOriginalImage: UIImage?

    private let defaultTitleText: String = MenualString.writing_placeholder_title
    private let defaultDescriptionText: String = MenualString.writing_placeholder_desc
    private let defaultWeatherText: String = MenualString.writing_placeholder_weather
    private let defaultPlaceText: String = MenualString.writing_placeholder_place
    private let selectionLimit: Int = 10

    // Camera Delegate
    let notificationIdentifier: String = "StartCamera"

    private lazy var naviView = MenualNaviView(type: .write)
    private lazy var weatherPlaceToolbarView = WeatherPlaceToolbarView()
    private lazy var scrollView = UIScrollView()
    private lazy var titleTextField = UITextView()
    private let divider1 = Divider(type: ._1px)
    private lazy var weatherSelectView = WeatherLocationSelectView(type: .weather)
    private let divider2 = Divider(type: ._1px)
    private lazy var locationSelectView = WeatherLocationSelectView(type: .location)
    private let divider3 = Divider(type: ._1px)
    private lazy var descriptionTextView = UITextView()
    private lazy var datePageTextCountView = DatePageTextCountView()
    private let divider4 = Divider(type: ._1px)
    private lazy var imageUploadView = ImageUploadView()
    private let imageView = UIImageView()
    private var phpickerConfiguration = PHPickerConfiguration()
    private weak var weakImagePicker: PHPickerViewController?
    private lazy var testImagePicker = UIImagePickerController()

    // 선택한 이미지
    private var selecteedImages: [Data] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()

        view.backgroundColor = .white
        initUI()
        setViews()
        bind()
        self.datePageTextCountView.date = Date().toString()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MenualLog.logEventAction("writing_appear")
        print("DiaryWriting :: viewWillAppear")

        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDelegate), name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)

        // Delegate 등록
        weatherPlaceToolbarView.delegate = self
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        weatherSelectView.selectTextView.delegate = self
        weatherSelectView.selectTextView.centerVerticalText()
        locationSelectView.selectTextView.delegate = self
        locationSelectView.selectTextView.centerVerticalText()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("DiaryWriting :: ViewDidDisAppear!")

        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: notificationIdentifier), object: nil)

        // Delegate 해제
        weatherPlaceToolbarView.delegate = nil
        titleTextField.delegate = nil
        descriptionTextView.delegate = nil
        weatherSelectView.selectTextView.delegate = nil
        locationSelectView.selectTextView.delegate = nil

        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }

    @objc
    func setDelegate() {
        dismiss(animated: false) {
            self.pressedTakeImagePullDownBtn()
        }
    }

    func bind() {
        guard let listener = listener else { return }
        titleTextField.rx.text
            .orEmpty
            .filter { [weak self] text in
                guard let self = self else { return false }
                return text == self.defaultTitleText ? false : true
            }
            .bind(to: listener.titleRelay )
            .disposed(by: disposeBag)

        descriptionTextView.rx.text
            .orEmpty
            .filter { [weak self] text in
                guard let self = self else { return false }
                return text == self.defaultDescriptionText ? false : true
            }
            .bind(to: listener.descRelay)
            .disposed(by: disposeBag)

        locationSelectView.selectTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .filter { [weak self] text in
                guard let self = self else { return false }
                return text == self.defaultPlaceText ? false : true
            }
            .bind(to: listener.placeDescRelay)
            .disposed(by: disposeBag)

        weatherSelectView.selectTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .filter { [weak self] text in
                guard let self = self else { return false }
                return text == self.defaultWeatherText ? false : true
            }
            .bind(to: listener.weatherDescRelay)
            .disposed(by: disposeBag)

        descriptionTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                // placeholder일 때는 비활성화
                if text == self.defaultDescriptionText {
                    self.naviView.rightButton1IsActive = false
                    return
                }

                self.datePageTextCountView.textCount = String(text.count)
                switch self.writingType {
                case .writing, .tempSave:
                    if text.count > 0 {
                        self.naviView.rightButton1IsActive = true
                    } else {
                        self.naviView.rightButton1IsActive = false
                    }
                case .edit:
                    if text.count == 0 {
                        self.naviView.rightButton1IsActive = false
                    }

                }
            })
            .disposed(by: disposeBag)

        isEditBeginRelay
            .subscribe(onNext: { [weak self] isEditBegin in
                guard let self = self else { return }
                if self.writingType != .edit { return }

                print("DiaryWriting :: isEditBeginRelay! \(isEditBegin)")

                switch isEditBegin {
                case true:
                    self.naviView.rightButton1IsActive = true
                case false:
                    self.naviView.rightButton1IsActive = false
                }
            })
            .disposed(by: disposeBag)

        locationSelectView.selectTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                print("DiaryWriting :: text - \(text)")
                if text == self.defaultPlaceText || text.count == 0 {
                    self.locationSelectView.isDeleteBtnEnabled = false
                    return
                }
                print("DiaryWriting :: isDeleteBtnEnabled!, text.count = \(text.count)")
                self.locationSelectView.isDeleteBtnEnabled = true

            })
            .disposed(by: disposeBag)

        weatherSelectView.selectTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }

                print("DiaryWriting :: text - \(text)")
                if text == self.defaultWeatherText || text.count == 0 {
                    self.weatherSelectView.isDeleteBtnEnabled = false
                    return
                }
                print("DiaryWriting :: isDeleteBtnEnabled!")
                self.weatherSelectView.isDeleteBtnEnabled = true
            })
            .disposed(by: disposeBag)
    }

    func addDiary() {
        switch writingType {
        case .writing, .tempSave:
            listener?.writeDiary()

        case .edit:
            print("PressedCheckBtn! edit!")
            listener?.updateDiary(isUpdateImage: isEdittedIamge)
        }
    }
}

// MARK: - Interactor Dependency Function
extension DiaryWritingViewController: DiaryWritingPresentable {
    func setUI(writeType: WritingType) {
        switch writeType {
            // UI 기본 세팅은 작성하기이므로 작성하기일 경우에는 세팅하지 않음
        case .writing, .tempSave:
            break
        case .edit:
            self.writingType = .edit
            self.naviView.naviViewType = .edit
            self.naviView.setNaviViewType()

        }

        guard let title = listener?.titleRelay.value,
              let weatherDesc = listener?.weatherDescRelay.value,
              let placeDesc = listener?.placeDescRelay.value,
              let desc = listener?.descRelay.value
        else { return }

        selectedPlaceType = listener?.placeRelay.value
        selectedWeatherType = listener?.weatherRelay.value

        // 타이틀 세팅
        let fixedTitle = title.count == 0 ? defaultTitleText : title
        if fixedTitle == title {
            titleTextField.attributedText = UIFont.AppTitleWithText(.title_5,
                                                                    Colors.grey.g200,
                                                                    text: fixedTitle)
        } else {
            titleTextField.text = defaultTitleText
            titleTextField.font = UIFont.AppTitle(.title_5)
            titleTextField.textColor = Colors.grey.g600
        }


        // 날씨, 장소 세팅
        weatherSelectView.selectedWeatherType = selectedWeatherType
        if weatherDesc == defaultWeatherText || weatherDesc.count == 0 {
            weatherSelectView.selected = false
            weatherSelectView.selectTextView.text = defaultWeatherText
            weatherSelectView.selectTitle = defaultWeatherText
        } else {
            weatherSelectView.selected = true
            weatherSelectView.selectTextView.text = weatherDesc
            weatherSelectView.selectTitle = weatherDesc
        }

        self.locationSelectView.selectedPlaceType = selectedPlaceType
        if placeDesc == defaultPlaceText || placeDesc.count == 0 {
            locationSelectView.selected = false
            locationSelectView.selectTextView.text = defaultPlaceText
            locationSelectView.selectTitle = defaultPlaceText
        } else {
            locationSelectView.selected = true
            locationSelectView.selectTextView.text = placeDesc
            locationSelectView.selectTitle = placeDesc
        }

        // desc 세팅
        let fixedDesc = desc.count == 0 ? defaultDescriptionText : desc
        if fixedDesc == desc {
            self.descriptionTextView.attributedText = UIFont.AppBodyWithText(.body_4,
                                                                             Colors.grey.g100,
                                                                             text: desc)
        } else {
            descriptionTextView.text = defaultDescriptionText
            descriptionTextView.textColor = Colors.grey.g600
            descriptionTextView.font = UIFont.AppBodyOnlyFont(.body_4).withSize(14)
        }

        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
        let estimatedSize = descriptionTextView.sizeThatFits(size)
        self.view.layoutIfNeeded()
        descriptionTextView.constraints.forEach { (constraint) in
          /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height <= 185 {
                if constraint.firstAttribute == .height {
                    constraint.constant = 185
                }
            }
            else {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }

        self.view.layoutIfNeeded()
    }

    func setWeatherView(model: WeatherModelRealm) {
        // 날씨를 선택하지 않았으면 뷰를 변경할 필요 없음
        guard let weather = model.weather else {
            return
        }
        print("DiaryWriting ::setWeatherView = \(model)")
        weatherSelectView.selected = true
        weatherSelectView.selectedWeatherType = weather
    }

    func setPlaceView(model: PlaceModelRealm) {
        guard let place = model.place else {
            return
        }
        print("DiaryWriting ::setPlaceView = \(model)")
        locationSelectView.selected = true
        locationSelectView.selectedPlaceType = place
    }
}

// MARK: - IBACtion
extension DiaryWritingViewController {
    @objc
    func pressedBackBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        var titleText: String = ""
        var isShowDialog: Bool = false
        switch writingType {
        case .writing, .tempSave:
            titleText = "메뉴얼 작성을 취소하시겠어요?"
            if isEditBeginRelay.value == true {
                isShowDialog = true
            } else {
                isShowDialog = false
            }
        case .edit:
            // 수정일 때는 임시저장 되지 않도록
            titleText = "메뉴얼 수정을 취소하시겠어요?"
            isShowDialog = false
        }

        if isShowDialog {
            showDialog(dialogScreen: .diaryWriting(.writingCancel),
                       size: writingType == .writing || writingType == .tempSave ? .medium : .small,
                       buttonType: .twoBtn,
                       titleText: titleText,
                       subTitleText: "작성한 내용은 임시저장글에 저장됩니다.",
                       cancelButtonText: "취소",
                       confirmButtonText: "확인"
            )
        } else {
            listener?.pressedBackBtn(isOnlyDetach: false)
        }

    }

    @objc
    func pressedCheckBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        view.endEditing(true) // 키보드가 내려가도록
        var titleText: String = ""
        var dialogScreen: DialogScreen = .diaryWriting(.writing)
        switch writingType {
        case .writing, .tempSave:
            dialogScreen = .diaryWriting(.writing)
            titleText = "메뉴얼을 등록하시겠어요?"
        case .edit:
            dialogScreen = .diaryWriting(.edit)
            titleText = "메뉴얼을 수정하시겠어요?"
        }
        showDialog(
             dialogScreen: dialogScreen,
             size: .small,
             buttonType: .twoBtn,
             titleText: titleText,
             cancelButtonText: MenualString.writing_alert_cancel,
             confirmButtonText: MenualString.writing_alert_confirm
        )
    }

    @objc
    func pressedTempSaveBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        listener?.pressedTempSaveBtn()
    }

    @objc
    func pressedImageUploadViewEditBtn(_ button: UIButton) {
        print("DiaryWriting :: pressedImageUploadViewEditBtn")
        // 따로 추가 기능이 없으므로 그대로 랜딩
        // pressedImageUploadView()
    }

    @objc
    func pressedPlaceViewDeleteBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryWriting :: pressedPlaceLocationViewDeleteBtn! - locationView")
        locationSelectView.selectTextView.text = ""
        isEditBeginRelay.accept(true)
    }

    @objc
    func pressedWeatherViewDeleteBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryWriting :: pressedPlaceLocationViewDeleteBtn! - weatherView")
        weatherSelectView.selectTextView.text = ""
        isEditBeginRelay.accept(true)
    }
}

// MARK: - ImageUpload
extension DiaryWritingViewController {
    // 앨범
    func pressedImageUploadPullDownBtn() {
        MenualLog.logEventAction("writing_image_upload")

        phpickerConfiguration.filter = .images

        // 선택 가능한 이미지 개수 체크
        let currentImageCount: Int = imageUploadView.imagesRelay.value.count
        let availableIamgeCount: Int = selectionLimit - currentImageCount

        // 선택 가능한 이미지 개수가 없을 경우
        if availableIamgeCount == 0 {
            _ = showToast(message: "사진은 최대 10장까지 추가할 수 있습니다.")
            return
        }
        phpickerConfiguration.selectionLimit = availableIamgeCount

        let imagePicker: PHPickerViewController = .init(
            configuration: phpickerConfiguration
        )
        weakImagePicker = imagePicker
        imagePicker.isEditing = true
        imagePicker.delegate = self

        let navigationController: UINavigationController = .init(
            rootViewController: imagePicker
        )
        navigationController.modalPresentationStyle = .automatic
        navigationController.navigationBar.isHidden = true
        navigationController.isNavigationBarHidden = true
        present(navigationController, animated: true, completion: nil)
    }

    // 카메라 호출
    @objc func pressedTakeImagePullDownBtn() {
        MenualLog.logEventAction("writing_image_take")
        // Privacy - Camera Usage Description
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            guard let self = self else { return }
            guard isAuthorized else {
                print("DiaryWriting :: 노권한!, \(isAuthorized)")
                DispatchQueue.main.async {
                    self.showDialog(
                         dialogScreen: .diaryWriting(.camera),
                         size: .large,
                         buttonType: .oneBtn,
                         titleText: "카메라 권한이 필요합니다",
                         subTitleText: "설정에서 Menual의\n카메라 권한을 활성화 해주세요",
                         confirmButtonText: "네"
                    )
                }
                return
            }

            if isAuthorized == true {
                print("DiaryWriting :: TakeImage!")
                DispatchQueue.main.async {
                    self.testImagePicker.sourceType = .camera
                    self.present(self.testImagePicker, animated: true, completion: nil)
                }
            }
        }


    }
}

// MARK: - UITextField
extension DiaryWritingViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("DiaryWriting :: textViewShouldBeginEditing")
        MenualLog.logEventAction(responder: textView)
        switch textView.tag {
        case TextViewType.title.rawValue:
            print("Title TextView")
            weatherPlaceToolbarView.isHidden = true
            if textView.text == defaultTitleText {
                textView.attributedText = UIFont.AppTitleWithText(
                    .title_5,
                    Colors.grey.g200,
                    text: textView.text
                )
                textView.text = nil
                // textView.textColor = Colors.grey.g200
            }

        case TextViewType.weather.rawValue:
            print("Weather TextView")
            weatherPlaceToolbarView.isHidden = false
            weatherPlaceToolbarView.weatherPlaceType = .weather
            weatherPlaceToolbarView.selectedWeatherType = selectedWeatherType
            if textView.text == defaultWeatherText {
                 weatherSelectView.selectTitle = ""
                textView.text = nil
                textView.textColor = Colors.grey.g400
            }

        case TextViewType.location.rawValue:
            print("Location TextView")
            weatherPlaceToolbarView.isHidden = false
            weatherPlaceToolbarView.weatherPlaceType = .place
            weatherPlaceToolbarView.selectedPlaceType = selectedPlaceType
            if textView.text == defaultPlaceText {
                 locationSelectView.selectTitle = ""
                textView.text = nil
                textView.textColor = Colors.grey.g400
            }

        case TextViewType.description.rawValue:
            print("Description TextView")
            weatherPlaceToolbarView.isHidden = true
            if textView.text == defaultDescriptionText {
                textView.attributedText = UIFont.AppBodyWithText(
                    .body_4,
                    Colors.grey.g200,
                    text: textView.text
                )
                textView.text = nil
                // textView.textColor = Colors.grey.g200
            }

        default:
            break
        }

        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")

        switch textView.tag {
        case TextViewType.title.rawValue:
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = defaultTitleText
                textView.textColor = Colors.grey.g600
            }

            if textView.text.count > TITLE_TEXT_MAX_COUNT {
                textView.text.removeLast()
            }

        case TextViewType.weather.rawValue:
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && weatherSelectView.selected == false {
                textView.text = defaultWeatherText
                textView.textColor = Colors.grey.g600
            }
            // 선택은 했는데 따로 텍스트를 입력안했을 경우 선택한 날씨 기본 텍스트 입력하도록
            else if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && weatherSelectView.selected == true {
                textView.text = weatherSelectView.selectedWeatherType?.rawValue ?? ""
            }
            break

        case TextViewType.location.rawValue:
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && locationSelectView.selected == false {
                textView.text = defaultPlaceText
                textView.textColor = Colors.grey.g600
            }
            // 선택은 했는데 따로 텍스트를 입력안했을 경우 선택한 장소 기본 텍스트 입력하도록
            else if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && locationSelectView.selected == true {
                textView.text = locationSelectView.selectedPlaceType?.rawValue ?? ""

                break}

        case TextViewType.description.rawValue:
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = defaultDescriptionText
                textView.textColor = Colors.grey.g600
            }

        default:
            break
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case TextViewType.title.rawValue:
            isEditBeginRelay.accept(true)

        case TextViewType.weather.rawValue:
            textView.centerVerticalText()
            isEditBeginRelay.accept(true)

        case TextViewType.location.rawValue:
            textView.centerVerticalText()
            isEditBeginRelay.accept(true)

        case TextViewType.description.rawValue:
            print("DiaryWriting :: TextView DidChagne!")

            let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)

            textView.constraints.forEach { (constraint) in
              /// 180 이하일때는 더 이상 줄어들지 않게하기
                if estimatedSize.height <= 185 {
                    if constraint.firstAttribute == .height {
                        constraint.constant = 185
                    }
                }
                else {
                    if constraint.firstAttribute == .height {
                        constraint.constant = estimatedSize.height + 20
                    }
                }
            }
            isEditBeginRelay.accept(true)

        default:
            break
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView.tag {
        case TextViewType.title.rawValue, TextViewType.weather.rawValue, TextViewType.location.rawValue:
            if text == "\n" {
                return false
            }

            //이전 글자 - 선택된 글자 + 새로운 글자(대체될 글자)
            let newLength = textView.text.count - range.length + text.count
            var koreanMaxCount = 0
            if textView.tag == TextViewType.title.rawValue {
                koreanMaxCount = TITLE_TEXT_MAX_COUNT + 1
            } else {
                koreanMaxCount = WEATHER_PLACE_TEXT_MAX_COUNT + 1
            }

            //글자수가 초과 된 경우 or 초과되지 않은 경우
            if newLength > koreanMaxCount { //11글자
                let overflow = newLength - koreanMaxCount //초과된 글자수
                if text.count < overflow {
                    return true
                }
                let index = text.index(text.endIndex, offsetBy: -overflow)
                let newText = text[..<index]
                guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location) else { return false }
                guard let endPosition = textView.position(from: textView.beginningOfDocument, offset: NSMaxRange(range)) else { return false }
                guard let textRange = textView.textRange(from: startPosition, to: endPosition) else { return false }

                textView.replace(textRange, withText: String(newText))

                return false
            }

        case TextViewType.description.rawValue:
            break

        default:
            break
        }

        return true
    }
}

// MARK: - PHPicker & ImagePicker
extension DiaryWritingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("DiaryWriting :: didFinishPicking!!")

        picker.dismiss(animated: true)
        var order: Int = 0

        for result in results {
            // 이미지 업로드가 불가능한 경우
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) == false {
                continue
            }


            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else { return }
                guard let image: UIImage = image as? UIImage,
                      let imageData: Data = image.jpegData(compressionQuality: 0.1)
                else { return }

                DispatchQueue.main.async {
                    self.selecteedImages.append(imageData)
                    var images: [Data] = self.listener?.uploadImagesRelay.value ?? []
                    images.append(imageData)
                    self.listener?.uploadImagesRelay.accept(images)
                    self.imageUploadView.reloadCollectionView()
                    order += 1
                }
                print("DiaryHome :: loading! order = \(order)")

//                if self.selecteedImages.count == results.count {
//                    print("DiaryHome :: loading! 이미지 로딩이 완료되었습니다.")
//                    DispatchQueue.main.async {
//                        picker.dismiss(animated: true)
//                        self.imageUploadView.images = self.selecteedImages
//                    }
//                }
            }
        }

        /*
        let itemProvider = results.first?.itemProvider

        if let itemProvider = itemProvider {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self, let image = image as? UIImage else { return }
                    DispatchQueue.main.async {
                        let cropVC = CustomCropViewController(image: image)
                        cropVC.cropVCNaviViewType = .backArrow

                        switch self.writingType {
                        case .writing, .tempSave:
                            cropVC.cropVCButtonType = .add
                        case .edit:
                            cropVC.cropVCButtonType = .edit
                        }

                        self.cropVC = cropVC
                        cropVC.delegate = self
                        print("DiaryWriting :: selectedOriginalImage = \(image)")
                        // self.selectedOriginalImage = self.fixImageOrientation(image)

                        // OriginalImage ViewModel에 넘기기
                        self.listener?.originalImageDataRelay.accept(self.fixImageOrientation(image).jpeg(.low))
                        // OriginalImage를 줄여서 Thumbnail을 만들어서 ViewModel에 넘기기
                        if let thumbImageData = UIImage().imageWithImage(sourceImage: self.fixImageOrientation(image), scaledToWidth: 150).jpeg(.high) {
                            self.listener?.thumbImageDataRelay.accept(thumbImageData)
                        }

                        picker.navigationController?.pushViewController(cropVC, animated: true)
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
            print("DiaryWriting :: 이미지가 없습니다!")
            self.isEdittedIamge = false
            dismiss(animated: true)
        }

         */
    }

    func fixImageOrientation(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}

extension DiaryWritingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
        print("DiaryWriting :: didFinishPickingMediaWithInfo!")
        var newImage: UIImage?

        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = image
        }

        guard let newImage = newImage else { return }
        // let cropVC = CropViewController(image: newImage!)
        // picker.pushViewController(cropVC, animated: true)
        let cropVC = CustomCropViewController(image: newImage)
        cropVC.cropVCNaviViewType = .close

        switch writingType {
        case .writing, .tempSave:
            cropVC.cropVCButtonType = .add
        case .edit:
            cropVC.cropVCButtonType = .edit
        }

        // self.cropVC = cropVC
        cropVC.delegate = self
        // self.selectedOriginalImage = newImage
        dismiss(animated: true) {
            self.present(cropVC, animated: true, completion: nil)
        }
        */
    }
}

// MARK: - Keyboard Extension
extension DiaryWritingViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        print("DiaryWriting :: keyboardWillShow! - \(keyboardHeight)")

        var height: CGFloat = keyboardHeight
        if weatherPlaceToolbarView.isHidden == false {
            height += 130
        }
        scrollView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(height)
        }

        weatherPlaceToolbarView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
    }

    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        print("DiaryWriting :: keyboardWillHide!")
        scrollView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }

        weatherPlaceToolbarView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - WeatherPlaceToolbarView Delegate
extension DiaryWritingViewController: WeatherPlaceToolbarViewDelegate {
    func close() {
        weatherPlaceToolbarView.isHidden = true
        print("DiaryWriting :: DiaryWrting에서 close 이벤트를 전달 받았습니다.")
    }

    func weatherSendData(weatherType: Weather) {
        print("DiaryWriting :: DiaryWrting에서 전달 받았습니다 \(weatherType)")
        selectedWeatherType = weatherType
        weatherSelectView.selectedWeatherType = weatherType
        weatherSelectView.selected = true
        isEditBeginRelay.accept(true)
        listener?.weatherRelay.accept(weatherType)
    }

    func placeSendData(placeType: Place) {
        print("DiaryWriting :: DiaryWrting에서 전달 받았습니다 \(placeType)")
        selectedPlaceType = placeType
        locationSelectView.selectedPlaceType = placeType
        locationSelectView.selected = true
        isEditBeginRelay.accept(true)
        listener?.placeRelay.accept(placeType)
    }
}

// MARK: - DialogDelegate

extension DiaryWritingViewController: DialogDelegate {
    func action(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryWriting(let diaryWritingDialog) = dialogScreen {
            switch diaryWritingDialog {
            case .writing, .edit:
                addDiary()

            case .writingCancel, .editCancel:
                listener?.saveTempSave()
                listener?.pressedBackBtn(isOnlyDetach: false)

            case .deletePhoto(let cell):
                // imageUploadView.image = nil
                imageUploadView.deleteImage(cell: cell)
                isEditBeginRelay.accept(true)

            case .deleteAllPhotos:
                imageUploadView.deleteAllImages()
                isEditBeginRelay.accept(true)

            case .camera:
                break
            }
        }
    }

    func exit(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryWriting(let diaryWritingDialog) = dialogScreen {
            switch diaryWritingDialog {
            case .writing, .edit:
                break

            case .writingCancel, .editCancel:
                break

            case .deletePhoto:
                break

            case .deleteAllPhotos:
                break

            case .camera:
                break
            }
        }
    }

}

// MARK: - UI Setting
extension DiaryWritingViewController {
    func initUI() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
            // 글 작성 완료 버튼
            $0.rightButton1.addTarget(self, action: #selector(pressedCheckBtn), for: .touchUpInside)
            // 임시 저장 버튼
            $0.rightButton2.addTarget(self, action: #selector(pressedTempSaveBtn), for: .touchUpInside)
        }

        weatherPlaceToolbarView.do {
            $0.categoryName = "weatherPlace"
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
            $0.isHidden = true
            $0.AppShadow(.shadow_6)
        }

        scrollView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.isScrollEnabled = true
            // $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        }

        titleTextField.do {
            $0.categoryName = "title"
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
            // 초기에만 세팅하고, Edit, TempSave에서는 세팅되지 않도록
            if $0.text.count == 0 || $0.text == defaultTitleText {
                $0.text = defaultTitleText
                $0.font = UIFont.AppTitle(.title_5)
                $0.textColor = Colors.grey.g600
            }
            $0.tag = TextViewType.title.rawValue
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
        }

        divider1.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800
        }

        weatherSelectView.do {
            $0.categoryName = "weather"
            $0.translatesAutoresizingMaskIntoConstraints = false

            $0.selectTextView.delegate = self
            $0.selectTextView.tag = TextViewType.weather.rawValue
            $0.selectTextView.text = self.defaultWeatherText
            $0.deleteBtn.addTarget(self, action: #selector(pressedWeatherViewDeleteBtn), for: .touchUpInside)
            $0.isDeleteBtnEnabled = false
        }

        divider2.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800
        }

        locationSelectView.do {
            $0.categoryName = "place"
            $0.translatesAutoresizingMaskIntoConstraints = false

            $0.selectTextView.delegate = self
            $0.selectTextView.tag = TextViewType.location.rawValue
            $0.selectTextView.text = self.defaultPlaceText
            $0.deleteBtn.addTarget(self, action: #selector(pressedPlaceViewDeleteBtn), for: .touchUpInside)
            $0.isDeleteBtnEnabled = false
        }

        divider3.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800
        }

        descriptionTextView.do {
            $0.categoryName = "description"
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
            // $0.typingAttributes = UIFont.AppBody(.body_4, .lightGray)
            // $0.backgroundColor = .gray.withAlphaComponent(0.1)
            $0.backgroundColor = .clear
            if $0.text.count == 0 || $0.text == defaultDescriptionText {
                $0.text = defaultDescriptionText
                $0.textColor = Colors.grey.g600
                $0.font = UIFont.AppBodyOnlyFont(.body_4).withSize(14)
            }
            $0.isScrollEnabled = false
            $0.tag = TextViewType.description.rawValue
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
        }

        datePageTextCountView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.page = String(self.listener?.page ?? 0)
        }

        divider4.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800
        }

        imageUploadView.do {
            $0.categoryName = "image"
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
        }

        imageView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds = true
            $0.backgroundColor = .brown
            $0.contentMode = .scaleAspectFill

        }
        testImagePicker.do {
            $0.delegate = self
            $0.sourceType = .photoLibrary
            $0.allowsEditing = false
        }
    }

    func setViews() {
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        view.backgroundColor = Colors.background

        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.view.addSubview(weatherPlaceToolbarView)

        scrollView.addSubview(titleTextField)
        scrollView.addSubview(divider1)
        scrollView.addSubview(weatherSelectView)
        scrollView.addSubview(divider2)
        scrollView.addSubview(locationSelectView)
        scrollView.addSubview(divider3)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(datePageTextCountView)
        scrollView.addSubview(divider4)
        scrollView.addSubview(imageUploadView)
        self.view.bringSubviewToFront(naviView)

        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }

        scrollView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom)
            make.bottom.equalToSuperview()
        }

        titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(24)
        }

        divider1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.height.equalTo(1)
        }

        weatherSelectView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(24)
            make.top.equalTo(divider1.snp.bottom).offset(13)
        }

        divider2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(weatherSelectView.snp.bottom).offset(12)
            make.height.equalTo(1)
        }

        locationSelectView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(24)
            make.top.equalTo(divider2.snp.bottom).offset(12)
        }

        divider3.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(locationSelectView.snp.bottom).offset(12)
            make.height.equalTo(1)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(divider3.snp.bottom).offset(16)
            make.height.equalTo(185)
        }

        datePageTextCountView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(descriptionTextView.snp.bottom)
            make.height.equalTo(15)
        }

        divider4.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(datePageTextCountView.snp.bottom).offset(16)
            make.height.equalTo(1)
        }

        imageUploadView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(divider4.snp.bottom).offset(16)
            make.height.equalTo(130)
            make.bottom.equalToSuperview().inset(40)
        }

        weatherPlaceToolbarView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(130)
        }
    }
}

// MARK: - ImageUploadViewDelegate

extension DiaryWritingViewController: ImageUploadViewDelegate {
    var uploadImagesRelay: BehaviorRelay<[Data]>? {
        listener?.uploadImagesRelay
    }

    func pressedTakeImageButton() {
        print("DiaryHome :: pressedTakeImageButton")
        pressedTakeImagePullDownBtn()
    }

    func pressedUploadImageButton() {
        print("DiaryHome :: pressedUploadImageButton")
        pressedImageUploadPullDownBtn()
    }

    func pressedDeleteButton(cell: ImageUploadCell) {
        showDialog(
            dialogScreen: .diaryWriting(.deletePhoto(cell: cell)),
            size: .small,
            buttonType: .twoBtn,
            titleText: "해당 사진을 삭제하시겠어요?",
            cancelButtonText: MenualString.writing_alert_cancel,
            confirmButtonText: "삭제하기"
        )
    }

    func pressedAllImagesDeleteButton() {
        showDialog(
            dialogScreen: .diaryWriting(.deleteAllPhotos),
            size: .small,
            buttonType: .twoBtn,
            titleText: "모든 사진을 삭제하시겠어요?",
            cancelButtonText: MenualString.writing_alert_cancel,
            confirmButtonText: "삭제하기"
        )
    }
}
