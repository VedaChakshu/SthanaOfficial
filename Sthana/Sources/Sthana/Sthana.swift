import Foundation
import SQLite3

public class Sthana {
    private var db: OpaquePointer?
    
    public init() {
        openDatabase()
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    private func openDatabase() {
        guard let dbPath = Bundle.module.path(forResource: "cities500", ofType: "sqlite") else {
            print("Sthana Error: Database file not found in bundle.")
            return
        }
        
        if sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK {
            print("Sthana Error: Error opening database.")
        }
    }
    
    public func search(text: String, limit: Int = 3) -> [Location] {
        guard let db = db else { return [] }
        
        var queryStatement: OpaquePointer?
        let queryString = """
            SELECT geonameid, name, latitude, longitude, country_code, 
                   admin1_code, admin2_code, admin3_code, admin4_code, 
                   elevation, timezone 
            FROM geoname 
            WHERE name LIKE ? OR asciiname LIKE ? OR alternatenames LIKE ?
            LIMIT ?;
        """
        
        var locations: [Location] = []
        
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            let searchString = "%\(text)%"
            let nsSearchString = searchString as NSString
            
            // Bind parameters (1-indexed)
            sqlite3_bind_text(queryStatement, 1, nsSearchString.utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 2, nsSearchString.utf8String, -1, nil)
            sqlite3_bind_text(queryStatement, 3, nsSearchString.utf8String, -1, nil)
            sqlite3_bind_int(queryStatement, 4, Int32(limit))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(queryStatement, 0))
                
                let name = String(cString: sqlite3_column_text(queryStatement, 1))
                let lat = sqlite3_column_double(queryStatement, 2)
                let lon = sqlite3_column_double(queryStatement, 3)
                
                let countryCode = decodeString(queryStatement, 4)
                let admin1 = decodeString(queryStatement, 5)
                let admin2 = decodeString(queryStatement, 6)
                let admin3 = decodeString(queryStatement, 7)
                let admin4 = decodeString(queryStatement, 8)
                
                let elevation = Int(sqlite3_column_int(queryStatement, 9))
                let timezone = decodeString(queryStatement, 10)
                
                let location = Location(
                    id: id,
                    name: name,
                    latitude: lat,
                    longitude: lon,
                    countryCode: countryCode,
                    admin1Code: admin1,
                    admin2Code: admin2,
                    admin3Code: admin3,
                    admin4Code: admin4,
                    elevation: elevation,
                    timezone: timezone
                )
                
                locations.append(location)
            }
        } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             print("Sthana Error: Query preparation failed: \(errorMessage)")
        }
        
        sqlite3_finalize(queryStatement)
        return locations
    }
    
    private func decodeString(_ stmt: OpaquePointer?, _ col: Int32) -> String {
        if let cString = sqlite3_column_text(stmt, col) {
            return String(cString: cString)
        }
        return ""
    }
}
