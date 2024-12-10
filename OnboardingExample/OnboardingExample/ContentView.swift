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
    var body: some View {
        OnboardingView()
            .ignoresSafeArea()
    }
}

struct OnboardingView: UIViewControllerRepresentable {
    @State var selectedSlide = 0

    func makeUIViewController(context: Context) -> OnboardingViewController {
        let slides: [Slide] = [
            Slide(
                backgroundImage: .onboardingBackground1,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(id: 1,
                                                          filename: "illu_onboarding_1",
                                                          bundle: .main,
                                                          loopFrameStart: 54,
                                                          loopFrameEnd: 138,
                                                          lottieConfiguration: LottieConfiguration(
                                                              renderingEngine: .mainThread
                                                          ))),
                bottomView: Text("Choisissez votre thème")
            ),
            Slide(
                backgroundImage: .onboardingBackground2,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 2,
                    filename: "illu_onboarding_2",
                    bundle: .main,
                    loopFrameStart: 108,
                    loopFrameEnd: 253,
                    lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
                )),
                bottomView: VStack {
                    Text("Gagnez du temps avec les actions de balayage")
                    Text("Personnalisez librement vos raccourcis dans les paramètres de l'app.")
                }
            ),
            Slide(
                backgroundImage: .onboardingBackground3,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 3,
                    filename: "illu_onboarding_3",
                    bundle: .main,
                    loopFrameStart: 111,
                    loopFrameEnd: 187,
                    lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
                )),
                bottomView: VStack {
                    Text("Appuyez quelques secondes sur un message pour en sélectionner plusieurs")
                    Text("Archivez, supprimez, déplacez ou mettez en favoris plusieurs messages en une fois.")
                }
            ),
            Slide(
                backgroundImage: .onboardingBackground4,
                backgroundImageTintColor: nil,
                content: .animation(IKLottieConfiguration(
                    id: 4,
                    filename: "illu_onboarding_4",
                    bundle: .main,
                    loopFrameStart: 127,
                    loopFrameEnd: 236,
                    lottieConfiguration: LottieConfiguration(renderingEngine: .mainThread)
                )),
                bottomView: VStack {
                    Text("Lancez vous !")
                    Text("Créez une adresse gratuite ou connectez-vous à un compte Infomaniak existant.")
                }
            )
        ]

        let configuration = OnboardingConfiguration(
            headerImage: .logoText,
            slides: slides,
            pageIndicatorColor: UIColor(Color.accentColor),
            isScrollEnabled: true,
            dismissHandler: {},
            isPageIndicatorHidden: true
        )

        let controller = OnboardingViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: OnboardingViewController, context: Context) {
        uiViewController.setSelectedSlide(index: selectedSlide)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: OnboardingViewControllerDelegate {
        func currentIndexChanged(newIndex: Int) {}

        func willDisplaySlideViewCell(_ slideViewCell: SlideCollectionViewCell, at index: Int) {}

        func bottomViewForIndex(_ index: Int) -> (any View)? {
            if index == 3 {
                return Text("Last")
            } else {
                return Text("Coucou")
            }
        }

        func shouldAnimateBottomViewForIndex(_ index: Int) -> Bool {
            if index == 3 {
                return true
            } else {
                return false
            }
        }
    }
}

#Preview {
    ContentView()
}
