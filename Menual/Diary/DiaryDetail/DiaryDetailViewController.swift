//
//  DiaryDetailViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol DiaryDetailPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
    func pressedReplySubmitBtn(desc: String)
    func pressedIndicatorButton(offset: Int)
    
    var diaryReplies: [DiaryReplyModel] { get }
    var currentDiaryPage: Int { get }
}

final class DiaryDetailViewController: UIViewController, DiaryDetailPresentable, DiaryDetailViewControllable {

    weak var listener: DiaryDetailPresentableListener?
    
    private let tableViewHeaderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    lazy var tableViewFooterView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blue
        $0.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
    }
    
    private let tempTextField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
    }
    
    lazy var tempSubmitBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(tempPressedSubmitReplyBtn), for: .touchUpInside)
        $0.setTitle("올리기", for: .normal)
    }
    
    lazy var tempLeftButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("<", for: .normal)
        $0.tag = -1
        $0.addTarget(self, action: #selector(tempPressedIndicatorButton(sender:)), for: .touchUpInside)
        $0.backgroundColor = .blue
    }
    
    lazy var tempRightButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle(">", for: .normal)
        $0.tag = 1
        $0.addTarget(self, action: #selector(tempPressedIndicatorButton(sender:)), for: .touchUpInside)
        $0.backgroundColor = .blue
    }
    
    lazy var naviView = MenualNaviView(type: .menualDetail).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rightButton1.setImage(Asset._24px.profile.image.withRenderingMode(.alwaysTemplate), for: .normal)
        // $0.rightButton1.addTarget(self, action: #selector(pressedMyPageBtn), for: .touchUpInside)
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    lazy var leftBarButtonItem = UIBarButtonItem().then {
        $0.image = Asset._24px.Arrow.back.image
        $0.style = .done
        $0.target = self
        $0.action = #selector(pressedBackBtn)
    }
    
    lazy var scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.background
        $0.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_5)
        $0.textColor = Colors.tint.main.v200
        $0.text = "텍스트입ㄴ다"
    }
    
    let createdAtLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = .white
        $0.text = "안녕하세요 만든 날짜입니다"
    }
    
    let testLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.tint.main.v200
        $0.text = "텍스트입ㄴ다"
    }
    
    lazy var descriptionTextLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = .white
        $0.text = "오늘의 메뉴얼을 입력해주세요.\n날짜가 적힌 곳을 탭하여 제목을 입력할 수 있습니다."
        $0.backgroundColor = .gray
        $0.numberOfLines = 0
    }
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.backgroundColor = .gray
    }
    
    let readCountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.textColor = .white
        $0.backgroundColor = .gray
        $0.numberOfLines = 1
        $0.textAlignment = .right
        $0.text = "0번 읽었슴다"
    }
    
    lazy var replyTableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 72, right: 0)
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.estimatedRowHeight = 72
        $0.rowHeight = 72
        $0.showsVerticalScrollIndicator = false
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
        view.backgroundColor = .gray
        setViews()

        // keyboard observer등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
        
        // Keyboard observer해제
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.view.addSubview(replyTableView)
        replyTableView.tableHeaderView = tableViewHeaderView
        replyTableView.tableFooterView = tableViewFooterView
        
        // temp
        self.view.addSubview(tempTextField)
        self.view.addSubview(tempSubmitBtn)
        self.view.addSubview(tempLeftButton)
        self.view.addSubview(tempRightButton)
        
//        self.view.addSubview(scrollView)
        self.view.addSubview(naviView)
        replyTableView.addSubview(titleLabel)
        replyTableView.addSubview(testLabel)
        replyTableView.addSubview(descriptionTextLabel)
        replyTableView.addSubview(createdAtLabel)
        replyTableView.addSubview(imageView)
        replyTableView.addSubview(readCountLabel)
        self.view.bringSubviewToFront(naviView)
        
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
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(390)
        }
        
        self.view.layoutIfNeeded()
        tableViewHeaderView.backgroundColor = .black
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        testLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(createdAtLabel.snp.bottom).offset(15)
        }
        
        descriptionTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(testLabel.snp.bottom).offset(40)
        }
        
        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        readCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalTo(descriptionTextLabel.snp.bottom).offset(20)
            make.height.equalTo(70)
        }
        
        //temp
        tempTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.bottom.equalTo(replyTableView.snp.bottom).inset(20)
            make.height.equalTo(50)
        }
        
        tempSubmitBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.bottom.equalTo(replyTableView.snp.bottom).inset(20)
        }
        
        tempLeftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.bottom.equalTo(tempSubmitBtn.snp.top).inset(20)
        }
        
        tempRightButton.snp.makeConstraints { make in
            make.leading.equalTo(tempLeftButton.snp.trailing).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.bottom.equalTo(tempSubmitBtn.snp.top).inset(20)
        }
    }
    
    func loadDiaryDetail(model: DiaryModel) {
        print("viewcontroller : \(model)")
        self.titleLabel.text = model.title
        self.testLabel.text = "\(model.weather?.weather?.rawValue), \(model.place?.place?.rawValue)"
        self.descriptionTextLabel.text = model.description
        self.descriptionTextLabel.setLineHeight()
        self.readCountLabel.text = "\(model.readCount)번 읽었습니다"
        self.createdAtLabel.text = model.createdAt.toStringWithHourMin() + " | " + "p.\(model.pageNum)"
        descriptionTextLabel.sizeToFit()
        createdAtLabel.sizeToFit()
    }
    
    func testLoadDiaryImage(imageName: UIImage?) {
        if let imageName = imageName {
            DispatchQueue.main.async {
                self.imageView.image = imageName
            }
        }
    }
    
    func reloadTableView() {
        print("diaryDetailViewController reloadTableView!")
        self.replyTableView.reloadData()
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func tempPressedSubmitReplyBtn() {
        print("pressedSubmitReplyBtn")
        guard let text = tempTextField.text else { return }
        listener?.pressedReplySubmitBtn(desc: text)
    }
    
    @objc
    func tempPressedIndicatorButton(sender: UIButton) {
        print("sender.s tag = \(sender.tag)")
        listener?.pressedIndicatorButton(offset: sender.tag)
    }
}

// MARK: - ReplayTableView
extension DiaryDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.diaryReplies.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }
        
        let index = indexPath.row
        
        guard let replies = listener?.diaryReplies,
              let desc = replies[safe: index]?.desc,
              let createdAt = replies[safe: index]?.createdAt,
              let replyNum = replies[safe: index]?.replyNum else { return UITableViewCell() }

        cell.backgroundColor = .clear
        cell.title = desc
        
        if let currentDiaryPage = listener?.currentDiaryPage {
            cell.pageAndReview = "p.\(currentDiaryPage)-" + String(replyNum)
        }
        
        cell.dateAndTime = createdAt.toStringWithHourMin()

        return cell
    }
}

// MARK: - Keyboard Extension
extension DiaryDetailViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        print("keyboardWillShow! - \(keyboardHeight)")
        replyTableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(keyboardHeight)
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        print("keyboardWillHide!")
        replyTableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
}
