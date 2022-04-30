//
//  BottomSheetSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import UIKit
import Then
import SnapKit
import RxSwift

enum BottomSheetSelectViewType {
    case weather
    case place
}

protocol BottomSheetSelectDelegate {
    func sendData(placeModel: PlaceModel)
    func sendData(weatherModel: WeatherModel)
}

class BottomSheetSelectView: UIView {
    
    var delegate: BottomSheetSelectDelegate?

    var title: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var placeholderText: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var selectedWeatherType: Weather? {
        didSet {
            layoutSubviews()
        }
    }
    
    var selectedPlaceType: Place? {
        didSet {
            layoutSubviews()
        }
    }
    
    lazy var textFieldOb = textField.rx.text.asObservable()
    
    var viewType: BottomSheetSelectViewType {
        didSet {
            layoutSubviews()
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "타이틀입니다."
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    private let collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.minimumLineSpacing = 12
    }
    
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout).then {
        $0.backgroundColor = .clear
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(MenualBottomSheetCell.self, forCellWithReuseIdentifier: "MenualCell")
        $0.delegate = self
        $0.dataSource = self
    }
    
    private lazy var textField = UITextField().then {
        // $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g100
        $0.backgroundColor = Colors.grey.g800
        $0.AppCorner(.tiny)
        $0.addLeftPadding()
    }
    
    private let recentLabel = UILabel().then {
        $0.text = "최근 목록"
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    init(frame: CGRect = CGRect.zero, _ type: BottomSheetSelectViewType) {
        self.viewType = type
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.text = title
        self.textField.text = placeholderText
        collectionView.reloadData()
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
        
        switch viewType {
        case .place:
            cell.placeIconType = Place().getVariation()[indexPath.row]
            if let selectedCellPlaceType = selectedPlaceType {
                if selectedCellPlaceType == cell.placeIconType {
                    cell.selected()
                }
            }

        case .weather:
            cell.weatherIconType = Weather().getVariation()[indexPath.row]
            if let selectedCellWeatherType = selectedWeatherType {
                if selectedCellWeatherType == cell.weatherIconType {
                    cell.selected()
                }
            }
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? MenualBottomSheetCell else {
            return
        }
        
        // 유저가 선택한 Cell이 이미 선택된 Cell일 경우에는 다시 비활성화
        if selectedCell.cellIsSelected == true {
            selectedCell.unSelected()
        }
        // 유저가 처음 선택한 Cell인 경우
        // 전체 Cell을 UnSelected로 변경하고, 선택한 Cell을 Selected로 변경
        else {
            for cell in collectionView.visibleCells {
                guard let cell = cell as? MenualBottomSheetCell else { continue }
                cell.unSelected()
            }
            selectedCell.selected()
        }

        // weather cell일 경우
        if let selectedCellWeatherType = selectedCell.weatherIconType {
            print("weatherType입니다")
            let defaultText = Weather().getWeatherText(weather: selectedCellWeatherType)
            
            if let text = self.textField.text {
                // 기본 Text일 경우 아이콘 기본 Text로 변경
                for weather in Weather().getVariation() {
                    if text == weather.rawValue {
                        self.textField.text = defaultText
                    }
                }
                
                // Text가 하나도 입력되어 있지 않을 경우 기본 Text로 변경
                if text.count == 0 {
                    self.textField.text = defaultText
                }
            }
            
            // 중간에 text를 변경했으므로 최신 text로 정보를 담아주기 위해서 다시 옵셔널 바인딩
            if let text = self.textField.text {
                print("text = \(text)")
                delegate?.sendData(weatherModel: WeatherModel(uuid: "", weather: selectedCellWeatherType, detailText: text))
            }
        }
        else if let selectedCellPlaceType = selectedCell.placeIconType {
            print("placeType입니다")
            let defaultText = Place().getPlaceText(place: selectedCell.placeIconType ?? .place)
            
            if let text = self.textField.text {
                // 기본 Text일 경우 아이콘 기본 Text로 변경
                for place in Place().getVariation() {
                    if text == place.rawValue {
                        self.textField.text = defaultText
                    }
                }
                
                // Text가 하나도 입력되어 있지 않을 경우 기본 Text로 변경
                if text.count == 0 {
                    self.textField.text = defaultText
                }
            }
            
            // 중간에 text를 변경했으므로 최신 text로 정보를 담아주기 위해서 다시 옵셔널 바인딩
            if let text = self.textField.text {
                delegate?.sendData(placeModel: PlaceModel(uuid: "", place: selectedCellPlaceType, detailText: text))
            }
        }
    }
}
