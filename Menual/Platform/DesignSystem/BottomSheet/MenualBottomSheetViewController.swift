//
//  MenualBottomSheetViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import UIKit
import SnapKit
import Then

/*
class MenualBottomSheetViewController: MenualBottomSheetBaseViewController {
    
    var keyHeight: CGFloat?
//    lazy var closeBtn = UIButton().then {
//        $0.setImage(Asset._24px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
//        $0.tintColor = .white
//        $0.addTarget(self, action: #selector(dimmedViewTapped), for: .touchUpInside)
//        $0.contentMode = .scaleAspectFit
//    }
        
    let segmentationView = MenualSegmentationBaseViewController(frame: CGRect.zero).then {
        $0.setButtonTitles(buttonTitles: ["날씨", "장소"])
        $0.backgroundColor = .clear
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
        bottomSheetView.backgroundColor = Colors.background
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setViews() {
        self.view.addSubview(segmentationView)
        self.view.addSubview(scrollView)
        // self.view.addSubview(closeBtn)
        self.view.addSubview(addBtn)
        
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
        
//        closeBtn.snp.makeConstraints { make in
//            make.trailing.equalTo(bottomSheetView.snp.trailing).inset(20)
//            make.top.equalTo(bottomSheetView.snp.top).offset(20)
//            make.width.height.equalTo(24)
//        }
        
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
        hideBottomSheetAndGoBack()
        weatherTextField.resignFirstResponder()
    }
    
    @objc
    func pressedAddBtn() {
        print("TODO :: pressedAddBtn!!")
        hideBottomSheetAndGoBack()
        weatherTextField.resignFirstResponder()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MenualBottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        self.weatherTextField.text = Weather().getWeatherText(weather: selectedCell.weatherIconType ?? .sun)
    }
}

extension MenualBottomSheetViewController: UITextFieldDelegate {
    
}

*/
