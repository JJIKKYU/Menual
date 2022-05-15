//
//  DiaryWritingViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import SnapKit
import UIKit
import PhotosUI

protocol DiaryWritingPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn()
    func writeDiary(info: DiaryModel)
    func testSaveImage(imageName: String, image: UIImage)
    func pressedWeatherPlaceAddBtn(type: BottomSheetSelectViewType)
    func pressedTempSaveBtn()
}

final class DiaryWritingViewController: UIViewController, DiaryWritingPresentable, DiaryWritingViewControllable  {

    weak var listener: DiaryWritingPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .write).then {
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
    
    lazy var titleTextField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.placeholder = "제목을 입력해주세요."
        $0.font = UIFont.AppTitle(.title_5)
    }
    
    lazy var descriptionTextView = UITextView().then {
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .white
        $0.typingAttributes = UIFont.AppBody(.body_4, .lightGray)
        $0.backgroundColor = .gray
        $0.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
    }
    
    let imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.masksToBounds = true
        $0.backgroundColor = .brown
        $0.contentMode = .scaleAspectFill
    }
    
    lazy var imageViewBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(pressedImageview), for: .touchUpInside)
        $0.setTitle("이미지 업로드하기", for: .normal)
    }
    
    lazy var weatherAddBtn = UIButton().then {
        $0.addTarget(self, action: #selector(pressedWeatherAddBtn), for: .touchUpInside)
        $0.setTitle("날씨 추가", for: .normal)
    }
    
    lazy var placeAddBtn = UIButton().then {
        $0.addTarget(self, action: #selector(pressedPlaceAddBtn), for: .touchUpInside)
        $0.setTitle("장소 추가", for: .normal)
    }
    
    var phpickerConfiguration = PHPickerConfiguration()
    lazy var imagePciker = PHPickerViewController(configuration: phpickerConfiguration).then {
        $0.delegate = self
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
        print("DiaryWriting!")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setViews() {
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        view.backgroundColor = .black
        
        self.view.addSubview(titleTextField)
        self.view.addSubview(descriptionTextView)
        self.view.addSubview(imageView)
        self.view.addSubview(imageViewBtn)
        self.view.addSubview(naviView)
        self.view.addSubview(weatherAddBtn)
        self.view.addSubview(placeAddBtn)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20 + 44 + UIApplication.topSafeAreaHeight)
        }
        
        weatherAddBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        placeAddBtn.snp.makeConstraints { make in
            make.leading.equalTo(weatherAddBtn.snp.trailing).offset(20)
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(weatherAddBtn.snp.bottom).offset(20)
            make.height.equalTo(200)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }
        
        imageViewBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.height.equalTo(50)
        }
    }
    
    func setWeatherView(model: WeatherModel) {
        // 날씨를 선택하지 않았으면 뷰를 변경할 필요 없음
        guard let weather = model.weather else {
            return
        }
        self.weatherAddBtn.setTitle(Weather().getWeatherText(weather: weather), for: .normal)
    }
    
    func setPlaceView(model: PlaceModel) {
        guard let place = model.place else {
            return
        }
        print("setPlaceView = \(model)")
        self.placeAddBtn.setTitle(Place().getPlaceText(place: place), for: .normal)
    }

    @objc
    func pressedBackBtn() {
        print("pressedBackBtn!")
        listener?.pressedBackBtn()
    }
    
    @objc
    func pressedCheckBtn() {
        print("PressedCheckBtn!")
        guard let title = self.titleTextField.text,
              let description = self.descriptionTextView.text
        else { return }
        
        let diaryModel = DiaryModel(uuid: NSUUID().uuidString,
                                    title: title,
                                    weather: WeatherModel(uuid: NSUUID().uuidString, weather: .sun, detailText: "123"),
                                    place: PlaceModel(uuid: NSUUID().uuidString, place: .place, detailText: "123"),
                                    description: description,
                                    image: self.imageView.image,
                                    readCount: 0,
                                    createdAt: Date()
        )
        print("diaryModel.id = \(diaryModel.uuid)")
        listener?.testSaveImage(imageName: diaryModel.uuid, image: self.imageView.image ?? UIImage())
        listener?.writeDiary(info: diaryModel)
        dismiss(animated: true)
    }
    
    @objc
    func pressedImageview() {
        print("PressedImageViewBtn!")
        phpickerConfiguration.filter = .images
        phpickerConfiguration.selectionLimit = 1
        present(imagePciker, animated: true, completion: nil)
    }
    
    @objc
    func pressedWeatherAddBtn() {
        print("pressedWeatherAddBtn")
        listener?.pressedWeatherPlaceAddBtn(type: .weather)
    }
    
    @objc
    func pressedPlaceAddBtn() {
        listener?.pressedWeatherPlaceAddBtn(type: .place)
    }
    
    @objc
    func pressedTempSaveBtn() {
        print("pressedTempSaveBtn")
        listener?.pressedTempSaveBtn()
    }
}

extension DiaryWritingViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다." {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
            textView.textColor = .lightGray
        }
    }
}

extension DiaryWritingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        self.imageView.image = image as? UIImage
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}
