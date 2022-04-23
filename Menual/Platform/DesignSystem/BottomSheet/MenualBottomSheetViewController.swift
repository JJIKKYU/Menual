//
//  MenualBottomSheetViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import UIKit
import SnapKit
import Then

class MenualBottomSheetViewController: MenualBottomSheetBaseViewController {
        
    let segmentationView = MenualSegmentationBaseViewController(frame: CGRect.zero).then {
        $0.setButtonTitles(buttonTitles: ["날씨", "장소"])
        $0.backgroundColor = .clear
    }
    
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .gray
    }

    let titleLabel = UILabel().then {
        $0.text = "날씨에 대해 기록해주세요"
        $0.font = UIFont.AppHead(.head_3)
        $0.textColor = .white
    }
    
    let weatherCollectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.minimumLineSpacing = 10
    }
    
    lazy var weatherCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: weatherCollectionViewLayout).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBlue
        $0.register(MenualBottomSheetCell.self, forCellWithReuseIdentifier: "MenualCell")
        $0.delegate = self
        $0.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        bottomSheetView.backgroundColor = Colors.background.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setViews() {
        self.view.addSubview(segmentationView)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(weatherCollectionView)
        
        segmentationView.snp.makeConstraints { make in
            make.leading.equalTo(bottomSheetView.snp.leading)
            make.top.equalTo(bottomSheetView.snp.top).offset(20)
            make.width.equalTo(90)
            make.height.equalTo(32)
        }
        
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
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(100)
        }
        
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
    }
}
