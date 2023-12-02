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
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum _120px {
    public enum Book {
      public static let close = ImageAsset(name: "120px/book/close")
      public static let `open` = ImageAsset(name: "120px/book/open")
    }
    public enum Calender {
      public static let table = ImageAsset(name: "120px/calender/table")
      public static let wall = ImageAsset(name: "120px/calender/wall")
    }
    public enum Clip {
      public static let bulldog = ImageAsset(name: "120px/clip/bulldog")
      public static let double = ImageAsset(name: "120px/clip/double")
    }
    public enum Clock {
      public static let angled = ImageAsset(name: "120px/clock/angled")
      public static let round = ImageAsset(name: "120px/clock/round")
    }
    public enum Coffee {
      public static let glasscup = ImageAsset(name: "120px/coffee/glasscup")
      public static let papercup = ImageAsset(name: "120px/coffee/papercup")
    }
    public static let diary = ImageAsset(name: "120px/diary")
    public static let drawer = ImageAsset(name: "120px/drawer")
    public enum Flower {
      public static let type1 = ImageAsset(name: "120px/flower/type1")
      public static let type2 = ImageAsset(name: "120px/flower/type2")
    }
    public enum Lamp {
      public static let angled = ImageAsset(name: "120px/lamp/angled")
      public static let round = ImageAsset(name: "120px/lamp/round")
    }
    public static let mirror = ImageAsset(name: "120px/mirror")
    public static let paper = ImageAsset(name: "120px/paper")
    public static let stand = ImageAsset(name: "120px/stand")
    public enum Stationery {
      public enum Pen {
        public static let type1 = ImageAsset(name: "120px/stationery/pen/type1")
        public static let type2 = ImageAsset(name: "120px/stationery/pen/type2")
      }
      public enum Pin {
        public static let type1 = ImageAsset(name: "120px/stationery/pin/type1")
        public static let type2 = ImageAsset(name: "120px/stationery/pin/type2")
      }
    }
    public static let stopwatch = ImageAsset(name: "120px/stopwatch")
    public static let tea = ImageAsset(name: "120px/tea")
  }
  public enum _16px {
    public static let add = ImageAsset(name: "16px/add")
    public static let album = ImageAsset(name: "16px/album")
    public enum Alert {
      public static let active = ImageAsset(name: "16px/alert/active")
    }
    public static let alert = ImageAsset(name: "16px/alert")
    public enum Arrow {
      public static let back = ImageAsset(name: "16px/arrow/back")
      public enum Down {
        public static let big = ImageAsset(name: "16px/arrow/down/big")
        public static let small = ImageAsset(name: "16px/arrow/down/small")
      }
      public static let front = ImageAsset(name: "16px/arrow/front")
      public static let `left` = ImageAsset(name: "16px/arrow/left")
      public static let `right` = ImageAsset(name: "16px/arrow/right")
      public enum Up {
        public static let big = ImageAsset(name: "16px/arrow/up/big")
        public static let small = ImageAsset(name: "16px/arrow/up/small")
      }
    }
    public static let bookmark = ImageAsset(name: "16px/bookmark")
    public static let calendar = ImageAsset(name: "16px/calendar")
    public static let camera = ImageAsset(name: "16px/camera")
    public static let check = ImageAsset(name: "16px/check")
    public enum Circle {
      public static let back = ImageAsset(name: "16px/circle/back")
      public enum Check {
        public static let active = ImageAsset(name: "16px/circle/check/active")
        public static let unactive = ImageAsset(name: "16px/circle/check/unactive")
      }
      public static let close = ImageAsset(name: "16px/circle/close")
      public static let front = ImageAsset(name: "16px/circle/front")
    }
    public static let close = ImageAsset(name: "16px/close")
    public static let delete = ImageAsset(name: "16px/delete")
    public static let download = ImageAsset(name: "16px/download")
    public static let erase = ImageAsset(name: "16px/erase")
    public static let exclamation = ImageAsset(name: "16px/exclamation")
    public static let filter = ImageAsset(name: "16px/filter")
    public static let full = ImageAsset(name: "16px/full")
    public static let highlight = ImageAsset(name: "16px/highlight")
    public static let information = ImageAsset(name: "16px/information")
    public static let keyboard = ImageAsset(name: "16px/keyboard")
    public static let lock = ImageAsset(name: "16px/lock")
    public static let modify = ImageAsset(name: "16px/modify")
    public static let more = ImageAsset(name: "16px/more")
    public static let picture = ImageAsset(name: "16px/picture")
    public enum Place {
      public static let bus = ImageAsset(name: "16px/place/Bus")
      public static let car = ImageAsset(name: "16px/place/Car")
      public static let company = ImageAsset(name: "16px/place/Company")
      public static let home = ImageAsset(name: "16px/place/Home")
      public static let luggage = ImageAsset(name: "16px/place/Luggage")
      public static let school = ImageAsset(name: "16px/place/School")
      public static let store = ImageAsset(name: "16px/place/Store")
      public static let subway = ImageAsset(name: "16px/place/Subway")
    }
    public static let place = ImageAsset(name: "16px/place")
    public static let profile = ImageAsset(name: "16px/profile")
    public static let question = ImageAsset(name: "16px/question")
    public enum Radio {
      public static let active = ImageAsset(name: "16px/radio/active")
      public static let unactive = ImageAsset(name: "16px/radio/unactive")
    }
    public static let read = ImageAsset(name: "16px/read")
    public static let recomment = ImageAsset(name: "16px/recomment")
    public static let rewrite = ImageAsset(name: "16px/rewrite")
    public static let search = ImageAsset(name: "16px/search")
    public static let setting = ImageAsset(name: "16px/setting")
    public static let share = ImageAsset(name: "16px/share")
    public static let storage = ImageAsset(name: "16px/storage")
    public static let symbol = ImageAsset(name: "16px/symbol")
    public static let time = ImageAsset(name: "16px/time")
    public static let unlock = ImageAsset(name: "16px/unlock")
    public enum View {
      public static let active = ImageAsset(name: "16px/view/active")
      public static let unactive = ImageAsset(name: "16px/view/unactive")
    }
    public enum Weather {
      public static let cloud = ImageAsset(name: "16px/weather/cloud")
      public static let rain = ImageAsset(name: "16px/weather/rain")
      public static let snow = ImageAsset(name: "16px/weather/snow")
      public static let sun = ImageAsset(name: "16px/weather/sun")
      public static let thunder = ImageAsset(name: "16px/weather/thunder")
      public static let wind = ImageAsset(name: "16px/weather/wind")
    }
    public static let weather = ImageAsset(name: "16px/weather")
    public static let word = ImageAsset(name: "16px/word")
    public static let write = ImageAsset(name: "16px/write")
  }
  public enum _20px {
    public static let add = ImageAsset(name: "20px/add")
    public static let album = ImageAsset(name: "20px/album")
    public enum Alert {
      public static let active = ImageAsset(name: "20px/alert/active")
      public static let unactive = ImageAsset(name: "20px/alert/unactive")
    }
    public enum Arrow {
      public static let back = ImageAsset(name: "20px/arrow/back")
      public enum Down {
        public static let big = ImageAsset(name: "20px/arrow/down/big")
        public static let small = ImageAsset(name: "20px/arrow/down/small")
      }
      public static let front = ImageAsset(name: "20px/arrow/front")
      public static let `left` = ImageAsset(name: "20px/arrow/left")
      public static let `right` = ImageAsset(name: "20px/arrow/right")
      public enum Up {
        public static let big = ImageAsset(name: "20px/arrow/up/big")
        public static let small = ImageAsset(name: "20px/arrow/up/small")
      }
    }
    public static let bookmark = ImageAsset(name: "20px/bookmark")
    public static let calendar = ImageAsset(name: "20px/calendar")
    public static let camera = ImageAsset(name: "20px/camera")
    public static let check = ImageAsset(name: "20px/check")
    public enum Circle {
      public static let back = ImageAsset(name: "20px/circle/back")
      public enum Check {
        public static let active = ImageAsset(name: "20px/circle/active")
        public static let unactive = ImageAsset(name: "20px/circle/unactive")
      }
      public static let close = ImageAsset(name: "20px/circle/close")
      public static let front = ImageAsset(name: "20px/circle/front")
    }
    public static let close = ImageAsset(name: "20px/close")
    public static let delete = ImageAsset(name: "20px/delete")
    public static let download = ImageAsset(name: "20px/download")
    public static let erase = ImageAsset(name: "20px/erase")
    public static let exclamation = ImageAsset(name: "20px/exclamation")
    public static let filter = ImageAsset(name: "20px/filter")
    public static let full = ImageAsset(name: "20px/full")
    public static let highlight = ImageAsset(name: "20px/highlight")
    public static let information = ImageAsset(name: "20px/information")
    public static let keyboard = ImageAsset(name: "20px/keyboard")
    public static let lock = ImageAsset(name: "20px/lock")
    public static let modify = ImageAsset(name: "20px/modify")
    public static let more = ImageAsset(name: "20px/more")
    public static let picture = ImageAsset(name: "20px/picture")
    public enum Place {
      public static let bus = ImageAsset(name: "20px/place/Bus")
      public static let car = ImageAsset(name: "20px/place/Car")
      public static let company = ImageAsset(name: "20px/place/Company")
      public static let home = ImageAsset(name: "20px/place/Home")
      public static let luggage = ImageAsset(name: "20px/place/Luggage")
      public static let school = ImageAsset(name: "20px/place/School")
      public static let store = ImageAsset(name: "20px/place/Store")
      public static let subway = ImageAsset(name: "20px/place/Subway")
    }
    public static let place = ImageAsset(name: "20px/place")
    public static let profile = ImageAsset(name: "20px/profile")
    public static let question = ImageAsset(name: "20px/question")
    public enum Radio {
      public static let active = ImageAsset(name: "20px/radio/active")
      public static let unactive = ImageAsset(name: "20px/radio/unactive")
    }
    public static let read = ImageAsset(name: "20px/read")
    public static let recomment = ImageAsset(name: "20px/recomment")
    public static let rewrite = ImageAsset(name: "20px/rewrite")
    public static let search = ImageAsset(name: "20px/search")
    public static let setting = ImageAsset(name: "20px/setting")
    public static let share = ImageAsset(name: "20px/share")
    public static let storage = ImageAsset(name: "20px/storage")
    public static let symbol = ImageAsset(name: "20px/symbol")
    public static let time = ImageAsset(name: "20px/time")
    public static let unlock = ImageAsset(name: "20px/unlock")
    public enum View {
      public static let active = ImageAsset(name: "20px/view/active")
      public static let unactive = ImageAsset(name: "20px/view/unactive")
    }
    public enum Weather {
      public static let cloud = ImageAsset(name: "20px/weather/cloud")
      public static let rain = ImageAsset(name: "20px/weather/rain")
      public static let snow = ImageAsset(name: "20px/weather/snow")
      public static let sun = ImageAsset(name: "20px/weather/sun")
      public static let thunder = ImageAsset(name: "20px/weather/thunder")
      public static let wind = ImageAsset(name: "20px/weather/wind")
    }
    public static let weather = ImageAsset(name: "20px/weather")
    public static let word = ImageAsset(name: "20px/word")
    public static let write = ImageAsset(name: "20px/write")
  }
  public enum _24px {
    public static let add = ImageAsset(name: "24px/add")
    public static let album = ImageAsset(name: "24px/album")
    public enum Alert {
      public static let active = ImageAsset(name: "24px/alert/active")
      public static let unactive = ImageAsset(name: "24px/alert/unactive")
    }
    public enum Arrow {
      public static let back = ImageAsset(name: "24px/arrow/back")
      public enum Down {
        public static let big = ImageAsset(name: "24px/arrow/down/big")
        public static let small = ImageAsset(name: "24px/arrow/down/small")
      }
      public static let front = ImageAsset(name: "24px/arrow/front")
      public static let `left` = ImageAsset(name: "24px/arrow/left")
      public static let `right` = ImageAsset(name: "24px/arrow/right")
      public enum Up {
        public static let big = ImageAsset(name: "24px/arrow/up/big")
        public static let small = ImageAsset(name: "24px/arrow/up/small")
      }
    }
    public static let bookmark = ImageAsset(name: "24px/bookmark")
    public static let calendar = ImageAsset(name: "24px/calendar")
    public static let camera = ImageAsset(name: "24px/camera")
    public static let check = ImageAsset(name: "24px/check")
    public enum Circle {
      public static let back = ImageAsset(name: "24px/circle/back")
      public enum Check {
        public static let active = ImageAsset(name: "24px/circle/check/active")
        public static let unactive = ImageAsset(name: "24px/circle/check/unactive")
      }
      public static let close = ImageAsset(name: "24px/circle/close")
      public static let front = ImageAsset(name: "24px/circle/front")
    }
    public static let close = ImageAsset(name: "24px/close")
    public static let delete = ImageAsset(name: "24px/delete")
    public static let download = ImageAsset(name: "24px/download")
    public static let erase = ImageAsset(name: "24px/erase")
    public static let exclamation = ImageAsset(name: "24px/exclamation")
    public static let filter = ImageAsset(name: "24px/filter")
    public static let full = ImageAsset(name: "24px/full")
    public static let highlight = ImageAsset(name: "24px/highlight")
    public static let information = ImageAsset(name: "24px/information")
    public static let keyboard = ImageAsset(name: "24px/keyboard")
    public static let lock = ImageAsset(name: "24px/lock")
    public static let modify = ImageAsset(name: "24px/modify")
    public static let more = ImageAsset(name: "24px/more")
    public static let picture = ImageAsset(name: "24px/picture")
    public enum Place {
      public static let bus = ImageAsset(name: "24px/place/Bus")
      public static let car = ImageAsset(name: "24px/place/Car")
      public static let company = ImageAsset(name: "24px/place/Company")
      public static let home = ImageAsset(name: "24px/place/Home")
      public static let luggage = ImageAsset(name: "24px/place/Luggage")
      public static let school = ImageAsset(name: "24px/place/School")
      public static let store = ImageAsset(name: "24px/place/Store")
      public static let subway = ImageAsset(name: "24px/place/Subway")
    }
    public static let place = ImageAsset(name: "24px/place")
    public static let profile = ImageAsset(name: "24px/profile")
    public static let question = ImageAsset(name: "24px/question")
    public enum Radio {
      public static let active = ImageAsset(name: "24px/radio/active")
      public static let unactive = ImageAsset(name: "24px/radio/unactive")
    }
    public static let read = ImageAsset(name: "24px/read")
    public static let recomment = ImageAsset(name: "24px/recomment")
    public static let rewrite = ImageAsset(name: "24px/rewrite")
    public static let search = ImageAsset(name: "24px/search")
    public static let setting = ImageAsset(name: "24px/setting")
    public static let share = ImageAsset(name: "24px/share")
    public static let storage = ImageAsset(name: "24px/storage")
    public static let symbol = ImageAsset(name: "24px/symbol")
    public static let time = ImageAsset(name: "24px/time")
    public static let unlock = ImageAsset(name: "24px/unlock")
    public enum View {
      public static let active = ImageAsset(name: "24px/view/active")
      public static let unactive = ImageAsset(name: "24px/view/unactive")
    }
    public enum Weather {
      public static let cloud = ImageAsset(name: "24px/weather/cloud")
      public static let rain = ImageAsset(name: "24px/weather/rain")
      public static let snow = ImageAsset(name: "24px/weather/snow")
      public static let sun = ImageAsset(name: "24px/weather/sun")
      public static let thunder = ImageAsset(name: "24px/weather/thunder")
      public static let wind = ImageAsset(name: "24px/weather/wind")
    }
    public static let weather = ImageAsset(name: "24px/weather")
    public static let word = ImageAsset(name: "24px/word")
    public static let write = ImageAsset(name: "24px/write")
  }
  public enum _40px {
    public enum Book {
      public static let close = ImageAsset(name: "40px/book/close")
      public static let `open` = ImageAsset(name: "40px/book/open")
    }
    public enum Calender {
      public static let table = ImageAsset(name: "40px/calender/table")
      public static let wall = ImageAsset(name: "40px/calender/wall")
    }
    public enum Clip {
      public static let bulldog = ImageAsset(name: "40px/clip/bulldog")
      public static let double = ImageAsset(name: "40px/clip/double")
    }
    public enum Clock {
      public static let angled = ImageAsset(name: "40px/clock/angled")
      public static let round = ImageAsset(name: "40px/clock/round")
    }
    public enum Coffee {
      public static let glasscup = ImageAsset(name: "40px/coffee/glasscup")
      public static let papercup = ImageAsset(name: "40px/coffee/papercup")
    }
    public static let diary = ImageAsset(name: "40px/diary")
    public static let drawer = ImageAsset(name: "40px/drawer")
    public enum Flower {
      public static let type1 = ImageAsset(name: "40px/flower/type1")
      public static let type2 = ImageAsset(name: "40px/flower/type2")
    }
    public enum Lamp {
      public static let angled = ImageAsset(name: "40px/lamp/angled")
      public static let round = ImageAsset(name: "40px/lamp/round")
    }
    public static let mirror = ImageAsset(name: "40px/mirror")
    public static let paper = ImageAsset(name: "40px/paper")
    public static let stand = ImageAsset(name: "40px/stand")
    public enum Stationery {
      public enum Pen {
        public static let type1 = ImageAsset(name: "40px/stationery/pen/type1")
        public static let type2 = ImageAsset(name: "40px/stationery/pen/type2")
      }
      public enum Pin {
        public static let type1 = ImageAsset(name: "40px/stationery/pin/type1")
        public static let type2 = ImageAsset(name: "40px/stationery/pin/type2")
      }
    }
    public static let stopwatch = ImageAsset(name: "40px/stopwatch")
    public static let tea = ImageAsset(name: "40px/tea")
  }
  public enum _80px {
    public enum Book {
      public static let close = ImageAsset(name: "80px/book/close")
      public static let `open` = ImageAsset(name: "80px/book/open")
    }
    public enum Calender {
      public static let table = ImageAsset(name: "80px/calender/table")
      public static let wall = ImageAsset(name: "80px/calender/wall")
    }
    public enum Clip {
      public static let bulldog = ImageAsset(name: "80px/clip/bulldog")
      public static let double = ImageAsset(name: "80px/clip/double")
    }
    public enum Clock {
      public static let angled = ImageAsset(name: "80px/clock/angled")
      public static let round = ImageAsset(name: "80px/clock/round")
    }
    public enum Coffee {
      public static let glasscup = ImageAsset(name: "80px/coffee/glasscup")
      public static let papercup = ImageAsset(name: "80px/coffee/papercup")
    }
    public static let diary = ImageAsset(name: "80px/diary")
    public static let drawer = ImageAsset(name: "80px/drawer")
    public enum Flower {
      public static let type1 = ImageAsset(name: "80px/flower/type1")
      public static let type2 = ImageAsset(name: "80px/flower/type2")
    }
    public enum Lamp {
      public static let angled = ImageAsset(name: "80px/lamp/angled")
      public static let round = ImageAsset(name: "80px/lamp/round")
    }
    public static let mirror = ImageAsset(name: "80px/mirror")
    public static let paper = ImageAsset(name: "80px/paper")
    public static let stand = ImageAsset(name: "80px/stand")
    public enum Stationery {
      public enum Pen {
        public static let type1 = ImageAsset(name: "80px/stationery/pen/type1")
        public static let type2 = ImageAsset(name: "80px/stationery/pen/type2")
      }
      public enum Pin {
        public static let type1 = ImageAsset(name: "80px/stationery/pin/type1")
        public static let type2 = ImageAsset(name: "80px/stationery/pin/type2")
      }
    }
    public static let stopwatch = ImageAsset(name: "80px/stopwatch")
    public static let tea = ImageAsset(name: "80px/tea")
  }
  public enum Illurstration {
    public static let emtpySpace = ImageAsset(name: "Illurstration/emtpy-space")
    public static let nullDiary = ImageAsset(name: "Illurstration/null-diary")
    public static let suggestReview = ImageAsset(name: "Illurstration/suggest-review")
    public static let viewLock = ImageAsset(name: "Illurstration/view-lock")
  }
  public enum Pagination {
    public static let paginationSelected = ImageAsset(name: "Pagination/paginationSelected")
    public static let paginationUnselected = ImageAsset(name: "Pagination/paginationUnselected")
  }
  public enum UpdateImages {
    public static let updateImage01 = ImageAsset(name: "UpdateImages/updateImage01")
    public static let updateImage02 = ImageAsset(name: "UpdateImages/updateImage02")
    public static let updateImage03 = ImageAsset(name: "UpdateImages/updateImage03")
  }
  public static let splashMenual = ImageAsset(name: "splashMenual")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
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
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

public extension ImageAsset.Image {
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
