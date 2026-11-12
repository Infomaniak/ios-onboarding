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

import SwiftUI
import UIKit

/// Configures the paging scroll view backing the enclosing page `TabView`.
/// Swiping is toggled on that scroll view only: `scrollDisabled` or a blocking gesture would also apply to the slides' bottom views.
struct PagingScrollViewConfiguratorView: UIViewRepresentable {
    let isScrollEnabled: Bool

    func makeUIView(context: Context) -> ConfiguratorView {
        ConfiguratorView()
    }

    func updateUIView(_ uiView: ConfiguratorView, context: Context) {
        uiView.isScrollEnabled = isScrollEnabled
    }

    final class ConfiguratorView: UIView {
        var isScrollEnabled = true {
            didSet {
                guard isScrollEnabled != oldValue else { return }
                configurePagingScrollView()
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
            isHidden = true
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return }
            configurePagingScrollView()
        }

        private func configurePagingScrollView() {
            var ancestor = superview
            while let view = ancestor {
                if let scrollView = view as? UIScrollView, scrollView.isPagingEnabled {
                    scrollView.isScrollEnabled = isScrollEnabled
                    return
                }
                ancestor = view.superview
            }
        }
    }
}
