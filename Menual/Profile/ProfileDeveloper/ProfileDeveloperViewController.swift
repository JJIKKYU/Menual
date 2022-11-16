//
//  ProfileDeveloperViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import RxSwift
import UIKit

protocol ProfileDeveloperPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class ProfileDeveloperViewController: UIViewController, ProfileDeveloperPresentable, ProfileDeveloperViewControllable {

    weak var listener: ProfileDeveloperPresentableListener?
}
