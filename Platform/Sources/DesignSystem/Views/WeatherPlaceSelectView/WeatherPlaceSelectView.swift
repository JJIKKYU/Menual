//
//  WeatherPlaceSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import Then
import SnapKit
import MenualEntity

public protocol WeatherPlaceSelectViewDelegate: AnyObject {
    // 체크표시 등 활성화
    func isSelected(_ isSelected: Bool)
    func weatherSendData(weatherType: Weather, isSelected: Bool)
    func placeSendData(placeType: Place, isSelected: Bool)
}

public class WeatherPlaceSelectView: UIView {
    
    public enum WeatherPlaceType {
        case weather
        case place
    }
    
    public var weatherPlaceType: WeatherPlaceSelectView.WeatherPlaceType = .place {
        didSet { setNeedsLayout() }
    }
    
    public var selectedWeatherType: Weather? {
        didSet { setNeedsLayout() }
    }
    public var selectedPlaceType: Place? {
        didSet { setNeedsLayout() }
    }
    
    var selectedWeatherTypes: [Weather]?
    
    var selectedPlaceTypes: [Place]?
    
    public weak var delegate: WeatherPlaceSelectViewDelegate?
    
    var selectionLimit: Int = 1 {
        didSet { setNeedsLayout() }
    }
    
    private var allSelect: Bool = false
    
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        
        $0.register(WeatherPlaceSelectViewCell.self, forCellWithReuseIdentifier: "WeatherPlaceSelectViewCell")
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: 60, height: 32)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 8
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.setCollectionViewLayout(flowlayout, animated: true)
    }
    

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(type: WeatherPlaceSelectView.WeatherPlaceType) {
        self.init()
        self.weatherPlaceType = type
    }
    
    func setViews() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 다중 선택을 지원할 경우
        if selectionLimit > 1 {
            collectionView.allowsMultipleSelection = true
        } else {
            collectionView.allowsMultipleSelection = false
        }

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        
        if let _ = selectedPlaceType {
            selectCell()
        } else if let _ = selectedWeatherType {
            selectCell()
        }
        
        if let _ = selectedPlaceTypes {
            selectCells()
        } else if let _ = selectedWeatherTypes {
            selectCells()
        }
    }
    
    // 사용하는 뷰에서 selectAllCells를 호출할 경우
    // true, false를 돌아가면서 전체선택, 전체선택풀기로 작동한다.
    public func selctAllCells() {
        print("WeatherPlaceSelectView :: selctAllCells!")
        for row in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            if allSelect == true {
                self.collectionView.deselectItem(at: indexPath, animated: false)
                self.collectionView(self.collectionView, didDeselectItemAt: indexPath)
            } else {
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                self.collectionView(self.collectionView, didSelectItemAt: indexPath)

            }
        }
        allSelect = !allSelect
    }
    
    // 사용하는 뷰에서 resetCells를 호출한 경우
    // selectAllCells에서 사용하는 Bool값을 false로 초기화하고
    // 선택을 모두 푼다.
    public func resetCells() {
        print("WeatherPlaceSelectView :: resetCells!")
        for row in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            self.collectionView.deselectItem(at: indexPath, animated: false)
            self.collectionView(self.collectionView, didDeselectItemAt: indexPath)
        }
        allSelect = false
    }
    
    func selectCell() {
        print("WeatherPlaceSelectView :: selectCell")

        for row in 0..<collectionView.numberOfItems(inSection: 0) {
            let currentIndexPath = IndexPath(row: row, section: 0)
            guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WeatherPlaceSelectViewCell else { return }
            
            var willSelectIndexPath: IndexPath?
            switch weatherPlaceType {
            case .weather:
                if let selectedWeatherType = selectedWeatherType,
                        cell.weatherIconType == selectedWeatherType {
                    print("WeatherPlaceSelectView :: weatherType = \(selectedWeatherType)")
                    willSelectIndexPath = IndexPath(row: row, section: 0)
                }

            case .place:
                if let selectedPlaceType = selectedPlaceType,
                   cell.placeIconType == selectedPlaceType {
                    print("WeatherPlaceSelectView :: placeType = \(selectedPlaceType)")
                    willSelectIndexPath = IndexPath(row: row, section: 0)
                }
            }
            
            // 위 조건문에 충족된 Cell이 있을경우
            if let willSelectIndexPath = willSelectIndexPath {
                self.collectionView.selectItem(at: willSelectIndexPath, animated: false, scrollPosition: .top)
                self.collectionView(self.collectionView, didSelectItemAt: willSelectIndexPath)
            }
        }
    }
    
    func selectCells() {
        for row in 0..<collectionView.numberOfItems(inSection: 0) {
            let currentIndexPath = IndexPath(row: row, section: 0)
            guard let cell = collectionView.cellForItem(at: currentIndexPath) as? WeatherPlaceSelectViewCell else { return }

            switch weatherPlaceType {
            case .weather:
                guard let selectedWeatherTypes = selectedWeatherTypes else {
                    return
                }

                for weatherType in selectedWeatherTypes {
                    print("WeatherPlaceSelectView :: weatherType = \(weatherType)")
                    if cell.weatherIconType == weatherType {
                        let willSelectIndexPath = IndexPath(row: row, section: 0)
                        self.collectionView.selectItem(at: willSelectIndexPath, animated: false, scrollPosition: .top)
                    }
                }

            case .place:
                guard let selectedPlaceTypes = selectedPlaceTypes else {
                    return
                }
                for placeType in selectedPlaceTypes {
                    print("WeatherPlaceSelectView :: placeType = \(placeType)")
                    if cell.placeIconType == placeType {
                        print("WeatherPlaceSelectView :: placeType == cell.placeIconType")
                        let willSelectIndexPath = IndexPath(row: row, section: 0)
                        self.collectionView.selectItem(at: willSelectIndexPath, animated: false, scrollPosition: .top)
                    }
                }
            }
        }

         
    }
}

// MARK: - UICollectionView
extension WeatherPlaceSelectView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch weatherPlaceType {
        case .weather:
            let weatherTypeCount = Weather().getVariation().count
            return weatherTypeCount
        case .place:
            let placeTypeCount = Place().getVariation().count
            return placeTypeCount
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherPlaceSelectViewCell", for: indexPath) as? WeatherPlaceSelectViewCell else { return UICollectionViewCell() }
        
        let index = indexPath.row
        
        switch weatherPlaceType {
        case .place:
            guard let placeType = Place().getVariation()[safe: index] else { return UICollectionViewCell() }
            cell.placeIconType = placeType
            cell.weatherPlaceSelectViewCellType = .place

        case .weather:
            guard let weatherType = Weather().getVariation()[safe: index] else { return UICollectionViewCell() }
            cell.weatherIconType = weatherType
            cell.weatherPlaceSelectViewCellType = .weather
        }
        
        return cell
    }
    
    // 선택할때
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("WeatherPlaceSelectView :: selectItem!")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherPlaceSelectViewCell", for: indexPath) as? WeatherPlaceSelectViewCell else { return }

        let index = indexPath.row
        switch weatherPlaceType {
        case .place:
            guard let placeType = Place().getVariation()[safe: index] else { return }
            delegate?.placeSendData(placeType: placeType, isSelected: cell.isSelected)
        case .weather:
            guard let weatherType = Weather().getVariation()[safe: index] else { return }
            delegate?.weatherSendData(weatherType: weatherType, isSelected: cell.isSelected)
        }
        delegate?.isSelected(cell.isSelected)
        cell.isSelected = !cell.isSelected
    }
    
    // 선택을 해제할때
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherPlaceSelectViewCell", for: indexPath) as? WeatherPlaceSelectViewCell else { return }

        let index = indexPath.row
        switch weatherPlaceType {
        case .place:
            guard let placeType = Place().getVariation()[safe: index] else { return }
            delegate?.placeSendData(placeType: placeType, isSelected: cell.isSelected)
        case .weather:
            guard let weatherType = Weather().getVariation()[safe: index] else { return }
            delegate?.weatherSendData(weatherType: weatherType, isSelected: cell.isSelected)
        }
        
        delegate?.isSelected(cell.isSelected)
        cell.isSelected = !cell.isSelected
    }
}
