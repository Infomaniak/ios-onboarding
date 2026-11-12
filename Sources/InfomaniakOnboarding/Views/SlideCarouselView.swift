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
    @State private var currentIndex: Int

    @Binding var selectedSlide: Int

    let slides: [Slide]
    let isScrollEnabled: Bool
    let pageIndicatorColor: Color?
    let isPageIndicatorHidden: Bool
    let safeAreaInsets: EdgeInsets

    private var isPageIndicatorVisible: Bool {
        !isPageIndicatorHidden && slides.count > 1
    }

    init(
        selectedSlide: Binding<Int>,
        slides: [Slide],
        isScrollEnabled: Bool,
        pageIndicatorColor: Color?,
        isPageIndicatorHidden: Bool,
        safeAreaInsets: EdgeInsets
    ) {
        _selectedSlide = selectedSlide
        _currentIndex = State(initialValue: min(max(selectedSlide.wrappedValue, 0), max(slides.count - 1, 0)))
        self.slides = slides
        self.isScrollEnabled = isScrollEnabled
        self.pageIndicatorColor = pageIndicatorColor
        self.isPageIndicatorHidden = isPageIndicatorHidden
        self.safeAreaInsets = safeAreaInsets
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(slides.indices, id: \.self) { index in
                SlideView(slide: slides[index], isCurrent: index == currentIndex, safeAreaInsets: safeAreaInsets)
                    .background { PagingScrollViewConfiguratorView(isScrollEnabled: isScrollEnabled) }
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            if isPageIndicatorVisible {
                PageIndicatorView(
                    currentPage: $currentIndex,
                    numberOfPages: slides.count,
                    currentPageColor: pageIndicatorColor
                )
                .padding(.bottom, OnboardingLayout.Padding.extraLarge)
            }
        }
        .onChange(of: selectedSlide) { newValue in
            guard slides.indices.contains(newValue) else {
                selectedSlide = currentIndex
                return
            }
            guard newValue != currentIndex else { return }
            withAnimation { currentIndex = newValue }
        }
        .onAppear {
            if selectedSlide != currentIndex {
                selectedSlide = currentIndex
            }
        }
        .onChange(of: currentIndex) { newValue in
            if selectedSlide != newValue {
                selectedSlide = newValue
            }
        }
        .onChange(of: slides.count) { newCount in
            let clampedIndex = min(max(currentIndex, 0), max(newCount - 1, 0))
            if clampedIndex != currentIndex {
                currentIndex = clampedIndex
            }
        }
    }
}
