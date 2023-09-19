

library(dplyr)
library(ggplot2)

# Read the data files
products <- read.table("products.tsv", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
merged_table <- read.table("merged_table.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# Merge the tables based on the filename
combined_data <- inner_join(products, merged_table, by = c("Filename" = "orig_filename"))


# Create the mapping based on the provided information
filename_mapping <- list(
  "Hain_H5" = "d__Bacteria;p__Planctomycetota",
  "NC_0009" = "p__Pseudomonadota;s__Escherichia_coli",
  "NZ_CP00" = "d__Archaea;g__Methanosarcina",
  "NZ_CP08" = "p__Actinomycetota;g__Streptomyces",
  "NC_0031" = "p__Proteobacteria;g__Yersinia",
  "Hain_H3" = "d__Archaea;p__Thermoplasmatota",
  "Hain_H4" = "p__Nitrospirota;g__Nitrospira_A",
  "no008_B" = "Zander's extra genome"
)


head(combined_data)
# Replace filenames in the combined data based on the mapping
combined_data$Filename <- sapply(combined_data$Filename, function(name) {
  for (key in names(filename_mapping)) {
    if (grepl(key, name)) {
      return(filename_mapping[[key]])
    }
  }
  return(name)
})


# Define the RiPP list
Ripp_list <- c("Cyanobactin", "Lanthipeptide-class-i", "Lanthipeptide-class-i", "Lanthipeptide-class-ii", 
               "Lanthipeptide-class-iv", "Lanthipeptide-class-v", "Proteusin", "Sactipeptide", 
               "Lassopeptide", "Linaridin", "Ranthipeptide", "Thiopeptide", "RRE-containing")

# Create the Product2 column based on the conditions
combined_data <- combined_data %>%
  mutate(Product2 = case_when(
    Product == "NRPS" ~ "NRPS",
    Product == "Terpene" ~ "Terpene",
    Product %in% c("T1PKS", "T2PKS", "T3PKS") ~ "PKS",
    Product %in% Ripp_list ~ "RiPP",
    TRUE ~ as.character(Product)
  ))

combined_data <- combined_data %>% filter(Product2 == "NRPS" | Product2 == "PKS" | Product2 == "RiPP" | Product2 == "Terpene")

head(combined_data)

plot <- combined_data %>% ggplot(aes(x = Filename, y = membership_value)) +
  
  # Add jittered dots and color them based on the value of membership_value
  geom_jitter(aes(color = ifelse(membership_value < 900, "grey", "blue")), width = 0.2, height = 0, size = 3) +
  scale_color_identity(guide = "none") +  # This will use the colors directly and not display a color legend
  
  # Modify dotted lines
  geom_hline(yintercept = 900, linetype="dotted", color = "black", size = 1.5) +  # Thicker black line at d=900
  geom_hline(yintercept = 1800, linetype="dotted", color = "darkgrey", size = 1.5) +  # Thicker dark grey line at d=1800
  
  # Adjust x-axis text labels
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, family = "sans", size = 12)) +
  ylim(300, 2000) +
  facet_wrap(~ Product2, scales = "free")  # Separate, clean facets for each Product2 

print(plot)
  
ggsave("distance_plot.png", width=10, height=6)  
