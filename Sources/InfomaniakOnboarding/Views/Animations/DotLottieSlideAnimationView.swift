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

struct DotLottieSlideAnimationView: View {
    @StateObject private var animation: DotLottieAnimation

    let configuration: IKDotLottieConfiguration
    let isPlaying: Bool

    init(configuration: IKDotLottieConfiguration, isPlaying: Bool) {
        self.configuration = configuration
        self.isPlaying = isPlaying
        _animation = StateObject(wrappedValue: DotLottieAnimation(
            fileName: configuration.filename,
            bundle: configuration.bundle,
            config: AnimationConfig(autoplay: isPlaying, loop: configuration.isLooping, mode: configuration.mode)
        ))
    }

    var body: some View {
        let dotLottieView: DotLottieView = animation.view()
        dotLottieView
            .onAppear { updatePlayback(isPlaying: isPlaying) }
            .onChange(of: isPlaying) { updatePlayback(isPlaying: $0) }
            .onDisappear { updatePlayback(isPlaying: false) }
    }

    private func updatePlayback(isPlaying: Bool) {
        if isPlaying {
            guard !animation.isPlaying() else { return }
            animation.play()
        } else {
            guard !animation.isPaused() else { return }
            animation.pause()
        }
    }
}
