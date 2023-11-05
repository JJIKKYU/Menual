//
//  DiaryDetailImageViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import DesignSystem
import RIBs
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit

// MARK: - DiaryDetailImagePresentableListener

public protocol DiaryDetailImagePresentableListener: AnyObject {
    var selectedIndex: Int { get }
    var imagesDataRelay: BehaviorRelay<[Data]> { get }

    func pressedBackBtn(isOnlyDetach: Bool)
}

// MARK: - DiaryDetailImageViewController

final class DiaryDetailImageViewController: UIViewController, DiaryDetailImagePresentable, DiaryDetailImageViewControllable {

    weak var listener: DiaryDetailImagePresentableListener?

    lazy var naviView = MenualNaviView(type: .detailImage)
    private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        self.scrollToItemAtIndex()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }

    private func configureUI() {
        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.rightButton1.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        }

        collectionView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear

            let layout: UICollectionViewFlowLayout = .init()
            layout.itemSize = .init(width: 100, height: 100)
            layout.scrollDirection = .horizontal
            layout.sectionInset = .zero
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0

            $0.setCollectionViewLayout(layout, animated: true)
            $0.register(ImageDetailCell.self, forCellWithReuseIdentifier: "ImageDetailCell")
            $0.isPagingEnabled = true
            $0.delegate = self
            $0.dataSource = self
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
        }
    }

    private func setViews() {
        view.backgroundColor = Colors.background
        view.addSubview(naviView)
        view.addSubview(collectionView)
        view.bringSubviewToFront(naviView)

        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(54)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - IBAction

extension DiaryDetailImageViewController {
    @objc
    func pressedBackBtn() {
        print("DiaryDetailImage :: pressedBackBtn")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - CollectionViewDelegate

extension DiaryDetailImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listener?.imagesDataRelay.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ImageDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageDetailCell", for: indexPath) as? ImageDetailCell else { return UICollectionViewCell() }

        guard let imageData: Data = listener?.imagesDataRelay.value[safe: indexPath.row] else { return UICollectionViewCell() }

        cell.imageData = imageData

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return self.view.frame.size
    }

    func scrollToItemAtIndex() {
        collectionView.reloadData()
        print("DiaryDetailImage :: listener?.selectedIndex = \(listener?.selectedIndex)")
        let indexPath: IndexPath = .init(row: listener?.selectedIndex ?? 0, section: 0)

        collectionView.layoutIfNeeded()
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
        collectionView.isPagingEnabled = true
    }
}
