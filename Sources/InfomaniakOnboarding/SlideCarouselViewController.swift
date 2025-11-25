//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import Foundation
import Lottie
import SwiftUI
import UIKit

class SlideCarouselViewController: UICollectionViewController {
    let slideCellIdentifier = "SlideCollectionViewCell"

    let slides: [Slide]
    let pageIndicator: UIPageControl
    let isPageIndicatorHidden: Bool

    var onSlideChanged: ((Int) -> Void)?
    var willDisplaySlideViewCell: ((SlideCollectionViewCell, Int) -> Void)?

    var animationStateForSlide = [IndexPath: AnimationState]()

    var currentSlideIndex = 0 {
        didSet {
            guard oldValue != currentSlideIndex else { return }

            pageIndicator.currentPage = currentSlideIndex
            onSlideChanged?(currentSlideIndex)
        }
    }

    init(slides: [Slide], pageIndicatorColor: UIColor?, isPageIndicatorHidden: Bool) {
        self.slides = slides
        self.isPageIndicatorHidden = isPageIndicatorHidden
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInsetReference = .fromContentInset

        pageIndicator = UIPageControl(frame: .zero)
        if !isPageIndicatorHidden {
            pageIndicator.numberOfPages = slides.count
            pageIndicator.pageIndicatorTintColor = .systemGray4
            pageIndicator.currentPageIndicatorTintColor = pageIndicatorColor
        }

        super.init(collectionViewLayout: layout)
        collectionView.register(
            UINib(nibName: slideCellIdentifier, bundle: Bundle.module),
            forCellWithReuseIdentifier: slideCellIdentifier
        )
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPrefetchingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear

        pageIndicator.addTarget(self, action: #selector(pageChanged), for: .valueChanged)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addPageIndicatorIfNeeded()
    }

    func addPageIndicatorIfNeeded() {
        guard slides.count > 1 else { return }
        view.addSubview(pageIndicator)

        pageIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            pageIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc func pageChanged() {
        setSelectedSlide(index: pageIndicator.currentPage)
    }

    func setSelectedSlide(index: Int) {
        guard index < slides.count,
              index != currentSlideIndex else { return }

        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let currentIndexPath = IndexPath(row: pageIndicator.currentPage, section: 0)
        if #available(iOS 16, *) {
            coordinator.animate { _ in
                self.collectionView?.collectionViewLayout.invalidateLayout()
            } completion: { _ in
                self.collectionView.scrollToItem(at: currentIndexPath, at: .left, animated: false)
            }
        } else {
            coordinator.animate { _ in
            } completion: { _ in
                self.collectionView?.collectionViewLayout.invalidateLayout()
                self.collectionView.scrollToItem(at: currentIndexPath, at: .left, animated: false)
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)

        guard !pageIndex.isNaN, pageIndex >= 0 else { return }

        currentSlideIndex = Int(pageIndex)
    }
}

extension SlideCarouselViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: slideCellIdentifier, for: indexPath) as? SlideCollectionViewCell
        else {
            fatalError("Only \(slideCellIdentifier) are supported")
        }

        cell.configureCell(slide: slides[indexPath.row])
        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? SlideCollectionViewCell else { return }

        let animationState = animationStateForSlide[indexPath]
        cell.resumePlaying(animationState: animationState)
        willDisplaySlideViewCell?(cell, indexPath.row)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let cell = cell as? SlideCollectionViewCell else { return }
        cell.pausePlaying()
        animationStateForSlide[indexPath] = AnimationState(
            fromFrame: cell.illustrationAnimationView.currentFrame,
            toFrame: cell.illustrationAnimationView.animation?.endFrame
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }
}

extension SlideCarouselViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
