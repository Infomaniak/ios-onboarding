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
import XCTest
@testable import InfomaniakOnboarding

final class InfomaniakOnboardingTests: XCTestCase {
    private func mode(
        _ phase: LottiePlaybackPhase,
        isPlaying: Bool = true,
        loopMode: LottieLoopMode = .playOnce,
        start: Int? = nil,
        end: Int? = nil
    ) -> LottiePlaybackMode {
        phase.playbackMode(isPlaying: isPlaying, loopMode: loopMode, loopFrameStart: start, loopFrameEnd: end)
    }

    func testPausedWhenNotPlaying() {
        XCTAssertEqual(mode(.intro, isPlaying: false), .paused(at: .currentFrame))
        XCTAssertEqual(mode(.loop, isPlaying: false, start: 1, end: 2), .paused(at: .currentFrame))
    }

    func testIntroPlaysLoopModeWithoutLoopSegment() {
        XCTAssertEqual(mode(.intro), .playing(.fromProgress(nil, toProgress: 1, loopMode: .playOnce)))
        XCTAssertEqual(mode(.intro, loopMode: .loop), .playing(.fromProgress(nil, toProgress: 1, loopMode: .loop)))
        XCTAssertEqual(
            mode(.intro, loopMode: .autoReverse),
            .playing(.fromProgress(nil, toProgress: 1, loopMode: .autoReverse))
        )
        XCTAssertEqual(
            mode(.intro, loopMode: .repeat(3)),
            .playing(.fromProgress(nil, toProgress: 1, loopMode: .repeat(3)))
        )
    }

    func testIntroPlaysOnceWithLoopSegment() {
        XCTAssertEqual(
            mode(.intro, loopMode: .loop, start: 10, end: 20),
            .playing(.fromProgress(nil, toProgress: 1, loopMode: .playOnce))
        )
    }

    func testLoopPhasePlaysLoopSegment() {
        XCTAssertEqual(
            mode(.loop, start: 10, end: 20),
            .playing(.fromFrame(10, toFrame: 20, loopMode: .loop))
        )
    }

    func testPhaseAfterIntro() {
        func phase(completed: Bool = true, start: Int?, end: Int?) -> LottiePlaybackPhase {
            .phaseAfterIntro(completed: completed, loopFrameStart: start, loopFrameEnd: end)
        }
        XCTAssertEqual(phase(start: 1, end: 2), .loop)
        XCTAssertEqual(phase(completed: false, start: 1, end: 2), .intro)
        XCTAssertEqual(phase(start: 1, end: nil), .intro)
        XCTAssertEqual(phase(start: nil, end: nil), .intro)
    }
}
