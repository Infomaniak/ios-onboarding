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
        case .airbnbLottieAnimationView(let animationView, _):
            guard !animationView.isAnimationPlaying else { return }

            if let fromFrame = animationState?.fromFrame,
               let toFrame = animationState?.toFrame
            {
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
    private enum Layout {
        static let horizontalMargin: CGFloat = 24
        static let illustrationToBottomViewSpacing: CGFloat = 24
    }

    @IBOutlet public private(set) var backgroundImageView: UIImageView!
    @IBOutlet public private(set) var illustrationAnimationView: UIView!
    @IBOutlet public private(set) var bottomView: UIView!
    @IBOutlet public private(set) var illustrationImageView: UIImageView!

    public private(set) var illustrationAnimationViewContent: IllustrationAnimationViewContent?

    private var airbnbDotLottieLoaded = false
    private var onAirbnbDotLottieLoaded: (() -> Void)?
    private var illustrationAspectRatioConstraint: NSLayoutConstraint?
    private var bottomViewAbovePageIndicatorConstraint: NSLayoutConstraint?
    private static let bottomViewBottomSpacing: CGFloat = 48

    private func applyBottomViewBottomSpacing() {
        for constraint in contentView.constraints
            where constraint.firstItem === contentView && constraint.firstAttribute == .bottom
            && constraint.secondItem === bottomView && constraint.secondAttribute == .bottom
        {
            constraint.constant = Self.bottomViewBottomSpacing
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        illustrationImageView.image = nil
        illustrationAnimationViewContent?.prepareForReuse()
        illustrationAnimationViewContent = nil
        illustrationAspectRatioConstraint?.isActive = false
        illustrationAspectRatioConstraint = nil
        for view in bottomView.subviews {
            view.removeFromSuperview()
        }
    }

    func configureCell(slide: Slide) {
        applyBottomViewBottomSpacing()
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
            animationView.contentMode = animationConfiguration.contentMode
            illustrationAnimationViewContent = .airbnbLottieAnimationView(animationView, animationConfiguration)
            addAnimationContentView(animationView)

            switch animationConfiguration.animationType {
            case .json:
                let jsonAnimation = LottieAnimation.named(animationConfiguration.filename, bundle: animationConfiguration.bundle)
                animationView.animation = jsonAnimation
                constrainIllustrationAspectRatio(of: animationView, to: animationView.intrinsicContentSize)
            case .dotLottie:
                Task {
                    airbnbDotLottieLoaded = false

                    let dotLottieAnimation = try await DotLottieFile.named(
                        animationConfiguration.filename,
                        bundle: animationConfiguration.bundle
                    )
                    animationView.loadAnimation(from: dotLottieAnimation)
                    constrainIllustrationAspectRatio(of: animationView, to: animationView.intrinsicContentSize)

                    onAirbnbDotLottieLoaded?()
                    onAirbnbDotLottieLoaded = nil
                    airbnbDotLottieLoaded = true
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
            animationView.topAnchor.constraint(greaterThanOrEqualTo: illustrationAnimationView.topAnchor),
            animationView.bottomAnchor.constraint(
                equalTo: illustrationAnimationView.bottomAnchor,
                constant: -Layout.illustrationToBottomViewSpacing
            ),
            animationView.leadingAnchor.constraint(equalTo: illustrationAnimationView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: illustrationAnimationView.trailingAnchor)
        ])

        let fillContainer = animationView.topAnchor.constraint(equalTo: illustrationAnimationView.topAnchor)
        fillContainer.priority = .defaultLow
        fillContainer.isActive = true
    }

    private func constrainIllustrationAspectRatio(of animationView: UIView, to size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        illustrationAspectRatioConstraint?.isActive = false

        let constraint = animationView.heightAnchor.constraint(
            equalTo: animationView.widthAnchor,
            multiplier: size.height / size.width
        )
        constraint.isActive = true
        illustrationAspectRatioConstraint = constraint
    }

    func resumePlaying(animationState: AnimationState?) {
        switch illustrationAnimationViewContent {
        case .airbnbLottieAnimationView(_, let configuration):
            guard configuration.animationType == .dotLottie else {
                illustrationAnimationViewContent?.resumePlaying(animationState: animationState)
                return
            }

            if airbnbDotLottieLoaded {
                illustrationAnimationViewContent?.resumePlaying(animationState: animationState)
            } else {
                onAirbnbDotLottieLoaded = { [weak self] in
                    self?.illustrationAnimationViewContent?.resumePlaying(animationState: animationState)
                }
            }
        default:
            illustrationAnimationViewContent?.resumePlaying(animationState: animationState)
        }
    }

    func pausePlaying() {
        illustrationAnimationViewContent?.pausePlaying()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        constrainForegroundInsideSafeArea()
    }

    private func constrainForegroundInsideSafeArea() {
        let safeArea = contentView.safeAreaLayoutGuide

        for illustration in [illustrationAnimationView, illustrationImageView].compactMap({ $0 }) {
            NSLayoutConstraint.activate([
                illustration.leadingAnchor.constraint(
                    greaterThanOrEqualTo: safeArea.leadingAnchor,
                    constant: Layout.horizontalMargin
                ),
                illustration.trailingAnchor.constraint(
                    lessThanOrEqualTo: safeArea.trailingAnchor,
                    constant: -Layout.horizontalMargin
                )
            ])
        }

        if let illustrationContainer = illustrationAnimationView.superview, illustrationContainer !== contentView {
            deactivateContentViewConstraints(involving: illustrationContainer, attributes: [.centerX])
            illustrationContainer.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        }

        deactivateContentViewConstraints(involving: bottomView, attributes: [.leading, .trailing])
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Layout.horizontalMargin),
            bottomView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Layout.horizontalMargin)
        ])
    }

    private func deactivateContentViewConstraints(involving view: UIView, attributes: Set<NSLayoutConstraint.Attribute>) {
        for constraint in contentView.constraints
            where (constraint.firstItem === view || constraint.secondItem === view)
            && attributes.contains(constraint.firstAttribute)
        {
            constraint.isActive = false
        }
    }

    func constrainBottomView(above pageIndicator: UIView, spacing: CGFloat = 24) {
        guard bottomViewAbovePageIndicatorConstraint == nil else { return }

        let constraint = bottomView.bottomAnchor.constraint(
            lessThanOrEqualTo: pageIndicator.topAnchor,
            constant: -spacing
        )
        constraint.isActive = true
        bottomViewAbovePageIndicatorConstraint = constraint
    }
}
