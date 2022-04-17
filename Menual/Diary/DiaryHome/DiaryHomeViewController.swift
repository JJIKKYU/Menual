//
//  DiaryHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import Then

protocol DiaryHomePresentableListener: AnyObject {
    func pressedSearchBtn()
    func pressedMyPageBtn()
    func pressedMomentsTitleBtn()
    func pressedMomentsMoreBtn()
    func pressedWritingBtn()
    
    func getMyMenualCount() -> Int
    func getMyMenualArr() -> [DiaryModel]
    
    func pressedDiaryCell(index: Int)
}

final class DiaryHomeViewController: UIViewController, DiaryHomePresentable, DiaryHomeViewControllable {
    
    weak var listener: DiaryHomePresentableListener?
    
    // MARK: - UI 코드
    // 이 친구는 스크롤되게 임시로 넣은 놈입니다.
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()

    lazy var naviView = MenualNaviView(type: .main).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1.setImage(Asset._24px.profile.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.rightButton1.addTarget(self, action: #selector(pressedMyPageBtn), for: .touchUpInside)
        
        $0.rightButton2.setImage(Asset._24px.search.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.rightButton2.addTarget(self, action: #selector(pressedSearchBtn), for: .touchUpInside)
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.backgroundColor = Colors.background.black
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
    }
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.search.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedSearchBtn)
    }
    
    lazy var rightBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.profile.image
        $0.target = self
        $0.action = #selector(pressedMyPageBtn)
        $0.style = .done
    }
    
    let testView = MomentsRoundView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // TODO: CustomView로 만들기
    var fabWriteBtn = UIView().then {
        $0.backgroundColor = Colors.tint.sub.n300
        $0.layer.cornerRadius = 4
        $0.AppShadow(.shadow_6)
    }
    
    // 임시로 뷰 넘어가게 하려고 만든 버튼
    lazy var wrtingBtnTest = UIButton().then {
        $0.addTarget(self, action: #selector(pressedFABWritingBtn), for: .touchUpInside)
        $0.setImage(Asset._24px.write.image, for: .normal)
    }
   
    lazy var momentsTitleView = TitleView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.title_moments
        $0.rightTitle = "전체보기 >"
        $0.titleButton.addTarget(self, action: #selector(pressedMomentsTitleBtn), for: .touchUpInside)
        $0.rightButton.addTarget(self, action: #selector(pressedMomentsMoreBtn), for: .touchUpInside)
    }
    
    lazy var momentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let flowlayout = UICollectionViewFlowLayout.init()
        $0.setCollectionViewLayout(flowlayout, animated: true)
        $0.backgroundColor = Colors.tint.main.v100
    }
    
    lazy var myMenualTitleView = TitleView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = MenualString.title_menualList
        $0.rightTitle = ""
        $0.titleButton.addTarget(self, action: #selector(pressedMyMenualBtn), for: .touchUpInside)
    }
    
    lazy var myMenualTableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .gray
        $0.register(MyMenualCell.self, forCellReuseIdentifier: "MyMenualCell")
        $0.estimatedRowHeight = 70.5
        $0.rowHeight = 70.5
    }
    
    var isStickyMyMenualCollectionView: Bool = false
    let isEnableStickyHeaderYOffset: CGFloat = 360 // StickHeader가 작동해야 하는 yOffset Value
    lazy var myMenualCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        let flowlayout = UICollectionViewFlowLayout.init()
        $0.setCollectionViewLayout(flowlayout, animated: true)
        $0.backgroundColor = Colors.tint.main.v100
    }
    
    // MARK: - VC 코드
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
        print("DiaryHome!")
        setViews()
    }
    
    func setViews() {
//        title = MenualString.title_menual
//        navigationItem.leftBarButtonItem = leftBarButtonItem
//        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        self.view.addSubview(naviView)
        self.view.addSubview(scrollView)
        self.view.addSubview(fabWriteBtn)
        

        scrollView.addSubview(titleLabel)
//        scrollView.addSubview(testView)
        scrollView.addSubview(momentsTitleView)
        scrollView.addSubview(momentsCollectionView)
        scrollView.addSubview(myMenualTitleView)
        scrollView.addSubview(myMenualCollectionView)
        scrollView.addSubview(myMenualTableView)
        
        naviView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        self.view.bringSubviewToFront(naviView)
        
        // 임시
        fabWriteBtn.addSubview(wrtingBtnTest)
        wrtingBtnTest.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(20)
        }
        
        fabWriteBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(34)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(1500)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
//        testView.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.width.equalTo(300)
//            make.top.equalToSuperview().offset(100)
//            make.height.equalTo(200)
//        }
        
        momentsTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(64)
            make.height.equalTo(40)
        }
        
        momentsCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(momentsTitleView.snp.bottom).offset(20)
            make.height.equalTo(200)
        }
        
        myMenualTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(momentsCollectionView.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        myMenualCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(myMenualTitleView.snp.bottom).offset(20)
            make.height.equalTo(100)
        }
        
        myMenualTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(myMenualCollectionView.snp.bottom).offset(20)
        }
    }
    
    @objc
    func pressedSearchBtn() {
        listener?.pressedSearchBtn()
    }
    
    @objc
    func pressedMyPageBtn() {
        listener?.pressedMyPageBtn()
    }
    
    @objc
    func pressedMomentsTitleBtn() {
        listener?.pressedMomentsTitleBtn()
        print("Moments Title Pressed!")
    }
    
    @objc
    func pressedMomentsMoreBtn() {
        listener?.pressedMomentsMoreBtn()
        print("Moments More Pressed!")
    }
    
    @objc
    func pressedMyMenualBtn() {
        
    }
    
    @objc
    func pressedFABWritingBtn() {
        print("FABWritingBtn Pressed!")
        listener?.pressedWritingBtn()
    }
}

// MARK: - Scroll View
extension DiaryHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // stickyMyMenualCollectionView(scrollView)
    }
    
    // MyMenualCollectionView보다 아래로 스크롤 했을 경우 상단에 고정되도록
    func stickyMyMenualCollectionView(_ scrollView: UIScrollView) {
        // CollectionView 위치보다 아래로 갈 경우 (StickyHeader 작동)
        if scrollView.contentOffset.y > self.isEnableStickyHeaderYOffset {
            if isStickyMyMenualCollectionView { return }
            self.myMenualCollectionView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(100)
                make.top.equalTo(self.view.snp.top)
            }
            self.view.layoutIfNeeded()
            
            // fabViewBtn 축소
            // TODO: 따로 함수로 구현할 것
            self.fabWriteBtn.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(20)
                make.height.equalTo(50)
                make.width.equalTo(50)
                make.bottom.equalToSuperview().inset(34)
            }
            UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut) {
                self.fabWriteBtn.layer.cornerRadius = 25
                self.view.layoutIfNeeded()
            }
            print("StickyHeader 작동!")
            isStickyMyMenualCollectionView = true
        }
        // StickyHeader가 작동하지 않아도 되는 경우 (평상시)
        else {
            if !isStickyMyMenualCollectionView { return }
            self.myMenualCollectionView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.width.equalToSuperview()
                make.height.equalTo(100)
                make.top.equalTo(myMenualTitleView.snp.bottom).offset(20)
            }
            self.view.layoutIfNeeded()
            
            // fabViewBtn 확장
            // TODO: 따로 함수로 구현할 것
            self.fabWriteBtn.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().inset(20)
                make.height.equalTo(50)
                make.bottom.equalToSuperview().inset(34)
            }
            UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut) {
                self.fabWriteBtn.AppCorner(.tiny)
                self.view.layoutIfNeeded()
            }
            print("StickyHeader 미작동!")
            isStickyMyMenualCollectionView = false
        }
    }
}

// MARK: - UITableView Deleagte, Datasource
extension DiaryHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listener?.getMyMenualCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMenualCell") as? MyMenualCell else { return UITableViewCell() }
        
        cell.backgroundColor = .clear
        
        if let myMenualArr = listener?.getMyMenualArr() {
            cell.title.text = myMenualArr[indexPath.row].title
            cell.subTitle.text = myMenualArr[indexPath.row].description
        } else {
            cell.title.text = "타이틀마"
            cell.subTitle.text = "서브 타이틀마"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MyMenualCell
        listener?.pressedDiaryCell(index: indexPath.row)
    }
    
    func reloadTableView() {
        print("reloadTableView!")
        myMenualTableView.reloadData()
    }
    
}
