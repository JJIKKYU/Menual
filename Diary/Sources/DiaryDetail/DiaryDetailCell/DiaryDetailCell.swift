//
//  DiaryDetailCell.swift
//
//
//  Created by 정진균 on 10/3/23.
//

import DesignSystem
import MenualEntity
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit

// MARK: - DiaryDetailCellDelegate

public protocol DiaryDetailCellDelegate: AnyObject {
}

// MARK: - DiaryDetailCell

public final class DiaryDetailCell: UICollectionViewCell {

    public weak var delegate: DiaryDetailCellDelegate?

    public var uploadImagesRelay: BehaviorRelay<[Data]>? = .init(value: [])
    public var thumbImageIndexRelay: BehaviorRelay<Int>? = .init(value: 0)

    public var diaryModel: DiaryModelRealm? {
        didSet { setNeedsLayout() }
    }

    private let titleLabel: UILabel = .init()
    private let createdAtPageView: CreatedAtPageView = .init()
    private let divider1: Divider = .init(type: ._1px)
    private let weatherSelectView: WeatherLocationSelectView = .init(type: .weather)
    private let divider2: Divider = .init(type: ._1px)
    private let locationSelectView: WeatherLocationSelectView = .init(type: .location)
    private let divider3: Divider = .init(type: ._1px)
    private let descriptionTextView: UITextView = .init()
    private let divider4: Divider = .init(type: ._1px)
    private let imageUploadView: ImageUploadView = .init(state: .detail)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true

        configureUI()
        setViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    private func configureUI() {
        backgroundColor = Colors.background

        titleLabel.do {
            $0.font = UIFont.AppTitle(.title_5)
            $0.textAlignment = .left
            $0.textColor = Colors.grey.g200
            $0.text = "제목은 최대 40자까지 입력할 수 있어요. 제목은 최대 40자까지 입력할 수 있어요. 제목은 최대 40자까지 입력할 수 있어요."
            $0.numberOfLines = 0
        }

        createdAtPageView.do {
            $0.createdAt = "YYYY.MM.DD HH:MM"
            $0.page = "P.15"
        }

        weatherSelectView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.selected = true
            $0.selectedWeatherType = .rain
            $0.selectTitle = "날씨가 참 좋구나"
            $0.isDeleteBtnEnabled = false
        }

        divider2.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        locationSelectView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.selected = true
            $0.selectedPlaceType = .company
            $0.selectTitle = "장소가 참 좋구나"
            $0.isDeleteBtnEnabled = false
        }

        divider3.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        descriptionTextView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다. 작성한 내용이 보여집니다."
            $0.isScrollEnabled = false
            $0.isEditable = false
            $0.backgroundColor = .clear
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
            $0.font = .AppBodyOnlyFont(.body_3)
            $0.textColor = Colors.grey.g200
        }

        imageUploadView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = true
            $0.delegate = self
        }
    }

    private func setViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(createdAtPageView)
        contentView.addSubview(divider1)
        contentView.addSubview(weatherSelectView)
        contentView.addSubview(divider2)
        contentView.addSubview(locationSelectView)
        contentView.addSubview(divider3)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(divider4)
        contentView.addSubview(imageUploadView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(20)
        }

        createdAtPageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        divider1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(createdAtPageView.snp.bottom).offset(9)
            make.height.equalTo(1)
        }

        weatherSelectView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(divider1.snp.bottom)
            make.height.equalTo(56)
        }

        divider2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(weatherSelectView.snp.bottom)
            make.height.equalTo(1)
        }

        locationSelectView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(divider2.snp.bottom)
            make.height.equalTo(56)
        }

        divider3.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(locationSelectView.snp.bottom)
            make.height.equalTo(1)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(divider3.snp.bottom).offset(17)
        }

        divider4.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(24)
            make.height.equalTo(1)
        }

        imageUploadView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(divider4.snp.bottom).offset(16)
            make.height.equalTo(100)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let diaryModel: DiaryModelRealm = diaryModel else { return }
        titleLabel.text = diaryModel.title

        weatherSelectView.selectedWeatherType = diaryModel.weather?.weather
        weatherSelectView.selectTitle = diaryModel.weather?.detailText ?? ""
        weatherSelectView.selected = true

        locationSelectView.selectedPlaceType = diaryModel.place?.place
        locationSelectView.selectTitle = diaryModel.place?.detailText ?? ""
        locationSelectView.selected = true

        descriptionTextView.text = diaryModel.desc

        createdAtPageView.createdAt = diaryModel.createdAt.toString()
        createdAtPageView.page = String(diaryModel.pageNum)

        uploadImagesRelay?.accept(diaryModel.images)
        thumbImageIndexRelay?.accept(diaryModel.thumbImageIndex)
    }
}

// MARK: - ImageUploadViewDelegate

extension DiaryDetailCell: ImageUploadViewDelegate {
}
