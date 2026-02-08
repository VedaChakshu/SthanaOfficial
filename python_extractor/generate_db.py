import sqlite3
import csv
import os

INPUT_FILE = "cities500.txt"
ADMIN1_FILE = "admin1CodesASCII.txt"
ADMIN2_FILE = "admin2Codes.txt"
DB_FILE = "cities500.sqlite"

def create_database():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    # Disable WAL mode for transportability
    cursor.execute("PRAGMA journal_mode = DELETE;")
    
    # Create tables
    cursor.execute("""
        CREATE TABLE geoname (
            geonameid INTEGER PRIMARY KEY,
            name TEXT,
            asciiname TEXT,
            alternatenames TEXT,
            latitude REAL,
            longitude REAL,
            feature_class TEXT,
            feature_code TEXT,
            country_code TEXT,
            cc2 TEXT,
            admin1_code TEXT,
            admin2_code TEXT,
            admin3_code TEXT,
            admin4_code TEXT,
            population INTEGER,
            elevation INTEGER,
            dem INTEGER,
            timezone TEXT,
            modification_date TEXT
        );
    """)
    
    cursor.execute("""
        CREATE TABLE admin1_codes (
            code TEXT PRIMARY KEY,
            name TEXT,
            asciiname TEXT,
            geonameid INTEGER
        );
    """)

    cursor.execute("""
        CREATE TABLE admin2_codes (
            code TEXT PRIMARY KEY,
            name TEXT,
            asciiname TEXT,
            geonameid INTEGER
        );
    """)
    
    print(f"Created database {DB_FILE} with tables.")
    
    # --- Process Admin1 Codes ---
    print(f"Reading from {ADMIN1_FILE}...")
    try:
        with open(ADMIN1_FILE, 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
            batch = []
            for row in reader:
                if len(row) < 4: continue
                # format: code, name, asciiname, geonameid
                record = (row[0], row[1], row[2], int(row[3]))
                batch.append(record)
            
            cursor.executemany("INSERT INTO admin1_codes VALUES (?, ?, ?, ?)", batch)
            conn.commit()
            print(f"Imported {len(batch)} admin1 codes.")
    except FileNotFoundError:
        print(f"Warning: {ADMIN1_FILE} not found.")

    # --- Process Admin2 Codes ---
    print(f"Reading from {ADMIN2_FILE}...")
    try:
        with open(ADMIN2_FILE, 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
            batch = []
            for row in reader:
                if len(row) < 4: continue
                # format: code, name, asciiname, geonameid
                record = (row[0], row[1], row[2], int(row[3]))
                batch.append(record)
            
            cursor.executemany("INSERT INTO admin2_codes VALUES (?, ?, ?, ?)", batch)
            conn.commit()
            print(f"Imported {len(batch)} admin2 codes.")
    except FileNotFoundError:
        print(f"Warning: {ADMIN2_FILE} not found.")

    # --- Process Geonames ---
    print(f"Reading from {INPUT_FILE}...")
    
    count = 0
    batch_size = 10000
    batch = []
    
    try:
        with open(INPUT_FILE, 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
            
            for row in reader:
                # Ensure row has correct number of columns (19)
                if len(row) != 19:
                    print(f"Skipping malformed row {count + 1}: {row}")
                    continue
                
                record = (
                    int(row[0]) if row[0] else None,
                    row[1],
                    row[2],
                    row[3],
                    float(row[4]) if row[4] else None,
                    float(row[5]) if row[5] else None,
                    row[6],
                    row[7],
                    row[8],
                    row[9],
                    row[10],
                    row[11],
                    row[12],
                    row[13],
                    int(row[14]) if row[14] else 0,
                    int(row[15]) if row[15] else None,
                    int(row[16]) if row[16] else None,
                    row[17],
                    row[18]
                )
                
                batch.append(record)
                count += 1
                
                if len(batch) >= batch_size:
                    cursor.executemany("""
                        INSERT INTO geoname VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """, batch)
                    conn.commit()
                    batch = []
                    print(f"Processed {count} rows...", end='\r')
            
            # Insert remaining
            if batch:
                cursor.executemany("""
                    INSERT INTO geoname VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, batch)
                conn.commit()
                
        print(f"\nSuccessfully imported {count} rows into {DB_FILE}.")
        
        # Create Indexes
        print("Creating indexes...")
        cursor.execute("CREATE INDEX idx_geoname_name ON geoname(name);")
        # Add index for joins
        cursor.execute("CREATE INDEX idx_geoname_admin1 ON geoname(country_code, admin1_code);")
        cursor.execute("CREATE INDEX idx_geoname_admin2 ON geoname(country_code, admin1_code, admin2_code);")
        
    except FileNotFoundError:
        print(f"Error: {INPUT_FILE} not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    create_database()
