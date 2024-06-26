/*
 Infomaniak Onboarding - iOS
 Copyright (C) 2024 Infomaniak Network SA

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

import SwiftUI

public struct OnboardingConfiguration {
    /// The image displayed at the top of the view, usually the app logo
    public let headerImage: UIImage?
    /// The slides to be displayed
    public let slides: [Slide]
    /// Custom color for the page indicator
    public let pageIndicatorColor: UIColor?
    /// Allow or not the slides to scroll
    public let isScrollEnabled: Bool

    public init(
        headerImage: UIImage?,
        slides: [Slide],
        pageIndicatorColor: UIColor?,
        isScrollEnabled: Bool
    ) {
        self.headerImage = headerImage
        self.slides = slides
        self.pageIndicatorColor = pageIndicatorColor
        self.isScrollEnabled = isScrollEnabled
    }
}
