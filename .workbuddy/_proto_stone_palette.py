# -*- coding: utf-8 -*-
"""超限石印象色定稿表 + Lab ΔE 两两验证（"有重复的就换一种"的落地）

规则：
  1. 印象色 = 装备主题色（不是 MC 16 名字色 —— gold 11 件、aqua 10 件，必撞）
  2. 同色系内用 明度/饱和度 分层；相邻色系间拉开色相
  3. 程序验证：两两 CIE ΔE76 < 18 即视为撞色，打印告警
用法: python .workbuddy/_proto_stone_palette.py
"""
import colorsys
import itertools

# id, 名, 印象色(RGB)
PALETTE = [
    # 红系（明度/色相分层：酒红 → 正红 → 橙红 → 玫红）
    ('myriad',           '万念',           (168,  40,  56)),
    ('red_lotus',        '红莲',           (232,  58,  58)),
    ('flame_brokenbody', '烈火残躯',       (255,  98,  40)),
    ('brain_leech',      '脑髓蛭',         (216,  72, 120)),
    # 橙黄系
    ('furnace_core',     '炉心',           (255, 140,  30)),
    ('liuguang',         '流光',           (255, 190,  60)),
    ('dusk_dawn',        '黄昏黎明之交界', (252, 224,  78)),
    # 白灰系（低饱和，靠冷暖与深浅分）
    ('dream_reader',     '释梦',           (252, 244, 208)),
    ('hengdao',          '横刀',           (212, 180,  96)),
    ('bone_erode',       '蚀骨',           (186, 188, 134)),
    ('polarized_light',  '偏振光',         (246, 249, 253)),
    # 青绿系
    ('anion',            '负离子',         ( 46, 216, 194)),
    ('sculk_echo',       '幽匿残响',       ( 46, 154, 132)),
    ('spine_symbiote',   '脊骨共生',       (126, 178, 170)),
    ('cold_crow',        '寒鸦',           ( 92, 198, 240)),
    # 冰蓝 → 深蓝 → 靛蓝 → 蓝紫（同一条"蓝梯"上分层）
    ('everfrost',        '永霜',           (164, 230, 248)),
    ('rogue_star',       '游星',           (100, 172, 242)),
    ('deepsea_echo',     '深海的回响',     ( 28,  88, 190)),
    ('stellar_elegy',    '群星坠落之挽歌', ( 62,  84, 216)),
    ('charge',           '超·负·荷',       (132, 132, 248)),
    # 紫粉系
    ('sickle_dreams',    '引梦镰',         (168,  92, 248)),
    ('dionysus_helmet',  '狄俄尼索斯之桂冠', (214, 116, 232)),
    ('begonia',          '海棠',           (244, 144, 192)),
    ('shadow_blade',     '影刃',           (106,  88, 146)),
]


def hex2lab(h):
    """sRGB → CIE Lab（D65）"""
    r, g, b = h
    # 未做 gamma 的粗略版足够用于对比
    for i, v in enumerate((r, g, b)):
        v /= 255.0
        v = v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
        h[i] = v * 100
    x = h[0] * 0.4124 + h[1] * 0.3576 + h[2] * 0.1805
    y = h[0] * 0.2126 + h[1] * 0.7152 + h[2] * 0.0722
    z = h[0] * 0.0193 + h[1] * 0.1192 + h[2] * 0.9505
    xn, yn, zn = 95.047, 100.0, 108.883
    for arr, n in ((x, xn), (y, yn), (z, zn)):
        pass
    def f(t):
        return t ** (1 / 3.0) if t > 0.008856 else 7.787 * t + 16 / 116.0
    fx, fy, fz = f(x / xn), f(y / yn), f(z / zn)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))


def lab(h):
    r, g, b = [v / 255.0 for v in h]
    def cv(v):
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = cv(r) * 100, cv(g) * 100, cv(b) * 100
    x = r * 0.4124 + g * 0.3576 + b * 0.1805
    y = r * 0.2126 + g * 0.7152 + b * 0.0722
    z = r * 0.0193 + g * 0.1192 + b * 0.9505
    def f(t):
        return t ** (1 / 3.0) if t > 0.008856 else 7.787 * t + 16 / 116.0
    fx, fy, fz = f(x / 95.047), f(y / 100.0), f(z / 108.883)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))


def dE(c1, c2):
    a, b = lab(c1), lab(c2)
    return sum((a[i] - b[i]) ** 2 for i in range(3)) ** 0.5


def hue(c):
    h = colorsys.rgb_to_hsv(c[0] / 255.0, c[1] / 255.0, c[2] / 255.0)[0] * 360
    return h


def main():
    bad = []
    mn = (1e9, None)
    for (i1, n1, c1), (i2, n2, c2) in itertools.combinations(PALETTE, 2):
        d = dE(c1, c2)
        if d < mn[0]:
            mn = (d, (n1, n2))
        if d < 18:
            bad.append((d, n1, n2, hue(c1), hue(c2)))
    if bad:
        print('⚠ 撞色对（ΔE < 18）：')
        for d, n1, n2, h1, h2 in sorted(bad):
            print('  ΔE=%5.1f  %s ↔ %s   (hue %.0f / %.0f)' % (d, n1, n2, h1, h2))
    else:
        print('✓ 全部 24 颗两两 ΔE ≥ 18，无撞色')
    print('最小 ΔE = %.1f（%s ↔ %s）' % (mn[0], mn[1][0], mn[1][1]))
    # 同色系内部分层是否成立（打印每组的最小 ΔE）
    groups = {}
    for i, n, c in PALETTE:
        groups.setdefault(hue(c) // 30, []).append((n, c))
    print('\n色相 30° 分桶（检查同桶内的最小 ΔE）：')
    for k in sorted(groups):
        g = groups[k]
        if len(g) < 2:
            continue
        worst = min((dE(a[1], b[1]), a[0], b[0])
                    for a, b in itertools.combinations(g, 2))
        print('  hue %d°~%d° (%d 颗): 最小 ΔE = %.1f (%s ↔ %s)'
              % (k * 30, k * 30 + 30, len(g), worst[0], worst[1], worst[2]))


if __name__ == '__main__':
    main()
