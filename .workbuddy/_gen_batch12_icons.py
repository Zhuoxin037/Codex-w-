# -*- coding: utf-8 -*-
"""_gen_batch12_icons.py —— 批 12 外观：7 件武器的 16×16 平面图标（唯一真相来源）
【为什么用"骨架 + 换色"而不是从零画】
  包内 100 张平面图标是同一套手绘像素风（16×16、斜向、7~22 色、手绘明暗分层）。
  从零画 7 件很难保证"看着像同一批货"。所以这里拿同类武器的**现成图标当骨架**，
  按亮度分层重新映射到目标配色 —— 形状（刃/护手/柄、弩身/弓臂、杖杆/宝珠）
  天然与原版一致，只换"哪件武器"的颜色语言。

【★ 亮度分层映射的规则】把骨架里所有不透明像素按亮度排序，等分成 N 档，
  第 k 档写成目标调色板的第 k 色。这样"原来的高光还是高光、阴面还是阴面"，
  明暗关系不会塌。骨架色数多于目标色数时相邻档会合并（这正是我们要的压缩）。

【★ 冷/暖分流】弩身是"木 + 金属"两种材质，全压成一个色系会糊成一团。
  所以按 b > r 判"这是冷色像素（金属）"，木身与金属分别套一套调色板。

【★ 缺月的"缺口"】在映射之后把刃上 2 个像素清成透明，视觉上就是刃被啃掉一块
  —— 名字叫「缺月」，这是唯一能让 16×16 看出"缺"的办法。

【用法】python .workbuddy/_gen_batch12_icons.py [--preview]
"""
import collections
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEX = os.path.join(ROOT, 'sweetdream_rp_完整版', 'assets', 'sweetdream',
                   'textures', 'item', 'vanilla')


def hexs(*xs):
    return [tuple(int(x[i:i + 2], 16) for i in (0, 2, 4)) for x in xs]


def lum(c):
    # 感知亮度(Rec.601 的整数版)：人眼对绿最敏感，蓝最迟钝
    return 299 * c[0] + 587 * c[1] + 114 * c[2]


def remap(src, palette, split=None):
    """把 src 的不透明像素按亮度分档映射到 palette。

    split: 可选 (判据函数, palette_warm, palette_cool) —— 像素先按材质分流，
      暖色像素用 palette_warm、冷色像素用 palette_cool，各自独立分档。
    """
    im = Image.open(os.path.join(TEX, src)).convert('RGBA')
    px = im.load()
    w, h = im.size

    groups = {'all': []}
    if split:
        groups = {'warm': [], 'cool': []}
    for y in range(h):
        for x in range(w):
            p = px[x, y]
            if p[3] == 0:
                continue
            if split:
                groups['cool' if p[2] > p[0] else 'warm'].append((x, y, p))
            else:
                groups['all'].append((x, y, p))

    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    op = out.load()
    for gname, items in groups.items():
        if not items:
            continue
        if split:
            pal = (split[1] if gname == 'warm' else split[2])
        else:
            pal = palette
        items.sort(key=lambda t: lum(t[2]))
        n = len(items)
        for i, (x, y, p) in enumerate(items):
            # 等分档：最后一档收口（i == n-1 时 k 正好 = len-1）
            k = min(len(pal) - 1, i * len(pal) // n)
            r, g, b = pal[k]
            op[x, y] = (r, g, b, p[3])
    return out


def punch(im, cells):
    """把指定像素清空（用在"缺月"的缺口上）。"""
    px = im.load()
    for x, y in cells:
        px[x, y] = (0, 0, 0, 0)
    return im


def dot(im, x, y, color, alpha=255):
    """单像素点色（用在宝珠中心的"三形态"提示上）。"""
    im.load()[x, y] = (color[0], color[1], color[2], alpha)
    return im


def save(im, name):
    im.save(os.path.join(TEX, name), optimize=True)
    print('  ->', name)


# ============================================================
# 名单：输出文件名 → 生成方式
# ============================================================
def build_all():
    made = []

    # ① 潮痕（剑·稀有）—— 骨架 = 横刀（同为 iron_sword 直刃）
    #    潮青五档：全冷色，护手吃最亮档 ⇒ 淡青"水光护手"
    tidemark = hexs('050f14', '0b2029', '10333d', '164e5c', '237f92', '5cc3cf', 'c8f2f5')
    save(remap('hengdao.png', tidemark), 'tidemark.png')
    made.append('tidemark.png')

    # ② 灰度（剑·稀有）—— 骨架 = 无息（白钢剑）
    #    纯灰阶：名字就叫"灰度"，整把刀只剩明度，没有色相
    gray = hexs('080808', '1a1a1a', '303030', '525252', '8a8a8a', 'c8c8c8', 'f8f8f8')
    save(remap('hush.png', gray), 'grayscale.png')
    made.append('grayscale.png')

    # ③ 缺月（剑·传说）—— 骨架 = 万念（紫）
    #    暗紫刀身 + 月白刃光；「缺」只削掉刃尖 1 个像素（崩口），
    #    ★ 别在刃中间穿洞：16×16 里中间的洞会被看成"断刀"，不是"缺月"。
    crescent = hexs('0a0712', '160f22', '241a38', '3a2a58', '5f4a8a', '9a86c8', 'ece4fa')
    im = remap('myriad.png', crescent)
    punch(im, [(15, 2)])                 # 刃尖崩掉一角
    dot(im, 13, 2, (10, 7, 18))          # 缺口阴影（让崩口有深度）
    save(im, 'crescent.png')
    made.append('crescent.png')

    # ④ 焦骨（斧·传说）—— 骨架 = 崩裂（diamond_axe）
    #    刃（右上 y<9）骨白五档；柄（左下）焦黑四档 + 余烬橙。
    #    ★ 分区靠位置判：斧头重心恒在右上，斧柄恒在左下（16×16 斜向摆位固定）。
    im = Image.open(os.path.join(TEX, 'fissure_axe.png')).convert('RGBA')
    px = im.load()
    bone = hexs('4a4033', '8a7d66', 'c4b89c', 'e8dfc4', 'f8f2e0')
    char = hexs('0a0806', '17120c', '2a2016', '4a3520', '7a5228')
    head, haft = [], []
    for y in range(16):
        for x in range(16):
            p = px[x, y]
            if p[3] == 0:
                continue
            (head if (y <= 8 and x >= 5) else haft).append((x, y, p))
    out = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    op = out.load()
    for items, pal in ((head, bone), (haft, char)):
        items.sort(key=lambda t: lum(t[2]))
        n = len(items)
        for i, (x, y, p) in enumerate(items):
            k = min(len(pal) - 1, i * len(pal) // n)
            op[x, y] = pal[k] + (p[3],)
    # 斧刃尖端补两点"焦黑"：骨白整块发亮就不像"焦"了，刃尖得是被烧过的
    for x, y in ((9, 1), (10, 1), (11, 2)):
        if op[x, y][3]:
            op[x, y] = (42, 32, 22, 255)
    # 刃的外轮廓压成烟熏黑（骨白刃 + 焦边才读得出"烧过"；也顺手把骨白收成斧形，
    # 否则 16×16 里纯白的一团更像骨头而不是斧刃）
    #   ★ 先收集再改：边遍历边改会让"刚才才染黑的像素"又参与邻居判断，越染越宽。
    edge = []
    for y in range(0, 9):
        for x in range(5, 16):
            p = op[x, y]
            if not p[3]:
                continue
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < 16 and 0 <= ny < 16 and op[nx, ny][3] == 0:
                    edge.append((x, y))
                    break
    for x, y in edge:
        op[x, y] = (48, 36, 24, 255)
    # 刃根一点余烬橙（火从刃根烧到刃尖的意思）
    if op[11, 3][3]:
        op[11, 3] = (184, 80, 26, 255)
    save(out, 'scorch_bone.png')
    made.append('scorch_bone.png')

    # ⑤ 龙舌（弩）—— 骨架 = 弧光（木 + 青金属）
    #    木身 → 暗血红；金属 → 赤金（龙鳞/舌的意思）；弦跟着变暖
    warm = hexs('1a0806', '2e100c', '571c14', '8a2e1e', 'c04a2e', 'e8863f', 'f6d29a')
    cool = hexs('3a1e06', '6b3a12', 'a8721e', 'd4a44a', 'f0d08a')
    for st in ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework'):
        n = 'crossbow_dragon_tongue_%s.png' % st
        save(remap('crossbow_arc_%s.png' % st, warm, split=(None, warm, cool)), n)
        made.append(n)

    # ⑥ 云迹（弩）—— 骨架 = 清梦（本来就是浅青白，天生像云）
    #    木身 → 云白；金属 → 淡青（再往"更白更淡"推一档）
    warm = hexs('4a4e50', '767c7c', '9aa0a0', 'bcc0bc', 'd8dcd8', 'eceee8', 'f8faf6')
    cool = hexs('5a7a86', '7fa0ac', 'a0c4d0', 'c8e4ec', 'e8f6fa')
    for st in ('standby', 'pulling_0', 'pulling_1', 'pulling_2', 'arrow', 'firework'):
        n = 'crossbow_cloudtrail_%s.png' % st
        src = 'crossbow_lucid_dream_%s.png' % st
        if not os.path.exists(os.path.join(TEX, src)):
            print('  !! 缺骨架', src)
            continue
        save(remap(src, warm, split=(None, warm, cool)), n)
        made.append(n)

    # triad 已迁移至刻俄柏三形态3D母版，用户明确删除旧平面贴图。
    # 此旧批次生成器不得重新创建 staff_triad.png。

    return made


if __name__ == '__main__':
    made = build_all()
    print('共生成 %d 张：' % len(made))
    for m in made:
        print('   ', m)
    if '--preview' in sys.argv:
        cols = 6
        rows = (len(made) + cols - 1) // cols
        pre = Image.new('RGBA', (cols * 96, rows * 96), (26, 26, 32, 255))
        for i, m in enumerate(made):
            im = Image.open(os.path.join(TEX, m)).convert('RGBA').resize((96, 96), Image.NEAREST)
            pre.alpha_composite(im, ((i % cols) * 96, (i // cols) * 96))
        p = os.path.join(ROOT, '.workbuddy', '_batch12_preview.png')
        pre.save(p)
        print('预览：', p)
