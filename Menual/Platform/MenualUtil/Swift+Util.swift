//
//  Swift+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import Foundation
import RealmSwift
import Realm

// safe array index 탐색
public extension Array {
    public subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

extension Realm {
    static func safeInit() -> Realm? {
        // let keyString: String = "Menual"
        // let key = keyString.data(using: .utf8)!
        
        let testKeychain = "111"
        
        
        let key = NSMutableData(length: 64)!
        
        let data2 = "메뉴얼프로젝트의비밀번호는무엇임".toBase64().data(using: .utf8)
        let data22 = data2?.base64EncodedString().fromBase64()
        let data33 = data2?.hexEncodedString()
        // let data = String("Menual").toBase64()
        print("JJIKKYU :: realm Key = \(key), data2 = \(data2), data22 = \(data22), data33 = \(data33)")

        // let encryptionConfig = Realm.Configuration(encryptionKey: data2!)

        do {
            // let realm = try Realm(configuration: encryptionConfig)
            let realm = try Realm()
            return realm
        }
        catch {
            // LOG ERROR
        }
        return nil
    }

    func safeWrite(_ block: () -> ()) {
        do {
            // Async safety, to prevent "Realm already in a write transaction" Exceptions
            if !isInWriteTransaction {
                try write(block)
            }
        } catch {
            // LOG ERROR
        }
    }
}

extension UIApplication {
    static var topSafeAreaHeight: CGFloat {
        var topSafeAreaHeight: CGFloat = 0
         if #available(iOS 11.0, *) {
               let window = UIApplication.shared.windows[0]
               let safeFrame = window.safeAreaLayoutGuide.layoutFrame
               topSafeAreaHeight = safeFrame.minY
             }
        return topSafeAreaHeight
    }
}

extension UIView {
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}

extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
}

// MARK: - UITextView extension
extension UITextView {

    func centerVerticalText() {
        self.textAlignment = .left
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
