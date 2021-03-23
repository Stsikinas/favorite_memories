//
//  CoreDataCRUDTests.swift
//  Favorite MemoriesTests
//
//  Created by Epsilon User on 23/3/21.
//

import XCTest
import CoreData
@testable import Favorite_Memories

class CoreDataCRUDTests: XCTestCase {
    
    var dataStack: DatabaseServiceUnitTests!
    
    override func setUp() {
        super.setUp()
        
        dataStack = DatabaseServiceUnitTests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        //dataStack = nil
    }

    
    func testAddAlbums() {
        let expectation = XCTestExpectation(description: "Save Albums async")

        let albums: [[String: Any]] = [
            [
                "id": 1,
                "title": "Summer 2019",
                "pageLoaded": 1
            ],
            [
                "id": 2,
                "title": "Winter 2019",
                "pageLoaded": 1
            ]
        ]
        dataStack.save(albums: albums) { (saved) in
            XCTAssertTrue(saved)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    
    /// Test the insert of photos in DB, through nilable elements (thumbUrl)
    func testAddPhotos() {
        let expectation = XCTestExpectation(description: "Save Photos async")

        let photos: [[String: Any]] = [
            [
                "albumId": 1,
                "id": 1,
                "title": "Me and Annie",
                "imageUrl": "some url",
                "thumbnailUrl": "thumb Url"
            ],
            [
                "albumId": 1,
                "id": 2,
                "title": "Sunset",
                "imageUrl": "some url"
            ]
        ]
        dataStack.save(photos: photos) { (saved) in
            expectation.fulfill()
            XCTAssertTrue(saved)
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    /// Test to get albums from DB
    func testFetchAlbums() {
        let expectation = XCTestExpectation(description: "Fetch Albums async")
        let albums: [[String: Any]] = [
            [
                "id": Int16(1),
                "title": "Summer 2019",
                "pageLoaded": Int16(1)
            ],
            [
                "id": Int16(2),
                "title": "Winter 2019",
                "pageLoaded": Int16(1)
            ]
        ]
        dataStack.save(albums: albums) { (saved) in
            self.dataStack.readAlbums { (fetchedAlbums) in
                if let receivedAlbums = fetchedAlbums {
                    XCTAssertEqual(receivedAlbums.count, albums.count)
                    XCTAssertFalse(receivedAlbums.isEmpty)
                } else {
                    XCTAssertNil(fetchedAlbums)
                }
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
