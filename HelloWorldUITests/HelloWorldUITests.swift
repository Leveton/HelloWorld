//
//  HelloWorldUITests.swift
//  HelloWorld
//
//  Created by Mike Leveton on 7/24/16.
//  Copyright © 2016 Mike Leveton. All rights reserved.
//

import XCTest
let sleepTime:UInt32     = 1

class HelloWorldUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        XCTAssertEqual(app.buttons.count, 2)
        let button0 = app.buttons["BUTTON 0"]
        let button1 = app.buttons["Button 1"]
        button0.tap()
        button1.tap()
        
        let button2 = app.buttons["BUTTON 0"]
        
        /* you have to wait for the app to be idle */
        while !button2.exists {
            sleep(sleepTime)
        }
        button2.tap()
        XCTAssertEqual(app.buttons.count, 3)
        let labels = app.descendantsMatchingType(.StaticText)
        let labelsQuery = labels.containingType(.StaticText, identifier: "CD")
        let element = labels["CD"]
        let element1 = labels.elementAtIndex(0)
        XCTAssert(element.exists, "OK")
        XCTAssert(element1.exists)
        XCTAssertEqual(labelsQuery.count, 1)
    }
    
}
