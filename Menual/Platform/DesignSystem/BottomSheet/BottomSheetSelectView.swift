//
//  BottomSheetSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import UIKit
import Then
import SnapKit

class BottomSheetSelectView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var title: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    let titleLabel = UILabel().then {
        $0.text = "타이틀입니다."
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    let collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.minimumLineSpacing = 12
    }
    
    lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout).then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(MenualBottomSheetCell.self, forCellWithReuseIdentifier: "MenualCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    lazy var textField = UITextField().then {
        // $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g100
        $0.backgroundColor = Colors.grey.g800
        $0.AppCorner(.tiny)
        $0.addLeftPadding()
    }
    
    let recentLabel = UILabel().then {
        $0.text = "최근 목록"
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.text = title
    }
    
    func setViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(textField)
        addSubview(recentLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(32)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(collectionView.snp.bottom).offset(12)
            make.height.equalTo(32)
        }
        
        recentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(textField.snp.bottom).offset(16)
        }
    }

}

extension BottomSheetSelectView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
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

        cell.placeIconType = Place().getVariation()[indexPath.row]
        
        // 재진입하여 이미 선택된 셀을 만들어야 하는 경우
//        if let selectedCellWeatherType = selectedCellWeatherType {
//            if tempArr[indexPath.row] == selectedCellWeatherType {
//                cell.selected()
//            }
//        }
        
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
        let defaultText = Place().getPlaceText(place: selectedCell.placeIconType ?? .place)
        
        // self.listener?.updateWeather(weather: selectedCell.weatherIconType ?? .sun)
        
        if let text = self.textField.text {
            for place in Place().getVariation() {
                if text == place.rawValue {
                    self.textField.text = defaultText
                }
            }
            
            if text.count == 0 {
                self.textField.text = defaultText
            }
            
            // self.listener?.updateWeatherDetailText(text: defaultText)
        }
    }
}
