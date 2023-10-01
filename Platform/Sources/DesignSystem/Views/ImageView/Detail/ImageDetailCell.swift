//
//  ImageDetailCell.swift
//  
//
//  Created by 정진균 on 9/30/23.
//

import PhotosUI
import SnapKit
import Then
import UIKit

public class ImageDetailCell: UICollectionViewCell {
    public var imageData: Data = .init() {
        didSet { setNeedsLayout() }
    }

    private let scrollView: UIScrollView = .init()
    private let imageView: UIImageView = .init()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true

        configureUI()
        setViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        imageData = .init()
    }

    private func configureUI() {
        backgroundColor = .clear

        imageView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
        }

        scrollView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false

            $0.minimumZoomScale = 1.0
            $0.maximumZoomScale = 10.0
            $0.delegate = self
            $0.backgroundColor = Colors.background

            $0.delegate = self
        }
    }

    private func setViews() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.size.equalTo(contentView)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        imageView.image = UIImage(data: imageData)
    }
}

// MARK: - UIScrollViewDelegate

extension ImageDetailCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
