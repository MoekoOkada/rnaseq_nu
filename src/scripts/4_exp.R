library(edgeR)
library(DESeq2)
library(dplyr)
library(stringr)
library(gplots)
library(ggplot2)
library(ggdendro)

# load count data
# setwd("3_count")
data <- read.table("counts.txt", header = T, row.names = 1, sep = "\t")
head(data)

data2 <- dplyr::select(
  data,
  -contains(c(
    "Chr", "Start",
    "End", "Strand"
  ))
)
head(data2)

# set groups
group <- factor(c(
  "b_cold", "b_cold", "b_cold",
  "a_control", "a_control", "a_control"
))
design <- model.matrix(~group)

# DEG detection from zinc treated samples
data3 <- dplyr::select(data2, -contains("Length"))
d <- DGEList(counts = data3, group = group)

## normalization with replicates
d1 <- calcNormFactors(d)
d1 <- estimateGLMCommonDisp(d1, design)
d1 <- estimateGLMTrendedDisp(d1, design)
d1 <- estimateGLMTagwiseDisp(d1, design)

# Multi-dimensional scaling plot
plotMDS(d1)

# 正規化の数値を一般化線型モデルで近似
fit1 <- glmFit(d1, design)
lrt1 <- glmLRT(fit1, coef = 2)

# 表にする
table1 <- as.data.frame(topTags(lrt1, n = nrow(count)))
# print(head(table1))

# 表を出力
write.table(table1,
  file = "Comp.txt",
  col.names = T, row.names = T, sep = "\t", quote = FALSE
)

# 発現量上位1000遺伝子でクラスタリング
top_deg <- as.data.frame(topTags(lrt, n = 1000))
scaledata <- t(scale(t(top_deg))) # Centers and scales data.
scaledata <- scaledata[complete.cases(scaledata), ]

hr <- hclust(as.dist(1 - cor(t(scaledata), method = "pearson")), method = "complete")
hc <- hclust(as.dist(1 - cor(scaledata, method = "spearman")), method = "complete")

# hirarchical clustering with heatmap
png("Cluster_hm.png")
heatmap.2(d2,
  Rowv = as.dendrogram(hr),
  Colv = as.dendrogram(hc),
  col = colorRampPalette(c("blue", "red"))(100),
  scale = "row",
  cexCol = 0.7,
  labRow = F,
  main = "Heatmap.2",
  trace = "none"
)
dev.off()

# DEGを検出 (FDR < 0.01)
FDR <- as.logical(table1$FDR < 0.01) # logical (true、false)の判定付きで変換。
DEG_names <- rownames(table1)[FDR] # trueだけDEG.namesに収納

# DEGを表に出力 (FDR < 0.01)
DEGs <- subset(table1, FDR < 0.001)
write.table(DEGs,
  file = "DEGs.txt",
  col.names = T, row.names = T, sep = "\t", quote = FALSE
)


# MA plot
plotSmear(lrt1, de.tags = DEG_names, cex = 0.3)

# MA plotを保存
png("MAplot.png", bg = "transparent")
print(plotSmear(lrt1, de.tags = DEG_names, cex = 0.3))
dev.off()

## volcano plot
countdata <- mutate(table1, thcolor = ifelse(FDR >= 0.01, 0,
  ifelse(logFC >= 1, 1,
    ifelse(logFC <= -1, 2, 0)
  )
))

vol <- ggplot() +
  geom_point(aes(x = countdata$logFC, y = -log10(countdata$FDR), color = as.factor(countdata$thcolor)), size = 0.1) +
  labs(x = "log2 (Fold Change)", y = "-log10 (p-value)") +
  scale_color_manual(values = c("black", "red", "blue")) +
  geom_hline(yintercept = -log10(0.05), size = 0.2, color = "red") +
  geom_vline(xintercept = -1, size = 0.2, color = "red") +
  geom_vline(xintercept = 1, size = 0.2, color = "red") +
  theme(legend.position = "none", panel.grid = element_blank())

vol
ggsave(vol, file = "volcano.png", dpi = 200, bg = "transparent")
