import XCTest

final class ImageFeedUITests: XCTestCase {
    private let ImageFeed = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        ImageFeed.launch()
    }
    
    func testAuth() throws {
        ImageFeed.buttons["LoginButton"].tap()
        let webView = ImageFeed.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("your_unsplash_email")
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText("your_unsplash_password")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = ImageFeed.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = ImageFeed.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.scrollToElement()
        
        let likeOffButton = cellToLike.buttons["like button off"]
        let likeOnButton = cellToLike.buttons["like button on"]
        
        if likeOffButton.exists {
            likeOffButton.tap()
            XCTAssertTrue(likeOnButton.waitForExistence(timeout: 3))
            
            likeOnButton.tap()
            XCTAssertTrue(likeOffButton.waitForExistence(timeout: 3))
        } else if likeOnButton.exists {
            likeOnButton.tap()
            XCTAssertTrue(likeOffButton.waitForExistence(timeout: 3))
                          
            likeOffButton.tap()
            XCTAssertTrue(likeOnButton.waitForExistence(timeout: 3))
        } else {
            XCTFail("Like button not found")
        }
        
        cellToLike.scrollToElement()
        cellToLike.tap()
        
        sleep(2)
        
        let scrollView = ImageFeed.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
                      
        let image = ImageFeed.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backwardButton = ImageFeed.buttons["BackwardButton"]
        XCTAssertTrue(backwardButton.waitForExistence(timeout: 3))
        backwardButton.tap()
    }
    
    func testProfile() throws {
        let tabBar = ImageFeed.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        
        ImageFeed.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(ImageFeed.staticTexts["FirstName and LastName"].exists)
        XCTAssertTrue(ImageFeed.staticTexts["@your_username"].exists)
        
        ImageFeed.buttons["logoutButton"].tap()
        
        let alert = ImageFeed.alerts["LogoutAlert"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        
        alert.buttons["Да"].tap()
    }
}

extension XCUIElement {
    func scrollToElement() {
        while !self.isHittable {
            swipeUp()
        }
    }
}
