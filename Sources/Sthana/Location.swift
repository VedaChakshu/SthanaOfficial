import Foundation

public struct Location: Identifiable, Hashable, Codable, Sendable {
    public let id: Int // geonameid
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let countryCode: String
    public let admin1Code: String
    public let admin2Code: String
    public let admin3Code: String
    public let admin4Code: String
    public let elevation: Int
    public let timezone: String
    
    // Admin Names
    public let admin1Name: String?
    public let admin2Name: String?
    
    // Stored properties for TimeZone offsets
    public let gmtOffset: Int
    public let gmtDstOffset: Int
    
    public init(id: Int, name: String, latitude: Double, longitude: Double, countryCode: String, admin1Code: String, admin2Code: String, admin3Code: String, admin4Code: String, elevation: Int, timezone: String, admin1Name: String? = nil, admin2Name: String? = nil) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.countryCode = countryCode
        self.admin1Code = admin1Code
        self.admin2Code = admin2Code
        self.admin3Code = admin3Code
        self.admin4Code = admin4Code
        self.elevation = elevation
        self.timezone = timezone
        self.admin1Name = admin1Name
        self.admin2Name = admin2Name
        
        // Calculate offsets during initialization
        let (std, dst) = Location.getTimeZoneOffsets(for: timezone)
        self.gmtOffset = std
        self.gmtDstOffset = dst
    }
    
    // Helper to calculate offsets
    private static func getTimeZoneOffsets(for timezoneIdentifier: String) -> (standard: Int, dst: Int) {
        guard let tz = TimeZone(identifier: timezoneIdentifier) else {
            return (0, 0)
        }
        
        let now = Date()
        let currentOffset = tz.secondsFromGMT(for: now)
        
        // Check for next transition to see if there is a DST change coming
        if let nextTransition = tz.nextDaylightSavingTimeTransition(after: now) {
             let nextOffset = tz.secondsFromGMT(for: nextTransition.addingTimeInterval(3600))
             // Typically DST offset is larger than Standard offset
             return (min(currentOffset, nextOffset), max(currentOffset, nextOffset))
        } else {
            // No future transition found, return current for both
            return (currentOffset, currentOffset)
        }
    }
}
