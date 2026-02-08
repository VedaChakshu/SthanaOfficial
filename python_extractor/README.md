# Python Extractor for GeoNames

This directory contains scripts to generate a SQLite database from GeoNames data exports.

## Database Structure

The generated database `cities500.sqlite` contains the main `geoname` table and two helper tables for Administrative Divisions.

### Table: `geoname`

| Column | Type | Description |
| :--- | :--- | :--- |
| `geonameid` | INTEGER | Integer id of record in geonames database (Primary Key) |
| `name` | TEXT | Name of geographical point (utf8) |
| `asciiname` | TEXT | Name of geographical point in plain ascii characters |
| `alternatenames` | TEXT | Alternate names, comma separated |
| `latitude` | REAL | Latitude in decimal degrees (wgs84) |
| `longitude` | REAL | Longitude in decimal degrees (wgs84) |
| `feature_class` | TEXT | See http://www.geonames.org/export/codes.html |
| `feature_code` | TEXT | See http://www.geonames.org/export/codes.html |
| `country_code` | TEXT | ISO-3166 2-letter country code |
| `cc2` | TEXT | Alternate country codes, comma separated |
| `admin1_code` | TEXT | Fipscode (subject to change to iso code) |
| `admin2_code` | TEXT | Code for the second administrative division |
| `admin3_code` | TEXT | Code for third level administrative division |
| `admin4_code` | TEXT | Code for fourth level administrative division |
| `population` | INTEGER | Bigint (8 byte int) |
| `elevation` | INTEGER | In meters |
| `dem` | INTEGER | Digital elevation model |
| `timezone` | TEXT | The iana timezone id |
| `modification_date` | TEXT | Date of last modification in yyyy-MM-dd format |

### Table: `admin1_codes` (States/Provinces)

| Column | Type | Description |
| :--- | :--- | :--- |
| `code` | TEXT | Concatenated code (e.g., "US.CA") |
| `name` | TEXT | Name (e.g., "California") |
| `asciiname` | TEXT | ASCII Name |
| `geonameid` | INTEGER | GeoName ID |

### Table: `admin2_codes` (Counties/Districts)

| Column | Type | Description |
| :--- | :--- | :--- |
| `code` | TEXT | Concatenated code (e.g., "US.CA.075") |
| `name` | TEXT | Name (e.g., "San Francisco County") |
| `asciiname` | TEXT | ASCII Name |
| `geonameid` | INTEGER | GeoName ID |

## Usage

### 1. Download Data

Download the required files from [GeoNames](http://download.geonames.org/export/dump/):

```bash
# Main Data (Cities with > 500 population)
curl -O http://download.geonames.org/export/dump/cities500.zip
unzip cities500.zip

# Admin Codes
curl -O http://download.geonames.org/export/dump/admin1CodesASCII.txt
curl -O http://download.geonames.org/export/dump/admin2Codes.txt
```

### 2. Generate Database

Run the script to generate `cities500.sqlite`:

```bash
python3 generate_db.py
```

This will produce `cities500.sqlite`. You can then move this file to the Swift package resources:

```bash
mv cities500.sqlite ../Sources/Sthana/Resources/
```
