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

import Lottie
import SwiftUI

struct LottieSlideAnimationView: View {
    @State private var phase = LottiePlaybackPhase.intro

    let configuration: IKLottieConfiguration
    let isPlaying: Bool

    private var playbackMode: LottiePlaybackMode {
        phase.playbackMode(
            isPlaying: isPlaying,
            loopMode: configuration.loopMode,
            loopFrameStart: configuration.loopFrameStart,
            loopFrameEnd: configuration.loopFrameEnd
        )
    }

    var body: some View {
        switch configuration.animationType {
        case .json:
            configured(LottieView(animation: .named(configuration.filename, bundle: configuration.bundle)))
        case .dotLottie:
            configured(LottieView { try await DotLottieFile.named(configuration.filename, bundle: configuration.bundle) })
        }
    }

    private func configured(_ lottieView: LottieView<EmptyView>) -> some View {
        lottieView
            .configuration(configuration.lottieConfiguration)
            .resizable()
            .configure { animationView in
                animationView.contentMode = configuration.contentMode == .fit ? .scaleAspectFit : .scaleAspectFill
                configuration.configureAnimationView?(animationView)
            }
            .playbackMode(playbackMode)
            .animationDidFinish { completed in
                guard phase == .intro else { return }
                phase = .phaseAfterIntro(
                    completed: completed,
                    loopFrameStart: configuration.loopFrameStart,
                    loopFrameEnd: configuration.loopFrameEnd
                )
            }
    }
}
