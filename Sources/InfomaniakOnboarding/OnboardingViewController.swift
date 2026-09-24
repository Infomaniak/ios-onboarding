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

import SwiftUI
import UIKit

@MainActor
public protocol OnboardingViewControllerDelegate: AnyObject {
    func currentIndexChanged(newIndex: Int)
    func bottomUIViewForIndex(_ index: Int) -> UIView?
    func bottomViewForIndex(_ index: Int) -> (any View)?
    func shouldAnimateBottomViewForIndex(_ index: Int) -> Bool
    func willDisplaySlideViewCell(_ slideViewCell: SlideCollectionViewCell, at index: Int)
}

public extension OnboardingViewControllerDelegate {
    func bottomUIViewForIndex(_ index: Int) -> UIView? {
        return nil
    }

    func bottomViewForIndex(_ index: Int) -> (any View)? {
        return nil
    }
}

public class OnboardingViewController: UIViewController {
    private enum Layout {
        static let cardCornerRadius: CGFloat = 24
        static let cardInset: CGFloat = 32
        static let cardMaximumWidth: CGFloat = 720
        static let cardMaximumHeight: CGFloat = 900
        static let minimumCardWidth: CGFloat = 768
        static let minimumCardHeight: CGFloat = 700
        static let productIconsBottomInset: CGFloat = 24
        static let productIconsSpacing: CGFloat = 24
    }

    public var currentSlideViewCell: SlideCollectionViewCell? {
        slideCarouselViewController.collectionView.visibleCells.first as? SlideCollectionViewCell
    }

    public var pageIndicator: UIPageControl {
        slideCarouselViewController.pageIndicator
    }

    public weak var delegate: OnboardingViewControllerDelegate?

    let configuration: OnboardingConfiguration

    let headerImageView: UIImageView?

    let contentContainerView = UIView()
    let stackView = UIStackView()
    let slideCarouselViewController: SlideCarouselViewController
    let bottomContainerView = UIView(frame: .zero)
    let productIconsView = ProductIconsView()

    private let backgroundGradientLayer = CAGradientLayer()
    private var edgeToEdgeConstraints = [NSLayoutConstraint]()
    private var cardConstraints = [NSLayoutConstraint]()
    private var productIconsConstraints = [NSLayoutConstraint]()
    private var usesElevatedCard: Bool?
    private var lastContentContainerSize = CGSize.zero

    var bottomViewCache: [Int: UIView] = [:]

    public init(configuration: OnboardingConfiguration) {
        slideCarouselViewController = SlideCarouselViewController(
            slides: configuration.slides,
            pageIndicatorColor: configuration.pageIndicatorColor,
            isPageIndicatorHidden: configuration.isPageIndicatorHidden
        )
        self.configuration = configuration
        if let headerImage = configuration.headerImage {
            headerImageView = UIImageView(image: headerImage)
        } else {
            headerImageView = nil
        }
        super.init(nibName: nil, bundle: nil)

        slideCarouselViewController.collectionView.isScrollEnabled = configuration.isScrollEnabled

        slideCarouselViewController.onSlideChanged = onSlideChanged(newSlideIndex:)
        slideCarouselViewController.willDisplaySlideViewCell = willDisplaySlideViewCell(_:at:)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureBackground()

        view.addSubview(contentContainerView)
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(stackView)
        view.addSubview(productIconsView)
        productIconsView.alpha = 0
        productIconsView.isHidden = true

        productIconsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        productIconsConstraints = [
            productIconsView.topAnchor.constraint(
                equalTo: contentContainerView.bottomAnchor,
                constant: Layout.productIconsSpacing
            ),
            productIconsView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Layout.productIconsBottomInset
            )
        ]

        if let headerImageView {
            contentContainerView.addSubview(headerImageView)
            headerImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerImageView.topAnchor.constraint(equalTo: contentContainerView.safeAreaLayoutGuide.topAnchor, constant: 24),
                headerImageView.centerXAnchor.constraint(equalTo: contentContainerView.centerXAnchor),
                headerImageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentContainerView.leadingAnchor, constant: 48),
                headerImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor, constant: -48)
            ])
        }

        if configuration.dismissHandler != nil {
            let closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
            contentContainerView.addSubview(closeButton)

            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 40),
                closeButton.heightAnchor.constraint(equalToConstant: 40),
                closeButton.topAnchor.constraint(equalTo: contentContainerView.safeAreaLayoutGuide.topAnchor, constant: 24),
                closeButton.leadingAnchor.constraint(equalTo: contentContainerView.safeAreaLayoutGuide.leadingAnchor, constant: 16)
            ])
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill

        stackView.addArrangedSubview(slideCarouselViewController.view)
        addChild(slideCarouselViewController)
        slideCarouselViewController.view.heightAnchor.constraint(
            equalTo: contentContainerView.heightAnchor,
            multiplier: 0.8
        ).isActive = true

        stackView.addArrangedSubview(bottomContainerView)
        bottomContainerView.heightAnchor.constraint(
            equalTo: contentContainerView.heightAnchor,
            multiplier: 0.2
        ).isActive = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor)
        ])

        configureAdaptiveConstraints()
        onSlideChanged(newSlideIndex: 0)
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCardLayout()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        productIconsView.startAnimating()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        productIconsView.stopAnimating()
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundGradientLayer.frame = view.bounds
        updateShadowPath()

        guard contentContainerView.bounds.size != lastContentContainerSize else { return }

        lastContentContainerSize = contentContainerView.bounds.size
        slideCarouselViewController.collectionView.collectionViewLayout.invalidateLayout()
        slideCarouselViewController.collectionView.layoutIfNeeded()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
        }
    }

    public func setSelectedSlide(index: Int) {
        slideCarouselViewController.setSelectedSlide(index: index)
    }

    public func reloadView(at index: Int) {
        bottomViewCache[index] = nil
        if index == slideCarouselViewController.currentSlideIndex {
            onSlideChanged(newSlideIndex: index)
        }
    }

    func resolveBottomView(newSlideIndex: Int) -> UIView {
        if let cachedView = bottomViewCache[newSlideIndex] {
            return cachedView
        }

        if let uiView = delegate?.bottomUIViewForIndex(newSlideIndex) {
            bottomViewCache[newSlideIndex] = uiView
            return uiView
        } else if let view = delegate?.bottomViewForIndex(newSlideIndex) {
            let controller = UIHostingController(rootView: AnyView(view))
            controller.view.backgroundColor = .clear

            bottomViewCache[newSlideIndex] = controller.view
            return controller.view
        } else {
            return UIView(frame: .zero)
        }
    }

    func onSlideChanged(newSlideIndex: Int) {
        let oldBottomView = bottomContainerView.subviews.last

        let newBottomView = resolveBottomView(newSlideIndex: newSlideIndex)
        newBottomView.translatesAutoresizingMaskIntoConstraints = false

        if delegate?.shouldAnimateBottomViewForIndex(newSlideIndex) ?? false {
            UIView.transition(with: bottomContainerView, duration: 0.25, options: .transitionCrossDissolve) { [weak self] in
                self?.switchBottomViews(oldBottomView: oldBottomView, newBottomView: newBottomView)
            }
        } else {
            switchBottomViews(oldBottomView: oldBottomView, newBottomView: newBottomView)
        }

        delegate?.currentIndexChanged(newIndex: newSlideIndex)
    }

    func switchBottomViews(oldBottomView: UIView?, newBottomView: UIView) {
        bottomContainerView.addSubview(newBottomView)
        oldBottomView?.removeFromSuperview()

        NSLayoutConstraint.activate([
            newBottomView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            newBottomView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
            newBottomView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            newBottomView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor)
        ])
    }

    func willDisplaySlideViewCell(_ slideViewCell: SlideCollectionViewCell, at index: Int) {
        delegate?.willDisplaySlideViewCell(slideViewCell, at: index)
    }

    @objc func didTapCloseButton() {
        configuration.dismissHandler?()
    }

    private func configureBackground() {
        view.backgroundColor = .systemBackground

        guard let backgroundGradient = configuration.backgroundGradient else { return }

        backgroundGradientLayer.startPoint = backgroundGradient.startPoint
        backgroundGradientLayer.endPoint = backgroundGradient.endPoint
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        updateGradientColors()
    }

    private func updateGradientColors() {
        backgroundGradientLayer.colors = configuration.backgroundGradient?.colors.map {
            $0.resolvedColor(with: traitCollection).cgColor
        }
    }

    private func configureAdaptiveConstraints() {
        edgeToEdgeConstraints = [
            contentContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        let widthConstraint = contentContainerView.widthAnchor.constraint(
            equalTo: view.widthAnchor,
            constant: -2 * Layout.cardInset
        )
        widthConstraint.priority = .defaultHigh

        let heightConstraint = contentContainerView.heightAnchor.constraint(
            equalTo: view.heightAnchor,
            constant: -2 * Layout.cardInset
        )
        heightConstraint.priority = .defaultHigh

        cardConstraints = [
            contentContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.cardMaximumWidth),
            contentContainerView.heightAnchor.constraint(lessThanOrEqualToConstant: Layout.cardMaximumHeight),
            widthConstraint,
            heightConstraint
        ]

        NSLayoutConstraint.activate(edgeToEdgeConstraints)
    }

    private func updateCardLayout() {
        let shouldUseElevatedCard = view.bounds.width >= Layout.minimumCardWidth
            && view.bounds.height >= Layout.minimumCardHeight
        guard shouldUseElevatedCard != usesElevatedCard else { return }

        usesElevatedCard = shouldUseElevatedCard
        NSLayoutConstraint.deactivate(shouldUseElevatedCard ? edgeToEdgeConstraints : cardConstraints)
        NSLayoutConstraint.activate(shouldUseElevatedCard ? cardConstraints : edgeToEdgeConstraints)
        if shouldUseElevatedCard {
            NSLayoutConstraint.activate(productIconsConstraints)
        } else {
            NSLayoutConstraint.deactivate(productIconsConstraints)
        }

        contentContainerView.backgroundColor = shouldUseElevatedCard ? .systemBackground : .clear
        contentContainerView.layer.cornerRadius = shouldUseElevatedCard ? Layout.cardCornerRadius : 0
        contentContainerView.layer.shadowColor = shouldUseElevatedCard ? UIColor.black.cgColor : nil
        contentContainerView.layer.shadowOpacity = shouldUseElevatedCard ? 0.12 : 0
        contentContainerView.layer.shadowRadius = shouldUseElevatedCard ? 24 : 0
        contentContainerView.layer.shadowOffset = CGSize(width: 0, height: 12)
        stackView.layer.cornerRadius = shouldUseElevatedCard ? Layout.cardCornerRadius : 0
        stackView.clipsToBounds = shouldUseElevatedCard

        productIconsView.isHidden = !shouldUseElevatedCard
        UIView.animate(withDuration: 0.2) {
            self.productIconsView.alpha = shouldUseElevatedCard ? 1 : 0
        }
    }

    private func updateShadowPath() {
        guard usesElevatedCard == true else {
            contentContainerView.layer.shadowPath = nil
            return
        }

        contentContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: contentContainerView.bounds,
            cornerRadius: Layout.cardCornerRadius
        ).cgPath
    }
}
