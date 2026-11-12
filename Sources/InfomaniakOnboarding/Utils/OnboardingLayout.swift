/*
 Infomaniak Onboarding - iOS
 Copyright (C) 2026 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import CoreGraphics

/// Layout tokens reproducing the historical UIKit onboarding layout.
enum OnboardingLayout {
    enum Padding {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }

    /// Share of the total height used by the slides carousel, the rest is used by the bottom view
    static let carouselHeightRatio: CGFloat = 0.8
    /// Share of the slide height used by the background image
    static let backgroundImageHeightRatio: CGFloat = 0.57
    /// Share of the slide width used by the illustration
    static let illustrationWidthRatio: CGFloat = 0.7
    static let illustrationMaxWidth: CGFloat = 300
    /// Minimum space kept above the illustration, under the header image
    static let illustrationTopInset: CGFloat = 128
    /// Under this height the illustration and the background are hidden to leave the space to the bottom view (landscape, small screens…)
    static let illustrationMinHeight: CGFloat = 100
    static let closeButtonSize: CGFloat = 40
    static let pageIndicatorDotSize: CGFloat = 8
    static let bottomViewAnimationDuration: Double = 0.25
}
