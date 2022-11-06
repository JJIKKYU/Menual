//
//  DiaryWritingViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RxRelay
import SnapKit
import UIKit
import PhotosUI
import ImageCropper
import CropViewController

protocol DiaryWritingPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
    func writeDiary(info: DiaryModel)
    func updateDiary(info: DiaryModel, edittedImage: Bool)
    
    func testSaveImage(imageName: String, image: UIImage)
    func saveCropImage(diaryUUID: String, imageData: Data)
    func saveOriginalImage(diaryUUID: String, imageData: Data)
    func saveTempSave(diaryModel: DiaryModel)
    func pressedWeatherPlaceAddBtn(type: BottomSheetSelectViewType)
    func pressedTempSaveBtn()
}

final class DiaryWritingViewController: UIViewController, DiaryWritingPresentable, DiaryWritingViewControllable {
    
    private let TITLE_TEXT_MAX_COUNT: Int = 40
    
    enum TextViewType: Int {
        case title = 0
        case weather = 1
        case location = 2
        case description = 3
    }
    
    enum WritingType {
        case writing
        case edit
    }

    weak var listener: DiaryWritingPresentableListener?
    private let isEditBeginRelay = BehaviorRelay<Bool>(value: false)
    private var editDiaryModel: DiaryModel?
    
    // 유저가 선택 후 기본 선택 되어있도록
    private var selectedWeatherType: Weather?
    private var selectedPlaceType: Place?
    
    private var disposeBag = DisposeBag()
    
    private var writingType: WritingType = .writing
    
    private var diaryModelUUID: String?
    
    // 수정하기 상태에서 이미지를 수정했을때만 저장할 수 있도록 하는 플래그
    private var isEdittedIamge: Bool = false
    // 업로드할 크롭된 이미지
    private var selectedImage: UIImage?
    // 업로드할 오리지날 이미지
    private var selectedOriginalImage: UIImage?
    
    private let defaultTitleText: String = "제목을 입력할 수 있어요"
    private let defaultDescriptionText: String = "오늘의 메뉴얼을 작성해주세요."
    
    // delegate 저장 후 VC 삭제시 해제 용도
    private var cropVC: CustomCropViewController?
    
    private lazy var naviView = MenualNaviView(type: .write).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        // 글 작성 완료 버튼
        $0.rightButton1.addTarget(self, action: #selector(pressedCheckBtn), for: .touchUpInside)
        $0.rightButton1.tintColor = .white
        $0.rightButton1.setImage(Asset._24px.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
        
        // 임시 저장 버튼
        $0.rightButton2.addTarget(self, action: #selector(pressedTempSaveBtn), for: .touchUpInside)
        $0.rightButton2.tintColor = .white
        $0.rightButton2.setImage(Asset._24px.storage.image.withRenderingMode(.alwaysTemplate), for: .normal)
    }
    
    private lazy var weatherPlaceToolbarView = WeatherPlaceToolbarView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.isHidden = true
        $0.AppShadow(.shadow_6)
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        // $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    }
    
    private lazy var titleTextField = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.text = defaultTitleText
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppTitle(.title_5)
        $0.tag = TextViewType.title.rawValue
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }
    
    private let divider1 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
    }
    
    private lazy var weatherSelectView = WeatherLocationSelectView(type: .weather).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.selectTextView.delegate = self
        $0.selectTextView.tag = TextViewType.weather.rawValue
        $0.selectTextView.text = "오늘 날씨는 어땠나요?"
        $0.deleteBtn.addTarget(self, action: #selector(pressedWeatherViewDeleteBtn), for: .touchUpInside)

    }
    
    private let divider2 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
    }
    
    private lazy var locationSelectView = WeatherLocationSelectView(type: .location).then {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.selectTextView.delegate = self
        $0.selectTextView.tag = TextViewType.location.rawValue
        $0.selectTextView.text = "지금 장소는 어디신가요?"
        $0.deleteBtn.addTarget(self, action: #selector(pressedPlaceViewDeleteBtn), for: .touchUpInside)
    }
    
    private let divider3 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
    }
    
    lazy var descriptionTextView = UITextView().then {
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        // $0.typingAttributes = UIFont.AppBody(.body_4, .lightGray)
        // $0.backgroundColor = .gray.withAlphaComponent(0.1)
        $0.backgroundColor = .clear
        $0.text = defaultDescriptionText
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_4).withSize(14)
        $0.isScrollEnabled = false
        $0.tag = TextViewType.description.rawValue
    }
    
    private let datePageTextCountView = DatePageTextCountView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let divider4 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g800
    }
    
    private lazy var imageUploadView = ImageUploadView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.uploadBtn.addTarget(self, action: #selector(pressedImageUploadView), for: .touchUpInside)
        $0.deleteBtn.addTarget(self, action: #selector(pressedImageUploadViewDeleteBtn), for: .touchUpInside)
        $0.editBtn.addTarget(self, action: #selector(pressedImageUploadViewEditBtn), for: .touchUpInside)
    }
    
    let imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.masksToBounds = true
        $0.backgroundColor = .brown
        $0.contentMode = .scaleAspectFill
    }
    
    /*
    lazy var imageViewBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedImageview), for: .touchUpInside)
        $0.setTitle("이미지 업로드하기", for: .normal)
    }
     */
    
    var phpickerConfiguration = PHPickerConfiguration()
    lazy var imagePicker = PHPickerViewController(configuration: phpickerConfiguration).then {
        $0.delegate = self
    }
    
    lazy var testImagePicker = UIImagePickerController().then {
        $0.delegate = self
        $0.sourceType = .photoLibrary
        $0.allowsEditing = false
    }
    
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
        setViews()
        bind()
        self.datePageTextCountView.date = Date().toString()

        locationSelectView.selectTextView.inputAccessoryView = weatherPlaceToolbarView
        weatherSelectView.selectTextView.inputAccessoryView = weatherPlaceToolbarView
        
        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Delegate 해제
        weatherPlaceToolbarView.delegate = nil
        titleTextField.delegate = nil
        descriptionTextView.delegate = nil
        weatherSelectView.selectTextView.delegate = nil
        locationSelectView.selectTextView.delegate = nil
        cropVC?.delegate = nil
        
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
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
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
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
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
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
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(divider4.snp.bottom).offset(16)
            make.height.equalTo(110)
            make.bottom.equalToSuperview()
        }
        
        weatherPlaceToolbarView.snp.makeConstraints { make in
            make.leading.width.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.height.equalTo(130)
        }
    }
    
    func bind() {
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
                
                switch self.writingType {
                case .writing:
                    self.datePageTextCountView.textCount = String(text.count)
                    if text.count > 0 {
                        self.naviView.rightButton1IsActive = true
                    } else {
                        self.naviView.rightButton1IsActive = false
                    }
                case .edit:
                    break

                }
            })
            .disposed(by: disposeBag)
        
        isEditBeginRelay
            .subscribe(onNext: { [weak self] isEditBegin in
                guard let self = self else { return }
                print("DiaryWriting :: isEditBeginRelay! \(isEditBegin)")
                switch isEditBegin {
                case true:
                    self.naviView.rightButton1IsActive = true
                case false:
                    self.naviView.rightButton1IsActive = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setWeatherView(model: WeatherModel) {
        // 날씨를 선택하지 않았으면 뷰를 변경할 필요 없음
        guard let weather = model.weather else {
            return
        }
        print("DiaryWriting ::setWeatherView = \(model)")
        weatherSelectView.selected = true
        weatherSelectView.selectedWeatherType = weather
    }

    func setPlaceView(model: PlaceModel) {
        guard let place = model.place else {
            return
        }
        print("DiaryWriting ::setPlaceView = \(model)")
        locationSelectView.selected = true
        locationSelectView.selectedPlaceType = place
    }
    
    func addDiary() {
        print("DiaryWriting :: addDiary! - 1")
        guard let title = self.titleTextField.text,
              let description = self.descriptionTextView.text
        else { return }
        print("DiaryWriting :: addDiary! - 2")
        
        let weatherModel = WeatherModel(uuid: NSUUID().uuidString,
                                        weather: weatherSelectView.selectedWeatherType ?? nil,
                                        detailText: weatherSelectView.selectTitle
        )

        let placeModel = PlaceModel(uuid: NSUUID().uuidString,
                                    place: locationSelectView.selectedPlaceType ?? nil,
                                    detailText: locationSelectView.selectTitle
        )

        switch writingType {
        case .writing:
            let diaryModel = DiaryModel(uuid: NSUUID().uuidString,
                                        pageNum: 0,
                                        title: title == defaultTitleText ? Date().toString() : title,
                                        weather: weatherModel,
                                        place: placeModel,
                                        description: description,
                                        image: self.selectedImage,
                                        originalImage: self.selectedOriginalImage,
                                        readCount: 0,
                                        createdAt: Date(),
                                        replies: [],
                                        isDeleted: false,
                                        isHide: false
            )


            print("diaryModel.id = \(diaryModel.uuid)")
            if isEdittedIamge == true,
               let selectedImage = selectedImage,
               let selectedImageData = selectedImage.pngData(),
               let selectedOriginalImage = selectedOriginalImage,
               let selectedOriginalImageData = selectedOriginalImage.pngData() {
                print("DiaryWriting :: 이미지를 사용자가 업로드 했습니다.")
                listener?.saveCropImage(diaryUUID: diaryModel.uuid, imageData: selectedImageData)
                listener?.saveOriginalImage(diaryUUID: diaryModel.uuid, imageData: selectedOriginalImageData)
            }
            // listener?.testSaveImage(imageName: diaryModel.uuid, image: self.selectedImage ?? UIImage())
            listener?.writeDiary(info: diaryModel)
            dismiss(animated: true)

        case .edit:
            print("PressedCheckBtn! edit!")
            let diaryModel = DiaryModel(uuid: "",
                                        pageNum: 0,
                                        title: title == defaultTitleText ? Date().toString() : title,
                                        weather: weatherModel,
                                        place: placeModel,
                                        description: description,
                                        image: self.selectedImage,
                                        originalImage: self.selectedOriginalImage,
                                        readCount: 0,
                                        createdAt: Date(),
                                        replies: [],
                                        isDeleted: false,
                                        isHide: false
            )
            
            self.listener?.updateDiary(info: diaryModel, edittedImage: self.isEdittedIamge)

            if isEdittedIamge == true,
               let selectedImage = selectedImage,
               let selectedImageData = selectedImage.pngData(),
               let selectedOriginalImage = selectedOriginalImage,
               let selectedOriginalImageData = selectedOriginalImage.pngData(),
               let diaryModelUUID = diaryModelUUID {
                print("DiaryWriting :: 이미지를 사용자가 업로드 했습니다.")
                listener?.saveCropImage(diaryUUID: diaryModelUUID, imageData: selectedImageData)
                listener?.saveOriginalImage(diaryUUID: diaryModelUUID, imageData: selectedOriginalImageData)
            }
            print("DiaryWriting :: diaryModel = \(diaryModel)")
        }
    }
    
    // tempSaveModel로 만들기 위해서 오물락조물락
    func zipDiaryModelForTempSave() -> DiaryModel? {
        guard let title = self.titleTextField.text,
              let description = self.descriptionTextView.text
        else { return nil }
        print("DiaryWriting :: zipDiaryModelForTempSave!")
        
        let weatherModel = WeatherModel(uuid: NSUUID().uuidString,
                                        weather: weatherSelectView.selectedWeatherType ?? nil,
                                        detailText: weatherSelectView.selectTitle
        )

        let placeModel = PlaceModel(uuid: NSUUID().uuidString,
                                    place: locationSelectView.selectedPlaceType ?? nil,
                                    detailText: locationSelectView.selectTitle
        )
        
        let diaryModel = DiaryModel(uuid: NSUUID().uuidString,
                                    pageNum: 0,
                                    title: title == defaultTitleText ? Date().toString() : title,
                                    weather: weatherModel,
                                    place: placeModel,
                                    description: description,
                                    image: self.selectedImage,
                                    originalImage: self.selectedOriginalImage,
                                    readCount: 0,
                                    createdAt: Date(),
                                    replies: [],
                                    isDeleted: false,
                                    isHide: false
        )
        
        return diaryModel
    }
    
    // 수정하기일때만 사용!
    func setDiaryEditMode(diaryModel: DiaryModel) {
        self.editDiaryModel = diaryModel
        self.diaryModelUUID = diaryModel.uuid
        self.writingType = .edit
        self.naviView.naviViewType = .edit
        self.naviView.setNaviViewType()
        
        self.titleTextField.text = diaryModel.title
        self.titleTextField.textColor = Colors.grey.g200
        
        self.weatherSelectView.selectTitle = diaryModel.weather?.detailText ?? ""
        self.weatherSelectView.selectedWeatherType = diaryModel.weather?.weather ?? .snow
        self.weatherSelectView.selected = true

        self.locationSelectView.selectedPlaceType = diaryModel.place?.place ?? .company
        self.locationSelectView.selectTitle = diaryModel.place?.detailText ?? ""
        self.locationSelectView.selected = true
        
        self.descriptionTextView.text = diaryModel.description
        self.descriptionTextView.textColor = UIColor.white
        
        self.imageUploadView.image = nil
        self.imageUploadView.image = diaryModel.image ?? nil
        
        self.selectedPlaceType = diaryModel.place?.place
        self.selectedWeatherType = diaryModel.weather?.weather
        
        self.view.layoutIfNeeded()
    }
    
    func setTempSaveModel(tempSaveModel: TempSaveModel) {
        print("DiaryWriting :: setTempSaveModel")
        self.titleTextField.text = tempSaveModel.title
        self.titleTextField.textColor = Colors.grey.g200
        
        self.weatherSelectView.selectTitle = tempSaveModel.weatherDetailText ?? ""
        self.weatherSelectView.selectedWeatherType = tempSaveModel.weather
        self.weatherSelectView.selected = true

        self.locationSelectView.selectedPlaceType = tempSaveModel.place
        self.locationSelectView.selectTitle = tempSaveModel.placeDetilText ?? ""
        self.locationSelectView.selected = true
        
        self.descriptionTextView.text = tempSaveModel.description
        self.descriptionTextView.textColor = UIColor.white
        
        self.imageUploadView.image = nil
        self.imageUploadView.image = tempSaveModel.image ?? nil
        
        self.selectedPlaceType = tempSaveModel.place
        self.selectedWeatherType = tempSaveModel.weather
    }
}

// MARK: - IBACtion
extension DiaryWritingViewController {
    @objc
    func pressedBackBtn() {
        print("pressedBackBtn!")
        var titleText: String = ""
        var isShowDialog: Bool = false
        switch writingType {
        case .writing:
            titleText = "메뉴얼 작성을 취소하시겠어요?"
            if isEditBeginRelay.value == true {
                isShowDialog = true
            } else {
                isShowDialog = false
            }
        case .edit:
            titleText = "메뉴얼 수정을 취소하시겠어요?"
            if isEditBeginRelay.value == true {
                isShowDialog = true
            } else {
                isShowDialog = false
            }
        }
        
        if isShowDialog {
            show(size: .medium,
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
    func pressedCheckBtn() {
        var titleText: String = ""
        switch writingType {
        case .writing:
            titleText = "메뉴얼을 등록하시겠어요?"
        case .edit:
            titleText = "메뉴얼을 수정하시겠어요?"
        }

        show(size: .small,
             buttonType: .twoBtn,
             titleText: titleText,
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedImageUploadView() {
        print("DiaryWriting :: pressedImageUploadView!")
        
        phpickerConfiguration.filter = .images
        phpickerConfiguration.selectionLimit = 1
        imagePicker.isEditing = true
        // present(imagePicker, animated: true, completion: nil)
//        testImagePicker.modalPresentationStyle = .fullScreen
        
//        present(testImagePicker, animated: true)
        let navigationController = UINavigationController(rootViewController: imagePicker)
//        let navigationController = UINavigationController(rootViewController: testImagePicker)
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.navigationBar.isHidden = true
        navigationController.isNavigationBarHidden = true
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc
    func pressedWeatherAddBtn() {
        print("pressedWeatherAddBtn")

        titleTextField.inputAccessoryView?.isHidden = false
        descriptionTextView.inputAccessoryView?.isHidden = false
        view.layoutIfNeeded()

        //listener?.pressedWeatherPlaceAddBtn(type: .weather)
    }
    
    @objc
    func pressedPlaceAddBtn() {
        titleTextField.inputAccessoryView?.isHidden = false
        descriptionTextView.inputAccessoryView?.isHidden = false
        view.layoutIfNeeded()

        // listener?.pressedWeatherPlaceAddBtn(type: .place)
    }
    
    @objc
    func pressedTempSaveBtn() {
        print("pressedTempSaveBtn")
        listener?.pressedTempSaveBtn()
    }
    
    @objc
    func pressedImageUploadViewEditBtn() {
        print("DiaryWriting :: pressedImageUploadViewEditBtn")
        // 따로 추가 기능이 없으므로 그대로 랜딩
        pressedImageUploadView()
    }
    
    @objc
    func pressedImageUploadViewDeleteBtn() {
        print("DiaryWriting :: pressedImageUploadViewDeleteBtn")
        imageUploadView.image = nil
        selectedImage = nil
        selectedOriginalImage = nil
    }
    
    @objc
    func pressedPlaceViewDeleteBtn() {
        print("DiaryWriting :: pressedPlaceLocationViewDeleteBtn! - locationView")
        selectedPlaceType = nil
        locationSelectView.selectedPlaceType = nil
        locationSelectView.selected = false
        locationSelectView.selectTextView.text = ""
        weatherPlaceToolbarView.selectedPlaceType = nil
    }
    
    @objc
    func pressedWeatherViewDeleteBtn() {
        print("DiaryWriting :: pressedPlaceLocationViewDeleteBtn! - weatherView")
        selectedWeatherType = nil
        weatherSelectView.selectedWeatherType = nil
        weatherSelectView.selected = false
        weatherSelectView.selectTextView.text = ""
        weatherPlaceToolbarView.selectedWeatherType = nil
    }
}

// MARK: - UITextField
extension DiaryWritingViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("DiaryWriting :: textViewShouldBeginEditing")
        
        if textView == descriptionTextView {
            titleTextField.inputAccessoryView?.isHidden = true
            descriptionTextView.inputAccessoryView?.isHidden = true
        }

        switch textView.tag {
        case TextViewType.title.rawValue:
            print("Title TextView")
            if textView.text == defaultTitleText {
                textView.text = nil
                textView.textColor = Colors.grey.g200
            }
            
        case TextViewType.weather.rawValue:
            print("Weather TextView")
            weatherPlaceToolbarView.isHidden = false
            weatherPlaceToolbarView.weatherPlaceType = .weather
            weatherPlaceToolbarView.selectedWeatherType = selectedWeatherType
            if textView.text == "오늘 날씨는 어땠나요?" {
                 weatherSelectView.selectTitle = ""
                textView.text = nil
                textView.textColor = UIColor.white
            }
            
        case TextViewType.location.rawValue:
            print("Location TextView")
            weatherPlaceToolbarView.isHidden = false
            weatherPlaceToolbarView.weatherPlaceType = .place
            weatherPlaceToolbarView.selectedPlaceType = selectedPlaceType
            if textView.text == "지금 장소는 어디신가요?" {
                 locationSelectView.selectTitle = ""
                textView.text = nil
                textView.textColor = UIColor.white
            }
            
        case TextViewType.description.rawValue:
            print("Description TextView")
            if textView.text == defaultDescriptionText {
                textView.text = nil
                textView.textColor = Colors.grey.g600
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
            if weatherSelectView.selected == true {
                
            }
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && weatherSelectView.selected == false {
                textView.text = "오늘 날씨는 어땠나요?"
                textView.textColor = Colors.grey.g600
            }
            break
            
        case TextViewType.location.rawValue:
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && locationSelectView.selected == false {
                textView.text = "지금 장소는 어디신가요?"
                textView.textColor = Colors.grey.g600
            }
            break
            
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
        let fixedWidth = textView.frame.size.width

        switch textView.tag {
        case TextViewType.title.rawValue:
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
            print("JJIKKYU :: newSizeHeight = \(newSize.height)")
            // textView.centerVerticalText()
            isEditBeginRelay.accept(true)
            
        case TextViewType.weather.rawValue:
            textView.centerVerticalText()
            isEditBeginRelay.accept(true)
            
        case TextViewType.location.rawValue:
            textView.centerVerticalText()
            isEditBeginRelay.accept(true)
            
        case TextViewType.description.rawValue:
            
            let size = CGSize(width: view.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach { (constraint) in
            
              /// 180 이하일때는 더 이상 줄어들지 않게하기
                if estimatedSize.height <= 185 {
                
                }
                else {
                    if constraint.firstAttribute == .height {
                        constraint.constant = estimatedSize.height
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
        case TextViewType.title.rawValue:
            if text == "\n" {
                return false
            }

            //이전 글자 - 선택된 글자 + 새로운 글자(대체될 글자)
            let newLength = textView.text.count - range.length + text.count
            let koreanMaxCount = TITLE_TEXT_MAX_COUNT + 1
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
            
        case TextViewType.weather.rawValue:
            if text == "\n" {
                return false
            }
            
        case TextViewType.location.rawValue:
            if text == "\n" {
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
        // picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        // self.imageView.image = image as? UIImage
                        // self.imageUploadView.image = image as? UIImage
                        
                        if let image = image as? UIImage {
                            let cropVC = CustomCropViewController(image: image)
                            self.cropVC = cropVC
                            cropVC.delegate = self
                            print("DiaryWriting :: selectedOriginalImage = \(image)")
                            self.selectedOriginalImage = image
                            picker.navigationController?.pushViewController(cropVC, animated: true)
                        }
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
            print("DiaryWriting :: 이미지가 없습니다!")
            self.isEdittedIamge = false
            dismiss(animated: true)
        }
    }
}

extension DiaryWritingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("DiaryWriting :: didFinishPickingMediaWithInfo!")
        var newImage: UIImage?
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = image
        }
        
        let cropVC = CropViewController(image: newImage!)
        picker.pushViewController(cropVC, animated: true)
    }
}

// MARK: - Keyboard Extension
extension DiaryWritingViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        print("DiaryWriting :: keyboardWillShow! - \(keyboardHeight)")
        scrollView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        print("DiaryWriting :: keyboardWillHide!")
        scrollView.snp.updateConstraints { make in
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
    }
    
    func placeSendData(placeType: Place) {
        print("DiaryWriting :: DiaryWrting에서 전달 받았습니다 \(placeType)")
        selectedPlaceType = placeType
        locationSelectView.selectedPlaceType = placeType
        locationSelectView.selected = true
        isEditBeginRelay.accept(true)
    }
}


// MARK: - CustomCropViewController
extension DiaryWritingViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("image! = \(image)")
        self.selectedImage = image
        self.imageUploadView.image = image
        self.isEdittedIamge = true
        self.isEditBeginRelay.accept(true)
        dismiss(animated: true)
    }
}

extension DiaryWritingViewController: DialogDelegate {
    func action(titleText: String) {
        switch titleText {
        case "메뉴얼 작성을 취소하시겠어요?",
             "메뉴얼 수정을 취소하시겠어요?":
            // TODO: - 임시저장 리스트에 저장하기
            if let diaryModel = zipDiaryModelForTempSave() {
                listener?.saveTempSave(diaryModel: diaryModel)
            }
            listener?.pressedBackBtn(isOnlyDetach: false)
            
        case "메뉴얼을 등록하시겠어요?",
             "메뉴얼을 수정하시겠어요?":
            addDiary()
            
        default:
            break
            
        }
    }
    
    func exit(titleText: String) {
        switch titleText {
        case "메뉴얼 작성을 취소하시겠어요?",
             "메뉴얼 수정을 취소하시겠어요?":
            break
            
        case "메뉴얼을 등록하시겠어요?",
             "메뉴얼을 수정하시겠어요?":
            break
            
        default:
            break
        }
    }
}
