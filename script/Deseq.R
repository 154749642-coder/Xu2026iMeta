# 1. 加载必要的包
library(DESeq2)
library(dplyr)

# 2. 读取表达矩阵
data <- read.table("L_Fg.L_Hg.txt", header = TRUE, sep = "\t", check.names = FALSE)

# 3. 确保 COG/KOG 列为行名
if (!"COG/KOG" %in% colnames(data)) {
  stop("列名 'COG/KOG' 不存在，请检查文件")
}

# 将 COG/KOG 列作为行名
rownames(data) <- make.unique(as.character(data$`COG/KOG`))

# 移除 COG/KOG 列
data <- data[, -which(names(data) == "COG/KOG")]

# 4. 确保剩下的部分是表达矩阵
count_data <- data  # 现在整个数据就是基因表达数据

# 5. 加载分组信息
col_data <- read.table("Coldata.txt", header = TRUE, sep = "\t", row.names = 1)
if (!all(rownames(col_data) == colnames(count_data))) {
  stop("样本名不匹配，请检查分组文件和表达矩阵的列名")
}
col_data$condition <- factor(col_data$condition)
col_data$condition <- relevel(col_data$condition, ref = "C_HgL")

# 6. 差异表达分析
dds <- DESeqDataSetFromMatrix(countData = count_data, colData = col_data, design = ~ condition)
dds <- DESeq(dds)
res <- results(dds)

# 7. 保存结果
write.table(res, "C_HgL.L_HgL.csv", sep = ",", quote = TRUE, row.names = TRUE)

print("差异表达分析结果已保存到 DESeq2_results.csv")

