library(ggplot2)
library(ggsci)
library(cowplot)
library(dplyr)
library(tidyverse)
library(reshape2)

BP <- read.table("topGO_BP_table.txt", header = T, sep = "\t")
BP$logFDR <- -log10(BP$Fisher)
MF <- read.table("topGO_MF_table.txt", header = T, sep = "\t")
MF$logFDR <- -log10(MF$Fisher)
CC <- read.table("topGO_CC_table.txt", header = T, sep = "\t")
CC$logFDR <- -log10(CC$Fisher)

g1 <- ggplot(BP, aes(y = logFDR)) +
  geom_bar(stat = "identity", width = 0.8) +
  coord_flip() +
  theme_classic(base_size = 11, base_family = "") +
  scale_fill_manual(values = "darkgreen") +
  theme(axis.text = element_text(size = 6, color = "black"), axis.title = element_text(size = 14, face = "bold")) +
  ylab("") +
  xlab("BP") +
  theme(legend.position = "none")

g2 <- ggplot(MF, aes(y = logFDR)) +
  geom_bar(stat = "identity", width = 0.8) +
  coord_flip() +
  theme_classic(base_size = 11, base_family = "") +
  scale_fill_manual(values = "blue") +
  theme(axis.text = element_text(size = 6, color = "black"), axis.title = element_text(size = 14, face = "bold")) +
  ylab("") +
  xlab("MF") +
  theme(legend.position = "none")

g2 <- ggplot(CC, aes(y = logFDR)) +
  geom_bar(stat = "identity", width = 0.8) +
  coord_flip() +
  theme_classic(base_size = 11, base_family = "") +
  scale_fill_manual(values = "orange") +
  theme(axis.text = element_text(size = 6, color = "black"), axis.title = element_text(size = 14, face = "bold")) +
  ylab("") +
  xlab("CC") +
  theme(legend.position = "none")

nAll <- nBP + nMF + nCC + 11
nAll

p <- plot_grid(g1, g2, g3, align = "v", nrow = 3, rel_heights = c((nBP + 3) / nAll, (nMF - 3) / nAll, (nCC + 11) / nAll))
ggsave(p, filename = "Barplot_GO.png", dpi = 300)
