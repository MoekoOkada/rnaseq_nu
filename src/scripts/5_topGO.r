library(topGO)
library(biomaRt)
library(tidyverse)
library(dplyr)
library(ggplot2)

setwd("~/Dropbox/0_Git/rnaseq2024/src/")

# install annotation
library("org.At.tair.db")
# 確認
head(toTable(org.At.tairGO))

# read DEG list
data <- read_table("DEGs.txt", col_names = FALSE)
colnames(data) <- c("GeneID", "logFC", "logCPM", "PValue", "FDR")
rownames(data) <- gsub("transcript:", "", rownames(data))
head(data)

# check which gene is deg
colnames(data) <- c("V1")
head(data)

deg <- mutate(gene, de = if_else(gene$geneNames %in% data$V1, true = TRUE, false = FALSE))
row.names(deg) <- deg$geneNames
summary(deg$de)

# create the gene universe (DEGs were converted to 0/1 value)
DEGs <- as.numeric(deg$de)
gene_universe <- factor(DEGs)
names(gene_universe) <- rownames(deg)
head(gene_universe)

# create the topGO data for BP
BP <- new("topGOdata",
  ontology = "BP",
  allGenes = DEGs,
  annotationFun = annFUN.org,
  mapping = "org.At.tair.db",
  ID = "TAIR"
)

BP


# Run topGO with elim algorithm and fisher test
BP_test <- runTest(BP, algorithm = "elim", statistic = "fisher")
BP_test

# Keep the results
BP_Table <- GenTable(BP,
  weightFisher = BP_test,
  orderBy = "elimFisher", ranksOf = "elimFisher", topNodes = sum(score(BP_test) < .05)
)
head(BP_Table)
nrow(BP_Table)
BP_Table

# BP_Table <- BP_Table[BP_Table$Annotated > 10, ]
# BP_Table <- BP_Table[BP_Table$Annotated < 1001, ]
# head(BP_Table)
#
# ### Recalculate p-value
# BP_Table$pval <- p.adjust(BP_Table$weightFisher, method = c("BH"), n = nrow(BP_Table))
# BP_Table$fdr <- p.adjust(BP_Table$weightFisher, method = c("fdr"), n = nrow(BP_Table))
# BP_Table <- BP_Table[BP_Table$fdr < 0.05, ]
#
write.table(BP_Table, file = "topGO_BP_table.txt", sep = "\t", quote = F, col.names = T, row.names = F)

png("topGO_BP.png", 1500, 1500)
par(cex = 0.5)
showSigOfNodes(BP, score(BP_test), useInfo = "def")
dev.off()

# create the topGO data
MF <- new("topGOdata",
  ontology = "MF",
  allGenes = DEGs,
  annotationFun = annFUN.org,
  mapping = "org.At.tair.db",
  ID = "TAIR"
)

MF

# Run topGO with elim algorithm and fisher test
MF_test <- runTest(MF, algorithm = "elim", statistic = "fisher")
MF_test

# Keep the results
MF_Table <- GenTable(MF,
  weightFisher = MF_test,
  orderBy = "elimFisher", ranksOf = "elimFisher", topNodes = sum(score(MF_test) < .05)
)
head(MF_Table)
nrow(MF_Table)

# MF_Table <- MF_Table[MF_Table$Annotated > 10, ]
# MF_Table <- MF_Table[MF_Table$Annotated < 1001, ]
# head(MF_Table)
#
# ### Recalculate p-value
# MF_Table$pval <- p.adjust(MF_Table$weightFisher, method = c("BH"), n = nrow(MF_Table))
# MF_Table$fdr <- p.adjust(MF_Table$weightFisher, method = c("fdr"), n = nrow(MF_Table))
# MF_Table <- MF_Table[MF_Table$fdr < 0.05, ]
#
write.table(MF_Table, file = "topGO_MF_table.txt", sep = "\t", quote = F, col.names = T, row.names = F)

png("topGO_MF.png", 1500, 1500)
par(cex = 0.5)
showSigOfNodes(MF, score(MF_test), useInfo = "def")
dev.off()


# create the topGO data
CC <- new("topGOdata",
  ontology = "CC",
  allGenes = DEGs,
  annotationFun = annFUN.org,
  mapping = "org.At.tair.db",
  ID = "TAIR"
)

CC

# Run topGO with elim algorithm and fisher test
CC_test <- runTest(CC, algorithm = "elim", statistic = "fisher")
CC_test

# Keep the results
CC_Table <- GenTable(CC,
  weightFisher = CC_test,
  orderBy = "elimFisher", ranksOf = "elimFisher", topNodes = sum(score(CC_test) < .05)
)
head(CC_Table)
nrow(CC_Table)

# CC_Table <- CC_Table[CC_Table$Annotated > 10, ]
# CC_Table <- CC_Table[CC_Table$Annotated < 1001, ]
# head(CC_Table)
#
# ### Recalculate p-value
# CC_Table$pval <- p.adjust(CC_Table$weightFisher, method = c("BH"), n = nrow(CC_Table))
# CC_Table$fdr <- p.adjust(CC_Table$weightFisher, method = c("fdr"), n = nrow(CC_Table))
# CC_Table <- CC_Table[CC_Table$fdr < 0.05, ]
#
write.table(CC_Table, file = "topGO_CC_table.txt", sep = "\t", quote = F, col.names = T, row.names = F)

png("topGO_CC.png", 1500, 1500)
par(cex = 0.5)
showSigOfNodes(CC, score(CC_test), useInfo = "def")
dev.off()
