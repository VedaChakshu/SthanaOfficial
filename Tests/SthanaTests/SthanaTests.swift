import XCTest
@testable import Sthana

final class SthanaTests: XCTestCase {
    func testSearch() {
        let sthana = Sthana()
        
        // Test standard search
        let results = sthana.search(text: "London", limit: 50)
        
        // Based on cities500, London (UK) should be present
        // geonameid 2643743, London
        XCTAssertFalse(results.isEmpty, "Search for 'London' returned no results")
        
        if let london = results.first(where: { $0.countryCode == "GB" && $0.name == "London" }) {
            print("Found London: \(london.name), \(london.latitude), \(london.longitude)")
            XCTAssertEqual(london.countryCode, "GB")
            
            // Timezone Verification (Europe/London)
            // Standard: 0, DST: 3600
            let (gmt, dst) = (london.gmtOffset, london.gmtDstOffset)
            print("London Offsets: GMT \(gmt), DST \(dst)")
            
            // gmt offset should be 0 (or close if history matters, but usually 0)
            XCTAssertEqual(gmt, 0, "Europe/London Standard Offset should be 0")
            // dst offset should be 3600
            XCTAssertEqual(dst, 3600, "Europe/London DST Offset should be 3600")
        } else {
            XCTFail("London (GB) not found in results")
        }
        
        // Test partial match
        let partialResults = sthana.search(text: "Zuri", limit: 50) // Zurich
        XCTAssertFalse(partialResults.isEmpty)
        if let zurich = partialResults.first(where: { $0.name.contains("Zürich") || $0.name.contains("Zurich") }) {
            print("Found Zurich: \(zurich.name)")
        } else {
             XCTFail("Zurich not found with partial 'Zuri'")
        }
        
        // Test Explicit ASCII Search
        // "Munchen" -> "München"
        let munichResults = sthana.search(text: "Munchen", limit: 10)
        // If cities500 has Munich, `name` is usually München (DE), `asciiname` is Munchen.
        if let munich = munichResults.first(where: { $0.name == "München" || $0.name == "Munich" }) {
             print("Found Munich via ASCII 'Munchen': \(munich.name)")
        } else {
             // It is possible cities500 lists Munich as Munich in name for English compatibility, let's check.
             // But the test proves we can search.
             print("Munich check: Results count \(munichResults.count)")
        }
    }
    
    func testTimezoneNoDST() {
        let sthana = Sthana()
        
        // Bangalore (Asia/Kolkata) - No DST
        let results = sthana.search(text: "Bangalore")
        
        if let bangalore = results.first(where: { $0.timezone == "Asia/Kolkata" }) {
            print("Found Bangalore: \(bangalore.name)")
            let (gmt, dst) = (bangalore.gmtOffset, bangalore.gmtDstOffset)
            print("Bangalore Offsets: GMT \(gmt), DST \(dst)")
            
            // IST is +05:30 -> 19800 seconds
            XCTAssertEqual(gmt, 19800)
            XCTAssertEqual(dst, 19800)
        } else {
            print("Bangalore not found, might need alternate name or bigger dataset if not in cities500 (it should be)")
        }
    }

    func testSearchLimit() {
        let sthana = Sthana()
        
        // "San" should have many results (San Francisco, San Diego, etc.)
        
        // Test default limit (3)
        let defaultResults = sthana.search(text: "San")
        XCTAssertEqual(defaultResults.count, 3, "Default search should return 3 results")
        
        // Test custom limit
        let customResults = sthana.search(text: "San", limit: 10)
        XCTAssertEqual(customResults.count, 10, "Search with limit 10 should return 10 results")
    }
    
    func testLocationCodable() throws {
        // Create a location
        let location = Location(
            id: 1,
            name: "Test Place",
            latitude: 0.0,
            longitude: 0.0,
            countryCode: "US",
            admin1Code: "CA",
            admin2Code: "",
            admin3Code: "",
            admin4Code: "",
            elevation: 10,
            timezone: "America/Los_Angeles"
        )
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(location)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedLocation = try decoder.decode(Location.self, from: data)
        
        // Verify
        XCTAssertEqual(location, decodedLocation)
        XCTAssertEqual(decodedLocation.gmtOffset, location.gmtOffset)
        XCTAssertEqual(decodedLocation.gmtDstOffset, location.gmtDstOffset)
        // Verify offsets are not 0 (unless implementation matches)
        // LA is -8h (-28800) standard, -7h (-25200) DST.
        // Or similar. Just check they were preserved.
    }
    
    func testDSTCheck() {
        let sthana = Sthana()
        
        // Create a location for London (observes DST)
        let london = Location(
             id: 2643743,
             name: "London",
             latitude: 51.5,
             longitude: -0.12,
             countryCode: "GB",
             admin1Code: "", admin2Code: "", admin3Code: "", admin4Code: "",
             elevation: 0,
             timezone: "Europe/London"
        )
        
        let tz = TimeZone(identifier: "Europe/London")!
        
        // Date in Summer (DST active): July 1st
        // Note: Creating date properly without current timezone interference
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 1
        components.timeZone = tz
        let summerDate = calendar.date(from: components)!
        
        XCTAssertTrue(sthana.isDaylightSavingTime(date: summerDate, location: london), "London should be in DST in July")
        
        // Date in Winter (DST inactive): January 1st
        components.month = 1
        let winterDate = calendar.date(from: components)!
        
        XCTAssertFalse(sthana.isDaylightSavingTime(date: winterDate, location: london), "London should NOT be in DST in January")
        
        // Location w/o DST: Bangalore
        let bangalore = Location(
             id: 1277333,
             name: "Bangalore",
             latitude: 12.97,
             longitude: 77.59,
             countryCode: "IN",
             admin1Code: "", admin2Code: "", admin3Code: "", admin4Code: "",
             elevation: 920,
             timezone: "Asia/Kolkata"
        )
        
        XCTAssertFalse(sthana.isDaylightSavingTime(date: summerDate, location: bangalore), "Bangalore should never be in DST")
    }
    
    func testAdminNames() {
        let sthana = Sthana()
        
        // Search for Madanapalle (IN)
        let results = sthana.search(text: "Madanapalle", limit: 3)
        
        if let mpl = results.first(where: { $0.countryCode == "IN" }) {
            print("Found Madanapalle: \(mpl.name), Admin1: \(mpl.admin1Name ?? "nil"), Admin2: \(mpl.admin2Name ?? "nil")")
            
            // Verify Admin1 is Andhra Pradesh
            XCTAssertEqual(mpl.admin1Name, "Andhra Pradesh")
            
            // Verify Admin2 (District) - Chittoor or Annamayya (depending on DB freshness)
            XCTAssertNotNil(mpl.admin2Name)
            if let admin2 = mpl.admin2Name {
                print("Madanapalle Admin2: \(admin2)")
            }
        } else {
             XCTFail("Madanapalle (IN) not found in results")
        }
        
        // Keep London test as a secondary verification for GB
        let londonResults = sthana.search(text: "London", limit: 3)
        if let london = londonResults.first(where: { $0.countryCode == "GB" }) {
             XCTAssertEqual(london.admin1Name, "England")
        }
    }
}
