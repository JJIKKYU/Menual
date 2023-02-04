//
//  ProfileRestoreViewController.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import UIKit

protocol ProfileRestorePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class ProfileRestoreViewController: UIViewController, ProfileRestorePresentable, ProfileRestoreViewControllable {

    weak var listener: ProfileRestorePresentableListener?
}
