# -*- coding: utf-8 -*-
"""
生成「雨迹」水迹贴图 —— 48x48 半透明水洼（像素风，与包内其它贴图协调）
用法: python .workbuddy/gen_rain_puddle_tex.py
输出: sweetdream_rp_完整版/assets/sweetdream/textures/item/rain_puddle.png

★ 2026-10-17 第二次改：从 32x32 提到 48x48、颜色整体压深 ★
  原因：模型板从 1.6 格加宽到 3.0 格（见 models/item/rain_puddle.json），
  32 像素铺 3 格只有 10.7 px/格，边缘会糊；48 像素 = 16 px/格，与原版一致。
  同时首版 alpha 只有 105~205、主色偏白，压在草地/石头上几乎看不出是水 ——
  现在水体 alpha 170、水膜 238，靠"深青 + 亮边"拉开对比。

设计要点（配合 dot_spawn 的 item_display 平铺）：
  · 只画一摊"水"，四周全透明 —— 叠在草地上不会盖住地面
  · 轮廓不规则（半径做噪声扰动），避免一排点看着像复制粘贴
  · 边缘一圈亮青（水膜反光），内部深青半透明；两圈涟漪 + 两点高光
  · 主色 (0.25,0.7,0.85) 与回旋/雨迹的 dust 粒子同源 = RGB(64,178,217)
"""
import math
import os
import random

from PIL import Image

W = H = 48
random.seed(20261017)

# 颜色（RGBA）
CORE = (24, 92, 126, 170)         # 水体（最暗）
MID = (42, 132, 172, 200)         # 中层
RIM = (96, 206, 236, 238)         # 水膜边缘（最亮的一圈青）
FOAM = (210, 248, 255, 252)       # 高光/涟漪
EDGE = (12, 54, 78, 230)          # 极外侧一圈压深，勾出轮廓

cx = cy = (W - 1) / 2.0
STRETCH = 1.26                    # 横向拉宽（水洼多是横向摊开的）

# 32 尺度 → 48 尺度的统一比例（轮廓/涟漪/高光都按这个放大，形状保持一致）
SC = W / 32.0


def radius(angle):
    """不规则水洼轮廓半径：主椭圆 + 两段正弦 + 轻微抖动"""
    base = 12.4 * SC
    wob = 1.55 * SC * math.sin(angle * 3.0 + 0.7) + 0.85 * SC * math.sin(angle * 5.0 + 2.1)
    wob += random.uniform(-0.45 * SC, 0.45 * SC)
    return base + wob


def inside(x, y, scale=1.0):
    dx = (x - cx) / STRETCH
    dy = y - cy
    r = math.hypot(dx, dy)
    a = math.atan2(dy, dx)
    return r <= radius(a) * scale


img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = img.load()

# ---- ① 水体填充（由外向内分两层）----
for y in range(H):
    for x in range(W):
        if not inside(x, y):
            continue
        dx = (x - cx) / STRETCH
        dy = y - cy
        r = math.hypot(dx, dy)
        # 距离边缘的相对位置：越靠边越亮
        edge_r = radius(math.atan2(dy, dx))
        t = max(0.0, min(1.0, r / max(edge_r, 0.001)))
        if t > 0.90:
            col = RIM
        elif t > 0.72:
            col = MID
        else:
            col = CORE
        px[x, y] = col

# ---- ② 外轮廓一圈压深（有边界才像"一摊水"而不是一团雾）----
for y in range(H):
    for x in range(W):
        if not inside(x, y):
            continue
        for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if not inside(x + ox, y + oy):
                px[x, y] = EDGE
                break

# ---- ③ 涟漪：两圈细亮环（错开中心，避免太规整）----
for ring, (rcx, rcy, rr, col) in enumerate(
    (
        (cx - 1.2 * SC, cy - 0.6 * SC, 6.4 * SC, FOAM),
        (cx + 2.0 * SC, cy + 1.4 * SC, 3.6 * SC, (176, 232, 248, 220)),
    )
):
    for y in range(H):
        for x in range(W):
            if not inside(x, y):
                continue
            d = math.hypot((x - rcx) / STRETCH, y - rcy)
            if abs(d - rr) < 0.62 * SC:
                px[x, y] = col

# ---- ④ 高光点（两小簇，水面反光）----
for hx, hy, n in ((10 * SC, 12 * SC, 2), (20 * SC, 19 * SC, 1)):
    for _ in range(n):
        x = int(hx) + random.randint(-1, 1)
        y = int(hy) + random.randint(-1, 1)
        if inside(x, y):
            px[x, y] = FOAM

out = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "sweetdream_rp_完整版", "assets", "sweetdream", "textures", "item", "rain_puddle.png",
)
img.save(out)
print("写出", out, img.size)
