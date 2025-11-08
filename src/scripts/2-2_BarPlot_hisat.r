# ライブラリの読み込み
library(ggplot2)
library(tidyr)
library(dplyr)
library(scales)

# 作業するディレクトリを設定
setwd("/path/to/your/directory")

# データの読み込み
data <- read.table("hisat_results_mod.txt", header = T, sep = "\t")
data <- data[, -8]
data <- select(data, -sample)
head(data)

# リード数の計算（ペアになっているものを２倍したりなど）
Mult <- as.numeric(data[4, ]) * 2 + as.numeric(data[9, ])
Unmap <- as.numeric(data[1, ]) * 2 - (as.numeric(data[3, ]) * 2 + as.numeric(data[8, ]) + as.numeric(data[5, ]) * 2 + as.numeric(data[4, ]) * 2 + as.numeric(data[9, ]))
Total <- as.numeric(data[1, ]) * 2
Pair <- as.numeric(data[3, ]) * 2
Disc <- as.numeric(data[5, ]) * 2
data3 <- rbind(Total, Pair, data[8, ], Disc, Mult, Unmap)
head(data3)

ID <- c("total", "Pair", "single", "discordantly", "Multimapped", "Unmapped")
data4 <- cbind(sample = ID, data3)
write.table(data4, file = args[4], col.names = TRUE, sep = "\t", quote = FALSE, row.names = FALSE)

# 作図のために形を変える
data5 <- pivot_longer(data4, -sample, names_to = "variable", values_to = "values")

# 積み上げ棒グラフの順番を決める
data5$category <- factor(data5$sample, levels = c("Unmapped", "Multimapped", "discordantly", "single", "Pair", "total"))
data5 <- filter(data5, category != "total")
head(data5)

# 色を決める
Colours1 <- c("#7B7B7B", "#629d62", "#084208", "#0078b4", "#00547e") # nolint

# 作図する
p1 <- ggplot(data5, aes(x = variable, y = as.numeric(values))) +
  geom_bar(stat = "identity", aes(fill = as.factor(category)))
p1 <- p1 + theme(
  panel.background = element_rect(fill = "transparent", color = "black"),
  panel.grid.minor = element_line(color = NA),
  panel.grid.major = element_line(color = "grey"),
  axis.text.x = element_text(size = 12, angle = 90, hjust = 1, color = "black", vjust = 0.5), # nolint
  axis.text.y = element_text(size = 12, color = "black"),
  axis.title.x = element_blank(),
  axis.title.y = element_blank()
) + scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = Colours1)
p1
ggsave(p1, file = "hisat_results.png", dpi = 200, bg = "transparent", width = 15, height = 7)

# ％表示での積み上げ棒グラフを作る
p2 <- ggplot(data5, aes(x = variable, y = as.numeric(values))) +
  geom_bar(stat = "identity", aes(fill = as.factor(category)), position = "fill")
p2 <- p2 + theme(
  panel.background = element_rect(fill = "transparent", color = "black"),
  panel.grid.minor = element_line(color = NA),
  panel.grid.major = element_line(color = "grey"),
  axis.text.x = element_text(size = 12, angle = 90, hjust = 1, color = "black", vjust = 0.5), # nolint
  axis.text.y = element_text(size = 12, color = "black"),
  axis.title.x = element_blank(),
  axis.title.y = element_blank()
) +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  scale_fill_manual(values = Colours1)
p2
ggsave(p2, file = "hisat_results_percent.png", dpi = 200, bg = "transparent", width = 15, height = 7)
