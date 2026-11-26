# InfomaniakOnboarding

A SwiftUI onboarding carousel used across Infomaniak apps: a header image, paged slides (image, Lottie or dotLottie
illustration over a tinted background wave), a page indicator and a customizable bottom view.

## Requirements

- iOS 16+
- Swift Package Manager
- Dependencies (resolved automatically): [Lottie](https://github.com/airbnb/lottie-ios) and [DotLottie](https://github.com/LottieFiles/dotlottie-ios)

## Installation

In Xcode: **File > Add Package Dependencies…** and enter `https://github.com/Infomaniak/ios-onboarding`, or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Infomaniak/ios-onboarding", from: "2.0.0")
]
```

Then add `InfomaniakOnboarding` to your target.

## Usage

```swift
import InfomaniakOnboarding
import Lottie
import SwiftUI

struct OnboardingView: View {
    @State private var selectedSlide = 0

    private let slides: [Slide] = [
        Slide(
            backgroundImage: Image("background1"),
            content: .illustration(Image("illustration1")),
            bottomView: Text("Welcome")
        ),
        Slide(
            backgroundImage: Image("background2"),
            content: .animation(IKLottieConfiguration(
                id: 1,
                filename: "animation",
                bundle: .main,
                loopFrameStart: 54,
                loopFrameEnd: 138,
                lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
            )),
            bottomView: Text("Animated")
        ),
        Slide(
            backgroundImage: Image("background3"),
            content: .dotLottieAnimation(IKDotLottieConfiguration(
                filename: "dotlottie-animation",
                bundle: .main,
                isLooping: true
            )),
            bottomView: Text("dotLottie")
        )
    ]

    private var configuration: OnboardingConfiguration {
        OnboardingConfiguration(
            headerImage: Image("logo"),
            slides: slides
        )
    }

    var body: some View {
        OnboardingCarouselView(configuration: configuration, selectedSlide: $selectedSlide)
    }
}
```

`Slide` takes the view displayed under its illustration as `bottomView`.
Use `.animation` for JSON / dotLottie V1 files (Airbnb's Lottie engine; pass `animationType: .dotLottie` for a dotLottie V1 file)
and `.dotLottieAnimation` for dotLottie V1/V2 files (DotLottie engine).

`OnboardingCarouselView` embeds its own `NavigationStack`: the header image and the close button are displayed in its toolbar.
The slides bottom views and the carousel bottom view are displayed without padding: add your own spacing in your views.

### Programmatic navigation

`selectedSlide` is a `Binding<Int>`: it is updated when the user swipes, and writing to it scrolls to the slide (wrap the change in `withAnimation` to animate it).

```swift
OnboardingCarouselView(configuration: configuration, selectedSlide: $selectedSlide)
    .onChange(of: selectedSlide) { newIndex in
        print("Now on slide \(newIndex)")
    }
```

On iOS 17+, prefer the two-parameter form `.onChange(of: selectedSlide) { _, newIndex in … }`.

### Bottom view

The `bottomView` closure builds the view displayed under the carousel (e.g. buttons) for a given slide index.
`shouldAnimateBottomViewForIndex` makes it cross-fade when the slide at that index appears.

```swift
OnboardingCarouselView(
    configuration: configuration,
    selectedSlide: $selectedSlide,
    shouldAnimateBottomViewForIndex: { $0 == configuration.slides.count - 1 }
) { index in
    if index == configuration.slides.count - 1 {
        Button("Get started") { /* finish */ }
    } else {
        Button("Next") { withAnimation { selectedSlide += 1 } }
    }
}
```

## Customization

`OnboardingConfiguration`:

```swift
OnboardingConfiguration(
    headerImage: Image("logo"),        // Image? displayed at the top
    slides: slides,
    isScrollEnabled: false,            // disable swiping between slides
    dismissHandler: { dismiss() },     // shows a close button when not nil
    isPageIndicatorHidden: true
)
```

The current page dot uses the tint color: apply `.tint(_:)` on `OnboardingCarouselView` (defaults to the app accent color).

Tint the background wave with `backgroundImageTintColor` (a `Color`; the image is then rendered as a template). Slides are plain values:
rebuild them from your SwiftUI state (color scheme, accent color…) and the view updates.

```swift
Slide(
    backgroundImage: Image("background1"),
    backgroundImageTintColor: colorScheme == .dark ? .black : .blue,
    content: .illustration(Image("illustration1")),
    bottomView: Text("Tinted")
)
```

For light / dark animation variants, pass a different `filename` depending on the color scheme: the animation reloads automatically.

Recolor parts of a Lottie animation with `colors`, each targeting a keypath in the animation.
Dynamic colors (e.g. from an asset catalog) follow the color scheme:

```swift
IKLottieConfiguration(
    id: 1,
    filename: "animation",
    bundle: .main,
    colors: [
        IKLottieColor("**.Fill 1.Color", color: .accentColor)
    ]
)
```

## UIKit

Host the carousel in a `UIHostingController`:

```swift
let onboarding = OnboardingCarouselView(configuration: configuration, selectedSlide: .constant(0))
let controller = UIHostingController(rootView: onboarding)
```

`.constant(0)` is only fine without a `bottomView`: the selection is never written back.
To observe or drive the selection from UIKit, wrap it in a small SwiftUI view that owns the `@State`.

## Migrating from 1.x (UIKit)

| 1.x (UIKit) | 2.x (SwiftUI) |
| --- | --- |
| `OnboardingViewController(configuration:)` | `OnboardingCarouselView(configuration:selectedSlide:shouldAnimateBottomViewForIndex:bottomView:)` |
| `OnboardingViewControllerDelegate.currentIndexChanged(newIndex:)` | `selectedSlide` binding + `.onChange(of:)` |
| `setSelectedSlide(index:)` | Write to the `selectedSlide` binding |
| `bottomViewForIndex` / `bottomUIViewForIndex` | `bottomView` `@ViewBuilder` closure |
| `shouldAnimateBottomViewForIndex` (delegate) | `shouldAnimateBottomViewForIndex:` parameter |
| `reloadView(at:)` | Removed, the view is reactive |
| `willDisplaySlideViewCell` / `currentSlideViewCell` | Removed: pass a `Color` as `backgroundImageTintColor` and rebuild the slides; use `IKLottieConfiguration(colors:)` to recolor Lottie animations |
| `pageIndicator` | `.tint(_:)` on `OnboardingCarouselView` for the current page dot / `isPageIndicatorHidden` in `OnboardingConfiguration` |
| `Slide(bottomViewController:)` | `Slide(bottomView:)` |
| `UIImage` (header, background, `.illustration`) | `Image` |
| `pageIndicatorColor` | `.tint(_:)` on `OnboardingCarouselView` |
| `UIColor` (`backgroundImageTintColor`) | `Color` |
| `IKLottieConfiguration.contentMode` (`UIView.ContentMode`) | SwiftUI `ContentMode` (`.fit` by default) |
| iOS 13+ | iOS 16+ |

`loopMode` of `IKLottieConfiguration` is now honoured when no loop segment is given.

Before:

```swift
struct OnboardingView: UIViewControllerRepresentable {
    @Binding var selectedSlide: Int

    func makeUIViewController(context: Context) -> OnboardingViewController {
        let controller = OnboardingViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: OnboardingViewController, context: Context) {
        controller.setSelectedSlide(index: selectedSlide)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: OnboardingViewControllerDelegate {
        // currentIndexChanged, bottomViewForIndex, shouldAnimateBottomViewForIndex…
    }
}
```

After:

```swift
OnboardingCarouselView(
    configuration: configuration,
    selectedSlide: $selectedSlide,
    shouldAnimateBottomViewForIndex: { $0 == lastIndex }
) { index in
    BottomView(index: index)
}
```

## License

GNU General Public License v3.0, see the source file headers.
