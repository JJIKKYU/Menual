//
//  WeatherPlaceSelectView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import UIKit
import Then
import SnapKit

protocol WeatherPlaceSelectViewDelegate {
    // 체크표시 등 활성화
    func isSelected(_ isSelected: Bool)
    func weatherSendData(weatherType: Weather, isSelected: Bool)
    func placeSendData(placeType: Place, isSelected: Bool)
}

class WeatherPlaceSelectView: UIView {
    
    enum WeatherPlaceType {
        case weather
        case place
    }
    
    var weatherPlaceType: WeatherPlaceSelectView.WeatherPlaceType = .place {
        didSet { setNeedsLayout() }
    }
    
    var delegate: WeatherPlaceSelectViewDelegate?
    
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
        
        let flowlayout = CustomCollectionViewFlowLayout.init()
        flowlayout.itemSize = CGSize(width: 56, height: 32)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 8
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        $0.setCollectionViewLayout(flowlayout, animated: true)
    }
    

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(type: WeatherPlaceSelectView.WeatherPlaceType) {
        self.init()
        self.weatherPlaceType = type
    }
    
    func setViews() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 다중 선택을 지원할 경우
        if selectionLimit > 1 {
            collectionView.allowsMultipleSelection = true
        } else {
            collectionView.allowsMultipleSelection = false
        }
        
        switch weatherPlaceType {
        case .weather:
            collectionView.reloadData()
        case .place:
            collectionView.reloadData()
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
}

// MARK: - UICollectionView
extension WeatherPlaceSelectView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch weatherPlaceType {
        case .weather:
            let weatherTypeCount = Weather().getVariation().count
            return weatherTypeCount
        case .place:
            let placeTypeCount = Place().getVariation().count
            return placeTypeCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
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
