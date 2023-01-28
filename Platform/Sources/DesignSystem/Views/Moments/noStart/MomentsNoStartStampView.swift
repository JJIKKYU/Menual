//
//  MomentsNoStartStampView.swift
//  Menual
//
//  Created by 정진균 on 2023/01/05.
//

import UIKit
import Then
import SnapKit

class MomentsNoStartStampView: UIView {

    // 작성한 메뉴얼 개수를 넣으면 활성화
    public var writingDiarySet: [Int: String] = [1: "12/31"] {
        didSet { collectionView.reloadData() }
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSize(width: 52, height: 68)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 16
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.setCollectionViewLayout(flowlayout, animated: true)
        
        $0.showsHorizontalScrollIndicator = false
        // $0.decelerationRate = .fast
        // $0.isPagingEnabled = false

        $0.register(MomentsNoStartStampCell.self, forCellWithReuseIdentifier: "StampCell")
        $0.backgroundColor = Colors.tint.main.v400
        $0.AppCorner(._4pt)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}

// MARK: - CollectionViewDeleagte
extension MomentsNoStartStampView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StampCell", for: indexPath) as? MomentsNoStartStampCell else { return UICollectionViewCell() }
        
        cell.number = indexPath.row + 1
        cell.stampStatus = .unactive

        if indexPath.row < writingDiarySet.count {
            cell.stampStatus = .active
            cell.dateString = writingDiarySet[indexPath.row + 1] ?? "??/??"
        }
        
        return cell
    }
}
