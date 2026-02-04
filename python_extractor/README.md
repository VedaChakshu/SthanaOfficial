# Python Extractor for GeoNames

This directory contains scripts to generate a SQLite database from GeoNames data exports.

## Database Structure

The generated database `cities500.sqlite` contains a single table `geoname`.

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

## Files
- `generate_db.py`: Script to generate the SQLite database from `cities500.txt`.
- `cities500.txt`: Raw data from GeoNames (extracted from zip).
