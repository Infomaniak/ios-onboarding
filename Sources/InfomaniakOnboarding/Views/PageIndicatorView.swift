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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< numberOfPages, id: \.self) { page in
                Button {
                    withAnimation {
                        if page < currentPage {
                            currentPage -= 1
                        } else if page > currentPage {
                            currentPage += 1
                        }
                    }
                } label: {
                    Circle()
                        .fill(page == currentPage ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary))
                        .frame(width: OnboardingLayout.pageIndicatorDotSize, height: OnboardingLayout.pageIndicatorDotSize)
                        .padding(.horizontal, OnboardingLayout.pageIndicatorDotSize / 2)
                        .padding(.vertical, OnboardingLayout.Padding.small)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, OnboardingLayout.Padding.small - OnboardingLayout.pageIndicatorDotSize / 2)
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(currentPage + 1) / \(numberOfPages)")
        .accessibilityAdjustableAction { direction in
            withAnimation {
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
}

#Preview {
    PageIndicatorView(currentPage: .constant(1), numberOfPages: 4)
}
