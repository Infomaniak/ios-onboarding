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

    var body: some View {
        VStack {
            SlideIllustrationView(content: slide.content, isCurrent: isCurrent)
                .frame(maxWidth: OnboardingLayout.illustrationMaxWidth)
                .padding(.top, OnboardingLayout.Padding.large)
                .frame(maxWidth: .infinity)
                .background {
                    slide.backgroundImage
                        .resizable()
                        .renderingMode(slide.backgroundImageTintColor == nil ? .original : .template)
                        .foregroundStyle(slide.backgroundImageTintColor ?? .clear)
                        .accessibilityHidden(true)
                        .ignoresSafeArea(edges: .top)
                }

            slide.bottomView
                .frame(maxHeight: .infinity)
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
        isCurrent: true
    )
}
