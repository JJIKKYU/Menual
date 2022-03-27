import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

struct MenualString {

    // MENUAL UX Localizations 적용 버전 = 1.01
    static let localizations_ver = "localizations_ver".localized
    static let title_menual = "title_menual".localized
    static let title_moments = "title_moments".localized
    static let title_menualList = "title_menualList".localized
    static let button_writeMenual = "button_writeMenual".localized
    static let title_aboutMe = "title_aboutMe".localized
    static let title_notice = "title_notice".localized
    static let title_reminder = "title_reminder".localized
    static let button_apply = "button_apply".localized
    static let placeholder_search = "placeholder_search".localized
    static let title_searchResult = "title_searchResult".localized
    static let title_searchHistory = "title_searchHistory".localized
    static let title_showWeather = "title_showWeather".localized
    static let title_showPlace = "title_showPlace".localized
    static let title_filter = "title_filter".localized
}
