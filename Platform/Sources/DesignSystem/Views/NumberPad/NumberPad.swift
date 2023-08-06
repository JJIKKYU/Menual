//
//  NumberPad.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import UIKit
import Then
import SnapKit
import MenualUtil

public protocol NumberPadDelegate: AnyObject {
    func deleteNumber()
    func selectNumber(number: Int)
}

public class NumberPad: UIView {
    
    public weak var delegate: NumberPadDelegate?
    
    private let numberPadData: [String] = ["1","2","3","4","5","6","7","8","9","","0","←"]
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = Colors.background
        
        $0.register(NumberPadCell.self, forCellWithReuseIdentifier: "NumberPadCell")
    }
    
    private let flowlayout = UICollectionViewFlowLayout.init().then {
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
    }

    public init() {
        super.init(frame: CGRect.zero)
        setViews()
        collectionView.setCollectionViewLayout(flowlayout, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.background
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }

}

// MARK: - UICollectionView Delegate
extension NumberPad: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberPadData.count = \(numberPadData.count)")
        return numberPadData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("index1 = \(indexPath.row)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberPadCell", for: indexPath) as? NumberPadCell else { return UICollectionViewCell() }
        
        let index = indexPath.row
        cell.number = numberPadData[index]
        print("index = \(index)")
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width: CGFloat = floor(bounds.width / 3) - 1
        let height: CGFloat = 87
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        print("NumberPad :: didSelectCell! = \(indexPath), \(numberPadData[index])")
        
        let data = numberPadData[index]
        
        if data == "" { return }
        
        // 지우기 일 경우
        if data == "←" {
            delegate?.deleteNumber()
        } else {
            let number = Int(data) ?? 0
            delegate?.selectNumber(number: number)
        }
    }
}
