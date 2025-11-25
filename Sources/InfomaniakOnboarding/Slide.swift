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

import Lottie
import SwiftUI
import UIKit

public enum SlideContent {
    case illustration(UIImage)
    case animation(IKLottieConfiguration)
}

@MainActor
public struct Slide {
    /// An image displayed behind the main illustration (usually a wave)
    public let backgroundImage: UIImage
    /// The color to apply to the background image
    public let backgroundImageTintColor: UIColor?
    /// The main content displayed either a Lottie animation or an image
    public let content: SlideContent
    /// The view displayed directly under the illustration
    public let bottomViewController: UIViewController

    public init(
        backgroundImage: UIImage,
        backgroundImageTintColor: UIColor?,
        content: SlideContent,
        bottomViewController: UIViewController
    ) {
        self.backgroundImage = backgroundImage
        self.backgroundImageTintColor = backgroundImageTintColor
        self.content = content
        self.bottomViewController = bottomViewController
    }

    public init(
        backgroundImage: UIImage,
        backgroundImageTintColor: UIColor?,
        content: SlideContent,
        bottomView: some View
    ) {
        self.backgroundImage = backgroundImage
        self.backgroundImageTintColor = backgroundImageTintColor
        self.content = content
        bottomViewController = UIHostingController(rootView: bottomView)
    }
}
