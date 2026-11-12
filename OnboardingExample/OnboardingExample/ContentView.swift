/*
 Infomaniak Onboarding - iOS
 Copyright (C) 2024 Infomaniak Network SA

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

import InfomaniakOnboarding
import Lottie
import SwiftUI

struct ContentView: View {
    @State private var selectedSlide = 0

    private let slides: [Slide] = [
        Slide(
            backgroundImage: Image("onboarding-background-1"),
            content: .animation(IKLottieConfiguration(
                id: 1,
                filename: "illu_onboarding_1",
                bundle: .main,
                loopFrameStart: 54,
                loopFrameEnd: 138,
                lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
            ))
        ) {
            Text("Choisissez votre thème")
        },
        Slide(
            backgroundImage: Image("onboarding-background-2"),
            content: .animation(IKLottieConfiguration(
                id: 2,
                filename: "illu_onboarding_2",
                bundle: .main,
                loopFrameStart: 108,
                loopFrameEnd: 253,
                lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
            ))
        ) {
            VStack {
                Text("Gagnez du temps avec les actions de balayage")
                Text("Personnalisez librement vos raccourcis dans les paramètres de l'app.")
            }
        },
        Slide(
            backgroundImage: Image("onboarding-background-3"),
            content: .animation(IKLottieConfiguration(
                id: 3,
                filename: "illu_onboarding_3",
                bundle: .main,
                loopFrameStart: 111,
                loopFrameEnd: 187,
                lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
            ))
        ) {
            VStack {
                Text("Appuyez quelques secondes sur un message pour en sélectionner plusieurs")
                Text("Archivez, supprimez, déplacez ou mettez en favoris plusieurs messages en une fois.")
            }
        },
        Slide(
            backgroundImage: Image("onboarding-background-4"),
            content: .animation(IKLottieConfiguration(
                id: 4,
                filename: "illu_onboarding_4",
                bundle: .main,
                loopFrameStart: 127,
                loopFrameEnd: 236,
                lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
            ))
        ) {
            VStack {
                Text("Lancez vous !")
                Text("Créez une adresse gratuite ou connectez-vous à un compte Infomaniak existant.")
            }
        }
    ]

    private var configuration: OnboardingConfiguration {
        OnboardingConfiguration(
            headerImage: Image("logo-text"),
            slides: slides,
            pageIndicatorColor: .accentColor,
            isScrollEnabled: true,
            dismissHandler: {},
            isPageIndicatorHidden: false
        )
    }

    private var lastSlideIndex: Int {
        slides.count - 1
    }

    var body: some View {
        OnboardingCarouselView(
            configuration: configuration,
            selectedSlide: $selectedSlide,
            shouldAnimateBottomViewForIndex: { $0 == lastSlideIndex }
        ) { index in
            if index == lastSlideIndex {
                Button("Commencer") {}
                    .buttonStyle(.borderedProminent)
            } else {
                Button("Suivant") {
                    selectedSlide += 1
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ContentView()
}
