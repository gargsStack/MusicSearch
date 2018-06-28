//
//  MusicSearchTests.swift
//  MusicSearchTests
//
//  Created by Vivek on 29/06/18.
//  Copyright © 2018 Vivek. All rights reserved.
//

import XCTest
import UIKit
@testable import MusicSearch

class MusicSearchTests: XCTestCase {
    
    var vc: ViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        vc = navController.topViewController as! ViewController
        //Load view hierarchy
        _ = vc.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //MARK:- Search bar
    //Is search bar delegate set?
    func testSearchBarDelegateSet() {
        XCTAssertNotNil(self.vc.searchController.searchBar.delegate)
    }
    
    //VC conforms to delegate protocol
    func testConformsToSearchBarDelegate() {
        XCTAssert(self.vc.conforms(to: UISearchBarDelegate.self))
        XCTAssertTrue(self.vc.responds(to: #selector(vc.searchBarShouldEndEditing(_:))))
        XCTAssertTrue(self.vc.responds(to: #selector(vc.searchBarSearchButtonClicked(_:))))
    }
    
    //MARK:- Song search
    //Search text is set
    func testSearchTextSetFunction() {
        let expectedSearchText = "Pretty little thing"
        
        vc.searchController.searchBar.text = expectedSearchText
        vc.searchBarSearchButtonClicked(vc.searchController.searchBar)
        
        let actualSearchText = vc.searchTerm
        XCTAssertEqual(expectedSearchText, actualSearchText)
    }
    
    //Search works
    func testSearchFunction() {
        let expectedSearchText = "Pretty little thing"
        
        let searchExp = expectation(description: "Search Test")
        vc.dataSource.search(for: expectedSearchText, completion: { tracks, error  in
            XCTAssertNotNil(tracks)
            searchExp.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: { error in XCTAssertNil(error, "Timeout on search")})
    }
    
    //MARK:- Collection search
    //Collection name is set
    func testCollectionSearchTextSetFunction() {
        let collectionId = "416316607"
        let collectionName = "Biscuits for Breakfast"
        vc.searchCollection(for: collectionId, collectionName: collectionName)
        
        XCTAssertEqual(vc.navigationItem.title, collectionName)
    }
    
    //Collection search works
    func testCollectionSearchFunction() {
        let collectionId = "416316607"
        
        let searchExp = expectation(description: "Search Collection Test")
        vc.dataSource.searchCollection(for: collectionId, completion: { tracks, error  in
            XCTAssertNotNil(tracks)
            searchExp.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: { error in XCTAssertNil(error, "Timeout on collection search")})
    }
}
