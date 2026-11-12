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

struct SlideView: View {
    let slide: Slide
    let isCurrent: Bool
    let safeAreaInsets: EdgeInsets

    var body: some View {
        GeometryReader { proxy in
            let backgroundHeight = proxy.size.height * OnboardingLayout.backgroundImageHeightRatio
            let illustrationTopInset = safeAreaInsets.top + OnboardingLayout.illustrationTopInset
            let illustrationHeight = max(backgroundHeight + OnboardingLayout.Padding.large - illustrationTopInset, 0)
            let illustrationWidth = min(
                proxy.size.width * OnboardingLayout.illustrationWidthRatio,
                OnboardingLayout.illustrationMaxWidth
            )

            let isIllustrationVisible = illustrationHeight >= OnboardingLayout.illustrationMinHeight

            ZStack(alignment: .top) {
                if isIllustrationVisible {
                    SlideBackgroundView(
                        image: slide.backgroundImage,
                        tintColor: slide.backgroundImageTintColor,
                        height: backgroundHeight
                    )

                    SlideIllustrationView(content: slide.content, isCurrent: isCurrent)
                        .frame(width: illustrationWidth, height: illustrationHeight, alignment: .bottom)
                        .padding(.top, illustrationTopInset)
                }

                // Without illustration, the bottom view uses the freed space under the header
                slide.bottomView
                    .padding(.leading, safeAreaInsets.leading + OnboardingLayout.Padding.small)
                    .padding(.trailing, safeAreaInsets.trailing + OnboardingLayout.Padding.small)
                    .padding(.top, isIllustrationVisible ? backgroundHeight + OnboardingLayout.Padding.huge : illustrationTopInset)
                    .padding(.bottom, OnboardingLayout.Padding.huge)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
    }
}

/// The wave behind the slide, starting at the top of the screen.
private struct SlideBackgroundView: View {
    let image: Image
    let tintColor: Color?
    let height: CGFloat

    var body: some View {
        Color.clear
            .frame(height: height)
            .background(alignment: .top) {
                image
                    .resizable()
                    .renderingMode(tintColor == nil ? .original : .template)
                    .foregroundStyle(tintColor ?? .clear)
                    .accessibilityHidden(true)
            }
    }
}

#Preview {
    SlideView(
        slide: Slide(
            backgroundImage: Image(systemName: "rectangle.fill"),
            backgroundImageTintColor: .blue,
            content: .illustration(Image(systemName: "envelope.fill"))
        ) {
            Text(verbatim: "Preview")
        },
        isCurrent: true,
        safeAreaInsets: EdgeInsets()
    )
}
