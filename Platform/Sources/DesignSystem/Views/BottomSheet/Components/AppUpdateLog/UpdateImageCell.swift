//
//  UpdateImageCell.swift
//
//
//  Created by 정진균 on 2023/08/27.
//

import SnapKit
import Then
import UIKit

public final class UpdateImageCell: UICollectionViewCell {
    public var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    private let imageView: UIImageView = .init()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    private func configureUI() {
        imageView.do {
            $0.layer.masksToBounds = true
            $0.contentMode = .scaleAspectFill
            // $0.layer.cornerRadius = 8
        }
    }

    private func setViews() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let image {
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
