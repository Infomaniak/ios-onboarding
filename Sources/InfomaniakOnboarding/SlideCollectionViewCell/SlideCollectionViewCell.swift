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

import DotLottie
import Foundation
import Lottie
import UIKit

struct AnimationState {
    let fromFrame: AnimationFrameTime?
    let toFrame: AnimationFrameTime?
}

@MainActor
public enum IllustrationAnimationViewContent {
    case airbnbLottieAnimationView(LottieAnimationView, IKLottieConfiguration)
    case dotLottieAnimationView(DotLottieAnimationView, IKDotLottieConfiguration)

    var animationState: AnimationState {
        switch self {
        case .airbnbLottieAnimationView(let animationView, _):
            let currentFrame = animationView.currentFrame
            let toFrame = animationView.animation?.endFrame
            return AnimationState(fromFrame: currentFrame, toFrame: toFrame)
        case .dotLottieAnimationView(let dotLottieView, _):
            let currentFrame = dotLottieView.dotLottieViewModel.currentFrame()
            return AnimationState(fromFrame: AnimationFrameTime(currentFrame), toFrame: 0)
        }
    }

    func prepareForReuse() {
        switch self {
        case .airbnbLottieAnimationView(let animationView, _):
            animationView.removeFromSuperview()
        case .dotLottieAnimationView(let dotLottieView, _):
            dotLottieView.removeFromSuperview()
        }
    }

    func resumePlaying(animationState: AnimationState?) {
        switch self {
        case .airbnbLottieAnimationView(let animationView, let configuration):
            guard !animationView.isAnimationPlaying else { return }

            if let fromFrame = animationState?.fromFrame,
               let toFrame = animationState?.toFrame {
                animationView.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: .playOnce) { _ in
                    afterInitialLoopPlay()
                }
            } else {
                animationView.play { _ in
                    afterInitialLoopPlay()
                }
            }
        case .dotLottieAnimationView(let dotLottieView, _):
            guard !dotLottieView.dotLottieViewModel.isPlaying() else { return }
            if let fromFrame = animationState?.fromFrame {
                dotLottieView.dotLottieViewModel.play(fromFrame: Float(fromFrame))
            } else {
                dotLottieView.dotLottieViewModel.play()
            }
        }
    }

    private func afterInitialLoopPlay() {
        switch self {
        case .airbnbLottieAnimationView(let animationView, let configuration):
            guard let loopFrameStart = configuration.loopFrameStart,
                  let loopFrameEnd = configuration.loopFrameEnd else { return }

            animationView.play(
                fromFrame: AnimationFrameTime(loopFrameStart),
                toFrame: AnimationFrameTime(loopFrameEnd),
                loopMode: .loop
            )
        case .dotLottieAnimationView:
            break
        }
    }

    func pausePlaying() {
        switch self {
        case .airbnbLottieAnimationView(let animationView, _):
            guard animationView.isAnimationPlaying else { return }
            animationView.pause()
        case .dotLottieAnimationView(let dotLottieView, _):
            guard dotLottieView.dotLottieViewModel.isPlaying() else { return }
            dotLottieView.dotLottieViewModel.pause()
        }
    }
}

public class SlideCollectionViewCell: UICollectionViewCell {
    @IBOutlet public private(set) weak var backgroundImageView: UIImageView!
    @IBOutlet public private(set) weak var illustrationAnimationView: UIView!
    @IBOutlet public private(set) weak var bottomView: UIView!
    @IBOutlet public private(set) weak var illustrationImageView: UIImageView!

    public private(set) var illustrationAnimationViewContent: IllustrationAnimationViewContent?

    override public func prepareForReuse() {
        super.prepareForReuse()
        illustrationImageView.image = nil
        illustrationAnimationViewContent?.prepareForReuse()
        illustrationAnimationViewContent = nil
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

            let animationView = LottieAnimationView()
            animationView.configuration = animationConfiguration.lottieConfiguration
            illustrationAnimationViewContent = .airbnbLottieAnimationView(animationView, animationConfiguration)
            addAnimationContentView(animationView)

            switch animationConfiguration.animationType {
            case .json:
                let jsonAnimation = LottieAnimation.named(animationConfiguration.filename, bundle: animationConfiguration.bundle)
                animationView.animation = jsonAnimation
            case .dotLottie:
                Task {
                    let dotLottieAnimation = try await DotLottieFile.named(
                        animationConfiguration.filename,
                        bundle: animationConfiguration.bundle
                    )
                    animationView.loadAnimation(from: dotLottieAnimation)
                }
            }
        case .dotLottieAnimation(let dotLottieConfiguration):
            illustrationAnimationView.isHidden = false
            illustrationImageView.isHidden = true

            let dotLottieView: DotLottieAnimationView = DotLottieAnimation(
                fileName: dotLottieConfiguration.filename,
                bundle: dotLottieConfiguration.bundle,
                config: AnimationConfig(loop: dotLottieConfiguration.isLooping, mode: dotLottieConfiguration.mode)
            ).view()

            illustrationAnimationViewContent = .dotLottieAnimationView(dotLottieView, dotLottieConfiguration)
            addAnimationContentView(dotLottieView)
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

    func addAnimationContentView(_ animationView: UIView) {
        illustrationAnimationView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: illustrationAnimationView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: illustrationAnimationView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: illustrationAnimationView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: illustrationAnimationView.trailingAnchor)
        ])
    }

    func resumePlaying(animationState: AnimationState?) {
        illustrationAnimationViewContent?.resumePlaying(animationState: animationState)
    }

    func pausePlaying() {
        illustrationAnimationViewContent?.pausePlaying()
    }
}
