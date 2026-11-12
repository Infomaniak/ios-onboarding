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

@available(iOS 17.0, *)
struct SlidePagingScrollView: View {
    @Environment(\.isScrollEnabled) private var isScrollEnabledInEnvironment

    @State private var topSafeAreaInset: CGFloat = 0

    @Binding var selectedSlide: Int

    let slides: [Slide]
    let isScrollEnabled: Bool

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(slides.indices, id: \.self) { index in
                    SlideView(slide: slides[index], isCurrent: index == selectedSlide)
                        .environment(\.isScrollEnabled, isScrollEnabledInEnvironment)
                        .safeAreaPadding(.top, topSafeAreaInset)
                        .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: Binding<Int?>(
            get: { selectedSlide },
            set: { newValue in
                if let newValue {
                    selectedSlide = newValue
                }
            }
        ))
        .scrollDisabled(!isScrollEnabled)
        .topScrollEdgeEffectHidden()
        .ignoresSafeArea()
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.safeAreaInsets.top
        } action: { newValue in
            topSafeAreaInset = newValue
        }
    }
}
