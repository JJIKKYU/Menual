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
    func pressedDeleteButton(cell: ImageUploadCell)
    func pressedAllImagesDeleteButton()
}

// MARK: - ImageUploadView

public final class ImageUploadView: UIView {
    var images: [Data] = [] {
        didSet { setNeedsLayout() }
    }
    // 썸네일 이미지 Index
    var thumbImageIndex: Int = 0

    public weak var delegate: ImageUploadViewDelegate?
    private let currentImageCountLabel: UILabel = .init()
    private let deleteButton: UIButton = .init()
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

        currentImageCountLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g600
            $0.text = "0/10개"
        }

        deleteButton.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(Asset._16px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.setTitle("전체삭제", for: .normal)
            $0.titleLabel?.font = .AppBodyOnlyFont(.body_2)
            $0.titleLabel?.textColor = Colors.grey.g400
            $0.tintColor = Colors.grey.g400
            $0.addTarget(self, action: #selector(pressedAllImagesDeleteButton), for: .touchUpInside)
        }
    }

    private func setViews() {
        addSubview(collectionView)
        addSubview(currentImageCountLabel)
        addSubview(deleteButton)

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(100)
        }

        currentImageCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(collectionView.snp.bottom).offset(13)
            make.bottom.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(collectionView.snp.bottom).offset(13)
            make.bottom.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()

        currentImageCountLabel.text = "\(images.count)/10개"
    }
}

// MARK: - Images

extension ImageUploadView {
    public func deleteImage(cell: ImageUploadCell) {
        guard let indexPath: IndexPath = collectionView.indexPath(for: cell) else { return }

        // 첫번째 Cell은 이미지 추가 Cell이므로 1을 빼서 진행
        let imageIndex: Int = indexPath.row - 1
        images.remove(at: imageIndex)
        collectionView.deleteItems(at: [indexPath])

        // 지우고자 하는 Cell이 썸네일일 경우
        if cell.parameters.isThumb {
            // 첫번째 Index의 Cell이 있을 경우
            // (처음 Cell은 사진추가하기 Cell이므로 index는 1로 세팅)
            let firstIndexPath: IndexPath = .init(row: 1, section: 0)
            guard let firstCell: ImageUploadCell = collectionView.cellForItem(at: firstIndexPath) as? ImageUploadCell else { return }
            firstCell.parameters.isThumb = true
        }
    }

    public func deleteAllImages() {
        images = []
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

        // 기본적으로 첫번째 이미지는 썸네일로 변경
        if index == 1 {
            cell.parameters.isThumb = true
        }

        cell.delegate = self
        cell.parameters.imageData = imageData

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: ImageUploadCell = collectionView.cellForItem(at: indexPath) as? ImageUploadCell else { return }

        let visibleCells = collectionView.visibleCells
            .map { $0 as? ImageUploadCell }

        visibleCells.forEach { visibleCell in
            visibleCell?.parameters.isThumb = false
        }

        cell.parameters.isThumb = true
    }
}

// MARK: - ImageUploadCellDelegate

extension ImageUploadView: ImageUploadCellDelegate {
    public func pressedTakeImageButton() {
        print("ImageUpload :: pressedTakeImageButton")
        delegate?.pressedTakeImageButton()
    }

    public func pressedUploadImageButton() {
        print("ImageUpload :: pressedUploadImageButton")
        delegate?.pressedUploadImageButton()
    }

    public func pressedDeleteButton(cell: ImageUploadCell) {
        print("ImageUpload :: pressedDeleteButton")
        delegate?.pressedDeleteButton(cell: cell)
    }

    @objc
    func pressedAllImagesDeleteButton() {
        delegate?.pressedAllImagesDeleteButton()
    }
}
