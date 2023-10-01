//
//  UploadImageCell.swift
//
//
//  Created by 정진균 on 2023/09/02.
//

import MenualUtil
import SnapKit
import Then
import UIKit

// MARK: - ImageUploadCellDelegate

public protocol ImageUploadCellDelegate: AnyObject {
    func pressedTakeImageButton()
    func pressedUploadImageButton()
    func pressedDeleteButton(cell: ImageUploadCell)
}

// MARK: - ImageUploadCell

public final class ImageUploadCell: UICollectionViewCell {
    public enum Status {
        case addImage
        case image
        case detailImage // 상세보기에서 보는 이미지 타입
    }

    public struct Parameters {
        public var status: Status = .addImage
        public var imageData: Data? = nil
        public var isThumb: Bool = false
    }

    public var parameters: ImageUploadCell.Parameters = .init() {
        didSet { setNeedsLayout() }
    }

    public weak var delegate: ImageUploadCellDelegate?

    private let imageView: UIImageView = .init()
    private let deleteBtn: UIButton = .init()
    private let thumbLabelView: UIView = .init()
    private let thumbLabel: UILabel = .init()

    // 이미지 추가하기 버튼일 경우 사용하는 View
    private let addImageStackView: UIStackView = .init()
    private let addImageView: UIImageView = .init()
    private let addImageLabel: UILabel = .init()
    private lazy var addImagePullDownButton = UIButton(frame: .zero)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        configureUI()
        setViews()
        setImageButtonUIActionMenu()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        parameters.imageData = nil
        parameters.isThumb = false
    }

    private func configureUI() {
        isUserInteractionEnabled = true
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = .clear

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = false
        }

        deleteBtn.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800.withAlphaComponent(0.7)
            $0.setImage(Asset._20px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g400
            $0.addTarget(self, action: #selector(pressedDeleteBtn(responder:)), for: .touchUpInside)

            let corners: CACornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMaxYCorner
            ]

            $0.layer.cornerRadius = 4
            $0.layer.maskedCorners = corners
            $0.layer.masksToBounds = true
        }

        thumbLabelView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.tint.sub.n400

            let corners: CACornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMaxYCorner
            ]

            $0.layer.cornerRadius = 4
            $0.layer.maskedCorners = corners
            $0.layer.masksToBounds = true

            $0.isHidden = true
        }

        thumbLabel.do {
            $0.text = "대표"
            $0.font = .AppBodyOnlyFont(.body_2)
            $0.textAlignment = .center
            $0.textColor = Colors.grey.g600
        }

        addImageStackView.do {
            $0.axis = .vertical
            $0.spacing = 4
            $0.distribution = .fill
            $0.alignment = .fill
            $0.isUserInteractionEnabled = false
        }

        addImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.image = Asset._24px.picture.image.withRenderingMode(.alwaysTemplate)
            $0.tintColor = Colors.grey.g600
            $0.isUserInteractionEnabled = false
        }

        addImageLabel.do {
            $0.textColor = Colors.grey.g600
            $0.font = .AppBodyOnlyFont(.body_2)
            $0.text = MenualString.uploadimage_title_add
            $0.isUserInteractionEnabled = false
        }

        addImagePullDownButton.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.showsMenuAsPrimaryAction = true
        }
    }

    private func setViews() {
        addSubview(imageView)
        addSubview(thumbLabelView)
        thumbLabelView.addSubview(thumbLabel)
        addSubview(deleteBtn)
        addSubview(addImagePullDownButton)
        addSubview(addImageStackView)
        addImageStackView.addArrangedSubview(addImageView)
        addImageStackView.addArrangedSubview(addImageLabel)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        thumbLabelView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(26)
        }

        thumbLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(28)
        }

        addImageStackView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        addImagePullDownButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let imageData: Data = parameters.imageData {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        }

        if parameters.isThumb {
            print("UploadImageCell :: thumb입니다!")
        }

        // 썸네일 여부에 따라 다르게
        switch parameters.isThumb {
        case true:
            layer.borderColor = Colors.tint.sub.n400.cgColor
            layer.borderWidth = 1
            thumbLabelView.isHidden = false

        case false:
            layer.borderColor = .none
            layer.borderWidth = 0
            thumbLabelView.isHidden = true
        }

        switch parameters.status {
        case .addImage:
            imageView.isHidden = true
            backgroundColor = Colors.grey.g800
            addImageStackView.isHidden = false
            addImagePullDownButton.isUserInteractionEnabled = true
            deleteBtn.isHidden = true

        case .image:
            imageView.isHidden = false
            addImageStackView.isHidden = true
            addImagePullDownButton.isUserInteractionEnabled = false
            addImagePullDownButton.isHidden = true
            deleteBtn.isHidden = false

        case .detailImage:
            imageView.isHidden = false
            addImageStackView.isHidden = true
            deleteBtn.isHidden = true
            addImagePullDownButton.isUserInteractionEnabled = false
            addImagePullDownButton.isHidden = true
        }
    }
}

// MARK: - PullDownImageButton

extension ImageUploadCell {
    func setImageButtonUIActionMenu() {
        let uploadImage = UIAction(
            title: MenualString.writing_button_select_picture,
            image: Asset._24px.album.image.withRenderingMode(.alwaysTemplate))
        { [weak self] action in
            guard let self = self else { return }
            print("ImageUpload :: action! = \(action)")
            self.delegate?.pressedUploadImageButton()
        }

        let takeImage = UIAction(
            title: MenualString.writing_button_take_picture,
            image: Asset._24px.camera.image.withRenderingMode(.alwaysTemplate))
        { [weak self] action in
            guard let self = self else { return }
            print("ImageUpload :: action! = \(action)")
            self.delegate?.pressedTakeImageButton()
        }

        addImagePullDownButton.menu = UIMenu(children: [takeImage, uploadImage])
    }
}

// MARK: - IABAction

extension ImageUploadCell {
    @objc
    private func pressedDeleteBtn(responder: UIResponder) {
        print("ImageUpload :: pressedDeleteBtn")
        delegate?.pressedDeleteButton(cell: self)
    }
}
