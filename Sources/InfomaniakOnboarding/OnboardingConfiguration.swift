//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import SwiftUI

public struct OnboardingConfiguration: Sendable {
    /// The image displayed at the top of the view, usually the app logo
    public let headerImage: UIImage?
    /// The slides to be displayed
    public let slides: [Slide]
    /// Custom color for the page indicator
    public let pageIndicatorColor: UIColor?
    /// Allow or not the slides to scroll
    public let isScrollEnabled: Bool
    /// Show or hide points on slides
    public let isPageIndicatorHidden: Bool

    /// Action to perform when the close button is tapped
    /// The button is only displayed when the handler is not nil
    public let dismissHandler: (@Sendable () -> Void)?

    public init(
        headerImage: UIImage?,
        slides: [Slide],
        pageIndicatorColor: UIColor?,
        isScrollEnabled: Bool,
        dismissHandler: (@Sendable () -> Void)?,
        isPageIndicatorHidden: Bool
    ) {
        self.headerImage = headerImage
        self.slides = slides
        self.pageIndicatorColor = pageIndicatorColor
        self.isScrollEnabled = isScrollEnabled
        self.dismissHandler = dismissHandler
        self.isPageIndicatorHidden = isPageIndicatorHidden
    }
}
