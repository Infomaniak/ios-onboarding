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

import UIKit

final class ProductIconsView: UIStackView {
    private enum Layout {
        static let animationDuration: TimeInterval = 0.6
        static let iconSize: CGFloat = 44
        static let pauseBetweenIcons: UInt64 = 1_000_000_000
        static let spacing: CGFloat = 12
    }

    private static let iconNames = [
        "mail",
        "kdrive",
        "kmeet",
        "swisstransfer",
        "authenticator",
        "euria"
    ]

    private var animationTask: Task<Void, Never>?

    init() {
        super.init(frame: .zero)

        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        spacing = Layout.spacing
        translatesAutoresizingMaskIntoConstraints = false

        for iconName in Self.iconNames {
            let imageView = UIImageView(image: Self.loadIcon(named: iconName))
            imageView.contentMode = .scaleAspectFit
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowOpacity = 0.16
            imageView.layer.shadowRadius = 5
            imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
                imageView.heightAnchor.constraint(equalToConstant: Layout.iconSize)
            ])
            addArrangedSubview(imageView)
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        guard animationTask == nil, !UIAccessibility.isReduceMotionEnabled else { return }

        animationTask = Task { @MainActor [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                for iconView in arrangedSubviews {
                    guard !Task.isCancelled else { return }

                    await animate(iconView, transform: CGAffineTransform(scaleX: 1.12, y: 1.12))
                    await animate(iconView, transform: .identity)
                    try? await Task.sleep(nanoseconds: Layout.pauseBetweenIcons)
                }
            }
        }
    }

    func stopAnimating() {
        animationTask?.cancel()
        animationTask = nil
        arrangedSubviews.forEach { $0.layer.removeAllAnimations() }
    }

    private func animate(_ view: UIView, transform: CGAffineTransform) async {
        await withCheckedContinuation { continuation in
            UIView.animate(
                withDuration: Layout.animationDuration,
                delay: 0,
                options: [.allowUserInteraction, .curveEaseInOut]
            ) {
                view.transform = transform
            } completion: { _ in
                continuation.resume()
            }
        }
    }

    private static func loadIcon(named name: String) -> UIImage? {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: "png",
            subdirectory: "ProductIcons"
        ) else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }
}
