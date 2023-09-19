# Read the original data
data <- read.csv("BGC_counts.tsv", sep="\t")

# Load required libraries
install.packages("reshape2", repos="https://cloud.r-project.org/")
library(ggplot2)
library(reshape2)
library(dplyr)

# Read the original data
data <- read.csv("BGC_counts.tsv", sep="\t")

# Replace names in the record column
name_replacements <- c(
  "Bin_1.fa" = "d__Archaea;p__Candidatus Lokiarchaeota",
  "Bin_10.fa" = "d__Bacteria;p__Patescibacteria",
  "Bin_2.fa" = "p__Pseudomonadota;s__Escherichia_coli",
  "Bin_3.fa" = "d__Archaea;g__Methanosarcina",
  "Bin_4.fa" = "p__Actinomycetota;g__Streptomyces",
  "Bin_5.fa" = "p__Proteobacteria;g__Yersinia",
  "Bin_6.fa" = "d__Archaea;p__Thermoplasmatota",
  "Bin_7.fa" = "p__Nitrospirota;g__Nitrospira_A",
  "Bin_8.fa" = "d__Bacteria;p__Patescibacteria_1",
  "Bin_9.fa" = "d__Bacteria;p__Planctomycetota"
)

data$record <- as.character(data$record)
data$record[data$record %in% names(name_replacements)] <- name_replacements[data$record]

# Data transformation
data$PKS <- data$T1PKS + data$T2PKS + data$T3PKS

# Creating the Other BGCs column
cols_to_exclude <- c("record", "total_count", "NRPS", "T1PKS", "T2PKS", "T3PKS", "PKS")
data$"Other BGCs" <- rowSums(data[,!(names(data) %in% cols_to_exclude)])

# Selecting only relevant columns for plotting
plot_data <- data[,c("record", "NRPS", "PKS", "Other BGCs")]

# Sort data based on the total counts
plot_data <- plot_data[order(-rowSums(plot_data[,2:4])),]

# Melt the data for plotting
melted_data <- melt(plot_data, id.vars = "record", variable.name = "BGC", value.name = "Count")

# Plotting
p <- ggplot(melted_data, aes(x=record, y=Count, fill=BGC)) + 
  geom_bar(stat="identity", position="stack") +
  labs(title="Stacked Bar Plot of BGC Clusters",
       x="Bin Name",
       y="Number of Bins") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Display the plot
print(p)

# Optionally, save the plot
ggsave("stacked_bar_plot.png", width=10, height=6)
