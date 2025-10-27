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

import Foundation
@preconcurrency import Lottie
import UIKit

public struct IKLottieConfiguration: Sendable {
    public enum AnimationType: Sendable {
        case json
        case dotLottie
    }

    public let id: Int
    public let filename: String
    public let bundle: Bundle
    public let animationType: AnimationType
    public let loopMode: LottieLoopMode
    public let contentMode: UIView.ContentMode
    public let loopFrameStart: Int?
    public let loopFrameEnd: Int?
    public let lottieConfiguration: LottieConfiguration

    public init(
        id: Int,
        filename: String,
        bundle: Bundle,
        animationType: AnimationType = .json,
        loopMode: LottieLoopMode = .playOnce,
        contentMode: UIView.ContentMode = UIView.ContentMode.scaleAspectFit,
        loopFrameStart: Int? = nil,
        loopFrameEnd: Int? = nil,
        lottieConfiguration: LottieConfiguration = LottieConfiguration()
    ) {
        self.id = id
        self.filename = filename
        self.bundle = bundle
        self.animationType = animationType
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.loopFrameStart = loopFrameStart
        self.loopFrameEnd = loopFrameEnd
        self.lottieConfiguration = lottieConfiguration
    }
}
