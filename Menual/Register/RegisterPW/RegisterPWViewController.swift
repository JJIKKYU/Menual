//
//  RegisterPWViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs
import RxSwift
import UIKit

protocol RegisterPWPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class RegisterPWViewController: UIViewController, RegisterPWPresentable, RegisterPWViewControllable {

    weak var listener: RegisterPWPresentableListener?
}
