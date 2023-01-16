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
  internal enum _120px {
    internal enum Book {
      internal static let close = ImageAsset(name: "120px/book/close")
      internal static let `open` = ImageAsset(name: "120px/book/open")
    }
    internal enum Calender {
      internal static let table = ImageAsset(name: "120px/calender/table")
      internal static let wall = ImageAsset(name: "120px/calender/wall")
    }
    internal enum Clip {
      internal static let bulldog = ImageAsset(name: "120px/clip/bulldog")
      internal static let double = ImageAsset(name: "120px/clip/double")
    }
    internal enum Clock {
      internal static let angled = ImageAsset(name: "120px/clock/angled")
      internal static let round = ImageAsset(name: "120px/clock/round")
    }
    internal enum Coffee {
      internal static let glasscup = ImageAsset(name: "120px/coffee/glasscup")
      internal static let papercup = ImageAsset(name: "120px/coffee/papercup")
    }
    internal static let diary = ImageAsset(name: "120px/diary")
    internal static let drawer = ImageAsset(name: "120px/drawer")
    internal enum Flower {
      internal static let type1 = ImageAsset(name: "120px/flower/type1")
      internal static let type2 = ImageAsset(name: "120px/flower/type2")
    }
    internal enum Lamp {
      internal static let angled = ImageAsset(name: "120px/lamp/angled")
      internal static let round = ImageAsset(name: "120px/lamp/round")
    }
    internal static let mirror = ImageAsset(name: "120px/mirror")
    internal static let paper = ImageAsset(name: "120px/paper")
    internal static let stand = ImageAsset(name: "120px/stand")
    internal enum Stationery {
      internal enum Pen {
        internal static let type1 = ImageAsset(name: "120px/stationery/pen/type1")
        internal static let type2 = ImageAsset(name: "120px/stationery/pen/type2")
      }
      internal enum Pin {
        internal static let type1 = ImageAsset(name: "120px/stationery/pin/type1")
        internal static let type2 = ImageAsset(name: "120px/stationery/pin/type2")
      }
    }
    internal static let stopwatch = ImageAsset(name: "120px/stopwatch")
    internal static let tea = ImageAsset(name: "120px/tea")
  }
  internal enum _16px {
    internal static let add = ImageAsset(name: "16px/add")
    internal static let album = ImageAsset(name: "16px/album")
    internal enum Alert {
      internal static let active = ImageAsset(name: "16px/alert/active")
    }
    internal static let alert = ImageAsset(name: "16px/alert")
    internal enum Arrow {
      internal static let back = ImageAsset(name: "16px/arrow/back")
      internal enum Down {
        internal static let big = ImageAsset(name: "16px/arrow/down/big")
        internal static let small = ImageAsset(name: "16px/arrow/down/small")
      }
      internal static let front = ImageAsset(name: "16px/arrow/front")
      internal static let `left` = ImageAsset(name: "16px/arrow/left")
      internal static let `right` = ImageAsset(name: "16px/arrow/right")
      internal enum Up {
        internal static let big = ImageAsset(name: "16px/arrow/up/big")
        internal static let small = ImageAsset(name: "16px/arrow/up/small")
      }
    }
    internal static let bookmark = ImageAsset(name: "16px/bookmark")
    internal static let calendar = ImageAsset(name: "16px/calendar")
    internal static let camera = ImageAsset(name: "16px/camera")
    internal static let check = ImageAsset(name: "16px/check")
    internal enum Circle {
      internal static let back = ImageAsset(name: "16px/circle/back")
      internal enum Check {
        internal static let active = ImageAsset(name: "16px/circle/check/active")
        internal static let unactive = ImageAsset(name: "16px/circle/check/unactive")
      }
      internal static let close = ImageAsset(name: "16px/circle/close")
      internal static let front = ImageAsset(name: "16px/circle/front")
    }
    internal static let close = ImageAsset(name: "16px/close")
    internal static let delete = ImageAsset(name: "16px/delete")
    internal static let download = ImageAsset(name: "16px/download")
    internal static let erase = ImageAsset(name: "16px/erase")
    internal static let exclamation = ImageAsset(name: "16px/exclamation")
    internal static let filter = ImageAsset(name: "16px/filter")
    internal static let full = ImageAsset(name: "16px/full")
    internal static let highlight = ImageAsset(name: "16px/highlight")
    internal static let information = ImageAsset(name: "16px/information")
    internal static let keyboard = ImageAsset(name: "16px/keyboard")
    internal static let lock = ImageAsset(name: "16px/lock")
    internal static let modify = ImageAsset(name: "16px/modify")
    internal static let more = ImageAsset(name: "16px/more")
    internal static let picture = ImageAsset(name: "16px/picture")
    internal enum Place {
      internal static let bus = ImageAsset(name: "16px/place/Bus")
      internal static let car = ImageAsset(name: "16px/place/Car")
      internal static let company = ImageAsset(name: "16px/place/Company")
      internal static let home = ImageAsset(name: "16px/place/Home")
      internal static let luggage = ImageAsset(name: "16px/place/Luggage")
      internal static let school = ImageAsset(name: "16px/place/School")
      internal static let store = ImageAsset(name: "16px/place/Store")
      internal static let subway = ImageAsset(name: "16px/place/Subway")
    }
    internal static let place = ImageAsset(name: "16px/place")
    internal static let profile = ImageAsset(name: "16px/profile")
    internal static let question = ImageAsset(name: "16px/question")
    internal enum Radio {
      internal static let active = ImageAsset(name: "16px/radio/active")
      internal static let unactive = ImageAsset(name: "16px/radio/unactive")
    }
    internal static let read = ImageAsset(name: "16px/read")
    internal static let recomment = ImageAsset(name: "16px/recomment")
    internal static let rewrite = ImageAsset(name: "16px/rewrite")
    internal static let search = ImageAsset(name: "16px/search")
    internal static let setting = ImageAsset(name: "16px/setting")
    internal static let share = ImageAsset(name: "16px/share")
    internal static let storage = ImageAsset(name: "16px/storage")
    internal static let symbol = ImageAsset(name: "16px/symbol")
    internal static let time = ImageAsset(name: "16px/time")
    internal static let unlock = ImageAsset(name: "16px/unlock")
    internal enum View {
      internal static let active = ImageAsset(name: "16px/view/active")
      internal static let unactive = ImageAsset(name: "16px/view/unactive")
    }
    internal enum Weather {
      internal static let cloud = ImageAsset(name: "16px/weather/cloud")
      internal static let rain = ImageAsset(name: "16px/weather/rain")
      internal static let snow = ImageAsset(name: "16px/weather/snow")
      internal static let sun = ImageAsset(name: "16px/weather/sun")
      internal static let thunder = ImageAsset(name: "16px/weather/thunder")
      internal static let wind = ImageAsset(name: "16px/weather/wind")
    }
    internal static let weather = ImageAsset(name: "16px/weather")
    internal static let word = ImageAsset(name: "16px/word")
    internal static let write = ImageAsset(name: "16px/write")
  }
  internal enum _20px {
    internal static let add = ImageAsset(name: "20px/add")
    internal static let album = ImageAsset(name: "20px/album")
    internal enum Alert {
      internal static let active = ImageAsset(name: "20px/alert/active")
      internal static let unactive = ImageAsset(name: "20px/alert/unactive")
    }
    internal enum Arrow {
      internal static let back = ImageAsset(name: "20px/arrow/back")
      internal enum Down {
        internal static let big = ImageAsset(name: "20px/arrow/down/big")
        internal static let small = ImageAsset(name: "20px/arrow/down/small")
      }
      internal static let front = ImageAsset(name: "20px/arrow/front")
      internal static let `left` = ImageAsset(name: "20px/arrow/left")
      internal static let `right` = ImageAsset(name: "20px/arrow/right")
      internal enum Up {
        internal static let big = ImageAsset(name: "20px/arrow/up/big")
        internal static let small = ImageAsset(name: "20px/arrow/up/small")
      }
    }
    internal static let bookmark = ImageAsset(name: "20px/bookmark")
    internal static let calendar = ImageAsset(name: "20px/calendar")
    internal static let camera = ImageAsset(name: "20px/camera")
    internal static let check = ImageAsset(name: "20px/check")
    internal enum Circle {
      internal static let back = ImageAsset(name: "20px/circle/back")
      internal enum Check {
        internal static let active = ImageAsset(name: "20px/circle/active")
        internal static let unactive = ImageAsset(name: "20px/circle/unactive")
      }
      internal static let close = ImageAsset(name: "20px/circle/close")
      internal static let front = ImageAsset(name: "20px/circle/front")
    }
    internal static let close = ImageAsset(name: "20px/close")
    internal static let delete = ImageAsset(name: "20px/delete")
    internal static let download = ImageAsset(name: "20px/download")
    internal static let erase = ImageAsset(name: "20px/erase")
    internal static let exclamation = ImageAsset(name: "20px/exclamation")
    internal static let filter = ImageAsset(name: "20px/filter")
    internal static let full = ImageAsset(name: "20px/full")
    internal static let highlight = ImageAsset(name: "20px/highlight")
    internal static let information = ImageAsset(name: "20px/information")
    internal static let keyboard = ImageAsset(name: "20px/keyboard")
    internal static let lock = ImageAsset(name: "20px/lock")
    internal static let modify = ImageAsset(name: "20px/modify")
    internal static let more = ImageAsset(name: "20px/more")
    internal static let picture = ImageAsset(name: "20px/picture")
    internal enum Place {
      internal static let bus = ImageAsset(name: "20px/place/Bus")
      internal static let car = ImageAsset(name: "20px/place/Car")
      internal static let company = ImageAsset(name: "20px/place/Company")
      internal static let home = ImageAsset(name: "20px/place/Home")
      internal static let luggage = ImageAsset(name: "20px/place/Luggage")
      internal static let school = ImageAsset(name: "20px/place/School")
      internal static let store = ImageAsset(name: "20px/place/Store")
      internal static let subway = ImageAsset(name: "20px/place/Subway")
    }
    internal static let place = ImageAsset(name: "20px/place")
    internal static let profile = ImageAsset(name: "20px/profile")
    internal static let question = ImageAsset(name: "20px/question")
    internal enum Radio {
      internal static let active = ImageAsset(name: "20px/radio/active")
      internal static let unactive = ImageAsset(name: "20px/radio/unactive")
    }
    internal static let read = ImageAsset(name: "20px/read")
    internal static let recomment = ImageAsset(name: "20px/recomment")
    internal static let rewrite = ImageAsset(name: "20px/rewrite")
    internal static let search = ImageAsset(name: "20px/search")
    internal static let setting = ImageAsset(name: "20px/setting")
    internal static let share = ImageAsset(name: "20px/share")
    internal static let storage = ImageAsset(name: "20px/storage")
    internal static let symbol = ImageAsset(name: "20px/symbol")
    internal static let time = ImageAsset(name: "20px/time")
    internal static let unlock = ImageAsset(name: "20px/unlock")
    internal enum View {
      internal static let active = ImageAsset(name: "20px/view/active")
      internal static let unactive = ImageAsset(name: "20px/view/unactive")
    }
    internal enum Weather {
      internal static let cloud = ImageAsset(name: "20px/weather/cloud")
      internal static let rain = ImageAsset(name: "20px/weather/rain")
      internal static let snow = ImageAsset(name: "20px/weather/snow")
      internal static let sun = ImageAsset(name: "20px/weather/sun")
      internal static let thunder = ImageAsset(name: "20px/weather/thunder")
      internal static let wind = ImageAsset(name: "20px/weather/wind")
    }
    internal static let weather = ImageAsset(name: "20px/weather")
    internal static let word = ImageAsset(name: "20px/word")
    internal static let write = ImageAsset(name: "20px/write")
  }
  internal enum _24px {
    internal static let add = ImageAsset(name: "24px/add")
    internal static let album = ImageAsset(name: "24px/album")
    internal enum Alert {
      internal static let active = ImageAsset(name: "24px/alert/active")
      internal static let unactive = ImageAsset(name: "24px/alert/unactive")
    }
    internal enum Arrow {
      internal static let back = ImageAsset(name: "24px/arrow/back")
      internal enum Down {
        internal static let big = ImageAsset(name: "24px/arrow/down/big")
        internal static let small = ImageAsset(name: "24px/arrow/down/small")
      }
      internal static let front = ImageAsset(name: "24px/arrow/front")
      internal static let `left` = ImageAsset(name: "24px/arrow/left")
      internal static let `right` = ImageAsset(name: "24px/arrow/right")
      internal enum Up {
        internal static let big = ImageAsset(name: "24px/arrow/up/big")
        internal static let small = ImageAsset(name: "24px/arrow/up/small")
      }
    }
    internal static let bookmark = ImageAsset(name: "24px/bookmark")
    internal static let calendar = ImageAsset(name: "24px/calendar")
    internal static let camera = ImageAsset(name: "24px/camera")
    internal static let check = ImageAsset(name: "24px/check")
    internal enum Circle {
      internal static let back = ImageAsset(name: "24px/circle/back")
      internal enum Check {
        internal static let active = ImageAsset(name: "24px/circle/check/active")
        internal static let unactive = ImageAsset(name: "24px/circle/check/unactive")
      }
      internal static let close = ImageAsset(name: "24px/circle/close")
      internal static let front = ImageAsset(name: "24px/circle/front")
    }
    internal static let close = ImageAsset(name: "24px/close")
    internal static let delete = ImageAsset(name: "24px/delete")
    internal static let download = ImageAsset(name: "24px/download")
    internal static let erase = ImageAsset(name: "24px/erase")
    internal static let exclamation = ImageAsset(name: "24px/exclamation")
    internal static let filter = ImageAsset(name: "24px/filter")
    internal static let full = ImageAsset(name: "24px/full")
    internal static let highlight = ImageAsset(name: "24px/highlight")
    internal static let information = ImageAsset(name: "24px/information")
    internal static let keyboard = ImageAsset(name: "24px/keyboard")
    internal static let lock = ImageAsset(name: "24px/lock")
    internal static let modify = ImageAsset(name: "24px/modify")
    internal static let more = ImageAsset(name: "24px/more")
    internal static let picture = ImageAsset(name: "24px/picture")
    internal enum Place {
      internal static let bus = ImageAsset(name: "24px/place/Bus")
      internal static let car = ImageAsset(name: "24px/place/Car")
      internal static let company = ImageAsset(name: "24px/place/Company")
      internal static let home = ImageAsset(name: "24px/place/Home")
      internal static let luggage = ImageAsset(name: "24px/place/Luggage")
      internal static let school = ImageAsset(name: "24px/place/School")
      internal static let store = ImageAsset(name: "24px/place/Store")
      internal static let subway = ImageAsset(name: "24px/place/Subway")
    }
    internal static let place = ImageAsset(name: "24px/place")
    internal static let profile = ImageAsset(name: "24px/profile")
    internal static let question = ImageAsset(name: "24px/question")
    internal enum Radio {
      internal static let active = ImageAsset(name: "24px/radio/active")
      internal static let unactive = ImageAsset(name: "24px/radio/unactive")
    }
    internal static let read = ImageAsset(name: "24px/read")
    internal static let recomment = ImageAsset(name: "24px/recomment")
    internal static let rewrite = ImageAsset(name: "24px/rewrite")
    internal static let search = ImageAsset(name: "24px/search")
    internal static let setting = ImageAsset(name: "24px/setting")
    internal static let share = ImageAsset(name: "24px/share")
    internal static let storage = ImageAsset(name: "24px/storage")
    internal static let symbol = ImageAsset(name: "24px/symbol")
    internal static let time = ImageAsset(name: "24px/time")
    internal static let unlock = ImageAsset(name: "24px/unlock")
    internal enum View {
      internal static let active = ImageAsset(name: "24px/view/active")
      internal static let unactive = ImageAsset(name: "24px/view/unactive")
    }
    internal enum Weather {
      internal static let cloud = ImageAsset(name: "24px/weather/cloud")
      internal static let rain = ImageAsset(name: "24px/weather/rain")
      internal static let snow = ImageAsset(name: "24px/weather/snow")
      internal static let sun = ImageAsset(name: "24px/weather/sun")
      internal static let thunder = ImageAsset(name: "24px/weather/thunder")
      internal static let wind = ImageAsset(name: "24px/weather/wind")
    }
    internal static let weather = ImageAsset(name: "24px/weather")
    internal static let word = ImageAsset(name: "24px/word")
    internal static let write = ImageAsset(name: "24px/write")
  }
  internal enum _40px {
    internal enum Book {
      internal static let close = ImageAsset(name: "40px/book/close")
      internal static let `open` = ImageAsset(name: "40px/book/open")
    }
    internal enum Calender {
      internal static let table = ImageAsset(name: "40px/calender/table")
      internal static let wall = ImageAsset(name: "40px/calender/wall")
    }
    internal enum Clip {
      internal static let bulldog = ImageAsset(name: "40px/clip/bulldog")
      internal static let double = ImageAsset(name: "40px/clip/double")
    }
    internal enum Clock {
      internal static let angled = ImageAsset(name: "40px/clock/angled")
      internal static let round = ImageAsset(name: "40px/clock/round")
    }
    internal enum Coffee {
      internal static let glasscup = ImageAsset(name: "40px/coffee/glasscup")
      internal static let papercup = ImageAsset(name: "40px/coffee/papercup")
    }
    internal static let diary = ImageAsset(name: "40px/diary")
    internal static let drawer = ImageAsset(name: "40px/drawer")
    internal enum Flower {
      internal static let type1 = ImageAsset(name: "40px/flower/type1")
      internal static let type2 = ImageAsset(name: "40px/flower/type2")
    }
    internal enum Lamp {
      internal static let angled = ImageAsset(name: "40px/lamp/angled")
      internal static let round = ImageAsset(name: "40px/lamp/round")
    }
    internal static let mirror = ImageAsset(name: "40px/mirror")
    internal static let paper = ImageAsset(name: "40px/paper")
    internal static let stand = ImageAsset(name: "40px/stand")
    internal enum Stationery {
      internal enum Pen {
        internal static let type1 = ImageAsset(name: "40px/stationery/pen/type1")
        internal static let type2 = ImageAsset(name: "40px/stationery/pen/type2")
      }
      internal enum Pin {
        internal static let type1 = ImageAsset(name: "40px/stationery/pin/type1")
        internal static let type2 = ImageAsset(name: "40px/stationery/pin/type2")
      }
    }
    internal static let stopwatch = ImageAsset(name: "40px/stopwatch")
    internal static let tea = ImageAsset(name: "40px/tea")
  }
  internal enum _80px {
    internal enum Book {
      internal static let close = ImageAsset(name: "80px/book/close")
      internal static let `open` = ImageAsset(name: "80px/book/open")
    }
    internal enum Calender {
      internal static let table = ImageAsset(name: "80px/calender/table")
      internal static let wall = ImageAsset(name: "80px/calender/wall")
    }
    internal enum Clip {
      internal static let bulldog = ImageAsset(name: "80px/clip/bulldog")
      internal static let double = ImageAsset(name: "80px/clip/double")
    }
    internal enum Clock {
      internal static let angled = ImageAsset(name: "80px/clock/angled")
      internal static let round = ImageAsset(name: "80px/clock/round")
    }
    internal enum Coffee {
      internal static let glasscup = ImageAsset(name: "80px/coffee/glasscup")
      internal static let papercup = ImageAsset(name: "80px/coffee/papercup")
    }
    internal static let diary = ImageAsset(name: "80px/diary")
    internal static let drawer = ImageAsset(name: "80px/drawer")
    internal enum Flower {
      internal static let type1 = ImageAsset(name: "80px/flower/type1")
      internal static let type2 = ImageAsset(name: "80px/flower/type2")
    }
    internal enum Lamp {
      internal static let angled = ImageAsset(name: "80px/lamp/angled")
      internal static let round = ImageAsset(name: "80px/lamp/round")
    }
    internal static let mirror = ImageAsset(name: "80px/mirror")
    internal static let paper = ImageAsset(name: "80px/paper")
    internal static let stand = ImageAsset(name: "80px/stand")
    internal enum Stationery {
      internal enum Pen {
        internal static let type1 = ImageAsset(name: "80px/stationery/pen/type1")
        internal static let type2 = ImageAsset(name: "80px/stationery/pen/type2")
      }
      internal enum Pin {
        internal static let type1 = ImageAsset(name: "80px/stationery/pin/type1")
        internal static let type2 = ImageAsset(name: "80px/stationery/pin/type2")
      }
    }
    internal static let stopwatch = ImageAsset(name: "80px/stopwatch")
    internal static let tea = ImageAsset(name: "80px/tea")
  }
  internal enum Illurstration {
    internal static let emtpySpace = ImageAsset(name: "Illurstration/emtpy_space")
    internal static let networkError = ImageAsset(name: "Illurstration/network_error")
    internal static let pageError = ImageAsset(name: "Illurstration/page_error")
    internal static let serviceCheck = ImageAsset(name: "Illurstration/service_check")
    internal static let viewLock = ImageAsset(name: "Illurstration/view_lock")
  }
  internal enum Pagination {
    internal static let paginationSelected = ImageAsset(name: "Pagination/paginationSelected")
    internal static let paginationUnselected = ImageAsset(name: "Pagination/paginationUnselected")
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
public final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle(for: BundleToken.self)
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
