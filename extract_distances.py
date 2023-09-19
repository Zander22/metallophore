import sqlite3
import pandas as pd
import os

# Connect to the "Sp. Report" database
conn2 = sqlite3.connect("full_run_result/reports/9/data.db") # a specific report

# Extract data from gcf_membership, bgc, and bgc_class tables
gcf_membership_df = pd.read_sql_query('SELECT * FROM gcf_membership', conn2)
bgc_df = pd.read_sql_query('SELECT * FROM bgc', conn2)
bgc_class_df = pd.read_sql_query('SELECT * FROM bgc_class', conn2)

# Merge the tables using pandas
# First, merge gcf_membership with bgc based on bgc_id and id
merged_df = gcf_membership_df.merge(bgc_df, left_on='bgc_id', right_on='id', how='inner')

# Next, merge the above result with bgc_class based on bgc_id
merged_df = merged_df.merge(bgc_class_df, on='bgc_id', how='inner')

# Create an export directory if it doesn't exist
export_dir_Sp_Report = "exported_full_tables_Sp_Report"
os.makedirs(export_dir_Sp_Report, exist_ok=True)

# Export the merged table to a .txt (TSV) file
merged_df.to_csv(os.path.join(export_dir_Sp_Report, "merged_table.txt"), sep='\t', index=False)

# Close the database connection
conn2.close()

print("Merged table has been exported to merged_table.txt!")




from Bio import SeqIO
import os
import sys
import pandas as pd

def extract_all_products_from_gbk(directory):
    results = []

    # Loop through each file in the directory
    for filename in os.listdir(directory):
        if filename.endswith(".gbk"):
            filepath = os.path.join(directory, filename)
            
            # Parse the GenBank file
            for record in SeqIO.parse(filepath, "genbank"):
                for feature in record.features:
                    if feature.type == "protocluster":
                        product_value = feature.qualifiers.get("product", [None])[0]
                        if product_value:
                            results.append((filename, product_value))
                            
    return results

if __name__ == '__main__':
    if True:
        print("Usage: python extract_products.py <input_directory>")
        sys.exit(1)
    directory = "./example_input/"
    results = extract_all_products_from_gbk(directory)
    output_filename = "products.tsv"
    results_df = pd.DataFrame(results, columns=["Filename", "Product"])
    results_df.to_csv(output_filename, sep='\t', index=False)
