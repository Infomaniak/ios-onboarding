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

import DotLottie
import SwiftUI

struct SlideIllustrationView: View {
    let content: SlideContent
    let isCurrent: Bool

    var body: some View {
        switch content {
        case .illustration(let image):
            image
                .resizable()
                .scaledToFit()
        case .animation(let configuration):
            LottieSlideAnimationView(configuration: configuration, isPlaying: isCurrent)
                .id(LottieAnimationId(configuration: configuration))
        case .dotLottieAnimation(let configuration):
            DotLottieSlideAnimationView(configuration: configuration, isPlaying: isCurrent)
                .id(DotLottieAnimationId(configuration: configuration))
        }
    }
}

/// Recreates the Lottie view and resets its playback phase when the animation source changes
private struct LottieAnimationId: Hashable {
    let filename: String
    let bundlePath: String
    let isDotLottie: Bool

    init(configuration: IKLottieConfiguration) {
        filename = configuration.filename
        bundlePath = configuration.bundle.bundlePath
        isDotLottie = configuration.animationType == .dotLottie
    }
}

/// Recreates the DotLottie player when the configuration changes, since `StateObject` is only initialized once per identity
private struct DotLottieAnimationId: Hashable {
    let filename: String
    let bundlePath: String
    let isLooping: Bool
    let mode: Mode

    init(configuration: IKDotLottieConfiguration) {
        filename = configuration.filename
        bundlePath = configuration.bundle.bundlePath
        isLooping = configuration.isLooping
        mode = configuration.mode
    }
}
