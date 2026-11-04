# -*- coding: utf-8 -*-
"""_gen_oath_victory_icon.py —— 「胜利誓约之剑」16×16 平面图标（唯一真相来源）

【取名与定位】剑 · 传说 · 主动：突击到目标背后 → 展开领域回复。
            视觉语言 = 「凯旋的十字剑」：象牙白刃 + 深金护手 + 金光自护手漫上刃根。

【为什么用 hengdao 当骨架】包内 34 把剑全是同一套手绘斜向摆位（刃在右上、柄在左下）。
  hengdao 是字形最"正"的一把：刃宽、有横档护手、柄长，最能承载"仪式感"。
  直接拿它当骨架，形状（刃/镡/柄/护环）天然与原版同族，只换"这是哪件剑"的颜色语言。

【★ 骨架换色的原理（与 _gen_batch12_icons.py 逐字同源）】
  取骨架里所有不透明像素 → 按感知亮度排序 → 等分成 N 档 → 第 k 档写成目标调色板第 k 色。
  "原来的高光还是高光、阴面还是阴面"，明暗关系不会塌；骨架色数多于目标色数时相邻档合并（压缩）。

【★ 三分区】16×16 斜向摆位里三块的位置是固定的：
    刃   = y ≤ 8（右上）
    护手 = y ≥ 9 且 暖色偏黄（R−B ≥ 35）—— 金饰
    柄   = 其余（y ≥ 9 的冷灰棕 = 木柄 + 黑色描边）
  三块各套一套调色板，否则金护手会被当成"亮部刃"压成白色，"金"就读不出来。

【★ 刃的冷暖过渡】刃的调色板故意做成「冷灰阴面 → 暖白高光」（不是纯灰阶）：
  纯灰 = 不锈钢板，冷阴暖亮 = 磨过的金属。这是 16×16 尺度下唯一能读出"刃"的办法。

【★ 金光漫刃】在刃最靠近护手的 2 个像素上染金亮 —— 让金"从护手爬上剑身"。
  只给 2 个：16×16 里超过 3 个像素的装饰点会被读成噪点/污渍。

【用法】python .workbuddy/_gen_oath_victory_icon.py [--write] [--preview]
  不带 --write 只出预览到 .workbuddy/_preview_oath_victory.png，不动资源包。
"""
import os
import sys

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEX = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream',
                   'textures', 'item', 'vanilla')

SKEL = 'hengdao'          # 骨架
OUT = 'oath_victory'      # 输出


def hexs(*xs):
    return [tuple(int(x[i:i + 2], 16) for i in (0, 2, 4)) for x in xs]


def lum(c):
    """感知亮度（Rec.601 整数版）：人眼对绿最敏感、对蓝最迟钝。"""
    return 299 * c[0] + 587 * c[1] + 114 * c[2]


# 刃：7 档，深棕阴面 → 香槟金白高光
#   ★ 阴面留一点冷（#2a2622），中间转暖，高光近白 —— 整把剑"浸在金里"但不发黄。
#     全暖会读成骨剑/木剑；全冷就回到 verdict/hengdao 那一族了。
#   ★ 中间三档比第一版更黄（#736656 / #9e8f76 / #c6b696）：包内 34 把剑的刃
#     全是冷白（#aeb8c4 那一路），暖到"香槟金白"才在并排时一眼分得开。
BLADE = hexs('2a2622', '4a4238', '736656', '9e8f76', 'c6b696', 'e8dcc0', 'fff8e8')
# 护手金：6 档，深铜 → 亮金（★ 比包内既有金更亮一档：这是"传说"的金）
GOLD = hexs('3a2a0a', '6a4f14', '9a7520', 'c49a30', 'e2be55', 'f5e09a')
# 柄：酒红缠皮 4 档
#   ★ 这张图的识别点。包内 34 把剑的柄清一色黑/棕/灰，没有红柄。
#     "胜利"的红缎带 + "誓约"的血色，语义也对得上；16×16 里柄只有 6~8 像素，
#     红柄不会抢主体，但足够让人一眼认出"这不是 hengdao"。
#   ★ 跨度必须收窄（#5a1a1e 就到顶）。第一版最高档给到 #7e2a1e、第二版 #6b1a12，
#     放大后都读成"锈迹/干涸的血"，因为那两档偏褐（G>B）。改成偏冷的「宝石红」
#     （B 抬到与 G 齐平）才像"深红皮革"，而不是"生锈"。
HAFT = hexs('1a0608', '2c0a0c', '421216', '5a1a1e')


def classify(x, y, p):
    if y <= 8:
        return 'blade'
    r, g, b = p[0], p[1], p[2]
    return 'gold' if (r - b) >= 35 else 'haft'


def build():
    im = Image.open(os.path.join(TEX, SKEL + '.png')).convert('RGBA')
    px = im.load()
    w, h = im.size
    assert (w, h) == (16, 16), f'骨架不是 16×16：{w}×{h}'

    groups = {'blade': [], 'gold': [], 'haft': []}
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            if p[3] == 0:
                continue
            groups[classify(x, y, p)].append((x, y, p))

    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    op = out.load()
    for gname, pal in (('blade', BLADE), ('gold', GOLD), ('haft', HAFT)):
        items = groups[gname]
        if not items:
            continue
        # ★ 按**亮度值**线性映射，不是按像素数等分。
        #   ★ 事故 2026-10-27：第一版照抄 _gen_batch12_icons.py 的"等分档"
        #     （k = i*len(pal)//n，把排序后的像素按个数均摊到各档），
        #     这把剑的骨架刃部 80% 像素都挤在亮区 ⇒ 一半被硬推进暗档，
        #     刃上出现横条纹，读起来像"刃被切成两段"。
        #   等分法在色阶分布均匀的骨架上看不出来，在偏亮的肋上必炸。
        #   线性映射保留的是"原来的相对明暗"，这才是换色要的东西。
        lo = min(lum(t[2]) for t in items)
        hi = max(lum(t[2]) for t in items)
        span = max(1, hi - lo)
        for x, y, p in items:
            k = int(round((lum(p) - lo) * (len(pal) - 1) / span))
            k = max(0, min(len(pal) - 1, k))
            op[x, y] = pal[k] + (p[3],)

    # ---- 形状：一个像素都不改 ----
    #   ★ 试过给护手两端各补 1 像素做「金翼」，实测失败：骨架护手横档右端是
    #     黑色描边（x=11 的 #1a1408），补在 x=12 的金像素被描边隔开，在 16×16 下
    #     就是一个**孤立的黄点**（像噪点/瑕疵），不是"翼"。左端能连上但右端连不上，
    #     只补左边又不对称。16×16 里没有"半像素过渡"可用，这类外扩一律不做。
    #   ⇒ 本件与包内所有换色件一样：只换色，不动形。
    #   （唯一例外是下面的柄尾金坠：它盖在**柄内部**的像素上，不新增轮廓，
    #     所以不存在"被描边隔开成孤立点"的问题。）

    # ---- 柄尾金坠：柄最末端的 1 个像素镶金 ----
    #   ★ 判据是"柄区内 y 最大的那一行里、x 最小的那个不透明像素"—— 骨架柄向
    #     左下延伸，最左下角就是柄尾。不写死坐标：换骨架时自动跟着走。
    haft_pts = [t for t in groups['haft'] if t[1] == max(q[1] for q in groups['haft'])]
    tail = min(haft_pts, key=lambda t: t[0])
    op[tail[0], tail[1]] = GOLD[4] + (255,)

    return out


def preview(im):
    """出对比图：骨架 / 成品 / 成品×2 平铺（模拟背包里并排两把的样子）。"""
    S = 14
    pad = 18
    cell = 16 * S + pad * 2
    cv = Image.new('RGBA', (cell * 3, cell + 34), (24, 24, 28, 255))
    d = ImageDraw.Draw(cv)

    skel = Image.open(os.path.join(TEX, SKEL + '.png')).convert('RGBA')
    for i, (title, src) in enumerate((('骨架 ' + SKEL, skel), ('胜利誓约', im), ('16×16 原尺寸', im))):
        s = S if i < 2 else 1
        big = src.resize((16 * s, 16 * s), Image.NEAREST)
        x = i * cell + pad
        y = pad
        if i == 2:
            # 原尺寸放到格子正中，周围补一圈棋盘格底（看清透明边）
            bg = Image.new('RGBA', (16 * S, 16 * S), (0, 0, 0, 0))
            for by in range(0, 16 * S, 8):
                for bx in range(0, 16 * S, 8):
                    c = (44, 44, 50, 255) if ((bx // 8 + by // 8) % 2 == 0) else (34, 34, 40, 255)
                    ImageDraw.Draw(bg).rectangle([bx, by, bx + 7, by + 7], fill=c)
            bg.alpha_composite(big, (8 * S - 8, 8 * S - 8))
            cv.alpha_composite(bg, (x, y))
        else:
            cv.alpha_composite(big, (x, y))
        d.text((x, cell + 6), title, fill=(210, 210, 214, 255))

    p = os.path.join(ROOT, '.workbuddy', '_preview_oath_victory.png')
    cv.save(p)
    return p


def main():
    write = '--write' in sys.argv
    im = build()
    print('生成 %s.png  16×16  不透明像素 %d'
          % (OUT, sum(1 for y in range(16) for x in range(16) if im.load()[x, y][3])))
    used = sorted({im.load()[x, y][:3] for y in range(16) for x in range(16) if im.load()[x, y][3]})
    print('实际用色 %d 档' % len(used))
    if write:
        im.save(os.path.join(TEX, OUT + '.png'), optimize=True)
        print('已写入', os.path.join(TEX, OUT + '.png'))
    print('预览 ->', preview(im))


if __name__ == '__main__':
    main()
