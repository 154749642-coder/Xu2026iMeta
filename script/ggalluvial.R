setwd("G:/柱状堆积图/低蛋白2")
library(reshape2)
library(ggplot2)
library(RColorBrewer)
library(ggalluvial)
library(dplyr)
rm(list = ls())
m1 = brewer.pal(9,"Set1")
m2 = brewer.pal(12,"Set3")
Palette1 <- c("#B2182B","#E69F00","#56B4E9","#009E73","#F0E442","#0072B2","#D55E00","#CC79A7","#CC6666","#9999CC","#66CC99","#999999","#ADD1E5")
Palette2 <- c('blue', 'orange', 'yellow', 'red', 'hotpink', 'cyan','purple', 'burlywood1','skyblue','grey','#8b8378','#458b74','#f0ffff','#eeb422','#ee6aa7','#8b3a62','#cd5c5c','#ee6363','#f0e68c','#e6e6fa','#add8e6','#bfefff','#f08080','#d1eeee','#7a8b8b','#8b814c','#8b5f65','gray')
mix <- c(m1,Palette2,Palette1,m2)
phylum <- read.delim('phylum.txt',row.names = 1,sep = '\t',stringsAsFactors = FALSE)
#过滤平均丰度大于0.001的物种
phylum_filter <- phylum[rowMeans(phylum)>0.0000001,] 
phylum_filter$sum <- rowSums(phylum_filter)
#求各类群的丰度总和，并排序
phylum_filter <-  phylum_filter[order(phylum_filter$sum,decreasing = TRUE),]
#删除最后一列和,并取Top10物种作图
phylum_top10 <- phylum_filter[c(1:15),-ncol(phylum_filter)]
# 剩余的物种合并为Others
phylum_top10['Others',] <- 1-colSums(phylum_top10)

#最后一个设置为灰色
colour <- mix[1:nrow(phylum_top10)]
#个人喜欢将最后一个设置为灰色，也就是Others
colour[length(colour)] <- 'gray' 

#设置因子，改为长格式
phylum_top10$Taxonomy <- factor(rownames(phylum_top10),levels = rev(rownames(phylum_top10)))
phylum_top10 <- melt(phylum_top10,id = 'Taxonomy')

#添加分组 合并信息
group <- read.delim('sample.txt', sep = '\t', stringsAsFactors = FALSE)
names(group)[1] <- 'variable'
phylum_top10 <- merge(phylum_top10, group, by = 'variable')
#普通柱状图
p1 <- ggplot(phylum_top10, aes(variable, 100 * value, fill = Taxonomy)) +
  geom_col(position = 'stack', width = 0.6, color = "black") +  # 加上黑色边框
  scale_fill_manual(values = rev(c(colour))) +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = '', y = 'Relative Abundance(%)') +
  theme(panel.grid = element_blank(), 
        panel.background = element_rect(color = 'black', fill = 'transparent'), 
        strip.text = element_text(size = 12)) +
  theme(axis.text = element_text(size = 12), 
        axis.title = element_text(size = 13), 
        legend.text = element_text(size = 11), 
        legend.background = element_blank())

p1

ggsave('Genu.pdf',p1,height = 7,width = 8)
p2 <- ggplot(data = phylum_top10, aes(x = variable, y = value*100, alluvium = Taxonomy, stratum = Taxonomy)) +
  geom_alluvium(aes(fill = Taxonomy), alpha = 0.5, width = 0.5, color = "transparent") +
  geom_stratum(aes(fill = Taxonomy), width = 0.5, color = "black") +
  scale_fill_manual(values = rev(c(colour))) +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = '', y = 'Relative Abundance(%)') +
  geom_flow(alpha = 0) +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(color = 'black', fill = 'transparent'),
        strip.text = element_text(size = 12)) +
  theme(axis.text = element_text(size = 12, angle = 45, hjust = 1),  # 旋转坐标轴标签
        axis.title = element_text(size = 13),
        legend.text = element_text(size = 11),
        legend.background = element_blank())

p2


ggsave('Genu.pdf',p2,height = 7,width = 12)

# 计算各列的平均值并添加为新列
phylum_top10$C_Fg <- rowMeans(phylum_top10[,1:6])
phylum_top10$C_Hg <- rowMeans(phylum_top10[,7:12])
phylum_top10$C_FgL <- rowMeans(phylum_top10[,13:18])
phylum_top10$C_HgL <- rowMeans(phylum_top10[,19:24])
phylum_top10 <- select(phylum_top10,C_Fg,C_Hg,C_FgL,C_HgL)
colour <- mix[1:nrow(phylum_top10)]#设置对应属的个数
colour[length(colour)] <- 'gray' #最后一个设置为灰色
phylum_top10$Taxonomy <- factor(rownames(phylum_top10),levels = rev(rownames(phylum_top10)))
phylum_top10 <- melt(phylum_top10,id = 'Taxonomy')

#作图 普通柱状图
p1 <- ggplot(phylum_top10, aes(variable, 100 * value, fill = Taxonomy)) +
  #facet_wrap(~group,scales = 'free_x',ncol = 2)+
  geom_col(position = 'stack', width = 0.6, color = "black") +  # 加上黑色边框
  scale_fill_manual(values = rev(c(colour))) +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = '', y = 'Relative Abundance(%)') +
  theme(panel.grid = element_blank(), 
        panel.background = element_rect(color = 'black', fill = 'transparent'), 
        strip.text = element_text(size = 12)) +
  theme(axis.text = element_text(size = 12), 
        axis.title = element_text(size = 13), 
        legend.text = element_text(size = 11), 
        legend.background = element_blank())

p1

#冲击图
p2 <- ggplot(data = phylum_top10,aes(x = variable, y = value*100, alluvium = Taxonomy, stratum = Taxonomy))+
  geom_alluvium(aes(fill = Taxonomy), alpha = 0.5, width = 0.5, color = "transparent") +
  geom_stratum(aes(fill = Taxonomy), width = 0.5, color = "black") +
  scale_fill_manual(values = rev(c(colour))) +
  theme_classic() +
  scale_y_continuous(expand = c(0, 0)) +
  labs(x = '', y = 'Relative Abundance(%)') +
  geom_flow(alpha = 0) +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(color = 'black', fill = 'transparent'),
        strip.text = element_text(size = 12)) +
  theme(axis.text = element_text(size = 12, angle = 45, hjust = 1),  # 旋转坐标轴标签
        axis.title = element_text(size = 13),
        legend.text = element_text(size = 11),
        legend.background = element_blank())

p2
