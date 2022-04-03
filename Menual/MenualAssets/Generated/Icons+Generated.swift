// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum IllustrationIcons {
    internal static let emtpySpace = ImageAsset(name: "emtpy_space")
    internal static let networkError = ImageAsset(name: "network_error")
    internal static let pageError = ImageAsset(name: "page_error")
    internal static let serviceCheck = ImageAsset(name: "service_check")
  }
  internal enum ObjectIcons {
    internal enum Book {
      internal static let close = ImageAsset(name: "close")
      internal static let `open` = ImageAsset(name: "open")
    }
    internal enum Calender {
      internal static let table = ImageAsset(name: "table")
      internal static let wall = ImageAsset(name: "wall")
    }
    internal enum Clip {
      internal static let bulldog = ImageAsset(name: "bulldog")
      internal static let double = ImageAsset(name: "double")
    }
    internal enum Clock {
      internal static let angled = ImageAsset(name: "angled")
      internal static let round = ImageAsset(name: "round")
    }
    internal enum Coffee {
      internal static let glasscup = ImageAsset(name: "glasscup")
      internal static let papercup = ImageAsset(name: "papercup")
    }
    internal static let diary = ImageAsset(name: "diary")
    internal static let drawer = ImageAsset(name: "drawer")
    internal enum Flower {
      internal static let type1 = ImageAsset(name: "type1")
      internal static let type2 = ImageAsset(name: "type2")
    }
    internal enum Lamp {
      internal static let angled = ImageAsset(name: "angled")
      internal static let round = ImageAsset(name: "round")
    }
    internal static let mirror = ImageAsset(name: "mirror")
    internal static let paper = ImageAsset(name: "paper")
    internal static let stand = ImageAsset(name: "stand")
    internal enum Stationery {
      internal enum Pen {
        internal static let _1 = ImageAsset(name: "1")
        internal static let _2 = ImageAsset(name: "2")
      }
      internal enum Pin {
        internal static let _1 = ImageAsset(name: "1")
        internal static let _2 = ImageAsset(name: "2")
      }
    }
    internal static let stopwatch = ImageAsset(name: "stopwatch")
    internal static let tea = ImageAsset(name: "tea")
  }
  internal enum StandardIcons {
    internal static let add = ImageAsset(name: "add")
    internal static let album = ImageAsset(name: "album")
    internal static let alert = ImageAsset(name: "alert")
    internal enum Arrow {
      internal static let back = ImageAsset(name: "back")
      internal enum Down {
        internal static let big = ImageAsset(name: "big")
        internal static let small = ImageAsset(name: "small")
      }
      internal static let front = ImageAsset(name: "front")
      internal static let `left` = ImageAsset(name: "left")
      internal static let `right` = ImageAsset(name: "right")
      internal enum Up {
        internal static let big = ImageAsset(name: "big")
        internal static let small = ImageAsset(name: "small")
      }
    }
    internal static let bookmark = ImageAsset(name: "bookmark")
    internal static let calendar = ImageAsset(name: "calendar")
    internal static let camera = ImageAsset(name: "camera")
    internal static let check = ImageAsset(name: "check")
    internal enum Circle {
      internal static let back = ImageAsset(name: "back")
      internal enum Check {
        internal static let active = ImageAsset(name: "active")
        internal static let unactive = ImageAsset(name: "unactive")
      }
      internal static let close = ImageAsset(name: "close")
      internal static let front = ImageAsset(name: "front")
    }
    internal static let close = ImageAsset(name: "close")
    internal static let delete = ImageAsset(name: "delete")
    internal static let download = ImageAsset(name: "download")
    internal static let erase = ImageAsset(name: "erase")
    internal static let exclamation = ImageAsset(name: "exclamation")
    internal static let filter = ImageAsset(name: "filter")
    internal static let highlight = ImageAsset(name: "highlight")
    internal static let information = ImageAsset(name: "information")
    internal static let keyboard = ImageAsset(name: "keyboard")
    internal static let lock = ImageAsset(name: "lock")
    internal static let modify = ImageAsset(name: "modify")
    internal static let more = ImageAsset(name: "more")
    internal static let picture = ImageAsset(name: "picture")
    internal enum Place {
      internal static let bus = ImageAsset(name: "Bus")
      internal static let car = ImageAsset(name: "Car")
      internal static let company = ImageAsset(name: "Company")
      internal static let home = ImageAsset(name: "Home")
      internal static let luggage = ImageAsset(name: "Luggage")
      internal static let school = ImageAsset(name: "School")
      internal static let store = ImageAsset(name: "Store")
      internal static let subway = ImageAsset(name: "Subway")
    }
    internal static let place = ImageAsset(name: "place")
    internal static let profile = ImageAsset(name: "profile")
    internal static let question = ImageAsset(name: "question")
    internal enum Radio {
      internal static let active = ImageAsset(name: "active")
      internal static let unactive = ImageAsset(name: "unactive")
    }
    internal static let read = ImageAsset(name: "read")
    internal static let recomment = ImageAsset(name: "recomment")
    internal static let search = ImageAsset(name: "search")
    internal static let setting = ImageAsset(name: "setting")
    internal static let share = ImageAsset(name: "share")
    internal static let storage = ImageAsset(name: "storage")
    internal static let time = ImageAsset(name: "time")
    internal static let unlock = ImageAsset(name: "unlock")
    internal enum View {
      internal static let active = ImageAsset(name: "active")
      internal static let unactive = ImageAsset(name: "unactive")
    }
    internal enum Weather {
      internal static let cloud = ImageAsset(name: "cloud")
      internal static let rain = ImageAsset(name: "rain")
      internal static let snow = ImageAsset(name: "snow")
      internal static let sun = ImageAsset(name: "sun")
      internal static let thunder = ImageAsset(name: "thunder")
      internal static let wind = ImageAsset(name: "wind")
    }
    internal static let write = ImageAsset(name: "write")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
