//
//  ListCellImageView.swift
//  
//
//  Created by 정진균 on 11/12/23.
//

import MenualUtil
import SnapKit
import Then
import UIKit

public final class ListCellImageView: UIImageView {

    public var imageCount: Int? {
        didSet { setNeedsLayout() }
    }

    private let imageCountLabel: UILabel = .init()
    private let backgroundView: UIView = .init()

    override init(image: UIImage? = nil) {
        super.init(image: image)
        configureUI()
        setViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundView.do {
            $0.backgroundColor = Colors.grey.g800.withAlphaComponent(0.8)
            $0.AppCorner(._2pt)
            $0.layer.masksToBounds = true
        }

        imageCountLabel.do {
            $0.font = .AppBodyOnlyFont(.body_1)
            $0.textColor = Colors.grey.g100
            $0.numberOfLines = 1
        }
    }

    private func setViews() {
        addSubview(backgroundView)
        backgroundView.addSubview(imageCountLabel)
        bringSubviewToFront(backgroundView)

        backgroundView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.width.height.equalTo(23)
        }

        imageCountLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let imageCount {
            backgroundView.isHidden = false
            imageCountLabel.text = "\(imageCount)"
        } else {
            backgroundView.isHidden = true
        }
    }
}
