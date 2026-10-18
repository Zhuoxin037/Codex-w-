# -*- coding: utf-8 -*-
"""
生成「雨迹」水迹贴图 —— 48x48 **四边渐隐**的半透明水膜
用法: python .workbuddy/gen_rain_puddle_tex.py
输出: sweetdream_rp_完整版/assets/sweetdream/textures/item/rain_puddle.png

★ 2026-10-18 第三次改：从"有轮廓的水洼"改成"四边渐隐的水膜" ★
  用户实测："水迹依旧没有铺满，且水迹之间还有重叠。"
  上一版贴图是**圆形水洼 + 一圈亮边 + 两圈涟漪**：相邻两点重叠时，那些轮廓线和
  涟漪环会一层压一层地重复出现，肉眼立刻看出"一坨坨重叠"。
  既然板宽（2.2 格）必然略大于撒点间距（1.3~2.0 格），重叠其实绕不开 ——
  那就让它**看不出来**：
    · 不画任何硬轮廓 / 同心环 / 边缘亮线；
    · alpha 从中心（115）沿余弦曲线平滑降到 0，两层叠起来 = 更实的一层，
      过渡自然，不会出现"第二圈边"；
    · 轮廓只靠低频噪声做轻微不规则（不形成可辨认的形状）。
  板宽同时收到 2.2 格（见 models/item/rain_puddle.json），重叠量降到 ~30%。

另外：贴图里保留几处小高光点（水面反光），但不做环状。
"""
import math
import os
import random

from PIL import Image

W = H = 48
random.seed(20261018)

CORE = (26, 96, 128)        # 水体（中心，最深）
RIM = (104, 200, 232)       # 外圈（稍亮，像水膜变薄）
FOAM = (206, 244, 252)      # 高光点

CX = CY = (W - 1) / 2.0
STRETCH = 1.18              # 横向轻微拉宽（水往低处摊）
RMAX = 21.0                 # 衰减半径（像素）：到这就完全透明
PEAK_A = 135                # 单层中心 alpha —— 两层叠加 ≈ 200，像一摊水而不是塑料板

img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = img.load()


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


for y in range(H):
    for x in range(W):
        dx = (x - CX) / STRETCH
        dy = y - CY
        r = math.hypot(dx, dy) / RMAX
        if r >= 1.0:
            continue
        # 低频扰动：让水膜轮廓不规则，但不会形成可以数出来的圆环
        ang = math.atan2(dy, dx)
        rr = r * (1.0 + 0.095 * math.sin(ang * 3.0 + 0.7) + 0.055 * math.sin(ang * 5.0 + 2.1))
        if rr >= 1.0:
            continue
        # 余弦衰减：中心实、边缘平滑归零（rr=1 时正好 0，不会留一条硬边）
        fall = 0.5 * (1.0 + math.cos(math.pi * min(1.0, rr)))

        # 低频水色噪声（不形成规则图案，只让深浅有点变化）
        n = (0.55 * math.sin(x * 0.42 + 1.1) * math.sin(y * 0.37 + 2.3)
             + 0.30 * math.sin((x + y) * 0.23 + 0.5))
        a = int(round(PEAK_A * (fall ** 1.35) * (0.86 + 0.14 * n)))
        if a <= 2:
            continue

        col = lerp(CORE, RIM, min(1.0, rr) ** 2.2)
        px[x, y] = col + (min(255, a),)

# 高光：内部随机 12 处小亮点（水面反光，位置随机 ⇒ 重叠时也不会排成环）
spots = 0
while spots < 12:
    hx = random.uniform(CX - RMAX * 0.62, CX + RMAX * 0.62)
    hy = random.uniform(CY - RMAX * 0.62, CY + RMAX * 0.62)
    x, y = int(hx), int(hy)
    if 0 <= x < W and 0 <= y < H and px[x, y][3] > 40:
        px[x, y] = FOAM + (min(255, px[x, y][3] + 70),)
        spots += 1

out = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "sweetdream_rp_完整版", "assets", "sweetdream", "textures", "item", "rain_puddle.png",
)
img.save(out)
print("写出", out, img.size)
