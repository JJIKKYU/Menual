//
//  ImageUploadView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import DesignSystem
import MenualUtil
import SnapKit
import Then
import UIKit

// MARK: - ImageUploadViewDelegate

public protocol ImageUploadViewDelegate: AnyObject {
    func pressedTakeImageButton()
    func pressedUploadImageButton()
}

// MARK: - ImageUploadView

public final class ImageUploadView: UIView {
    var images: [Data] = [] {
        didSet { setNeedsLayout() }
    }

    public weak var delegate: ImageUploadViewDelegate?
    private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())

    init() {
        super.init(frame: CGRect.zero)
        configureUI()
        setViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        collectionView.do {
            $0.register(ImageUploadCell.self, forCellWithReuseIdentifier: "ImageUploadCell")
            $0.delegate = self
            $0.dataSource = self
            $0.backgroundColor = .clear

            let flowlayout = UICollectionViewFlowLayout.init()
            flowlayout.itemSize = .init(width: 100, height: 100)
            flowlayout.scrollDirection = .horizontal
            flowlayout.minimumLineSpacing = 8
            flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            $0.setCollectionViewLayout(flowlayout, animated: true)
            $0.showsHorizontalScrollIndicator = false
        }
    }

    private func setViews() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
}

// MARK: - CollectionViewDelegate

extension ImageUploadView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ImageUploadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCell", for: indexPath) as? ImageUploadCell else { return UICollectionViewCell() }

        let index: Int = indexPath.row
        // 첫번째 셀은 이미지 추가 버튼이므로 1씩 빼주어서 접근
        let imageData: Data = images[safe: index - 1] ?? Data()

        // 첫번째 Cell의 경우 추가하기 Cell로 세팅
        if index == 0 {
            cell.parameters.status = .addImage
        } else {
            cell.parameters.status = .image
        }
        cell.delegate = self
        cell.parameters.imageData = imageData

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// MARK: - ImageUploadCellDelegate

extension ImageUploadView: ImageUploadCellDelegate {
    public func pressedTakeImageButton() {
        print("ImageUploadView :: pressedTakeImageButton")
        delegate?.pressedTakeImageButton()
    }

    public func pressedUploadImageButton() {
        print("ImageUploadView :: pressedUploadImageButton")
        delegate?.pressedUploadImageButton()
    }
}
