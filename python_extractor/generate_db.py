import sqlite3
import csv
import os

INPUT_FILE = "cities500.txt"
DB_FILE = "cities500.sqlite"

def create_database():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)
    
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    
    # Disable WAL mode for transportability
    cursor.execute("PRAGMA journal_mode = DELETE;")
    
    # Create table
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
    
    print(f"Created database {DB_FILE} and table 'geoname'.")
    
    # Read data and insert
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
                
                # Parse numeric fields to avoid storing them as text if they are valid numbers
                # geonameid is index 0
                # latitude is index 4
                # longitude is index 5
                # population is index 14
                # elevation is index 15
                # dem is index 16
                
                # Note: csv reader returns all strings. We rely on sqlite to handle typing or we can cast.
                # It's better to cast explicitly for the executemany.
                
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
        
    except FileNotFoundError:
        print(f"Error: {INPUT_FILE} not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    create_database()
