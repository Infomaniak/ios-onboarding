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
