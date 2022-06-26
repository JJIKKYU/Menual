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
    func weatherSendData(weatherType: Weather)
    func placeSendData(placeType: Place)
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
    
    private lazy var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        
        $0.register(WeatherPlaceSelectViewCell.self, forCellWithReuseIdentifier: "WeatherPlaceSelectViewCell")
        $0.showsHorizontalScrollIndicator = false
        
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
        
        switch weatherPlaceType {
        case .weather:
            collectionView.reloadData()
        case .place:
            collectionView.reloadData()
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherPlaceSelectViewCell", for: indexPath) as? WeatherPlaceSelectViewCell else { return }
        
        let index = indexPath.row
        switch weatherPlaceType {
        case .place:
            guard let placeType = Place().getVariation()[safe: index] else { return }
            delegate?.placeSendData(placeType: placeType)
        case .weather:
            guard let weatherType = Weather().getVariation()[safe: index] else { return }
            delegate?.weatherSendData(weatherType: weatherType)
        }
        
        delegate?.isSelected(cell.isSelected)
        cell.isSelected = !cell.isSelected
    }
}
