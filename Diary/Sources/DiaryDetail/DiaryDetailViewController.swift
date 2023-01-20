//
//  DiaryDetailViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift
import RxRelay
import UIKit
import Then
import SnapKit
import RealmSwift
import MenualEntity
import DesignSystem
import MenualUtil

public protocol DiaryDetailPresentableListener: AnyObject {
    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedReplySubmitBtn(desc: String)
    func pressedIndicatorButton(offset: Int, isInitMode: Bool)
    func pressedMenuMoreBtn()
    func pressedReminderBtn()
    
    func pressedImageView()
    
    func hideDiary()
    func deleteReply(replyModel: DiaryReplyModelRealm)
    
    var diaryReplyArr: [DiaryReplyModelRealm] { get }
    var currentDiaryPage: Int { get }
}

final class DiaryDetailViewController: UIViewController, DiaryDetailPresentable, DiaryDetailViewControllable {
    
    weak var listener: DiaryDetailPresentableListener?
    private var pageNum: Int = 0
    private var isEnableImageView: Bool = false
    // 기본 크기 40에서 추가된 사이즈만큼 Height 조절
    private var replyBottomViewPlusHeight: CGFloat = 0
    // 숨김처리일 경우 사용되는 변수
    private var isHide: Bool = false
    private var replyTextPlcaeHolder: String = MenualString.reply_placeholder
    
    private var isShowKeboard: Bool  = false
    private var willDeleteReplyUUID: String?
    private var willDeleteReplyModel: DiaryReplyModelRealm?
    
    private let tableViewHeaderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.backgroundColor = Colors.background
        $0.backgroundColor = .clear
    }
    
    private lazy var replyBottomView = ReplyBottomView().then {
        $0.categoryName = "reply"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.writeBtn.addTarget(self, action: #selector(pressedSubmitReplyBtn), for: .touchUpInside)
        $0.replyTextView.delegate = self
    }

    lazy var naviView = MenualNaviView(type: .menualDetail).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        
        $0.rightButton1.addTarget(self, action: #selector(pressedMenuMoreBtn), for: .touchUpInside)
        $0.rightButton2.addTarget(self, action: #selector(pressedReminderBtn), for: .touchUpInside)
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.grey.g200
        $0.text = "텍스트입ㄴ다"
        $0.numberOfLines = 0
    }
    
    private let createdAtPageView = CreatedAtPageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let weatherLocationStackView = UIStackView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 13
        $0.distribution = .fill
    }
    
    private let divider1 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var weatherSelectView = WeatherLocationSelectView(type: .weather).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.selected = true
        $0.selectedWeatherType = .rain
        $0.selectTitle = ""
        $0.isDeleteBtnEnabled = false
    }
    
    private let divider2 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var locationSelectView = WeatherLocationSelectView(type: .location).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.selected = true
        $0.selectedPlaceType = .company
        $0.selectTitle = ""
        $0.isDeleteBtnEnabled = false
    }
    
    private let divider3 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var descriptionTextView = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = ""
        $0.isScrollEnabled = false
        $0.isEditable = false
        $0.backgroundColor = .clear
        $0.textContainerInset = .zero
        $0.textContainer.lineFragmentPadding = 0
    }
    
    private let divider4 = Divider(type: ._1px).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.backgroundColor = Colors.background
        $0.AppCorner(._4pt)
    }
    
    private lazy var imageViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedImageView))
    
    lazy var replyTableView = UITableView(frame: .zero, style: .grouped).then {
        $0.categoryName = "replyList"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 100, right: 0)
        $0.register(ReplyCell.self, forCellReuseIdentifier: "ReplyCell")
        
        $0.estimatedRowHeight = 44
        $0.rowHeight = UITableView.automaticDimension
        
        // $0.sectionHeaderHeight = UITableView.automaticDimension
        // $0.estimatedSectionHeaderHeight = 64
        
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = Colors.background
        
        $0.tableFooterView = nil
        $0.separatorStyle = .none
    }
    
    lazy var spaceRequiredFAB = FAB(fabType: .spacRequired, fabStatus: .default_).then {
        $0.categoryName = "inddicator"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spaceRequiredRightArrowBtn.addTarget(self, action: #selector(pressedIndicatorBtn(sender:)), for: .touchUpInside)
        $0.spaceRequiredLeftArrowBtn.addTarget(self, action: #selector(pressedIndicatorBtn(sender:)), for: .touchUpInside)
    }
    
    lazy var hideView = UIView().then {
        $0.categoryName = "hide"
        $0.translatesAutoresizingMaskIntoConstraints = false
        let lockEmptyView = Empty().then {
            $0.screenType = .writing
            $0.writingType = .lock
        }
        lazy var btn = CapsuleButton(frame: .zero, includeType: .iconText).then {
            $0.actionName = "unhide"
            $0.title = "숨김 해제하기"
            $0.image = Asset._16px.Circle.front.image.withRenderingMode(.alwaysTemplate)
        }
        btn.addTarget(self, action: #selector(pressedLockBtn), for: .touchUpInside)
        $0.addSubview(lockEmptyView)
        $0.addSubview(btn)

        lockEmptyView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(81)
            make.width.equalTo(160)
            make.height.equalTo(180)
            make.centerX.equalToSuperview()
        }
        btn.snp.makeConstraints { make in
            make.top.equalTo(lockEmptyView.snp.bottom).offset(12)
            make.width.equalTo(113)
            make.height.equalTo(28)
            make.centerX.equalToSuperview()
        }
        $0.isHidden = true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
        setViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenualLog.logEventAction("detail_appear")
        
        replyTableView.delegate = self
        replyBottomView.replyTextView.delegate = self
        
        imageViewGesture.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageViewGesture)

        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // 바깥쪽 터치했을때 키보드 내려가게
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            print("!!?")
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        
        replyTableView.delegate = nil
        replyBottomView.replyTextView.delegate = nil
        imageView.removeGestureRecognizer(imageViewGesture)
        
        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        print("DiaryDetail :: presentingVC = \(presentingViewController?.classForCoder)")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("DiaryDetail :: ViewWillLayoutSubviews!")
        
        var changedHeight: CGFloat = 0
        var enabledImageViewHeight: CGFloat = 0

        if isEnableImageView == true {
            enabledImageViewHeight = 16 + divider4.frame.height + 12 + imageView.frame.height
        }

        print("DiaryDetail :: isEnableImageView = \(isEnableImageView), enabledImageViewHeight = \(enabledImageViewHeight)")


        // 숨김처리가 아닐 경우에만
        if isHide == false {
//            changedHeight += 24 + titleLabel.frame.height + 16 + createdAtPageView.frame.height + 8 + divider1.frame.height + 12 + weatherSelectView.frame.height + 12 + divider2.frame.height + 12 + locationSelectView.frame.height + 12 + divider3.frame.height + 16 + descriptionTextView.frame.height + enabledImageViewHeight
            changedHeight += 24 + titleLabel.frame.height + 16 + createdAtPageView.frame.height + 8 + weatherLocationStackView.frame.height + 16 + descriptionTextView.frame.height + enabledImageViewHeight + 28

            tableViewHeaderView.snp.updateConstraints { make in
                make.height.equalTo(changedHeight)
            }
        }
        print("DiaryDetail :: changedHeight = \(changedHeight)")



        DispatchQueue.main.async {
             self.replyTableView.reloadData()
        }
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.view.addSubview(replyTableView)
        replyTableView.tableHeaderView = tableViewHeaderView

        self.view.addSubview(replyBottomView)
        self.view.addSubview(spaceRequiredFAB)
        
        self.view.addSubview(naviView)
        
        tableViewHeaderView.addSubview(titleLabel)
        tableViewHeaderView.addSubview(createdAtPageView)
        tableViewHeaderView.addSubview(weatherLocationStackView)
        weatherLocationStackView.addArrangedSubview(divider1)
        weatherLocationStackView.addArrangedSubview(weatherSelectView)
        weatherLocationStackView.addArrangedSubview(divider2)
        weatherLocationStackView.addArrangedSubview(locationSelectView)
        weatherLocationStackView.addArrangedSubview(divider3)
        tableViewHeaderView.addSubview(descriptionTextView)
        tableViewHeaderView.addSubview(divider4)
        tableViewHeaderView.addSubview(imageView)
        tableViewHeaderView.addSubview(hideView)
        
        self.view.bringSubviewToFront(naviView)
        self.view.bringSubviewToFront(replyBottomView)
        self.view.bringSubviewToFront(spaceRequiredFAB)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        replyTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        tableViewHeaderView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(350)
        }
        
        replyBottomView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(106)
        }
        
        spaceRequiredFAB.snp.makeConstraints { make in
            make.bottom.equalTo(replyBottomView.snp.top).offset(-20)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(24)
        }

        createdAtPageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(15)
        }
        
        weatherLocationStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(createdAtPageView.snp.bottom).offset(8)
        }
        
        divider1.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        weatherSelectView.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.leading.equalToSuperview()
        }
        
        divider2.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        locationSelectView.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.leading.equalToSuperview()
        }
        
        divider3.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(weatherLocationStackView.snp.bottom).offset(20)
        }
        
        divider4.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(1)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(20)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(divider4.snp.bottom).offset(12)
            make.height.equalTo(80)
        }

        hideView.snp.makeConstraints { make in
            make.top.bottom.width.height.equalToSuperview()
        }

    }
    
    func setFAB(leftArrowIsEnabled: Bool, rightArrowIsEnabled: Bool) {
        spaceRequiredFAB.leftArrowIsEnabled = leftArrowIsEnabled
        spaceRequiredFAB.rightArrowIsEnabled = rightArrowIsEnabled
    }
    
    func loadDiaryDetail(model: DiaryModelRealm?) {
        guard let model = model else { return }
        print("DiaryDetail :: loadDiaryDetail!")
        print("DiaryDetail :: model.isHide = \(model.isHide)")
        // FAB Button
        spaceRequiredFAB.spaceRequiredCurrentPage = String(model.pageNum)
        
        setImageConstraint(image: model.cropImage)
        
        // cell 생성에 필요한 정보 임시 저장
        pageNum = model.pageNum
        print("pageNum = \(pageNum)")
        
        isHide = model.isHide
        isHideMenual(isHide: model.isHide)
        if isHide { return }

        // print("DiaryDetail :: \(model)")
        
        titleLabel.text = model.title
        titleLabel.setLineHeight(lineHeight: 1.28)
        titleLabel.lineBreakStrategy = .hangulWordPriority
        titleLabel.sizeToFit()
        
        // DiaryModel에서 WeatherModel을 UnWerapping해서 세팅
        if let weatherModel: WeatherModelRealm = model.weather {
            weatherSelectView.selected = true
            weatherSelectView.selectedWeatherType = weatherModel.weather
            weatherSelectView.selectTitle = weatherModel.detailText
            if weatherModel.weather == nil {
                print("DiaryDetail :: weather이 없습니다.")
                divider2.isHidden = true
                weatherSelectView.isHidden = true
            }
        }

        // DiaryModel에서 PlaceModel을 UnWerapping해서 세팅
        if let placeModel: PlaceModelRealm = model.place {
            locationSelectView.selected = true
            locationSelectView.selectedPlaceType = placeModel.place
            locationSelectView.selectTitle = placeModel.detailText
            if placeModel.place == nil {
                print("DiaryDetail :: place가 없습니다.")
                divider3.isHidden = true
                locationSelectView.isHidden = true
            }
        }
        
        descriptionTextView.attributedText = UIFont.AppBodyWithText(.body_4,
                                                                     Colors.grey.g100,
                                                                     text: model.desc)
        descriptionTextView.sizeToFit()
        
        createdAtPageView.createdAt = model.createdAt.toString()
        createdAtPageView.page = String(model.pageNum)
        
        replyTableView.reloadData()
    }
    
    func isHideMenual(isHide: Bool) {
        switch isHide {
        case true:
            print("DiaryDetail :: isHide! = \(isHide)")
            titleLabel.isHidden = true
            divider1.isHidden = true
            weatherSelectView.isHidden = true
            divider2.isHidden = true
            locationSelectView.isHidden = true
            divider3.isHidden = true
            descriptionTextView.isHidden = true
            createdAtPageView.isHidden = true
            divider4.isHidden = true
            imageView.isHidden = true
            
            tableViewHeaderView.snp.updateConstraints { make in
                make.height.equalTo(400)
            }
            hideView.isHidden = false
            replyTableView.reloadData()

        case false:
            print("DiaryDetail :: isHide! = \(isHide)")
            titleLabel.isHidden = false
            divider1.isHidden = false
            weatherSelectView.isHidden = false
            divider2.isHidden = false
            locationSelectView.isHidden = false
            divider3.isHidden = false
            descriptionTextView.isHidden = false
            createdAtPageView.isHidden = false
            
            print("DiaryDetail :: isHide! -> isEnableImageView = \(isEnableImageView)")
            if isEnableImageView == true {
                divider4.isHidden = false
                imageView.isHidden = false
            } else {
                divider4.isHidden = true
                imageView.isHidden = true
            }
            
            hideView.isHidden = true
            replyTableView.reloadData()
        }
    }
    
    func setImageConstraint(image: Data?) {
        let isImageEnabled: Bool = image != nil ? true : false

        print("DiaryDetail :: isImageEnabled = \(isEnableImageView)")

        switch isImageEnabled {
        case true:
            guard let image = image else {
                return
            }
            
            isEnableImageView = true
            divider4.isHidden = false
            imageView.isHidden = false
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: image)
            }
        case false:
            divider4.isHidden = true
            imageView.isHidden = true
            isEnableImageView = false
            
            DispatchQueue.main.async {
                self.imageView.image = nil
            }
        }
    }
    
    func reloadTableView() {
        print("diaryDetailViewController reloadTableView!")
        self.replyTableView.reloadData()
    }
    
    func reminderCompViewshowToast(isEding: Bool) {
        var message: String = ""
        switch isEding {
        case true:
            message = MenualString.reminder_toast_edit
        case false:
            message = MenualString.reminder_toast_set
        }
        let toast = showToast(message: message)
        MenualLog.logEventAction(responder: toast)
    }
    
    func setReminderIconEnabled(isEnabled: Bool) {
        switch isEnabled {
        case true:
            naviView.rightButton2IsActive = true
        case false:
            naviView.rightButton2IsActive = false
        }
    }
}

// MARK: - IBAction
extension DiaryDetailViewController {
    @objc
    func pressedMenuMoreBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        listener?.pressedMenuMoreBtn()
    }
    
    @objc
    func pressedReminderBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        listener?.pressedReminderBtn()
    }
    
    @objc
    func pressedBackBtn() {
        MenualLog.logEventAction(responder: naviView.backButton)
        print("DiaryDetail :: pressedBackBtn!")
        guard let replyText: String = replyBottomView.replyTextView.text else { return }
        
        // 겹스끼 내용을 한 글자 이상 작성했을 경우 Alert (UX)
        if replyText.count > 0 && replyText != replyTextPlcaeHolder {
            show(size: .small,
                 buttonType: .twoBtn,
                 titleText: "겹쓰기를 취소하고 돌아가시겠어요?",
                 cancelButtonText: "취소",
                 confirmButtonText: "확인"
            )
        } else {
            listener?.pressedBackBtn(isOnlyDetach: false)
        }
    }
    
    @objc
    func pressedSubmitReplyBtn(_ button: UIButton) {
        let parameter: [String: Any] = [
            "replyStringCount": replyBottomView.replyTextView.text.count
        ]
        MenualLog.logEventAction(responder: button, parameter: parameter)
        print("DiaryDetail :: pressedSubmitReplyBtn")
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "겹쓰기 작성을 완료하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    @objc
    func pressedIndicatorBtn(sender: UIButton) {
        MenualLog.logEventAction(responder: sender)
        print("DiaryDetail :: sender.s tag = \(sender.tag)")
        listener?.pressedIndicatorButton(offset: sender.tag, isInitMode: false)
        DispatchQueue.main.async {
            self.replyTableView.reloadData()
        }
    }
    
    // 숨김 해제하기 버튼
    @objc
    func pressedLockBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryDetail :: 숨김 해제하기 버튼 클릭!")
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "숨김을 해제 하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
        
    }
    
    @objc
    func pressedImageView(_ button: UIButton) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        MenualLog.logEventAction("detail_image")
        print("DiaryDetail :: pressedImageView!")
        listener?.pressedImageView()
    }
    func enableBackSwipe() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc
    func pressedReplyCloseBtn(sender: UIButton) {
        MenualLog.logEventAction(responder: sender)
        print("DiaryDetail :: pressedRelyCloseBtn!, sender.tag = \(sender.tag)")
        guard let willDeleteReply = listener?.diaryReplyArr[safe: sender.tag] else { return }
        self.willDeleteReplyModel = willDeleteReply
        // print("DiaryDetail :: uuid = \(cell.replyUUID)")
        // self.willDeleteReplyUUID = cell.replyUUID
        
        show(size: .small,
             buttonType: .twoBtn,
             titleText: "겹쓰기를 삭제 하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
}

// MARK: - ReplayTableView
extension DiaryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        
        guard let replies = listener?.diaryReplyArr else { return 0 }
        let desc = replies[index].desc
        let lblDescLong = UITextView()
        lblDescLong.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 19, right: 16)
        lblDescLong.textAlignment = .left
        // lblDescLong.text = desc
        // lblDescLong.font = UIFont.AppBodyOnlyFont(.body_2)
        lblDescLong.attributedText = UIFont.AppBodyWithText(.body_3,
                                                    Colors.grey.g300,
                                                    text: desc
        )
        lblDescLong.sizeToFit()
        let width = UIScreen.main.bounds.width - 40
        let newSize = lblDescLong.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let moreBtnSizeHeight: CGFloat = 50
        print("width = \(width), newSize = \(newSize), cellReplyText = \(desc)")
        return newSize.height + moreBtnSizeHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.diaryReplyArr.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("DiaryDetail :: cellForRowAt!")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell") as? ReplyCell else { return UITableViewCell() }
        
        let index = indexPath.row
        
        guard let replies = listener?.diaryReplyArr else { return UITableViewCell() }
        
        let desc = replies[index].desc
        let createdAt = replies[index].createdAt
        let replyNum = replies[index].replyNum
        let uuid = replies[index].uuid

        cell.backgroundColor = .clear
        // cell이 클릭되지 않도록
        cell.selectionStyle = .none
//        cell.title = desc
        cell.replyText = desc
        cell.replyNum = replyNum
        cell.createdAt = createdAt
        cell.pageNum = pageNum
        cell.replyUUID = uuid
        cell.closeBtn.tag = indexPath.row
        cell.closeBtn.addTarget(self, action: #selector(pressedReplyCloseBtn(sender:)), for: .touchUpInside)
        cell.actionName = "reply"
        // cell.replyTextView.sizeToFit()
        
//        if let currentDiaryPage = listener?.currentDiaryPage {
//            cell.pageAndReview = "p.\(currentDiaryPage)-" + String(replyNum)
//        }
        
//        cell.dateAndTime = createdAt.toStringWithHourMin()

        return cell
    }
}

// MARK: - Keyboard Extension
extension DiaryDetailViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        print("keyboardWillShow! - \(keyboardHeight)")
        
        spaceRequiredFAB.isHidden = true
        isShowKeboard = true
        
        replyTableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
        
        replyBottomView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
            make.height.equalTo(84 + replyBottomViewPlusHeight)
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide!")
        
        isShowKeboard = false
        spaceRequiredFAB.isHidden = false
        
        replyTableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        
        replyBottomView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(106 + replyBottomViewPlusHeight)
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


// MARK: - textView Delegate
extension DiaryDetailViewController: UITextViewDelegate {
    // MARK: textview 높이 자동조절
    func textViewDidChange(_ textView: UITextView) {

        switch textView {
        case replyBottomView.replyTextView:
            let size = CGSize(width: replyBottomView.replyTextView.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)

            print("estmatedSize Height = \(estimatedSize.height)")
            let line = textView.numberOfLines()
            print("DiaryDetail :: line = \(line)")

            textView.constraints.forEach { (constraint) in
              /// 40 이하일때는 더 이상 줄어들지 않게하기
                if estimatedSize.height <= 43 {
                    replyBottomView.replyTextView.snp.updateConstraints { make in
                        make.height.equalTo(43)
                    }
                }
                else if line < 5 {
                    print("DiaryDetail :: line < 5")
                    replyBottomView.replyTextView.isScrollEnabled = false
                    replyBottomView.replyTextView.snp.updateConstraints { make in
                        make.height.equalTo(estimatedSize.height)
                    }

                    replyBottomViewPlusHeight = estimatedSize.height - 40
                    if isShowKeboard {
                        replyBottomView.snp.updateConstraints { make in
                            make.height.equalTo(84 + replyBottomViewPlusHeight)
                        }
                    } else {
                        replyBottomView.snp.updateConstraints { make in
                            make.height.equalTo(106 + replyBottomViewPlusHeight)
                        }
                    }
                }
                else if line >= 5 {
                    print("DiaryDetail :: line > 5")
                    replyBottomView.replyTextView.isScrollEnabled = true
                }
            }

        default:
            break
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        switch textView {
        case replyBottomView.replyTextView:
            guard let text = textView.text else { return false }
            if text == replyTextPlcaeHolder {
                textView.text = nil
                textView.textColor = Colors.grey.g100
            }

            return true

        default:
            return true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case replyBottomView.replyTextView:
            guard let text = textView.text else { return }
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = replyTextPlcaeHolder
                textView.textColor = Colors.grey.g500
            }

        default:
            break
        }
    }
}

// MARK: - Dialog
extension DiaryDetailViewController: DialogDelegate {
    func action(titleText: String) {
        print("DiaryDetail :: action!")
        switch titleText {
        case "숨김을 해제 하시겠어요?":
            listener?.hideDiary()
            
        case "겹쓰기를 취소하고 돌아가시겠어요?":
            listener?.pressedBackBtn(isOnlyDetach: false)
            
        case "겹쓰기 작성을 완료하시겠어요?":
            let text = replyBottomView.writedText
            listener?.pressedReplySubmitBtn(desc: text)
            replyBottomView.replyTextView.text = ""
            textViewDidChange(replyBottomView.replyTextView)
            replyBottomView.replyTextView.layoutIfNeeded()
            replyBottomView.setNeedsLayout()
            view.endEditing(true)

        case "겹쓰기를 삭제 하시겠어요?":
            guard let willDeleteReplyModel = willDeleteReplyModel else { return }
            listener?.deleteReply(replyModel: willDeleteReplyModel)

        default:
            break
        }
    }
    
    func exit(titleText: String) {
        print("DiaryDetail :: exit")
        switch titleText {
        case "숨김을 해제 하시겠어요?":
            break
            
        case "겹쓰기를 취소하고 돌아가시겠어요?":
            break
            
        case "겹쓰기 작성을 완료하시겠어요?":
            break
            
        case "겹쓰기를 삭제 하시겠어요?":
            self.willDeleteReplyUUID = nil

        default:
            break
        }
    }
}
