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
import Lottie
import UIKit

struct AnimationState {
    let fromFrame: AnimationFrameTime?
    let toFrame: AnimationFrameTime?
}

public class SlideCollectionViewCell: UICollectionViewCell {
    @IBOutlet public private(set) weak var backgroundImageView: UIImageView!
    @IBOutlet public private(set) weak var illustrationAnimationView: LottieAnimationView!
    @IBOutlet public private(set) weak var bottomView: UIView!
    @IBOutlet public private(set) weak var illustrationImageView: UIImageView!

    var configuration: IKLottieConfiguration?

    override public func prepareForReuse() {
        super.prepareForReuse()
        illustrationImageView.image = nil
        illustrationAnimationView.animation = nil
        illustrationAnimationView.configuration = LottieConfiguration()
        for view in bottomView.subviews {
            view.removeFromSuperview()
        }
    }

    func configureCell(slide: Slide) {
        backgroundImageView.image = slide.backgroundImage
        backgroundImageView.tintColor = slide.backgroundImageTintColor

        switch slide.content {
        case .illustration(let image):
            illustrationAnimationView.isHidden = true
            illustrationImageView.isHidden = false
            illustrationImageView.image = image
        case .animation(let animationConfiguration):
            illustrationAnimationView.isHidden = false
            illustrationImageView.isHidden = true

            configuration = animationConfiguration
            illustrationAnimationView.configuration = animationConfiguration.lottieConfiguration

            switch animationConfiguration.animationType {
            case .json:
                let jsonAnimation = LottieAnimation.named(animationConfiguration.filename, bundle: animationConfiguration.bundle)
                illustrationAnimationView.animation = jsonAnimation
            case .dotLottie:
                Task {
                    let dotLottieAnimation = try await DotLottieFile.asset(
                        named: animationConfiguration.filename,
                        bundle: animationConfiguration.bundle
                    )
                    illustrationAnimationView.loadAnimation(from: dotLottieAnimation)
                }
            }
        }

        if let slideBottomView = slide.bottomViewController.view {
            slideBottomView.backgroundColor = .clear
            slideBottomView.isOpaque = false

            bottomView.addSubview(slideBottomView)
            slideBottomView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                slideBottomView.topAnchor.constraint(equalTo: bottomView.topAnchor),
                slideBottomView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
                slideBottomView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
                slideBottomView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor)
            ])
        }
    }

    func resumePlaying(animationState: AnimationState?) {
        guard let configuration,
              !illustrationAnimationView.isAnimationPlaying else { return }

        if let fromFrame = animationState?.fromFrame,
           let toFrame = animationState?.toFrame {
            illustrationAnimationView.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: .playOnce) { [weak self] _ in
                self?.afterInitialLoopPlay(configuration: configuration)
            }
        } else {
            illustrationAnimationView.play { [weak self] _ in
                self?.afterInitialLoopPlay(configuration: configuration)
            }
        }
    }

    func afterInitialLoopPlay(configuration: IKLottieConfiguration) {
        guard let loopFrameStart = configuration.loopFrameStart,
              let loopFrameEnd = configuration.loopFrameEnd else { return }

        illustrationAnimationView.play(
            fromFrame: AnimationFrameTime(loopFrameStart),
            toFrame: AnimationFrameTime(loopFrameEnd),
            loopMode: .loop
        )
    }

    func pausePlaying() {
        guard illustrationAnimationView.isAnimationPlaying else { return }
        illustrationAnimationView.pause()
    }
}
