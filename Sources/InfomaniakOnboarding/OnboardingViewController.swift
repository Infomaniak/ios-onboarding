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
    public var currentSlideViewCell: SlideCollectionViewCell? {
        slideCarouselViewController.collectionView.visibleCells.first as? SlideCollectionViewCell
    }

    public var pageIndicator: UIPageControl {
        slideCarouselViewController.pageIndicator
    }

    let configuration: OnboardingConfiguration

    let headerImageView: UIImageView?

    let stackView = UIStackView()
    let slideCarouselViewController: SlideCarouselViewController
    let bottomContainerView = UIView(frame: .zero)

    public weak var delegate: OnboardingViewControllerDelegate?

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

        view.addSubview(stackView)
        if let headerImageView {
            view.addSubview(headerImageView)
            headerImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                headerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                headerImageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 48),
                headerImageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -48)
            ])
        }
        if let dismissAction = configuration.dismissHandler {
            let closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
            view.addSubview(closeButton)

            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 40),
                closeButton.heightAnchor.constraint(equalToConstant: 40),
                closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
            ])
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally

        stackView.addArrangedSubview(slideCarouselViewController.view)
        addChild(slideCarouselViewController)
        slideCarouselViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true

        stackView.addArrangedSubview(bottomContainerView)
        bottomContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        onSlideChanged(newSlideIndex: 0)
    }

    public func setSelectedSlide(index: Int) {
        slideCarouselViewController.setSelectedSlide(index: index)
    }

    func resolveBottomView(newSlideIndex: Int) -> UIView {
        if let uiView = delegate?.bottomUIViewForIndex(newSlideIndex) {
            return uiView
        } else if let view = delegate?.bottomViewForIndex(newSlideIndex) {
            let controller = UIHostingController(rootView: AnyView(view))
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
}
