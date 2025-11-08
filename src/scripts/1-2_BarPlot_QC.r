# ライブラリの読み込み
library(ggplot2)
library(tidyr)
library(dplyr)
library(scales)

# 作業するディレクトリを設定
setwd("/path/to/your/directory")

# データの読み込み
data <- read.delim("qc_results_mod.txt", header = T, sep = "\t")
data <- data[, -8]
head(data)

# 作図用に形を変える
data2 <- pivot_longer(data, -sample, names_to = "variable", values_to = "values") # nolint
head(data2)

# 積み上げ棒グラフの順番を決める
data2$category <- factor(data2$sample, levels = c("Dropped", "Reverse only surviving", "Forward only surviving", "Both surviving")) # nolint
head(data2)

# 色を決める
Colours1 <- c("#7B7B7B", "#629d62", "#4eb14e", "#039BE5") # nolint

# 作図する
p1 <- ggplot(data2, aes(x = variable, y = values)) +
  geom_bar(stat = "identity", aes(fill = category)) # 積み上げ棒グラフ
p1 <- p1 + theme( # 図の調整
  panel.background = element_rect(fill = "transparent", color = "black"),
  panel.grid.minor = element_line(color = NA),
  panel.grid.major = element_line(color = "grey"),
  axis.text.x = element_text(size = 12, angle = 90, hjust = 1, color = "black", vjust = 0.5), # nolint
  axis.text.y = element_text(size = 12, color = "black"),
  axis.title.x = element_blank(),
  axis.title.y = element_blank()
) + scale_y_continuous(expand = c(0, 0)) +
  scale_fill_manual(values = Colours1)
p1 # 図を表示させる
ggsave(args[2], dpi = 200, bg = "transparent") # 図を保存する

# ％表示での積み上げ棒グラフを作る
p2 <- ggplot(data2, aes(x = variable, y = values)) +
  geom_bar(stat = "identity", aes(fill = category), position = "fill")
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
ggsave(args[3], dpi = 200, bg = "transparent")
