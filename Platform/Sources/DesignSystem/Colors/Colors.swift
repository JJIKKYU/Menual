//
//  Color+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/02/26.
//

import Foundation
import UIKit

enum Colors {

    static var background: UIColor {
        return color(
            dark: UIColor(red: 0.09803921729326248, green: 0.09803921729326248, blue: 0.09803921729326248, alpha: 1),
            light: UIColor(red: 0.09803921729326248, green: 0.09803921729326248, blue: 0.09803921729326248, alpha: 1)
        )
    }

    enum tint {

        enum main {

            static var v100: UIColor {
                return color(
                    dark: UIColor(red: 0.8313725590705872, green: 0.729411780834198, blue: 1, alpha: 1),
                    light: UIColor(red: 0.8313725590705872, green: 0.729411780834198, blue: 1, alpha: 1)
                )
            }

            static var v200: UIColor {
                return color(
                    dark: UIColor(red: 0.7450980544090271, green: 0.5960784554481506, blue: 1, alpha: 1),
                    light: UIColor(red: 0.7450980544090271, green: 0.5960784554481506, blue: 1, alpha: 1)
                )
            }

            static var v300: UIColor {
                return color(
                    dark: UIColor(red: 0.6627451181411743, green: 0.4588235318660736, blue: 1, alpha: 1),
                    light: UIColor(red: 0.6627451181411743, green: 0.4588235318660736, blue: 1, alpha: 1)
                )
            }

            static var v400: UIColor {
                return color(
                    dark: UIColor(red: 0.5764706134796143, green: 0.32549020648002625, blue: 1, alpha: 1),
                    light: UIColor(red: 0.5764706134796143, green: 0.32549020648002625, blue: 1, alpha: 1)
                )
            }

            static var v500: UIColor {
                return color(
                    dark: UIColor(red: 0.5176470875740051, green: 0.29411765933036804, blue: 0.9019607901573181, alpha: 1),
                    light: UIColor(red: 0.5176470875740051, green: 0.29411765933036804, blue: 0.9019607901573181, alpha: 1)
                )
            }

            static var v600: UIColor {
                return color(
                    dark: UIColor(red: 0.4627451002597809, green: 0.25882354378700256, blue: 0.800000011920929, alpha: 1),
                    light: UIColor(red: 0.4627451002597809, green: 0.25882354378700256, blue: 0.800000011920929, alpha: 1)
                )
            }

            static var v700: UIColor {
                return color(
                    dark: UIColor(red: 0.40392157435417175, green: 0.22745098173618317, blue: 0.7019608020782471, alpha: 1),
                    light: UIColor(red: 0.40392157435417175, green: 0.22745098173618317, blue: 0.7019608020782471, alpha: 1)
                )
            }

            static var v800: UIColor {
                return color(
                    dark: UIColor(red: 0.3450980484485626, green: 0.19607843458652496, blue: 0.6000000238418579, alpha: 1),
                    light: UIColor(red: 0.3450980484485626, green: 0.19607843458652496, blue: 0.6000000238418579, alpha: 1)
                )
            }
        }

        enum sub {

            static var n100: UIColor {
                return color(
                    dark: UIColor(red: 0.9411764740943909, green: 1, blue: 0.6000000238418579, alpha: 1),
                    light: UIColor(red: 0.9411764740943909, green: 1, blue: 0.6000000238418579, alpha: 1)
                )
            }

            static var n200: UIColor {
                return color(
                    dark: UIColor(red: 0.9137254953384399, green: 1, blue: 0.40392157435417175, alpha: 1),
                    light: UIColor(red: 0.9137254953384399, green: 1, blue: 0.40392157435417175, alpha: 1)
                )
            }

            static var n300: UIColor {
                return color(
                    dark: UIColor(red: 0.8823529481887817, green: 1, blue: 0.20392157137393951, alpha: 1),
                    light: UIColor(red: 0.8823529481887817, green: 1, blue: 0.20392157137393951, alpha: 1)
                )
            }

            static var n400: UIColor {
                return color(
                    dark: UIColor(red: 0.8549019694328308, green: 1, blue: 0.003921568859368563, alpha: 1),
                    light: UIColor(red: 0.8549019694328308, green: 1, blue: 0.003921568859368563, alpha: 1)
                )
            }

            static var n500: UIColor {
                return color(
                    dark: UIColor(red: 0.7686274647712708, green: 0.9019607901573181, blue: 0.003921568859368563, alpha: 1),
                    light: UIColor(red: 0.7686274647712708, green: 0.9019607901573181, blue: 0.003921568859368563, alpha: 1)
                )
            }

            static var n600: UIColor {
                return color(
                    dark: UIColor(red: 0.6823529601097107, green: 0.800000011920929, blue: 0.003921568859368563, alpha: 1),
                    light: UIColor(red: 0.6823529601097107, green: 0.800000011920929, blue: 0.003921568859368563, alpha: 1)
                )
            }

            static var n700: UIColor {
                return color(
                    dark: UIColor(red: 0.6000000238418579, green: 0.7019608020782471, blue: 0.003921568859368563, alpha: 1),
                    light: UIColor(red: 0.6000000238418579, green: 0.7019608020782471, blue: 0.003921568859368563, alpha: 1)
                )
            }

            static var n800: UIColor {
                return color(
                    dark: UIColor(red: 0.5137255191802979, green: 0.6000000238418579, blue: 0.003921568859368563, alpha: 1),
                    light: UIColor(red: 0.5137255191802979, green: 0.6000000238418579, blue: 0.003921568859368563, alpha: 1)
                )
            }
        }

        enum system {

            enum blue {

                static var b100: UIColor {
                    return color(
                        dark: UIColor(red: 0, green: 0.3960784375667572, blue: 1, alpha: 1),
                        light: UIColor(red: 0, green: 0.3960784375667572, blue: 1, alpha: 1)
                    )
                }

                static var b200: UIColor {
                    return color(
                        dark: UIColor(red: 0, green: 0.32156863808631897, blue: 0.800000011920929, alpha: 1),
                        light: UIColor(red: 0, green: 0.32156863808631897, blue: 0.800000011920929, alpha: 1)
                    )
                }
            }

            enum red {

                static var r100: UIColor {
                    return color(
                        dark: UIColor(red: 1, green: 0.33725491166114807, blue: 0.1882352977991104, alpha: 1),
                        light: UIColor(red: 1, green: 0.33725491166114807, blue: 0.1882352977991104, alpha: 1)
                    )
                }

                static var r200: UIColor {
                    return color(
                        dark: UIColor(red: 0.8705882430076599, green: 0.2078431397676468, blue: 0.04313725605607033, alpha: 1),
                        light: UIColor(red: 0.8705882430076599, green: 0.2078431397676468, blue: 0.04313725605607033, alpha: 1)
                    )
                }
            }

            enum yellow {

                static var y100: UIColor {
                    return color(
                        dark: UIColor(red: 1, green: 0.7686274647712708, blue: 0, alpha: 1),
                        light: UIColor(red: 1, green: 0.7686274647712708, blue: 0, alpha: 1)
                    )
                }

                static var y200: UIColor {
                    return color(
                        dark: UIColor(red: 1, green: 0.6705882549285889, blue: 0, alpha: 1),
                        light: UIColor(red: 1, green: 0.6705882549285889, blue: 0, alpha: 1)
                    )
                }
            }
        }
    }

    enum grey {

        static var g100: UIColor {
            return color(
                dark: UIColor(red: 0.9529411792755127, green: 0.9529411792755127, blue: 0.9529411792755127, alpha: 1),
                light: UIColor(red: 0.9529411792755127, green: 0.9529411792755127, blue: 0.9529411792755127, alpha: 1)
            )
        }

        static var g200: UIColor {
            return color(
                dark: UIColor(red: 0.8549019694328308, green: 0.8549019694328308, blue: 0.8549019694328308, alpha: 1),
                light: UIColor(red: 0.8549019694328308, green: 0.8549019694328308, blue: 0.8549019694328308, alpha: 1)
            )
        }

        static var g300: UIColor {
            return color(
                dark: UIColor(red: 0.7568627595901489, green: 0.7568627595901489, blue: 0.7568627595901489, alpha: 1),
                light: UIColor(red: 0.7568627595901489, green: 0.7568627595901489, blue: 0.7568627595901489, alpha: 1)
            )
        }

        static var g400: UIColor {
            return color(
                dark: UIColor(red: 0.658823549747467, green: 0.658823549747467, blue: 0.658823549747467, alpha: 1),
                light: UIColor(red: 0.658823549747467, green: 0.658823549747467, blue: 0.658823549747467, alpha: 1)
            )
        }

        static var g500: UIColor {
            return color(
                dark: UIColor(red: 0.3803921639919281, green: 0.3803921639919281, blue: 0.3803921639919281, alpha: 1),
                light: UIColor(red: 0.3803921639919281, green: 0.3803921639919281, blue: 0.3803921639919281, alpha: 1)
            )
        }

        static var g600: UIColor {
            return color(
                dark: UIColor(red: 0.30588236451148987, green: 0.30588236451148987, blue: 0.30588236451148987, alpha: 1),
                light: UIColor(red: 0.30588236451148987, green: 0.30588236451148987, blue: 0.30588236451148987, alpha: 1)
            )
        }

        static var g700: UIColor {
            return color(
                dark: UIColor(red: 0.22745098173618317, green: 0.22745098173618317, blue: 0.22745098173618317, alpha: 1),
                light: UIColor(red: 0.22745098173618317, green: 0.22745098173618317, blue: 0.22745098173618317, alpha: 1)
            )
        }

        static var g800: UIColor {
            return color(
                dark: UIColor(red: 0.15294118225574493, green: 0.15294118225574493, blue: 0.15294118225574493, alpha: 1),
                light: UIColor(red: 0.15294118225574493, green: 0.15294118225574493, blue: 0.15294118225574493, alpha: 1)
            )
        }
    }
}

extension Colors {

    static func color(dark: UIColor, light: UIColor) -> UIColor {
        guard #available(iOS 13, *) else { return light }
        
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            switch UITraitCollection.userInterfaceStyle {
            case .dark: return dark
            case .light: return light
            default: return light
            }
        }
    }
}
