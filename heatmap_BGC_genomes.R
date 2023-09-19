install.packages("tibble" , repos="https://cloud.r-project.org/")
library(tibble)
library(dplyr)
library(tidyr)
library(pheatmap)

# Load the data
data <- read.table("clusters.txt", header = FALSE, stringsAsFactors = FALSE)

# Extract the genome and cluster number
data$genome <- sub("bgc.*", "", data$V1)
data$cluster <- data$V2

# Create a presence-absence matrix
presence_absence <- data %>%
  select(cluster, genome) %>%
  mutate(presence = 1) %>%
  spread(key = genome, value = presence, fill = 0) %>%
  remove_rownames() %>%
  column_to_rownames(var="cluster")

presence_absence <- presence_absence[rowSums(presence_absence) >= 2, ]

# Generate the heatmap
pheatmap(presence_absence, 
         color = c("white", "red"), 
         scale = "none", 
         clustering_distance_rows = "euclidean",
         clustering_distance_cols = "euclidean",
         clustering_method = "complete")

ggsave("heatmap.pdf", width=10, height=6)  

