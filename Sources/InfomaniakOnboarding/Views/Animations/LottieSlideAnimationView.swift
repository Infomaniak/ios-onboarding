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
    @Environment(\.colorScheme) private var colorScheme

    @State private var phase = LottiePlaybackPhase.intro

    let configuration: IKLottieConfiguration
    let isPlaying: Bool

    var body: some View {
        LottieView {
            switch configuration.animationType {
            case .json:
                LottieAnimation.named(configuration.filename, bundle: configuration.bundle).map { .lottieAnimation($0) }
            case .dotLottie:
                try await .dotLottieFile(DotLottieFile.named(configuration.filename, bundle: configuration.bundle))
            }
        }
        .configuration(configuration.lottieConfiguration)
        .resizable()
        .configure { animationView in
            animationView.contentMode = configuration.contentMode == .fit ? .scaleAspectFit : .scaleAspectFill
        }
        .colors(configuration.colors, colorScheme: colorScheme)
        .playbackMode(phase.playbackMode(
            isPlaying: isPlaying,
            loopMode: configuration.loopMode,
            loopFrameStart: configuration.loopFrameStart,
            loopFrameEnd: configuration.loopFrameEnd
        ))
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

private extension LottieView {
    func colors(_ colors: [IKLottieColor], colorScheme: ColorScheme) -> LottieView {
        colors.reduce(self) { view, lottieColor in
            view.valueProvider(
                ColorValueProvider(lottieColor.color.lottieColor(in: colorScheme)),
                for: AnimationKeypath(keypath: lottieColor.keypath)
            )
        }
    }
}

private extension Color {
    func lottieColor(in colorScheme: ColorScheme) -> LottieColor {
        if #available(iOS 17.0, *) {
            var environment = EnvironmentValues()
            environment.colorScheme = colorScheme
            let resolved = resolve(in: environment)
            return LottieColor(r: Double(resolved.red), g: Double(resolved.green), b: Double(resolved.blue), a: Double(resolved.opacity))
        } else {
            let traitCollection = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
            return UIColor(self).resolvedColor(with: traitCollection).lottieColorValue
        }
    }
}
