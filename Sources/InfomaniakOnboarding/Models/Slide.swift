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

public enum SlideContent: Sendable {
    case illustration(Image)
}

@MainActor
public struct Slide {
    /// An image displayed behind the main illustration (usually a wave)
    public let backgroundImage: Image
    /// The color to apply to the background image.
    /// When not nil, the image is rendered as a template and tinted with this color.
    public let backgroundImageTintColor: Color?
    /// The main content displayed either a Lottie animation or an image
    public let content: SlideContent
    /// The view displayed directly under the illustration
    public let bottomView: AnyView

    public init(
        backgroundImage: Image,
        backgroundImageTintColor: Color? = nil,
        content: SlideContent,
        bottomView: some View
    ) {
        self.backgroundImage = backgroundImage
        self.backgroundImageTintColor = backgroundImageTintColor
        self.content = content
        self.bottomView = AnyView(bottomView)
    }

    public init(
        backgroundImage: Image,
        backgroundImageTintColor: Color? = nil,
        content: SlideContent,
        @ViewBuilder bottomView: () -> some View
    ) {
        self.init(
            backgroundImage: backgroundImage,
            backgroundImageTintColor: backgroundImageTintColor,
            content: content,
            bottomView: bottomView()
        )
    }
}
