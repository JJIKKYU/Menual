//
//  MenualBottomSheetAppUpdateLogComponentView.swift
//
//
//  Created by 정진균 on 2023/08/27.
//

import MenualUtil
import SnapKit
import Then
import UIKit

// MARK: - AppUpdateLogComponentDelegate

public protocol AppUpdateLogComponentDelegate: AnyObject {
    func pressedConfirmBtn()
}

// MARK: - MenualBottomSheetAppUpdateLogComponentView

public final class MenualBottomSheetAppUpdateLogComponentView: UIView {
    public let updateImages: [UIImage]
    public weak var delegate: AppUpdateLogComponentDelegate?

    private let titleLabel: UILabel = .init()
    private let descriptionLabel: UILabel = .init()
    private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
    private let collectionViewPagination: Pagination = .init()
    private let confirmBtn: BoxButton = .init(frame: .zero, btnStatus: .active, btnSize: .xLarge)
    private let prevBtn: UIButton = .init()
    private let nextBtn: UIButton = .init()

    public init(updateImages: [UIImage]) {
        self.updateImages = updateImages
        super.init(frame: .zero)
        configureUI()
        setViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureUI() {
        titleLabel.do {
            $0.font = .AppTitle(.title_2)
            $0.textColor = Colors.grey.g200
            $0.text = "일기작성 알림 기능을 추가했어요!"
        }

        descriptionLabel.do {
            $0.font = .AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
            $0.text = """
                      이제 설정에서 일기작성 알림을 설정할 수 있어요.
                      원하는 요일과 시간을 설정하면 일기 작성을 놓치지 않도록 알림을
                      제공해 드릴게요!

                      + 그 외에도 더 나은 사용 경험을 위해 UI를 수정했어요.
                      """
            $0.setLineHeight(lineHeight: 1.24)
            $0.numberOfLines = 0
        }

        collectionView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.register(UpdateImageCell.self, forCellWithReuseIdentifier: "UpdateImageCell")
            let flowlayout = UICollectionViewFlowLayout.init()
            flowlayout.scrollDirection = .horizontal
            flowlayout.minimumLineSpacing = 0
            flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            $0.setCollectionViewLayout(flowlayout, animated: true)
            $0.decelerationRate = .fast
            $0.isPagingEnabled = true
            $0.layer.cornerRadius = 8
            $0.layer.masksToBounds = true
            $0.backgroundColor = Colors.grey.g700
            $0.showsHorizontalScrollIndicator = false
        }

        collectionViewPagination.do {
            $0.numberOfPages = updateImages.count
        }

        confirmBtn.do {
            $0.title = "확인했어요"
            $0.addTarget(self, action: #selector(pressedConfirmBtn), for: .touchUpInside)
        }

        prevBtn.do {
            $0.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g800
            $0.addTarget(self, action: #selector(pressedPrevBtn), for: .touchUpInside)
        }

        nextBtn.do {
            $0.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g100
            $0.addTarget(self, action: #selector(pressedNextBtn), for: .touchUpInside)
        }
    }

    private func configureButtonState() {
        // nextBtn 세팅
        let nextPageIndex: Int = collectionViewPagination.currentPage + 1
        let maxCountIndex: Int = updateImages.count - 1
        let nextBtnIsEnabled: Bool = nextPageIndex > maxCountIndex ? false : true

        switch nextBtnIsEnabled {
        case true:
            nextBtn.tintColor = Colors.grey.g100

        case false:
            nextBtn.tintColor = Colors.grey.g800
        }

        // prevBtn 세팅
        let prevPageIndex: Int = collectionViewPagination.currentPage - 1
        let prevBtnIsEnabled: Bool = prevPageIndex >= 0 ? true : false

        switch prevBtnIsEnabled {
        case true:
            prevBtn.tintColor = Colors.grey.g100

        case false:
            prevBtn.tintColor = Colors.grey.g800
        }
    }

    private func setViews() {
        // addSubview(titleLabel)
        // addSubview(descriptionLabel)
        addSubview(collectionView)
        addSubview(collectionViewPagination)
        addSubview(confirmBtn)
        addSubview(prevBtn)
        addSubview(nextBtn)

        /*
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview()
        }
        */

        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            // make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.top.equalToSuperview()
            make.height.equalTo(251)
        }

        collectionViewPagination.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }

        confirmBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(collectionViewPagination.snp.bottom).offset(24)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        prevBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(36)
            make.centerY.equalTo(collectionView)
            make.width.height.equalTo(24)
        }

        nextBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(36)
            make.centerY.equalTo(collectionView)
            make.width.height.equalTo(24)
        }
    }
}

// MARK: - CollectionView

extension MenualBottomSheetAppUpdateLogComponentView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("AppUpdateLogComp :: AppUpdateInfoRepository :: updateImages.count = \(updateImages.count)")
        return updateImages.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: UpdateImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpdateImageCell", for: indexPath) as? UpdateImageCell else { return UICollectionViewCell() }

        let index: Int = indexPath.row
        guard let image = updateImages[safe: index] else { return UICollectionViewCell() }

        cell.image = image

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(
            width: self.collectionView.bounds.width,
            height: self.collectionView.bounds.height
        )
    }
}

// MARK: - ScrollView

extension MenualBottomSheetAppUpdateLogComponentView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width: CGFloat = scrollView.bounds.size.width

        if width == 0 { return }

        let x: CGFloat = scrollView.contentOffset.x + (width / 2)

        let newPage: Int = Int(x / width)
        if collectionViewPagination.currentPage != newPage {
            collectionViewPagination.currentPage = newPage
            configureButtonState()
        }
    }
}

// MARK: - IBAction

extension MenualBottomSheetAppUpdateLogComponentView {
    @objc
    func pressedConfirmBtn() {
        delegate?.pressedConfirmBtn()
    }

    @objc
    func pressedPrevBtn() {
        let prevPageIndex: Int = collectionViewPagination.currentPage - 1
        let isEnabled: Bool = prevPageIndex >= 0 ? true : false

        switch isEnabled {
        case true:
            prevBtn.tintColor = Colors.grey.g100
            scrollToPage(index: prevPageIndex)

        case false:
            prevBtn.tintColor = Colors.grey.g800
        }
    }

    @objc
    func pressedNextBtn() {
        let nextPageIndex: Int = collectionViewPagination.currentPage + 1
        let maxCountIndex: Int = updateImages.count - 1
        let isEnabled: Bool = nextPageIndex > maxCountIndex ? false : true

        switch isEnabled {
        case true:
            nextBtn.tintColor = Colors.grey.g100
            scrollToPage(index: nextPageIndex)

        case false:
            nextBtn.tintColor = Colors.grey.g800
        }
    }
}

// MARK: - ScrollEvent

extension MenualBottomSheetAppUpdateLogComponentView {
    private func scrollToPage(index: Int) {
        let indexPath: IndexPath = .init(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionViewPagination.currentPage = index
        configureButtonState()
    }
}
