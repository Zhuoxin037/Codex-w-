# -*- coding: utf-8 -*-
"""
sweetdream 图标字体生成脚本
=========================================================================
跑法(在仓库根目录):
    python sweetdream_rp/tools/make_icons.py

它生成三样东西:
    sweetdream_rp/assets/sweetdream/textures/font/icons.png   5 个图标并排的图集
    sweetdream_rp/assets/sweetdream/lang/*.json               图标字符的翻译键
    (字体定义 font/icons.json 是手写的, 不在这里生成)

【怎么改图标】
  下面 SHAPES 里每个图标就是一段 Python 绘图代码, 画在 4 倍的画布上(128x128),
  最后用 NEAREST 缩到 32x32 —— 这样边缘是"整齐的像素块", 不糊。
  想换颜色改 COLORS; 想彻底换画风, 直接把 icons.png 用你的绘图软件重画
  (保持 160x32、5 格、透明背景), 然后**不用**再跑这个脚本。

【图集布局】
  5 格横排, 每格 32x32, 总尺寸 160x32。
  字符顺序 = yuanhai / liuhuo / yehuo / shixin / dream, 对应 U+E000..U+E004。
"""
import json
import os
from PIL import Image, ImageDraw

SS = 4                      # 超采样倍率
CELL = 32                   # 每个图标最终尺寸
N = 5                       # 图标数量
HERE = os.path.dirname(os.path.abspath(__file__))
RP = os.path.dirname(HERE)

COLORS = {
    "yuanhai": {"core": "#1E6FA8", "light": "#6FD3F2", "outline": "#06263A"},
    "liuhuo":  {"core": "#E8701A", "light": "#FFD98A", "outline": "#4A1A00"},
    "yehuo":   {"core": "#6A3FA0", "light": "#C9A7F0", "outline": "#2A1040"},
    "shixin":  {"core": "#C81E3C", "light": "#FF7A8A", "outline": "#3A0010"},
    "dream":   {"core": "#EDE6C8", "light": "#FFFFFF", "outline": "#6B6455"},
}

# 私用区字符: U+E000..U+E004(5 个图标)
CHARS = [chr(0xE000 + i) for i in range(N)]
ORDER = ["yuanhai", "liuhuo", "yehuo", "shixin", "dream"]


def draw_droplet(d, c):
    """渊海: 一滴水(圆 + 尖顶)"""
    d.polygon([(64, 12), (98, 62), (30, 62)], fill=c["core"])
    d.ellipse([22, 42, 106, 118], fill=c["core"])
    d.ellipse([46, 62, 72, 96], fill=c["light"])


def draw_flame(d, c):
    """流火: 火苗(倒水滴 + 内焰)"""
    d.polygon([(64, 10), (100, 70), (28, 70)], fill=c["core"])
    d.ellipse([20, 52, 108, 122], fill=c["core"])
    d.ellipse([48, 72, 78, 112], fill=c["light"])


def draw_crescent(d, c):
    """夜火: 弯月(大圆挖掉一个偏移圆)"""
    d.ellipse([18, 18, 108, 108], fill=c["core"])
    d.ellipse([46, 6, 128, 96], fill=(0, 0, 0, 0))
    d.ellipse([30, 30, 52, 66], fill=c["light"])


def draw_heart(d, c):
    """噬心: 咬了一口的爱心"""
    d.ellipse([14, 26, 68, 80], fill=c["core"])
    d.ellipse([60, 26, 114, 80], fill=c["core"])
    d.polygon([(16, 58), (112, 58), (64, 118)], fill=c["core"])
    # 右上角"咬"掉一块(挖成透明) —— 缺口要大一点才看得出是"噬心"
    d.ellipse([78, 0, 130, 52], fill=(0, 0, 0, 0))
    d.ellipse([96, 4, 122, 30], fill=(0, 0, 0, 0))
    d.ellipse([26, 40, 46, 64], fill=c["light"])


def draw_cloud(d, c):
    """白昼梦: 一朵云(三个圆 + 底座)"""
    d.ellipse([10, 52, 70, 106], fill=c["core"])
    d.ellipse([40, 34, 100, 100], fill=c["core"])
    d.ellipse([72, 50, 120, 104], fill=c["core"])
    d.rectangle([20, 78, 112, 106], fill=c["core"])
    d.ellipse([30, 56, 50, 76], fill=c["light"])


DRAW = {
    "yuanhai": draw_droplet,
    "liuhuo": draw_flame,
    "yehuo": draw_crescent,
    "shixin": draw_heart,
    "dream": draw_cloud,
}


def render(mark):
    """画一格: 先画放大图 -> 描边 -> 缩到 32x32"""
    c = COLORS[mark]
    size = CELL * SS
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    DRAW[mark](ImageDraw.Draw(img), c)

    # 描边: 把不透明区域向外膨胀 1 像素(在放大图里就是 SS 像素), 涂成暗色,
    # 再把本体盖回去 —— 于是得到一圈干净的深色轮廓, 像原版图标那样有厚度。
    from PIL import ImageFilter
    alpha = img.split()[3]
    grown = alpha.filter(ImageFilter.MaxFilter(2 * SS + 1))
    outline = Image.new("RGBA", (size, size), c["outline"])
    outline.putalpha(grown)
    outline.alpha_composite(img)

    return outline.resize((CELL, CELL), Image.NEAREST)


def main():
    sheet = Image.new("RGBA", (CELL * N, CELL), (0, 0, 0, 0))
    for i, mark in enumerate(ORDER):
        sheet.paste(render(mark), (i * CELL, 0))

    tex = os.path.join(RP, "assets", "sweetdream", "textures", "font", "icons.png")
    os.makedirs(os.path.dirname(tex), exist_ok=True)
    sheet.save(tex)
    print("写出图集:", tex, sheet.size)

    # lang: 翻译键 -> 图标字符(客户端读, 所以数据包里完全不用出现私用字符)
    lang_dir = os.path.join(RP, "assets", "sweetdream", "lang")
    os.makedirs(lang_dir, exist_ok=True)
    table = {"sweetdream.icon." + m: CHARS[i] for i, m in enumerate(ORDER)}
    for name in ("zh_cn", "en_us"):
        p = os.path.join(lang_dir, name + ".json")
        with open(p, "w", encoding="utf-8") as f:
            json.dump(table, f, ensure_ascii=False, indent=2)
        print("写出翻译:", p)

    print("字符表:", {k: hex(ord(v)) for k, v in table.items()})


if __name__ == "__main__":
    main()
