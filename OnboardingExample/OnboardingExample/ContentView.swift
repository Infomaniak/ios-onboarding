//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

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
