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

public final class ImageUploadView: UIView {
    var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    public let uploadedImageView: UIImageView = .init()
    private let uploadBtn: UIButton = .init()
    private let centerView: UIView = .init()
    private let placeHolderImageView: UIImageView = .init()
    private let placeHolderTextLabel: UILabel = .init()
    public lazy var deleteBtn: UIButton = .init()
    public lazy var editBtn: UIButton = .init()

    init() {
        super.init(frame: CGRect.zero)
        configureUI()
        setViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        uploadedImageView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            $0.AppCorner(._4pt)
        }

        uploadBtn.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("", for: .normal)
            $0.backgroundColor = .clear
            $0.backgroundColor = Colors.grey.g800.withAlphaComponent(0.4)
        }

        centerView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        placeHolderImageView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = Asset._24px.picture.image.withRenderingMode(.alwaysTemplate)
            $0.tintColor = Colors.grey.g700
            $0.AppCorner(._4pt)
        }

        placeHolderTextLabel.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = Colors.grey.g600
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.text = MenualString.writing_button_add_image
        }

        deleteBtn.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
            $0.contentHorizontalAlignment = .fill
            $0.contentVerticalAlignment = .fill
            $0.setImage(Asset._20px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g600
            $0.isHidden = true
        }

        editBtn.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
            $0.contentHorizontalAlignment = .fill
            $0.contentVerticalAlignment = .fill
            $0.setImage(Asset._20px.modify.image.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = Colors.grey.g600
            $0.isHidden = true
        }
    }

    private func setViews() {
        addSubview(centerView)
        addSubview(uploadBtn)
        addSubview(uploadedImageView)
        addSubview(editBtn)
        addSubview(deleteBtn)

        centerView.addSubview(placeHolderImageView)
        centerView.addSubview(placeHolderTextLabel)

        placeHolderImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }

        placeHolderTextLabel.snp.makeConstraints { make in
            make.leading.equalTo(placeHolderImageView.snp.trailing).offset(4)
            make.width.equalTo(47)
            make.height.equalTo(15)
            make.centerY.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(uploadBtn)
        }

        uploadBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(80)
        }

        uploadedImageView.snp.makeConstraints { make in
            make.leading.width.top.equalToSuperview()
            make.height.equalTo(80)
        }

        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(uploadedImageView.snp.bottom).offset(10)
            make.width.equalTo(20)
        }

        editBtn.snp.makeConstraints { make in
            make.trailing.equalTo(deleteBtn.snp.leading).offset(-8)
            make.top.equalTo(uploadedImageView.snp.bottom).offset(10)
            make.width.equalTo(20)
        }


    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let image = image {
            print("DiaryWriting :: ImageUploadView :: image!")
            uploadedImageView.image = image
            uploadedImageView.isHidden = false
            editBtn.isHidden = false
            deleteBtn.isHidden = false
        } else {
            uploadedImageView.image = nil
            uploadedImageView.isHidden = true
            editBtn.isHidden = true
            deleteBtn.isHidden = true
        }
    }
}
