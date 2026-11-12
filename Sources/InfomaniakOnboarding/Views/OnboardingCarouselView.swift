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

    private var isPageIndicatorVisible: Bool {
        !configuration.isPageIndicatorHidden && configuration.slides.count > 1
    }

    private var displayedSlide: Int {
        min(max(selectedSlide, 0), max(configuration.slides.count - 1, 0))
    }

    /// - Parameters:
    ///   - configuration: The onboarding configuration (slides, header, page indicator…)
    ///   - selectedSlide: The index of the displayed slide. Updated when the user swipes; set it to scroll programmatically, in `withAnimation` to animate.
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
        NavigationStack {
            VStack(spacing: 0) {
                SlideCarouselView(
                    selectedSlide: $selectedSlide,
                    slides: configuration.slides,
                    isScrollEnabled: configuration.isScrollEnabled
                )
                .safeAreaInset(edge: .bottom) {
                    if isPageIndicatorVisible {
                        PageIndicatorView(currentPage: $selectedSlide, numberOfPages: configuration.slides.count)
                    }
                }

                ZStack {
                    if !configuration.slides.isEmpty {
                        bottomView(displayedSlide)
                            .id(displayedSlide)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(
                    shouldAnimateBottomViewForIndex(displayedSlide)
                        ? .easeInOut(duration: OnboardingLayout.bottomViewAnimationDuration)
                        : nil,
                    value: displayedSlide
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                if let headerImage = configuration.headerImage {
                    ToolbarItem(placement: .principal) {
                        headerImage
                            .resizable()
                            .scaledToFit()
                    }
                }
                if let dismissHandler = configuration.dismissHandler {
                    ToolbarItem(placement: .cancellationAction) {
                        if #available(iOS 26.0, *) {
                            Button(role: .close, action: dismissHandler)
                        } else {
                            Button(action: dismissHandler) {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }
            }
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
        Button("Next") { withAnimation { selectedSlide = min(index + 1, slides.count - 1) } }
            .buttonStyle(.borderedProminent)
    }
}
