//
//  DiaryBottomSheetViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay
import UIKit

protocol DiaryBottomSheetPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedCloseBtn()
    func updateWeatherDetailText(text: String)
    func updateWeather(weather: Weather)
    func pressedWriteBtn()
}

final class DiaryBottomSheetViewController: MenualBottomSheetBaseViewController, DiaryBottomSheetPresentable, DiaryBottomSheetViewControllable {
    
    weak var listener: DiaryBottomSheetPresentableListener?
    var disposeBag = DisposeBag()
    var keyHeight: CGFloat?
    var selectedCellWeatherType: Weather?
    
    lazy var closeBtn = UIButton().then {
        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(dimmedViewTapped), for: .touchUpInside)
        $0.contentMode = .scaleAspectFit
    }
        
    lazy var segmentationView = MenualSegmentationBaseViewController(frame: CGRect.zero).then {
        $0.setButtonTitles(buttonTitles: ["날씨", "장소"])
        $0.backgroundColor = .clear
        $0.delegate = self
    }
    
    let weatherView = UIView().then {
        $0.backgroundColor = .clear
        $0.isHidden = false
    }
    
    let placeView = BottomSheetSelectView().then {
        $0.isHidden = true
        $0.title = "장소에 대해 기록해주세요"
    }
    
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }

    let titleLabel = UILabel().then {
        $0.text = "날씨에 대해 기록해주세요"
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    let weatherCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.minimumLineSpacing = 12
    }
    
    lazy var weatherCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: weatherCollectionViewLayout).then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(MenualBottomSheetCell.self, forCellWithReuseIdentifier: "MenualCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    lazy var weatherTextField = UITextField().then {
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g100
        $0.backgroundColor = Colors.grey.g800
        $0.AppCorner(.tiny)
        $0.addLeftPadding()
    }
    
    lazy var addBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = UIFont.AppTitle(.title_2)
        $0.setTitle("날씨 추가하기", for: .normal)
        $0.addTarget(self, action: #selector(pressedAddBtn), for: .touchUpInside)
        $0.setTitleColor(Colors.grey.g800, for: .normal)
        $0.backgroundColor = Colors.tint.sub.n400
        $0.AppCorner(.tiny)
    }
    
    let recentLabel = UILabel().then {
        $0.text = "최근 목록"
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         setViews()
         bind()
         bottomSheetView.backgroundColor = Colors.background.black
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        segmentationView.delegate = nil
    }
    
    func setViews() {
        self.view.addSubview(segmentationView)
        self.view.addSubview(closeBtn)
        self.view.addSubview(addBtn)
        self.view.addSubview(weatherView)
        self.view.addSubview(placeView)
        self.view.bringSubviewToFront(addBtn)
        
        weatherView.addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(weatherCollectionView)
        scrollView.addSubview(weatherTextField)
        scrollView.addSubview(recentLabel)
        
        segmentationView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading).offset(20)
            make.top.equalTo(bottomSheetView.snp.top).offset(20)
            make.width.equalTo(90)
            make.height.equalTo(32)
        }
        
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(bottomSheetView.snp.trailing).inset(20)
            make.top.equalTo(bottomSheetView.snp.top).offset(20)
            make.width.height.equalTo(24)
        }
        
        weatherView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.top.equalTo(segmentationView.snp.bottom).offset(20)
            make.width.equalTo(bottomSheetView.snp.width)
            make.bottom.equalTo(bottomSheetView.snp.bottom)
        }
        
        placeView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.top.equalTo(segmentationView.snp.bottom).offset(20)
            make.width.equalTo(bottomSheetView.snp.width)
            make.bottom.equalTo(bottomSheetView.snp.bottom)
        }
        
        // Weahter View Setting
        scrollView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.width.equalTo(bottomSheetView.snp.width)
            make.top.equalTo(segmentationView.snp.bottom).offset(20)
            make.bottom.equalTo(bottomSheetView.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview()
        }
        
        weatherCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(32)
        }
        
        weatherTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(weatherCollectionView.snp.bottom).offset(12)
            make.height.equalTo(32)
        }
        
        addBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(bottomSheetView.snp.bottom).inset(20)
        }
        
        recentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(weatherTextField.snp.bottom).offset(16)
        }
    }
    
    func bind() {
        weatherTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext : { [weak self] changedText in
                guard let self = self else { return }
                if changedText.count == 0 { return }
                self.listener?.updateWeatherDetailText(text: changedText)
            })
            .disposed(by: disposeBag)
    }
    
    func setViewsWithWeatherModel(model: WeatherModel) {
        // 재진입 할 경우 이전에 선택했던 정보 세팅
        self.weatherTextField.text = model.detailText
        self.selectedCellWeatherType = model.weather
        weatherCollectionView.reloadData()
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        keyHeight = keyboardHeight

        self.view.frame.size.height -= keyboardHeight
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        guard let keyHeight = keyHeight else {
            return
        }

        self.view.frame.size.height += keyHeight
    }
    
    @objc
    override func dimmedViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        // hideBottomSheetAndGoBack()
        // weatherTextField.resignFirstResponder()
        print("dimmedViewTapped")
         listener?.pressedCloseBtn()
        
    }
    
    @objc
    func pressedAddBtn() {
        print("TODO :: pressedAddBtn!!")
        hideBottomSheetAndGoBack()
        weatherTextField.resignFirstResponder()
        listener?.pressedWriteBtn()
    }
    
}

extension DiaryBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenualCell", for: indexPath) as? MenualBottomSheetCell else {
            return UICollectionViewCell()
        }
        let tempArr: [Weather] = [
            .sun,
            .rain,
            .cloud,
            .thunder,
            .snow
        ]
        cell.weatherIconType = tempArr[indexPath.row]
        
        // 재진입하여 이미 선택된 셀을 만들어야 하는 경우
        if let selectedCellWeatherType = selectedCellWeatherType {
            if tempArr[indexPath.row] == selectedCellWeatherType {
                cell.selected()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? MenualBottomSheetCell else {
            return
        }
        
        for cell in collectionView.visibleCells {
            guard let cell = cell as? MenualBottomSheetCell else { continue }
            cell.unSelected()
        }
        selectedCell.selected()
        let defaultText = Weather().getWeatherText(weather: selectedCell.weatherIconType ?? .sun)
        
        self.listener?.updateWeather(weather: selectedCell.weatherIconType ?? .sun)
        
        if let text = self.weatherTextField.text,
           text.count == 0 {
            // TODO: - defaultText일 경우에도 변경 되도록
            self.weatherTextField.text = defaultText
            self.listener?.updateWeatherDetailText(text: defaultText)
        }
    }
}

extension DiaryBottomSheetViewController: UITextFieldDelegate {
    
}

extension DiaryBottomSheetViewController: MenualSegmentationDelegate {
    func changeToIdx(index: Int) {
        print("index! \(index)")
        switch index {
        // 날씨
        case 0:
            placeView.isHidden = true
            weatherView.isHidden = false
            self.addBtn.setTitle("날씨 추가하기", for: .normal)
            
        // 장소
        case 1:
            placeView.isHidden = false
            weatherView.isHidden = true
            self.addBtn.setTitle("장소 추가하기", for: .normal)
            
        default:
            break
        }
    }
}
