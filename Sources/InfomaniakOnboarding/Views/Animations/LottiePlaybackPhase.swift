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

enum LottiePlaybackPhase: Equatable {
    case intro
    case loop

    static func phaseAfterIntro(completed: Bool, loopFrameStart: Int?, loopFrameEnd: Int?) -> LottiePlaybackPhase {
        guard completed, loopFrameStart != nil, loopFrameEnd != nil else { return .intro }
        return .loop
    }

    func playbackMode(
        isPlaying: Bool,
        loopMode: LottieLoopMode,
        loopFrameStart: Int?,
        loopFrameEnd: Int?
    ) -> LottiePlaybackMode {
        guard isPlaying else { return .paused(at: .currentFrame) }

        guard let loopFrameStart, let loopFrameEnd else {
            // Without loop segment, the intro plays the loop mode on the full range and never switches to the loop phase
            return .playing(.fromProgress(nil, toProgress: 1, loopMode: loopMode))
        }

        switch self {
        case .intro:
            // Resumes from the current frame and plays once, then switches to the loop phase
            return .playing(.fromProgress(nil, toProgress: 1, loopMode: .playOnce))
        case .loop:
            return .playing(.fromFrame(
                AnimationFrameTime(loopFrameStart),
                toFrame: AnimationFrameTime(loopFrameEnd),
                loopMode: .loop
            ))
        }
    }
}
