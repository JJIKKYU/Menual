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
    func pressedDetailImage(index: Int)
    func pressedReplyCloseBtn(sender: UIButton)
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

    private let weatherPlaceStackView: UIStackView = .init()
    private let divider1: Divider = .init(type: ._1px)
    private let weatherSelectView: WeatherLocationSelectView = .init(type: .weather)
    private let divider2: Divider = .init(type: ._1px)
    private let placeSelectView: WeatherLocationSelectView = .init(type: .location)
    private let divider3: Divider = .init(type: ._1px)
    private let descriptionTextView: UITextView = .init()
    private let divider4: Divider = .init(type: ._1px)
    private let imageUploadView: ImageUploadView = .init(state: .detail)

    private let tableViewHeaderView: UIView = .init()
    private let tableView: UITableView = .init(frame: .zero, style: .grouped)

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

        weatherSelectView.isHidden = true
        divider2.isHidden = true
        placeSelectView.isHidden = true
        divider3.isHidden = true
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

        weatherPlaceStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
        }

        weatherSelectView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.selected = false
            $0.isDeleteBtnEnabled = false
        }

        divider2.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
        }

        placeSelectView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.selected = false
            $0.isDeleteBtnEnabled = false
        }

        divider3.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
        }

        descriptionTextView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = " "
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

        tableViewHeaderView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = true
            $0.backgroundColor = .clear
        }

        tableView.do {
            $0.categoryName = "replyList"
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
            $0.dataSource = self

            $0.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 100, right: 0)
            $0.estimatedRowHeight = 44
            $0.rowHeight = UITableView.automaticDimension

            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = Colors.background

            $0.tableFooterView = nil
            $0.separatorStyle = .none

            $0.isScrollEnabled = true

            $0.register(ReplyCell.self, forCellReuseIdentifier: "ReplyCell")
        }
    }

    private func setViews() {
        tableView.tableHeaderView = tableViewHeaderView

        [divider1, weatherSelectView, divider2, placeSelectView, divider3].forEach {
            weatherPlaceStackView.addArrangedSubview($0)
        }

        tableViewHeaderView.do {
            $0.addSubview(titleLabel)
            $0.addSubview(createdAtPageView)
            $0.addSubview(weatherPlaceStackView)
            $0.addSubview(descriptionTextView)
            $0.addSubview(divider4)
            $0.addSubview(imageUploadView)
        }
        contentView.addSubview(tableView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }

        createdAtPageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.height.equalTo(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        weatherPlaceStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(createdAtPageView.snp.bottom).offset(9)
        }

        [divider1, divider2, divider3, divider4].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
        }

        [weatherSelectView, placeSelectView].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }

        /*
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
         */

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
            make.bottom.equalToSuperview().inset(20)
        }

        tableViewHeaderView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            // make.height.equalTo(300)
        }

        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let diaryModel: DiaryModelRealm = diaryModel else { return }
        titleLabel.text = diaryModel.title

        if let weather: Weather = diaryModel.weather?.weather,
           let detailText: String = diaryModel.weather?.detailText {
            weatherSelectView.do {
                $0.selectedWeatherType = weather
                $0.selectTitle = detailText
                $0.selected = true
                $0.isHidden = false
            }
            divider2.isHidden = false
        }

        if let place: Place = diaryModel.place?.place,
           let detailText: String = diaryModel.place?.detailText {
            placeSelectView.do {
                $0.selectedPlaceType = place
                $0.selectTitle = detailText
                $0.selected = true
                $0.isHidden = false
            }
            divider3.isHidden = false
        }

        descriptionTextView.text = diaryModel.desc

        createdAtPageView.createdAt = diaryModel.createdAt.toString()
        createdAtPageView.page = String(diaryModel.pageNum)

        uploadImagesRelay?.accept(diaryModel.images)
        thumbImageIndexRelay?.accept(diaryModel.thumbImageIndex)

        tableViewHeaderView.sizeToFit()
        tableViewHeaderView.layoutIfNeeded()

        tableView.layoutIfNeeded()
    }
}

// MARK: - ImageUploadViewDelegate

extension DiaryDetailCell: ImageUploadViewDelegate {
    public func pressedDetailImage(index: Int) {
        delegate?.pressedDetailImage(index: index)
    }
}

// MARK: - UITableViewDelegate, UITableviewDataSource

extension DiaryDetailCell: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryModel?.repliesArr.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let defaultCell: UITableViewCell = .init()
        guard let cell: ReplyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? ReplyCell else { return defaultCell }

        let index: Int = indexPath.row

        guard let model: DiaryReplyModelRealm = diaryModel?.repliesArr[safe: index] else { return defaultCell }

        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        cell.do {
            $0.replyText = model.desc
            $0.replyNum = model.replyNum
            $0.createdAt = model.createdAt
            $0.replyUUID = model.uuid
            $0.closeBtn.tag = index
            $0.closeBtn.addTarget(self, action: #selector(pressedReplyCloseBtn(sender:)), for: .touchUpInside)
            $0.actionName = "reply"
        }

        return cell
    }
}

// MARK: - IBAction

extension DiaryDetailCell {
    @objc
    func pressedReplyCloseBtn(sender: UIButton) {
        delegate?.pressedReplyCloseBtn(sender: sender)
    }
}
