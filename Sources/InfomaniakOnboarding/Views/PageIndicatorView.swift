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

struct PageIndicatorView: View {
    @Binding var currentPage: Int

    let numberOfPages: Int
    let currentPageColor: Color?

    var body: some View {
        HStack(spacing: OnboardingLayout.pageIndicatorDotSize) {
            ForEach(0 ..< numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? currentPageColor ?? .accentColor : Color(uiColor: .systemGray4))
                    .frame(width: OnboardingLayout.pageIndicatorDotSize, height: OnboardingLayout.pageIndicatorDotSize)
            }
        }
        .padding(OnboardingLayout.Padding.small)
        .contentShape(Rectangle())
        .onTapGesture(coordinateSpace: .local) { location in
            // Like UIPageControl, a tap moves one page toward the tapped side of the current dot
            let dotSize = OnboardingLayout.pageIndicatorDotSize
            let currentDotCenterX = OnboardingLayout.Padding.small + dotSize * CGFloat(2 * currentPage) + dotSize / 2
            withAnimation {
                if location.x < currentDotCenterX {
                    currentPage = max(currentPage - 1, 0)
                } else {
                    currentPage = min(currentPage + 1, numberOfPages - 1)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(currentPage + 1) / \(numberOfPages)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                currentPage = min(currentPage + 1, numberOfPages - 1)
            case .decrement:
                currentPage = max(currentPage - 1, 0)
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    PageIndicatorView(currentPage: .constant(1), numberOfPages: 4, currentPageColor: nil)
}
