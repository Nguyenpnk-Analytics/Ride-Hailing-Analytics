import pandas as pd
from dateutil import parser

# Read csv file
file_path = r"C:....csv"
df = pd.read_csv(file_path)

# Convert date and time to standard format yyyy-MM-dd HH:mm:ss
def parse_date_safe(date_str):
    try:
        dt = parser.parse(str(date_str))
        return dt.strftime('%Y-%m-%d %H:%M:%S')
    except:
        return None

# Convert START_DATE and END_DATE columns
df['START_DATE'] = df['START_DATE'].apply(parse_date_safe)
df['END_DATE'] = df['END_DATE'].apply(parse_date_safe)

# Delete last row
df = df.iloc[:-1]

# Save cleaned file
output_path = file_path.replace(".csv", "_clean.csv")
df.to_csv(output_path, index=False, encoding='utf-8-sig')

print(f"✅ Finished. Saved at:\n{output_path}")
