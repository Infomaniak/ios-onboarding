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

/// Displays the onboarding: a header image, a paged carousel of slides and a bottom view per slide.
public struct OnboardingCarouselView<BottomView: View>: View {
    @Binding var selectedSlide: Int

    let configuration: OnboardingConfiguration
    let shouldAnimateBottomViewForIndex: (Int) -> Bool
    let bottomView: (Int) -> BottomView

    private var displayedSlide: Int {
        min(max(selectedSlide, 0), max(configuration.slides.count - 1, 0))
    }

    /// - Parameters:
    ///   - configuration: The onboarding configuration (slides, header, page indicator…)
    ///   - selectedSlide: The index of the displayed slide. Updated when the user swipes; set it to scroll programmatically.
    ///   - shouldAnimateBottomViewForIndex: Whether the bottom view should cross-fade when the slide at this index appears.
    ///   - bottomView: The view displayed under the carousel for a given slide index.
    public init(
        configuration: OnboardingConfiguration,
        selectedSlide: Binding<Int>,
        shouldAnimateBottomViewForIndex: @escaping (Int) -> Bool = { _ in false },
        @ViewBuilder bottomView: @escaping (Int) -> BottomView
    ) {
        _selectedSlide = selectedSlide
        self.configuration = configuration
        self.shouldAnimateBottomViewForIndex = shouldAnimateBottomViewForIndex
        self.bottomView = bottomView
    }

    public var body: some View {
        GeometryReader { proxy in
            let fullHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            VStack(spacing: 0) {
                SlideCarouselView(
                    selectedSlide: $selectedSlide,
                    slides: configuration.slides,
                    isScrollEnabled: configuration.isScrollEnabled,
                    pageIndicatorColor: configuration.pageIndicatorColor,
                    isPageIndicatorHidden: configuration.isPageIndicatorHidden,
                    safeAreaInsets: proxy.safeAreaInsets
                )
                .frame(height: fullHeight * OnboardingLayout.carouselHeightRatio)

                // The outgoing and incoming bottom views overlap during the cross-fade
                ZStack {
                    if !configuration.slides.isEmpty {
                        bottomView(displayedSlide)
                            .id(displayedSlide)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, proxy.safeAreaInsets.bottom)
                .animation(
                    shouldAnimateBottomViewForIndex(displayedSlide)
                        ? .easeInOut(duration: OnboardingLayout.bottomViewAnimationDuration)
                        : nil,
                    value: displayedSlide
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .top) {
                if let headerImage = configuration.headerImage {
                    OnboardingHeaderView(image: headerImage)
                        .padding(.top, proxy.safeAreaInsets.top + OnboardingLayout.Padding.large)
                        .padding(.leading, proxy.safeAreaInsets.leading)
                        .padding(.trailing, proxy.safeAreaInsets.trailing)
                }
            }
            .overlay(alignment: .topLeading) {
                if let dismissHandler = configuration.dismissHandler {
                    OnboardingCloseButton(action: dismissHandler)
                        .padding(.top, proxy.safeAreaInsets.top + OnboardingLayout.Padding.large)
                        .padding(.leading, proxy.safeAreaInsets.leading + OnboardingLayout.Padding.medium)
                }
            }
            // Like the historical UIKit layout, the onboarding covers the whole screen and applies safe area insets explicitly
            .ignoresSafeArea()
        }
    }
}

public extension OnboardingCarouselView where BottomView == EmptyView {
    init(configuration: OnboardingConfiguration, selectedSlide: Binding<Int>) {
        self.init(configuration: configuration, selectedSlide: selectedSlide) { _ in EmptyView() }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var selectedSlide = 0

    let slides = (0 ..< 3).map { index in
        Slide(
            backgroundImage: Image(systemName: "rectangle.fill"),
            backgroundImageTintColor: [Color.blue, .green, .orange][index],
            content: .illustration(Image(systemName: "star.fill")),
            bottomView: VStack {
                Text("Slide \(index + 1)").font(.title)
                Text("Description of the slide").multilineTextAlignment(.center)
            }
        )
    }

    OnboardingCarouselView(
        configuration: OnboardingConfiguration(
            headerImage: Image(systemName: "hand.wave.fill"),
            slides: slides,
            dismissHandler: {}
        ),
        selectedSlide: $selectedSlide,
        shouldAnimateBottomViewForIndex: { _ in true }
    ) { index in
        Button("Next") { selectedSlide = min(index + 1, slides.count - 1) }
            .buttonStyle(.borderedProminent)
    }
}
