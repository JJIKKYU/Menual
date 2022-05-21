//
//  DesignSystemViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift
import UIKit

protocol DesignSystemPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
}

final class DesignSystemViewController: UIViewController, DesignSystemPresentable, DesignSystemViewControllable {

    weak var listener: DesignSystemPresentableListener?
}
