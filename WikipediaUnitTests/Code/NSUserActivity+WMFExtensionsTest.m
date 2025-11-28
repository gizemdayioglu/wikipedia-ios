#import <XCTest/XCTest.h>
#import "NSUserActivity+WMFExtensions.h"


@interface NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test : XCTestCase
@end

@implementation NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test

- (void)testURLWithoutWikipediaSchemeReturnsNil {
    NSURL *url = [NSURL URLWithString:@"http://www.foo.com"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testInvalidArticleURLReturnsNil {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/wiki/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");
}

- (void)testExploreURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://explore"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeExplore);
}

- (void)testHistoryURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://history"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeHistory);
}

- (void)testSavedURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://saved"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeSavedPages);
}

- (void)testSearchURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/w/index.php?search=dog"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString,
                          @"https://en.wikipedia.org/w/index.php?search=dog&title=Special:Search&fulltext=1");
}

@end

@interface NSUserActivity_WMFExtensions_PlacesTest : XCTestCase
@end

@implementation NSUserActivity_WMFExtensions_PlacesTest

- (void)testPlacesActivityWithValidCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.3676&lon=4.9041"];
    NSUserActivity *activity = [NSUserActivity wmf_placesActivityWithURL:url];
    
    XCTAssertNotNil(activity);
    NSNumber *lat = activity.userInfo[@"WMFPlacesLatitude"];
    NSNumber *lon = activity.userInfo[@"WMFPlacesLongitude"];
    
    XCTAssertEqual(lat.doubleValue, 52.3676);
    XCTAssertEqual(lon.doubleValue, 4.9041);
}

- (void)testPlacesActivityWithInvalidLatitude {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=100&lon=4.9041"];
    NSUserActivity *activity = [NSUserActivity wmf_placesActivityWithURL:url];
    
    NSNumber *lat = activity.userInfo[@"WMFPlacesLatitude"];
    XCTAssertNil(lat);
}

- (void)testPlacesActivityWithInvalidLongitude {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.3676&lon=200"];
    NSUserActivity *activity = [NSUserActivity wmf_placesActivityWithURL:url];
    
    NSNumber *lon = activity.userInfo[@"WMFPlacesLongitude"];
    XCTAssertNil(lon);
}

- (void)testPlacesActivityWithMalformedCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=abc&lon=def"];
    NSUserActivity *activity = [NSUserActivity wmf_placesActivityWithURL:url];
    
    XCTAssertNotNil(activity);
    NSNumber *lat = activity.userInfo[@"WMFPlacesLatitude"];
    NSNumber *lon = activity.userInfo[@"WMFPlacesLongitude"];
    
    XCTAssertNil(lat);
    XCTAssertNil(lon);
}

- (void)testPlacesActivityWithEdgeCaseCoordinates {
    NSURL *url1 = [NSURL URLWithString:@"wikipedia://places?lat=-90&lon=-180"];
    NSUserActivity *activity1 = [NSUserActivity wmf_placesActivityWithURL:url1];
    XCTAssertNotNil(activity1.userInfo[@"WMFPlacesLatitude"]);
    XCTAssertNotNil(activity1.userInfo[@"WMFPlacesLongitude"]);
    
    NSURL *url2 = [NSURL URLWithString:@"wikipedia://places?lat=90&lon=180"];
    NSUserActivity *activity2 = [NSUserActivity wmf_placesActivityWithURL:url2];
    XCTAssertNotNil(activity2.userInfo[@"WMFPlacesLatitude"]);
    XCTAssertNotNil(activity2.userInfo[@"WMFPlacesLongitude"]);
}

@end
