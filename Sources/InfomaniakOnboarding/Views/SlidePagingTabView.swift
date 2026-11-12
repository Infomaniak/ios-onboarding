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

struct SlidePagingTabView: View {
    @Binding var selectedSlide: Int

    let slides: [Slide]
    let isScrollEnabled: Bool

    var body: some View {
        TabView(selection: $selectedSlide) {
            ForEach(slides.indices, id: \.self) { index in
                SlideView(slide: slides[index], isCurrent: index == selectedSlide)
                #if canImport(UIKit)
                    .background { PagingScrollViewConfiguratorView(isScrollEnabled: isScrollEnabled) }
                #endif
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}
