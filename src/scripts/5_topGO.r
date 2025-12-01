library(topGO)
library(biomaRt)
library(tidyverse)
library(stringr)
library(ggplot2)

# install annotation
library("org.At.tair.db")
# 確認
head(toTable(org.At.tairGO))

# read DEG list
# 期待する列: ID, logFC, logCPM, LR, PValue, FDR
df_raw <- read_table("Comp.txt", col_names = TRUE, sep = "\t")

# 先頭列名が欠落していても動くように先頭列をIDにリネーム
if (!"ID" %in% names(df_raw)) {
  names(df_raw)[1] <- "ID"
}

# 列が不足している場合はここでエラーになる
stopifnot(all(c("ID","logFC","logCPM","LR","PValue","FDR") %in% names(df_raw)))

# 転写産物IDをTAIR遺伝子IDに合わせる（transcript: と .1 等の小数点以降を除去）
df <- df_raw %>%
  mutate(
    Gene = ID %>%
      str_replace("^transcript:", "") %>%
      str_replace("\\.\\d+$", ""))

# org.At.tair.db に存在する ID だけを背景に採用
valid <- AnnotationDbi::keys(org.At.tair.db, keytype = "TAIR")
df <- df %>% filter(TAIR %in% valid)

# トランスクリプト重複 → 遺伝子代表（FDR最小）
df <- df %>% arrange(TAIR, FDR) %>% distinct(TAIR, .keep_all = TRUE)

# DEG判定
# FDR < 0.01 かつ、２倍以上変動（|logFC| > 1）をDEGとする
fdr_thresh <- 0.01
df <- df %>% mutate(isDEG = FDR <= fdr_thresh & abs(logFC) > 1)

# 6) gene universe（名前付き factor の 0/1）
gene_universe <- factor(as.integer(df$isDEG))
names(gene_universe) <- df$TAIR

# 確認
summary(gene_universe)   # 0/1の数
head(gene_universe)

## 7) topGO を小関数で（BP/MF/CC）
run_topgo <- function(allGenes_vec, ontology) {
  GO <- new("topGOdata",
            ontology = ontology,
            allGenes = allGenes_vec,
            annotationFun = annFUN.org,
            mapping = "org.At.tair.db",
            ID = "TAIR")
  test <- runTest(GO, algorithm = "elim", statistic = "fisher")
  topN <- max(1, sum(score(test) < 0.05, na.rm = TRUE))
  tab <- GenTable(GO, elimFisher = test,
                  orderBy = "elimFisher", ranksOf = "elimFisher",
                  topNodes = topN)
  readr::write_tsv(tab, paste0("topGO_", ontology, "_table.txt"))
  png(paste0("topGO_", ontology, ".png"), 1500, 1500)
  par(cex = 0.5); showSigOfNodes(GO, score(test), useInfo = "def"); dev.off()
  tab
}

# 実行（BP/MF/CC）
tab_BP <- run_topgo(gene_universe, "BP")
tab_MF <- run_topgo(gene_universe, "MF")
tab_CC <- run_topgo(gene_universe, "CC")
# 出力: topGO_BP_table.txt / topGO_BP.png などができます
