import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np

# Step 1: 读取数据
df = pd.read_csv('chicken_bar.txt', sep='\t')  # 根据实际情况修改文件路径和分隔符

# Step 2: 清理数据，确保没有缺失的 log2 Fold Change
df = df.dropna(subset=['log2 Fold Change'])

# Step 3: 获取所有 Comparison 类型
comparisons = df['Comparison'].unique()

# Step 4: 创建一个大的画布，并通过子图划分区域
n_comparisons = len(comparisons)
fig, axes = plt.subplots(n_comparisons, 1, figsize=(12, 3 * n_comparisons))  # 调整高度以减少空隙

# 如果只有一个子图（n_comparisons == 1），axes 不是数组，所以需要特殊处理
if n_comparisons == 1:
    axes = [axes]

# Step 5: 获取统一的 x 轴范围，用于所有子图
x_ticks = list(range(-1, 1))  # 统一的 x 轴刻度范围，修改为 -8 到 7

# 固定的柱子宽度
fixed_bar_width = 0.4  # 设置统一的柱子宽度，确保视觉效果一致

# Step 6: 使用渐变色映射 (colormap)
cmap = mpl.cm.YlGnBu  # 使用黄绿蓝渐变
norm = mpl.colors.Normalize(vmin=df['log2 Fold Change'].min(), vmax=df['log2 Fold Change'].max())  # 归一化数据范围

# Step 7: 遍历每个 Comparison，绘制柱状图
for i, comparison in enumerate(comparisons):
    ax = axes[i]

    # 筛选出当前 Comparison 的数据
    subset = df[df['Comparison'] == comparison]

    # 画出每个柱子的渐变
    for idx, row in subset.iterrows():
        # 计算渐变的起始和结束颜色
        start_color = cmap(norm(0))  # 起始颜色：黄色
        end_color = cmap(norm(row['log2 Fold Change']))  # 结束颜色：根据 log2 Fold Change 确定的颜色

        # 使用 `LineCollection` 来创建一个颜色渐变的效果
        # 我们将每个柱子切成多个小段，确保从底部到顶部颜色逐渐变化
        n_segments = 50  # 切分为 50 个段（可以根据需要调整）
        x_values = np.linspace(0, row['log2 Fold Change'], n_segments)
        colors = [cmap(norm(x)) for x in x_values]  # 计算每个小段的颜色

        for j in range(n_segments - 1):
            ax.barh(row['Description'], x_values[j+1] - x_values[j], left=x_values[j],
                    color=colors[j], height=fixed_bar_width)

    # 设置标题和标签
    ax.set_title(f'{comparison}', fontsize=10)
    ax.set_xlabel('log2 Fold Change', fontsize=10)
    ax.set_yticklabels(ax.get_yticklabels(), fontsize=10)

    # 设置 x 轴的范围，确保 0 在中间
    ax.set_xlim(-1, 1)  # 统一设置 x 轴范围
    ax.set_xticks(x_ticks)  # 设置统一的 x 轴刻度

    # 如果有负值，显示负数和正数的刻度
    ax.axvline(x=0, color='black', linestyle='--', lw=1)  # 在 x=0 处画一条虚线

    # 旋转 x 轴标签
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')  # 让标签旋转45度

    # 去掉 set_aspect，避免让图形过高
    ax.set_aspect('auto')  # 确保纵横比自动调整，避免图形变形

    # 强制固定纵横比一致
    ax.set_aspect(0.5)  # 统一纵横比，避免不同子图的比例差异

# Step 8: 调整子图之间的间距
plt.subplots_adjust(hspace=0.05, top=0.95, bottom=0.05)  # 调整子图间距并减少顶部和底部空白

# Step 9: 保存为 PDF 格式
plt.savefig('ND_VS_LPD.pdf', format='pdf', dpi=300, bbox_inches='tight')

# Step 10: 显示图形
plt.show()