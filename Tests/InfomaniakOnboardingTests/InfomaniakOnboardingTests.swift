import XCTest
@testable import InfomaniakOnboarding

final class InfomaniakOnboardingTests: XCTestCase {
    @MainActor
    func testLargeLayoutUsesElevatedCard() {
        let controller = makeViewController()
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 1_024, height: 1_366)
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.contentContainerView.layer.cornerRadius, 24)
        XCTAssertEqual(controller.contentContainerView.layer.shadowOpacity, 0.12)
        XCTAssertEqual(controller.contentContainerView.frame.width, 720)
        XCTAssertEqual(controller.contentContainerView.frame.height, 900)
        XCTAssertFalse(controller.stackView.frame.isEmpty)
        XCTAssertFalse(controller.slideCarouselViewController.view.frame.isEmpty)
        XCTAssertEqual(controller.slideCarouselViewController.collectionView.numberOfItems(inSection: 0), 1)
        let cell = controller.slideCarouselViewController.collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(cell)
        XCTAssertFalse(cell?.frame.isEmpty ?? true)
        XCTAssertFalse(controller.productIconsView.isHidden)
        XCTAssertEqual(controller.productIconsView.arrangedSubviews.count, 6)
        XCTAssertTrue(controller.productIconsView.arrangedSubviews.allSatisfy {
            ($0 as? UIImageView)?.image != nil
        })
    }

    @MainActor
    func testCompactLayoutRemainsEdgeToEdge() {
        let controller = makeViewController()
        controller.loadViewIfNeeded()
        controller.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.contentContainerView.layer.cornerRadius, 0)
        XCTAssertEqual(controller.contentContainerView.frame, controller.view.bounds)
        XCTAssertTrue(controller.productIconsView.isHidden)
    }

    @MainActor
    private func makeViewController() -> OnboardingViewController {
        let configuration = OnboardingConfiguration(
            headerImage: nil,
            slides: [
                Slide(
                    backgroundImage: UIImage(),
                    backgroundImageTintColor: nil,
                    content: .illustration(UIImage()),
                    bottomViewController: UIViewController()
                )
            ],
            pageIndicatorColor: nil,
            isScrollEnabled: true,
            dismissHandler: nil,
            isPageIndicatorHidden: true,
            backgroundGradient: OnboardingBackgroundGradient(colors: [.red, .blue])
        )
        return OnboardingViewController(configuration: configuration)
    }
}
