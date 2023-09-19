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
                    if feature.type == "CDS":
                        product_value = feature.qualifiers.get("product", [None])[0]
                        if product_value:
                            results.append((filename, product_value))
                            
    return results

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python extract_products.py <input_directory>")
        sys.exit(1)
    directory = sys.argv[1]
    results = extract_all_products_from_gbk(directory)
    output_filename = "products.tsv"
    results_df = pd.DataFrame(results, columns=["Filename", "Product"])
    results_df.to_csv(output_filename, sep='\t', index=False)
