//
//  DiaryDetailViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import DesignSystem
import MenualEntity
import MenualUtil
import MessageUI
import RealmSwift
import RIBs
import RxRelay
import RxSwift
import SnapKit
import Then
import UIKit

// MARK: - DiaryDetailPresentableListener

public protocol DiaryDetailPresentableListener: AnyObject {
    var diaryModelArrRelay: BehaviorRelay<[DiaryModelRealm]> { get }

    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedReplySubmitBtn(desc: String)
    func pressedMenuMoreBtn()
    func pressedReminderBtn()
    
    func pressedImageView(index: Int)

    func hideDiary()
    func deleteReply(replyModel: DiaryReplyModelRealm)
    
    var diaryReplyArr: [DiaryReplyModelRealm] { get }
    var currentDiaryPage: Int { get }
    var uploadImagesRelay: BehaviorRelay<[Data]> { get }
    var currentDiaryModelRelay: BehaviorRelay<DiaryModelRealm?> { get }
    var currentDiaryModelIndexRelay: BehaviorRelay<Int> { get }
}

// MARK: - DiaryDetailViewController

final class DiaryDetailViewController: UIViewController, DiaryDetailPresentable, DiaryDetailViewControllable {
    
    weak var listener: DiaryDetailPresentableListener?

    private let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())

    // 첫 진입때만 이동하도록
    private var isFirstCurrentPage: Bool = true
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

    private let replyBottomView: ReplyBottomView = .init()

    private let naviView: MenualNaviView = .init(type: .menualDetail)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen

        configureUI()
        setViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MenualLog.logEventAction("detail_willappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MenualLog.logEventAction("detail_appear")

        replyBottomView.replyTextView.delegate = self

        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // 바깥쪽 터치했을때 키보드 내려가게
        // let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        // view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCurrentPageDiary()
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }

        replyBottomView.replyTextView.delegate = nil
        
        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func reloadTableView() {
        print("DiaryDetail :: reloadTableView!")
        collectionView.reloadData()
    }

    func reloadCurrentCell() {
        let index: Int = listener?.currentDiaryModelIndexRelay.value ?? 0
        let indexPath: IndexPath = .init(row: index, section: 0)
        guard let cell: DiaryDetailCell = collectionView.cellForItem(at: indexPath) as? DiaryDetailCell else { return }

        cell.reloadTableView()
    }

    func reminderCompViewshowToast(type: ReminderToastType) {
        var message: String = ""
        switch type {
        case .write:
            message = MenualString.reminder_toast_set
            
        case .edit:
            message = MenualString.reminder_toast_edit
            
        case .delete:
            message = MenualString.reminder_toast_delete
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
            showDialog(
                 dialogScreen: .diaryDetail(.replyCancel),
                 size: .small,
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
        showDialog(
            dialogScreen: .diaryDetail(.reply),
             size: .small,
             buttonType: .twoBtn,
             titleText: "겹쓰기 작성을 완료하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
    
    // 숨김 해제하기 버튼
    @objc
    func pressedLockBtn(_ button: UIButton) {
        MenualLog.logEventAction(responder: button)
        print("DiaryDetail :: 숨김 해제하기 버튼 클릭!")
        showDialog(
             dialogScreen: .diaryDetail(.hide),
             size: .small,
             buttonType: .twoBtn,
             titleText: "숨김을 해제 하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
        
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
        
        showDialog(
             dialogScreen: .diaryDetail(.replyDelete),
             size: .small,
             buttonType: .twoBtn,
             titleText: "겹쓰기를 삭제 하시겠어요?",
             cancelButtonText: "취소",
             confirmButtonText: "확인"
        )
    }
}

// MARK: - Keyboard Extension
extension DiaryDetailViewController {
    @objc
    private func keyboardWillShow(_ notification: NSNotification) {
        DispatchQueue.main.async {
            guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
            print("keyboardWillShow! - \(keyboardHeight)")

            self.isShowKeboard = true

            self.collectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(keyboardHeight)
            }

            self.replyBottomView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(keyboardHeight)
                make.height.equalTo(84 + self.replyBottomViewPlusHeight)
            }
        }
    }
    
    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide!")
        DispatchQueue.main.async {
            self.isShowKeboard = false

            self.collectionView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }

            self.replyBottomView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
                make.height.equalTo(106 + self.replyBottomViewPlusHeight)
            }
        }
    }
    
    @objc
    private func dismissKeyboard() {
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
    func action(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryDetail(let diaryDetailDialog) = dialogScreen {
            switch diaryDetailDialog {
            case .reply:
                let text = replyBottomView.writedText
                listener?.pressedReplySubmitBtn(desc: text)
                replyBottomView.replyTextView.text = ""
                textViewDidChange(replyBottomView.replyTextView)
                replyBottomView.replyTextView.layoutIfNeeded()
                replyBottomView.setNeedsLayout()
                view.endEditing(true)

            case .replyCancel:
                listener?.pressedBackBtn(isOnlyDetach: false)
                
            case .replyDelete:
                guard let willDeleteReplyModel = willDeleteReplyModel else { return }
                listener?.deleteReply(replyModel: willDeleteReplyModel)
                
            case .hide:
                listener?.hideDiary()
                
            }
        }
    }
    
    func exit(dialogScreen: DesignSystem.DialogScreen) {
        if case .diaryDetail(let diaryDetailDialog) = dialogScreen {
            switch diaryDetailDialog {
            case .reply:
                break
                
            case .replyCancel:
                break
                
            case .replyDelete:
                self.willDeleteReplyUUID = nil
                
            case .hide:
                break
            }
        }
    }
}

// MARK: - AppstoreReview

extension DiaryDetailViewController: MFMailComposeViewControllerDelegate {
    /// 리뷰 팝업에서 건의하기 버튼을 눌렀을 경우
    func presentMailVC() {
        print("DiaryHome :: pressedReviewQABtn")
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             이곳에 내용을 작성해주세요.
                             
                             오타 발견 문의 시 아래 양식에 맞춰 작성해주세요.
                             
                             <예시>
                             글귀 ID : 글귀 4 (글귀 클릭 시 상단에 표시)
                             수정 전 : 실수해도 되.
                             수정 후 : 실수해도 돼.
                             
                             -------------------
                             
                             Device Model : \(DeviceUtil.getDeviceIdentifier())
                             Device OS : \(UIDevice.current.systemVersion)
                             App Version : \(DeviceUtil.getCurrentVersion())
                             
                             -------------------
                             """
            
            composeViewController.setToRecipients(["jjikkyu@naver.com"])
            composeViewController.setSubject("<메뉴얼> 문의 및 의견")
            composeViewController.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeViewController, animated: true, completion: nil)
        } else {
            print("메일 보내기 실패")
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
            let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
                // 앱스토어로 이동하기(Mail)
                if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            sendMailErrorAlert.addAction(goAppStoreAction)
            sendMailErrorAlert.addAction(cancleAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
}

// MARK: - UI Setting

extension DiaryDetailViewController {
    private func configureUI() {
        replyBottomView.do {
            $0.categoryName = "reply"
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.writeBtn.addTarget(self, action: #selector(pressedSubmitReplyBtn), for: .touchUpInside)
            $0.replyTextView.delegate = self
        }

        naviView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)

            $0.rightButton1.addTarget(self, action: #selector(pressedMenuMoreBtn), for: .touchUpInside)
            $0.rightButton2.addTarget(self, action: #selector(pressedReminderBtn), for: .touchUpInside)
        }

        collectionView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.background

            let layout: UICollectionViewFlowLayout = .init()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumLineSpacing = 0
            $0.setCollectionViewLayout(layout, animated: true)

            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false

            $0.delegate = self
            $0.dataSource = self
            $0.register(DiaryDetailCell.self, forCellWithReuseIdentifier: "DiaryDetailCell")
        }
    }

    private func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        view.addSubview(naviView)
        view.addSubview(collectionView)
        view.addSubview(replyBottomView)
        view.bringSubviewToFront(naviView)

        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        replyBottomView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(106)
        }
    }
}

// MARK: - CollectionViewDelegate

extension DiaryDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listener?.diaryModelArrRelay.value.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: DiaryDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryDetailCell", for: indexPath) as? DiaryDetailCell else { return UICollectionViewCell() }

        guard let diaryModel: DiaryModelRealm = listener?.diaryModelArrRelay.value[safe: indexPath.row] else { return UICollectionViewCell() }

        print("DiaryDetail :: cureent Index = \(indexPath.row)")
        cell.delegate = self
        cell.diaryModel = diaryModel
        // cell.hideButton.addTarget(self, action: #selector(pressedLockBtn), for: .touchUpInside)

        // btn.addTarget(self, action: #selector(pressedLockBtn), for: .touchUpInside)
        // cell.hideImageUploadCollectionView()

        cell.sizeToFit()
        cell.layoutIfNeeded()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return .init(
            width: collectionView.frame.width,
            height: collectionView.frame.height
        )
    }
}

// MARK: - CollectionViewType DiaryDetail

extension DiaryDetailViewController {
    private func findCurrentPageIndex() -> Int? {
        guard let currentDiaryPage: Int = listener?.currentDiaryPage else { return nil }

        guard let diaryModelArr: [DiaryModelRealm] = listener?.diaryModelArrRelay.value else { return nil }

        guard let currentIndex: Int = diaryModelArr
            .enumerated()
            .filter ({ $0.element.pageNum == currentDiaryPage })
            .first?
            .offset
        else { return nil }

        print("currentIndex = \(currentIndex)")
        return currentIndex
    }

    internal func setCurrentPageDiary() {
        print("DiaryDetail :: setCurrentPageDiary")
        guard let currentPageIndex: Int = findCurrentPageIndex() else { return }
        if !isFirstCurrentPage { return }

        let destinationIndexPath: IndexPath = .init(item: currentPageIndex, section: 0)

        // 해당 페이지까지 애니메이션 없는 스크롤 처리
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: destinationIndexPath, at: .centeredHorizontally, animated: false)
        collectionView.isPagingEnabled = true
        isFirstCurrentPage = false

        // 노티피케이션 등록을 위한 index aceept
        listener?.currentDiaryModelIndexRelay.accept(currentPageIndex)
    }
}

// MARK: - UploadImageViewDelegate, DiaryDetailCellDelegate

extension DiaryDetailViewController: ImageUploadViewDelegate, DiaryDetailCellDelegate {
    var uploadImagesRelay: RxRelay.BehaviorRelay<[Data]>? {
        listener?.uploadImagesRelay
    }

    var thumbImageIndexRelay: BehaviorRelay<Int>? {
        return nil
    }

    func pressedDetailImage(index: Int, uuid: String) {
        listener?.pressedImageView(index: index)
    }

    func didScroll() {
        view.endEditing(true)
    }
}

// MARK: - ScrollViewDelegate

extension DiaryDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != collectionView { return }

        // 현재 화면에서 보이는 셀의 IndexPath를 가져옵니다.
        let visibleCells: [IndexPath] = collectionView.indexPathsForVisibleItems
        if visibleCells.isEmpty { return }

        let cellWidth: CGFloat = scrollView.frame.size.width
        let currentIdx = Int((scrollView.contentOffset.x + cellWidth / 2) / cellWidth)
        print("DiaryDetail :: currentPage = \(currentIdx)")

        guard let currentDiaryModel: DiaryModelRealm = listener?.diaryModelArrRelay.value[safe: currentIdx] else { return }

        // 이전과 같은 index를 가지고 있다면 2번 refresh할 필요 없음
        if let beforeIdx: Int = listener?.currentDiaryModelIndexRelay.value {
            if beforeIdx == currentIdx { return }
        }

        listener?.currentDiaryModelRelay.accept(currentDiaryModel)
        listener?.currentDiaryModelIndexRelay.accept(currentIdx)
        print("DiaryDetail :: uuid = \(currentDiaryModel.uuid), \(currentDiaryModel.title)")
    }
}
