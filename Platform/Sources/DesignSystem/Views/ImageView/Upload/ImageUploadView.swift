//
//  ImageUploadView.swift
//  Menual
//
//  Created by 정진균 on 2022/06/26.
//

import MenualUtil
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit
import Photos

// MARK: - ImageUploadViewDelegate

public protocol ImageUploadViewDelegate: AnyObject {
    var uploadImagesRelay: BehaviorRelay<[Data]>? { get }
    var thumbImageIndexRelay: BehaviorRelay<Int>? { get }

    func pressedTakeImageButton()
    func pressedUploadImageButton()
    func pressedDeleteButton(cell: ImageUploadCell)
    func pressedAllImagesDeleteButton()
    func pressedDetailImage(index: Int)
}

public extension ImageUploadViewDelegate {
    func pressedTakeImageButton() {}
    func pressedUploadImageButton() {}
    func pressedDeleteButton(cell: ImageUploadCell) {}
    func pressedAllImagesDeleteButton() {}
    func pressedDetailImage(index: Int) {}
}

// MARK: - ImageUploadView

public final class ImageUploadView: UIView {

    public enum ImageUploadViewState {
        case writing
        case edit
        case detail
    }

    public weak var delegate: ImageUploadViewDelegate? {
        didSet { bind() }
    }
    public var images: [Data] = [] {
        didSet {
            if oldValue != images {
                collectionView.reloadData()
            }
        }
    }

    public var state: ImageUploadViewState
    private let currentImageCountLabel: UILabel = .init()
    private let deleteButton: UIButton = .init()
    private let collectionView: MenualCollectionView = .init(frame: .zero, collectionViewLayout: .init())
    private let disPoseBag: DisposeBag = .init()

    public init(state: ImageUploadViewState) {
        self.state = state
        super.init(frame: CGRect.zero)

        print("ImageUpload :: init!")
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
            $0.allowsSelection = true
            $0.dragInteractionEnabled = true
            $0.dragDelegate = self
            $0.dropDelegate = self

            let flowlayout = UICollectionViewFlowLayout.init()
            flowlayout.itemSize = .init(width: 100, height: 100)
            flowlayout.scrollDirection = .horizontal
            flowlayout.minimumLineSpacing = 8
            flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            $0.setCollectionViewLayout(flowlayout, animated: true)
            $0.showsHorizontalScrollIndicator = false

//            if state == .detail {
//                $0.layer.opacity = 0
//            }
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
            $0.setTitleColor(Colors.grey.g400, for: .normal)
            $0.setTitleColor(Colors.grey.g600, for: .highlighted)
            $0.tintColor = Colors.grey.g400
            $0.addTarget(self, action: #selector(pressedAllImagesDeleteButton), for: .touchUpInside)
            $0.isHidden = true
        }
    }

    private func setViews() {
        addSubview(collectionView)

        switch state {
        case .writing, .edit:
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

        case .detail:
            collectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    private func bind() {
        delegate?.uploadImagesRelay?
            // .delay(.milliseconds(500), scheduler: MainScheduler.instance)
//            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] images in
                guard let self = self else { return }

                self.currentImageCountLabel.text = "\(images.count)/10개"

                if images.isEmpty {
                    deleteButton.isHidden = true
                } else {
                    deleteButton.isHidden = false
                }

//                DispatchQueue.main.async {
//                    self.reloadDataWithAnimation()
//                }
                print("ImageUpload :: reloadData!")
                // self.collectionView.reloadData()
            })
            .disposed(by: disPoseBag)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        switch state {
        case .writing, .edit:
            collectionView.dragInteractionEnabled = true
            currentImageCountLabel.isHidden = false

        case .detail:
            collectionView.dragInteractionEnabled = false
            deleteButton.isHidden = true
            currentImageCountLabel.isHidden = true
        }

//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//        }
    }
}

// MARK: - Images

extension ImageUploadView {
    public func deleteImage(cell: ImageUploadCell) {
        guard let indexPath: IndexPath = collectionView.indexPath(for: cell) else { return }

        // 첫번째 Cell은 이미지 추가 Cell이므로 1을 빼서 진행
        let imageIndex: Int = indexPath.row - 1
        var images: [Data] = delegate?.uploadImagesRelay?.value ?? []
        images.remove(at: imageIndex)
        delegate?.uploadImagesRelay?.accept(images)
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
        delegate?.uploadImagesRelay?.accept([])
        collectionView.reloadData()
    }

    public func reloadCollectionView() {
        collectionView.reloadData()
    }
}

// MARK: - CollectionViewDelegate

extension ImageUploadView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // let imageCount: Int = delegate?.uploadImagesRelay?.value.count ?? 0
        let imageCount: Int = images.count

        switch state {
        case .writing, .edit:
            return imageCount + 1

        case .detail:
            return imageCount
        }

    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: ImageUploadCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageUploadCell", for: indexPath) as? ImageUploadCell else { return UICollectionViewCell() }

        let index: Int = indexPath.row
        var imageData: Data = .init()
        switch state {
        // 첫번째 셀은 이미지 추가 버튼이므로 1씩 빼주어서 접근
        case .writing:
            imageData = delegate?.uploadImagesRelay?.value[safe: index - 1] ?? Data()
            if index == 0 {
                cell.parameters.status = .addImage
            } else {
                // 기본적으로 첫번째 이미지는 썸네일로 변경
                let thumbIndex: Int = delegate?.thumbImageIndexRelay?.value ?? 0
                if index == thumbIndex + 1 {
                    cell.parameters.isThumb = true
                }

                cell.parameters.status = .image
            }

        // 수정모드
        case .edit:
            // imageData = delegate?.uploadImagesRelay?.value[safe: index - 1] ?? Data()
            imageData = images[safe: index - 1] ?? Data()
            let thumbIndex: Int = delegate?.thumbImageIndexRelay?.value ?? 0

            if index == 0 {
                cell.parameters.status = .addImage
            } else {
                cell.parameters.status = .image
            }

            if index == thumbIndex + 1 {
                cell.parameters.isThumb = true
            }

        // 상세보기의 경우는 제대로 접근
        case .detail:
            // imageData = delegate?.uploadImagesRelay?.value[safe: index] ?? Data()
            imageData = images[safe: index] ?? Data()
            cell.parameters.status = .detailImage
        }

        cell.delegate = self
        cell.isUserInteractionEnabled = true
        cell.imageData = imageData

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("ImageUpload :: didSelect! \(indexPath)")

        switch state {
        case .writing, .edit:
            // 첫번재 Cell은 addImage로 thumb가 될 수 없음.
            if indexPath.row == 0 {
                return
            }

            guard let cell: ImageUploadCell = collectionView.cellForItem(at: indexPath) as? ImageUploadCell else { return }

            let visibleCells = collectionView.visibleCells
                .map { $0 as? ImageUploadCell }

            visibleCells.forEach { visibleCell in
                visibleCell?.parameters.isThumb = false
            }

            cell.parameters.isThumb = true
            delegate?.thumbImageIndexRelay?.accept(indexPath.row - 1)

        case .detail:
            delegate?.pressedDetailImage(index: indexPath.row)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }

    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath: IndexPath = coordinator.destinationIndexPath,
              let sourceIndexPath: IndexPath = coordinator.items.first?.sourceIndexPath
        else { return }

        guard let itemToMoveImageData: Data =  delegate?.uploadImagesRelay?.value[safe: sourceIndexPath.row - 1] else { return }

        let thumbIndex: Int = delegate?.thumbImageIndexRelay?.value ?? 0
        if thumbIndex == sourceIndexPath.row - 1 {
            delegate?.thumbImageIndexRelay?.accept(destinationIndexPath.row - 1)
        } else if thumbIndex == destinationIndexPath.row - 1 {
            delegate?.thumbImageIndexRelay?.accept(sourceIndexPath.row - 1)
        }

        let index: Int = sourceIndexPath.row
        var imagesData: [Data] = delegate?.uploadImagesRelay?.value ?? []
        imagesData.remove(at: index - 1)
        imagesData.insert(itemToMoveImageData, at: destinationIndexPath.row - 1)
        delegate?.uploadImagesRelay?.accept(imagesData)

        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        }
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 데이터 소스에서 아이템을 이동
        guard let itemToMoveImageData: Data =  delegate?.uploadImagesRelay?.value[safe: sourceIndexPath.row - 1] else { return }

        let index: Int = sourceIndexPath.row - 1
        var imagesData: [Data] = delegate?.uploadImagesRelay?.value ?? []
        imagesData.remove(at: index - 1)
        imagesData.insert(itemToMoveImageData, at: destinationIndexPath.row)
        delegate?.uploadImagesRelay?.accept(imagesData)
        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
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

// MARK: - CollectionView Animation

extension ImageUploadView {
    private func reloadDataWithAnimation() {
        if state != .detail { return }

        hideCollectionView()

        collectionView.reloadDataWithCompletion { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.5) {
                self.collectionView.layer.opacity = 1
            } completion: { isAnimated in
                print("ImageUpload :: isAnimated! = \(isAnimated)")
            }
        }
    }

    public func hideCollectionView() {
        // collectionView.layer.removeAllAnimations()
        // collectionView.layer.opacity = 0
        // collectionView.layer.layoutIfNeeded()
    }
}
