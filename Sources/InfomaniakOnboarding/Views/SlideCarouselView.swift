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

struct SlideCarouselView: View {
    @Binding var selectedSlide: Int

    let slides: [Slide]
    let isScrollEnabled: Bool

    private var clampedSelectedSlide: Binding<Int> {
        Binding(
            get: { min(max(selectedSlide, 0), max(slides.count - 1, 0)) },
            set: { selectedSlide = $0 }
        )
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            SlidePagingScrollView(selectedSlide: clampedSelectedSlide, slides: slides, isScrollEnabled: isScrollEnabled)
        } else {
            SlidePagingTabView(selectedSlide: clampedSelectedSlide, slides: slides, isScrollEnabled: isScrollEnabled)
        }
    }
}
