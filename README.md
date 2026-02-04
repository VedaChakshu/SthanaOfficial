# Sthana 📍

> **Offline Global Location Search & Timezone Intelligence for Swift**

Sthana (Sanskrit: *Place/Location*) is a lightweight, zero-dependency Swift package that provides robust offline location search capabilities. It comes bundled with a highly optimized SQLite database containing over 200,000 cities worldwide (population > 500), powered by [GeoNames](http://www.geonames.org/).

## Features ✨

- 🌍 **Fully Offline**: Search instantly without network latency or API quotas.
- 🔍 **Smart Search**: Find locations by native name, ASCII name, or alternate names (e.g., searching "Munchen" finds "München").
- ⏱️ **Timezone Aware**: Access precise GMT and DST offsets for every location.
- ☀️ **Daylight Saving Time**: Native utility to check if a specific Date matches a Location's DST rules.
- 📦 **Modern Swift**: Native `SQLite3` integration, `Codable` structs, and strict concurrency safety.

## Installation 📦

Add `Sthana` to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/VedaChakshu/SthanaOfficial.git", from: "1.0.0")
]
```

## Usage 🛠️

### 1. Basic Search
Search for cities by name. The results include detailed administrative metadata.

```swift
import Sthana

let sthana = Sthana()

// Search for "London" (defaults to top 3 results)
let results = sthana.search(text: "London")

if let city = results.first {
    print("Found: \(city.name), \(city.countryCode)") 
    // Output: Found: London, GB
    
    print("Coordinates: \(city.latitude), \(city.longitude)")
}
```

### 2. Advanced Querying
Control the number of results and search using broader terms.

```swift
// Get top 10 matches for "San" (San Francisco, San Diego, etc.)
let cities = sthana.search(text: "San", limit: 10)
```

### 3. Timezone & DST Support
Sthana provides computed timezone offsets and utilities to check for Daylight Saving Time.

```swift
let london = results.first!

// Get offsets (in seconds)
print("Standard Offset: \(london.gmtOffset)") // 0
print("DST Offset: \(london.gmtDstOffset)")   // 3600

// Check if a specific date is in DST for this location
let now = Date()
let isDST = sthana.isDaylightSavingTime(date: now, location: london)

if isDST {
    print("London is currently observing Daylight Saving Time ☀️")
} else {
    print("London is in Standard Time ❄️")
}
```

## Data Source 📊

This library uses data from the [GeoNames](http://www.geonames.org/) database.
- **Source File**: `cities500.zip`
- **License**: [Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/)

## Python Extractor 🐍

The repository includes a helper Python script (`python_extractor/`) used to generate the optimized `cities500.sqlite` database from raw GeoNames text files. This allows for easy regeneration of the dataset with newer dumps.

---

<p align="center">
  Made with ❤️ for the Swift Community
</p>
