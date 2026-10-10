# -*- coding: utf-8 -*-
"""
build_offhand_icons.py —— 「副手物品」原版风 16×16 图标生成器  v2

对象 = 数据包 `equipment/tool/` 下 7 件「副手 · 被动」道具：
    bitter_cold 苦寒 / blaze_plume 炽翎 / mana_pump 体外魔力泵 /
    nullify 无效 / seraph_wing 炽天使之翼 / thunder 雷鸣 / wrath 愠怒
（第 8 件 look 观测镜已有原版风图标 `sweetdream:look`，本批不动。）

------------------------------------------------------------------
v1 用「disc / rect / line 直接往 16×16 上盖」的纯手绘法，被用户否掉
（"太丑、精细度不够"）。根因：
  · 斜线是 stamp 堆的 ⇒ 边缘全是方块锯齿；圆 / 曲线取整 ⇒ 糊；
  · 上色只有"上亮下暗"4 档 ⇒ 平。
v2 换两条**高保真**路线，最终观感统一：

  [A] 原版掩码重映射 —— 用于**有机形状**（羽毛 / 翅膀 / 冰晶簇）
      本机 1.21.5 客户端 jar 里同类原版物品贴图的 alpha 掩码**逐像素照抄**，
      再读原版每像素**亮度** → 按区域归一化 → 映射到该件自己的色阶。
      形状与明暗 100% 是原版美术的，我们只换色相。
      （= build_vanilla_icons.py 的既定范式，用户对 11 件武器图标已认可）

  [B] 超采样矢量 —— 用于**几何形状**（禁制符 / 闪电 / 翼 / 怒面 / 魔力罐）
      在 16×SS 画布上用 ImageDraw 画真几何（polygon / ellipse / line），
      BOX 降采样得到覆盖率 → 阈值出 16×16 掩码 → 程序化打光。
      斜线与曲线拿到真正的像素阶梯，不再是 stamp 堆的方块。

打光规则：**纯亮度**调整（v > 3 向白提亮、v < 3 变暗），不向某个彩色高光混
——否则多材质件（魔力泵的金属壳 + 紫液）会被高光色整体染紫。

配色锚点 = 各件 `give` 里 `item_name.color`
（aqua / red / light_purple / dark_gray / gold / yellow / dark_red）。

输出：
  模型设计/原版风_副手物品_20261010/贴图/<id>.png        16×16 单件
  模型设计/原版风_副手物品_20261010/预览_副手7件.png      总览（含"改造前"对照）
  模型设计/原版风_副手物品_20261010/_细节_22x.png         22× 细节
  模型设计/原版风_副手物品_20261010/_备选方案.png         存疑件的备选对比
  模型设计/原版风_副手物品_20261010/配色对照表.md
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\数据包'
OUT = os.path.join(ROOT, '模型设计', '原版风_副手物品_20261010')
TEX = os.path.join(OUT, '贴图')
REF = os.path.join(ROOT, '.workbuddy', '_vanilla_ref')
FONT = r'C:\Windows\Fonts\msyh.ttc'
W = H = 16
SS = 8                      # 矢量超采样倍数（16 → 128）


def hx(s):
    s = s.lstrip('#')
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), 255)


def lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def mix(a, b, k):
    k = 0.0 if k < 0 else (1.0 if k > 1 else k)
    return tuple(int(round(a[i] + (b[i] - a[i]) * k)) for i in range(4))


def sample_ramp(ramp, t):
    t = 0.0 if t < 0 else (1.0 if t > 1 else t)
    p = t * (len(ramp) - 1)
    i = int(p)
    j = min(i + 1, len(ramp) - 1)
    f = p - i
    a, b = ramp[i], ramp[j]
    return tuple(int(round(a[k] + (b[k] - a[k]) * f)) for k in range(4))


def shade_col(col, v):
    """v: 1..6（3 = 本色）。**纯亮度**调整，不向彩色高光混 ⇒ 多材质件不串色。"""
    if v > 3:
        k = (v - 3) / 3.0
        c = mix(col, (255, 255, 255, 255), k * 0.30)
        return tuple(min(255, int(round(x * (1.0 + k * 0.22)))) for x in c[:3]) + (255,)
    if v < 3:
        k = (3 - v) / 2.0
        return tuple(max(0, int(round(x * (1.0 - k * 0.44)))) for x in col[:3]) + (255,)
    return col


# ==================================================== 掩码工具
def blank_rgba():
    return Image.new('RGBA', (W, H), (0, 0, 0, 0))


def mask_from_image(im, carve=None):
    px = im.load()
    m = [[px[x, y][3] > 0 for x in range(W)] for y in range(H)]
    if carve:
        for y in range(H):
            for x in range(W):
                if m[y][x] and carve(x, y):
                    m[y][x] = False
    return m


def mask_vanilla(name, carve=None):
    im = Image.open(os.path.join(REF, name + '.png')).convert('RGBA')
    return mask_from_image(im, carve), im


def bounds(m):
    xs = [x for y in range(H) for x in range(W) if m[y][x]]
    if not xs:
        return None
    ys = [y for y in range(H) for x in range(W) if m[y][x]]
    return min(xs), min(ys), max(xs), max(ys)


def flip_y(m):
    return [[m[H - 1 - y][x] for x in range(W)] for y in range(H)]


def center_mask(m):
    b = bounds(m)
    if not b:
        return m
    x0, y0, x1, y1 = b
    tx = (W - (x1 - x0 + 1)) // 2 - x0
    ty = (H - (y1 - y0 + 1)) // 2 - y0
    if tx == 0 and ty == 0:
        return m
    n = [[False] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if m[y][x]:
                nx, ny = x + tx, y + ty
                if 0 <= nx < W and 0 <= ny < H:
                    n[ny][nx] = True
    return n


# ==================================================== 超采样矢量画布
class Vec(object):
    """在 16*SS 上画几何，BOX 降采样 → 16×16 掩码。斜线 / 曲线拿到真阶梯。"""

    def __init__(self):
        self.im = Image.new('L', (W * SS, H * SS), 0)
        self.d = ImageDraw.Draw(self.im)

    def poly(self, pts, fill=255):
        self.d.polygon([(x * SS, y * SS) for x, y in pts], fill=fill)

    def rect(self, x0, y0, x1, y1, fill=255):
        self.d.rectangle([x0 * SS, y0 * SS, x1 * SS, y1 * SS], fill=fill)

    def ell(self, cx, cy, rx, ry=None, fill=255):
        ry = rx if ry is None else ry
        self.d.ellipse([(cx - rx) * SS, (cy - ry) * SS,
                        (cx + rx) * SS, (cy + ry) * SS], fill=fill)

    def ring(self, cx, cy, ro, ri, fill=255):
        self.ell(cx, cy, ro, ro, fill)
        self.ell(cx, cy, ri, ri, 0)

    def seg(self, x0, y0, x1, y1, w=1.0, fill=255):
        self.d.line([(x0 * SS, y0 * SS), (x1 * SS, y1 * SS)], fill=fill,
                    width=max(1, int(round(w * SS))))

    def band(self, x0, y0, x1, y1, hw, fill=255):
        """等宽斜带（半宽 hw，两端方头）"""
        dx, dy = x1 - x0, y1 - y0
        L = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / L * hw, dx / L * hw
        self.poly([(x0 + nx, y0 + ny), (x1 + nx, y1 + ny),
                   (x1 - nx, y1 - ny), (x0 - nx, y0 - ny)], fill)

    def wedge(self, cx, cy, ang, ln, w_root, w_tip, fill=255):
        """羽片：根宽 w_root、尖宽 w_tip，从 (cx,cy) 沿 ang 伸出 ln"""
        a = math.radians(ang)
        dx, dy = math.cos(a), math.sin(a)
        nx, ny = -dy, dx
        self.poly([(cx + nx * w_root / 2, cy + ny * w_root / 2),
                   (cx - nx * w_root / 2, cy - ny * w_root / 2),
                   (cx - nx * w_tip / 2 + dx * ln, cy - ny * w_tip / 2 + dy * ln),
                   (cx + nx * w_tip / 2 + dx * ln, cy + ny * w_tip / 2 + dy * ln)], fill)

    def petal(self, cx, cy, ang, ln, wmid, fill=255, n=14):
        """柳叶形羽片：从 (cx,cy) 沿 ang 伸出 ln，中部最宽 wmid（两端收成尖）"""
        a = math.radians(ang)
        dx, dy = math.cos(a), math.sin(a)
        nx, ny = -dy, dx
        up, dn = [], []
        for i in range(n + 1):
            t = i / float(n)
            w = wmid * (math.sin(math.pi * t) ** 0.65)
            up.append((cx + dx * ln * t + nx * w / 2, cy + dy * ln * t + ny * w / 2))
            dn.append((cx + dx * ln * t - nx * w / 2, cy + dy * ln * t - ny * w / 2))
        self.poly(up + list(reversed(dn)), fill)

    def mask(self, thr=0.5):
        sm = self.im.resize((W, H), Image.BOX)
        px = sm.load()
        t = int(round(255 * thr))
        return [[px[x, y] >= t for x in range(W)] for y in range(H)]


# ==================================================== 上色
def paint_vec(m, C, base=None, masks=None, overlay=None, outline=True):
    """几何件：按"左上受光 / 右下阴影"的对角梯度程序化打光（纯亮度）。
    base(x,y,t) 给主题基色；masks=[(bool2d,color)] 覆盖五官；overlay=[(pred,color)] 细节。"""
    b = bounds(m)
    if not b:
        return blank_rgba()
    x0, y0, x1, y1 = b
    span = max(1, (x1 - x0) + (y1 - y0))
    out = blank_rgba()
    o = out.load()
    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            g = ((x - x0) + (y - y0)) / float(span)
            v = 5 - int(round(g * 3.3))
            up = y > 0 and m[y - 1][x]
            dn = y < H - 1 and m[y + 1][x]
            lf = x > 0 and m[y][x - 1]
            rt = x < W - 1 and m[y][x + 1]
            if not up or not lf:
                v = min(6, v + 1)
            if not dn or not rt:
                v = max(1, v - 1)
            t = (y - y0) / float(y1 - y0) if y1 > y0 else 0.5
            col = shade_col(base(x, y, t) if base else C['b'], v)
            if masks:
                for mm, cc in masks:
                    if mm[y][x]:
                        col = cc
                        break
            if overlay:
                for pred, cc in overlay:
                    if pred(x, y, t):
                        col = cc
                        break
            o[x, y] = col
    if outline:
        for y in range(H):
            for x in range(W):
                if m[y][x]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    xx, yy = x + dx, y + dy
                    if 0 <= xx < W and 0 <= yy < H and m[yy][xx]:
                        o[x, y] = C['o']
                        break
    return out


def paint_vanilla(name, region_fn, ramps, overlay=None, carve=None, flip=False):
    """有机件：alpha 掩码照抄原版，亮度按区域归一化后映射到自己的色阶。"""
    m, im = mask_vanilla(name, carve)
    px = im.load()
    if flip:
        m = flip_y(m)
    rng = {}
    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            r = region_fn(x, y, px[x, y])
            L = lum(px[x, y])
            lo, hi = rng.get(r, (999.0, -1.0))
            rng[r] = (min(lo, L), max(hi, L))
    out = blank_rgba()
    o = out.load()
    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            reg = region_fn(x, y, px[x, y])
            lo, hi = rng.get(reg, (0.0, 255.0))
            t = 1.0 if hi <= lo else (lum(px[x, y]) - lo) / (hi - lo)
            col = sample_ramp(ramps.get(reg, ramps['_default']), t)
            if overlay:
                for pred, cc in overlay:
                    if pred(x, y, t):
                        col = cc
                        break
            o[x, y] = col
    return out, m


# ============================================================ 1 苦寒
RAMP_ICE = {
    '_default': [hx('#07203A'), hx('#0E4864'), hx('#187A98'), hx('#2FA8C4'),
                 hx('#6AD2E4'), hx('#B4F0F8'), hx('#EAFFFF')],
}


ICE_C = dict(o=hx('#07203A'), x=hx('#0E4864'), d=hx('#187A98'), a=hx('#2FA8C4'),
             b=hx('#55C2D8'), h=hx('#8EE2EE'), H=hx('#C8F6FC'), X=hx('#EAFEFF'))


def art_bitter_cold():
    """六向冰晶：中心六角核 + 6 根主臂（臂中 1 对分叉），16×SS 超采样画精确几何"""
    C = ICE_C
    v = Vec()
    cx = cy = 8.0
    R = 6.6
    for k in range(6):
        a = math.radians(-90 + 60 * k)
        v.seg(cx, cy, cx + R * math.cos(a), cy + R * math.sin(a), 1.7)
    for k in range(6):
        a = math.radians(-90 + 60 * k)
        bx, by = cx + 4.3 * math.cos(a), cy + 4.3 * math.sin(a)
        for s in (-1, 1):
            a2 = a + s * math.radians(56)
            v.seg(bx, by, bx + 2.1 * math.cos(a2), by + 2.1 * math.sin(a2), 1.1)
    hexp = [(cx + 1.8 * math.cos(math.radians(-90 + 60 * k)),
             cy + 1.8 * math.sin(math.radians(-90 + 60 * k))) for k in range(6)]
    v.poly(hexp)
    m = center_mask(v.mask(0.42))
    return paint_vec(m, C, overlay=[
        (lambda x, y, t: (x - 7.5) ** 2 + (y - 7.5) ** 2 <= 1.2, C['X']),
    ]), C, m


def art_bitter_cold_ice():
    """备选：原版海晶碎片掩码（三块簇拥的斜晶柱）映射成冰蓝"""
    im, m = paint_vanilla('prismarine_crystals', lambda x, y, c: '_all', RAMP_ICE)
    return im, RAMP_ICE, m


# ============================================================ 2 炽翎
def region_plume(x, y, c):
    if y <= 3:
        return 'tip'
    if y <= 7:
        return 'up'
    if y <= 11:
        return 'mid'
    return 'low'


RAMP_PLUME = {
    'tip': [hx('#E4650D'), hx('#F7A11E'), hx('#FFC93C'), hx('#FFE08A'),
            hx('#FFF3C0'), hx('#FFFEF0')],
    'up':  [hx('#A83008'), hx('#D4500A'), hx('#F07A14'), hx('#FFAE30'),
            hx('#FFD868')],
    'mid': [hx('#7A1706'), hx('#A83008'), hx('#D4500A'), hx('#F07A14'), hx('#FFAE30')],
    'low': [hx('#4E0B04'), hx('#7A1706'), hx('#A83008'), hx('#D4500A')],
    '_default': [hx('#7A1706'), hx('#D4500A'), hx('#FFD868')],
}


def art_blaze_plume():
    """燃烧的羽翎：轮廓照抄原版 feather，亮度按 y 分段映射成「羽根橙红 → 羽尖亮黄」"""
    im, m = paint_vanilla('feather', region_plume, RAMP_PLUME)
    return im, RAMP_PLUME, m


# ============================================================ 3 体外魔力泵
MANA_C = dict(o=hx('#0E0219'), x=hx('#1C0630'), d=hx('#33104E'), a=hx('#5A1E88'),
              b=hx('#8A34C0'), h=hx('#C070EC'), H=hx('#EABAFF'), X=hx('#FDF4FF'),
              mb=hx('#5A6270'), mh=hx('#9EA6B4'), mg=hx('#2E343C'))


def base_mana_pump(x, y, t):
    if 5 <= x <= 10 and 6 <= y <= 13:
        return MANA_C['b'] if y >= 9 else MANA_C['x']
    if 4 <= x <= 11 and 4 <= y <= 14:
        return MANA_C['mb'] if not (x in (4, 11) or y in (4, 14)) else MANA_C['mg']
    return MANA_C['mb']


def art_mana_pump():
    """魔力罐：金属外壳 + 正面竖窗里发光的魔力液 + 顶部两个接线柱"""
    C = MANA_C
    v = Vec()
    v.rect(3.0, 3.0, 13.0, 16.0)
    for x0 in (5.0, 9.0):
        v.rect(x0, 0.0, x0 + 2.0, 4.0)
    m = center_mask(v.mask())
    return paint_vec(m, C, base=base_mana_pump, masks=[
        ([[5 <= x <= 10 and 6 <= y <= 8 for x in range(W)] for y in range(H)], C['d']),
    ], overlay=[
        (lambda x, y, t: 6 <= x <= 9 and y == 9, C['h']),
        (lambda x, y, t: (x, y) in ((6, 11), (9, 12)), C['X']),
    ]), C, m


# ============================================================ 4 无效
def art_nullify():
    """禁制符：一道环 + 一道 45° 斜杠（左端出环、右端出环）—— 只留两个形状，不做内环/刻度"""
    C = dict(o=hx('#0A0C0F'), x=hx('#171A1F'), d=hx('#242931'), a=hx('#383F49'),
             b=hx('#505863'), h=hx('#7B8492'), H=hx('#AEB8C4'), X=hx('#E4EAF0'))
    v = Vec()
    v.ring(8.0, 8.0, 7.0, 5.0)
    v.band(3.2, 3.2, 12.8, 12.8, 1.15)
    m = center_mask(v.mask(0.52))
    return paint_vec(m, C), C, m


# ============================================================ 5 炽天使之翼
# 「现实天使翼」的结构（v3 定稿方向）：
#   · 单翼 = 一块"尖椭圆翼面"。翼根在背部中线，翼尖朝外上；
#   · 前缘(leading edge)  = 平滑外弧（翼的外/上边界）；
#   · 后缘(trailing edge) = 一排飞羽，末端带**羽尖锯齿**（翼的内/下边界）；
#   · 翼面内沿翼展分 NF 根飞羽，羽缝用暗线横切 ⇒ 层叠羽毛的读感。
# 16×16 里 1 根羽只有 ~1 px，所以全部在 128×128 超采样画，再 BOX 降采样。
SERAPH_PALS = {
    # 暖金：名色 gold，与另外 6 件同一材质观感
    'gold': dict(
        cn='暖金（名色）',
        ramp=[hx('#2E1C02'), hx('#5A3A06'), hx('#8A5C0A'), hx('#B98A1C'),
              hx('#E0AC34'), hx('#F7D666'), hx('#FFF2B8')],
        o=hx('#241402'), seam=hx('#6E4608')),
    # 圣白 / 象牙：整支白羽，暖白不刺眼
    'ivory': dict(
        cn='圣白 · 象牙',
        ramp=[hx('#3C362C'), hx('#736A58'), hx('#AFA58E'), hx('#DAD0BA'),
              hx('#F3EDDE'), hx('#FFFBEC'), hx('#FFFFFF')],
        o=hx('#2A251E'), seam=hx('#9A9382')),
    # 白金：羽毛本体白、根部与羽尖偏金（最贴"炽天使"）
    'platinum': dict(
        cn='白金 · 白羽金尖',
        ramp=[hx('#7A5A14'), hx('#B08C28'), hx('#DCC060'), hx('#F2E6B4'),
              hx('#FDF8E8'), hx('#FFFFFF'), hx('#FFFFFF')],
        o=hx('#4A3410'), seam=hx('#C29A3C')),
    # 圣青：冷白带天青，神性感
    'celestial': dict(
        cn='圣青 · 冷白',
        ramp=[hx('#22323C'), hx('#3E5E6E'), hx('#6E9AA8'), hx('#A8CEDC'),
              hx('#D8EEF6'), hx('#F4FCFF'), hx('#FFFFFF')],
        o=hx('#18242C'), seam=hx('#5E8898')),
}


def _seraph_geo(S, ang, L, ch0, ch1, nf, tooth=2.0):
    """返回单翼几何：d 翼展单位向量 / n 弦单位向量 / front,back 前后缘点列"""
    d = (math.cos(math.radians(ang)), math.sin(math.radians(ang)))
    n = (-d[1], d[0])
    chord = lambda t: ch0 * (1.0 - t) ** 0.8 + ch1
    mid = lambda t: (S[0] + d[0] * L * t, S[1] + d[1] * L * t)
    saw = lambda t: 0.5 * (1.0 - math.cos(2.0 * math.pi * ((t * nf) % 1.0)))
    N = 84
    front, back = [], []
    for i in range(N + 1):
        t = i / float(N)
        c = chord(t)
        bx, by = mid(t)
        front.append((bx + n[0] * c * 0.5, by + n[1] * c * 0.5))
        e = c * 0.5 + tooth * (1.0 - t) ** 0.25 * saw(t)
        back.append((bx - n[0] * e, by - n[1] * e))
    return d, n, chord, mid, front, back, N


def paint_seraph(m, sm, C, seg=None, nf=5):
    """翼面着色：对角光（沿翼展由暗到亮）+ 羽片明暗分段 + 羽缝暗线 + 外圈描边"""
    b = bounds(m)
    x0, y0, x1, y1 = b
    span = max(1, (x1 - x0) + (y1 - y0))
    ramp = C['ramp']
    out = blank_rgba()
    o = out.load()
    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            g = ((x - x0) + (y - y0)) / float(span)
            t = 1.0 - g * 0.92
            if seg is not None and seg[y][x] >= 0 and nf > 1:
                t += (seg[y][x] / float(nf - 1) - 0.5) * 0.11
            up = y > 0 and m[y - 1][x]
            dn = y < H - 1 and m[y + 1][x]
            lf = x > 0 and m[y][x - 1]
            rt = x < W - 1 and m[y][x + 1]
            if not up or not lf:
                t = min(1.0, t + 0.16)
            if not dn or not rt:
                t = max(0.0, t - 0.16)
            col = sample_ramp(ramp, t)
            if sm[y][x]:
                col = C['seam']
            o[x, y] = col
    for y in range(H):
        for x in range(W):
            if m[y][x]:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                xx, yy = x + dx, y + dy
                if 0 <= xx < W and 0 <= yy < H and m[yy][xx]:
                    o[x, y] = C['o']
                    break
    return out


def art_seraph_wing(pal='platinum'):
    """炽天使之翼（现实翼形）：翼根在背部中线 → 向外上展开；
    前缘平滑外弧，后缘 5 根飞羽带羽尖锯齿，翼面按羽段做明暗分层。左右镜像成双翼。
    2026-10-10 用户定稿配色 = platinum（白金 · 白羽金尖）。"""
    P = SERAPH_PALS[pal]
    C = dict(o=P['o'], seam=P['seam'], ramp=P['ramp'])
    S = (10.3, 12.5)                 # 右翼根（画布中线右侧）
    ang, L = -64.0, 11.0             # 翼尖方向 / 翼展长度
    ch0, ch1, nf = 1.8, 1.00, 4      # 翼根弦宽 / 翼尖弦宽 / 飞羽根数
    d, n, chord, mid, front, back, N = _seraph_geo(S, ang, L, ch0, ch1, nf)

    v = Vec()
    v.poly(front + list(reversed(back)))
    ml = v.mask(0.5)

    # 羽缝：外段 2 条分羽线（过多会显脏）
    sv = Vec()
    for k in (2, 3):
        t = k / float(nf)
        c = chord(t)
        bx, by = mid(t)
        e0 = c * 0.5 + 1.0 * (1.0 - t) ** 0.35
        p0 = (bx - n[0] * e0, by - n[1] * e0)
        e1 = max(0.0, c * 0.5 - 0.55)
        p1 = (bx + n[0] * e1, by + n[1] * e1)
        sv.band(p0[0], p0[1], p1[0], p1[1], 0.50)
    sm = sv.mask(0.42)
    sm = [[sm[y][x] and ml[y][x] for x in range(W)] for y in range(H)]

    # 左翼 = 右翼镜像（两翼在背部中线相接）
    m = [[ml[y][x] or ml[y][W - 1 - x] for x in range(W)] for y in range(H)]
    s2 = [[sm[y][x] or sm[y][W - 1 - x] for x in range(W)] for y in range(H)]

    # 羽段号（沿翼展 0..nf-1），供着色做逐羽明暗
    seg = [[-1] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            if not m[y][x]:
                continue
            tx = ((x - S[0]) * d[0] + (y - S[1]) * d[1]) / L
            if x > 7.5:
                s = int(max(0.0, min(0.999, tx)) * nf)
            else:
                s = int(max(0.0, min(0.999, ((W - 1 - x - S[0]) * d[0]
                                             + (y - S[1]) * d[1]) / L)) * nf)
            seg[y][x] = s

    return paint_seraph(m, s2, C, seg=seg, nf=nf), C, m


# ---- 历史版本（仅供配色对比图里作"旧版"对照，不进正式产出） ----
def region_seraph(x, y, c):
    if y <= 4:
        return 'tip'
    if y <= 7:
        return 'mid'
    if y <= 10:
        return 'low'
    return 'root'


RAMP_SERAPH = {
    'tip':  [hx('#8A5C0A'), hx('#B47B10'), hx('#D8A62A'), hx('#F0C850'), hx('#FFF0B0')],
    'mid':  [hx('#6E4608'), hx('#9C6C0E'), hx('#C68C18'), hx('#EAB43C'), hx('#F8D468')],
    'low':  [hx('#4E3005'), hx('#7A4C08'), hx('#A87418'), hx('#D2A028'), hx('#F0C850')],
    'root': [hx('#2E1C02'), hx('#523206'), hx('#7A4C08'), hx('#A87418'), hx('#D2A028')],
    '_default': [hx('#6E4608'), hx('#C68C18'), hx('#F8D468')],
}
SERAPH_C = dict(o=hx('#3A2404'), x=hx('#5A3A06'), d=hx('#7A4E08'), a=hx('#A87418'),
                b=hx('#D2A028'), h=hx('#F0C850'), H=hx('#FFE896'), X=hx('#FFF8D8'))


def art_seraph_wing_elytra():
    """旧版：原版 elytra 官方翅膀形状 + 4 段金羽层 + 底部收羽尖（对照用）"""
    im, m = paint_vanilla('elytra', region_seraph, RAMP_SERAPH,
                          carve=lambda x, y: y >= 12 and (x <= 4 or x >= 11),
                          overlay=[(lambda x, y, t: y in (7, 10), hx('#4E3005'))])
    return im, RAMP_SERAPH, m


# ============================================================ 6 雷鸣
def art_thunder():
    """折线闪电：标准 bolt 多边形（顶尖 → 左下 → 折 → 底尖 → 右上 → 折）"""
    C = dict(o=hx('#4A3400'), x=hx('#6E4E00'), d=hx('#96700A'), a=hx('#C19606'),
             b=hx('#E6BE1E'), h=hx('#FFE04A'), H=hx('#FFF6B0'), X=hx('#FFFDE0'))
    v = Vec()
    v.poly([(9.47, 0.50), (2.84, 9.33), (8.00, 9.33),
            (5.79, 15.22), (13.16, 6.39), (8.00, 6.39)])
    m = center_mask(v.mask(0.38))
    return paint_vec(m, C), C, m


# ============================================================ 7 愠怒
WRATH_C = dict(o=hx('#1E0204'), x=hx('#3A060B'), d=hx('#5A0D12'), a=hx('#7C1319'),
               b=hx('#A81F26'), h=hx('#D1484C'), H=hx('#F58E86'), X=hx('#FFD84A'))


def art_wrath():
    """怒面：圆形面具 + 向鼻梁压低的怒眉 + 一双斜吊怒目 + 上翘锯齿嘴"""
    C = WRATH_C
    v = Vec()
    v.ell(8.0, 8.3, 7.0, 7.1)
    m = center_mask(v.mask())
    # 怒眉（外高内低，向鼻梁压）
    vb = Vec()
    vb.band(1.8, 4.8, 6.4, 7.0, 0.95)
    vb.band(14.2, 4.8, 9.6, 7.0, 0.95)
    mb = vb.mask(0.5)
    # 怒目（斜吊的梯形，外高内低）
    ve = Vec()
    ve.poly([(3.0, 8.4), (6.3, 9.6), (6.3, 11.4), (3.0, 10.2)])
    ve.poly([(13.0, 8.4), (9.7, 9.6), (9.7, 11.4), (13.0, 10.2)])
    me = ve.mask(0.5)
    # 嘴（上翘的獠牙锯齿）
    vm = Vec()
    for i in range(5):
        x0 = 3.4 + i * 1.9
        vm.poly([(x0, 12.4), (x0 + 1.3, 12.4), (x0 + 0.65, 13.5)])
    mm = vm.mask(0.5)
    return paint_vec(m, C, masks=[(mb, C['o']), (mm, C['o']), (me, C['X'])]), C, m


ICONS = [
    ('bitter_cold', '苦寒',       '冰晶簇 · 解除冻结',          art_bitter_cold),
    ('blaze_plume', '炽翎',       '燃烧羽翎 · 延长点燃',        art_blaze_plume),
    ('mana_pump',   '体外魔力泵', '魔力罐 + 竖窗 · 上限 +120',  art_mana_pump),
    ('nullify',     '无效',       '禁制环符 · 技能伤害 +20%',   art_nullify),
    ('seraph_wing', '炽天使之翼', '白金双翼 · 攻击力技能 +50%', art_seraph_wing),
    ('thunder',     '雷鸣',       '折线闪电 · 二次落雷',        art_thunder),
    ('wrath',       '愠怒',       '怒面 · 低血强化',            art_wrath),
]
NAMECOL = {'bitter_cold': 'aqua', 'blaze_plume': 'red', 'mana_pump': 'light_purple',
           'nullify': 'dark_gray', 'seraph_wing': 'gold', 'thunder': 'yellow',
           'wrath': 'dark_red'}
SRC = {'bitter_cold': '超采样矢量', 'blaze_plume': '原版 feather 掩码',
       'mana_pump': '超采样矢量', 'nullify': '超采样矢量',
       'seraph_wing': '超采样矢量（现实翼形 · 双翼 · 4 飞羽）', 'thunder': '超采样矢量',
       'wrath': '超采样矢量'}

# 存疑件的备选（只出对比图，不进 ICONS）
ALTS = [
    ('bitter_cold', '备选：原版冰晶簇掩码', art_bitter_cold_ice),
]

# 炽天使之翼的配色候补（pal → 主题名），出专门对比图
WING_PALS = ['gold', 'ivory', 'platinum', 'celestial']


def txt(d, xy, s, size=20, fill=(232, 232, 238)):
    try:
        f = ImageFont.truetype(FONT, size)
    except Exception:
        f = ImageFont.load_default()
    d.text(xy, s, font=f, fill=fill)


def up(im, s):
    return im.resize((im.width * s, im.height * s), Image.NEAREST)


def main():
    if not os.path.isdir(TEX):
        os.makedirs(TEX)
    res = {}
    for pid, cn, motif, fn in ICONS:
        im, C, m = fn()
        im.save(os.path.join(TEX, pid + '.png'))
        res[pid] = (im, C, m)
        print('icon -> %-12s bbox=%s' % (pid, bounds(m)))

    # ---------------- 总览（改造前 + 新版） ----------------
    S = 8
    CELL = 16 * S
    SLOT = 16 * 4
    PAD = 18
    n = len(ICONS) + 1
    COLW = CELL + PAD
    LEFT = 150
    WD = LEFT + n * COLW + PAD
    HT = 40 + 26 + CELL + 34 + 26 + SLOT + 60
    sheet = Image.new('RGBA', (WD, HT), (26, 28, 34, 255))
    d = ImageDraw.Draw(sheet)
    txt(d, (PAD, 12), '副手物品 · 16×16 原版风图标 v2（原版掩码重映射 + 超采样矢量）',
        24, (246, 246, 250))
    y1 = 40 + 26
    y2 = y1 + CELL + 34
    txt(d, (PAD, y1 - 22), '① 贴图 8× 放大', 16, (156, 160, 172))
    txt(d, (PAD, y2 - 22), '② 背包格内实际观感（4×）', 16, (156, 160, 172))
    col_x = lambda i: LEFT + i * COLW
    slot_bg = Image.new('RGBA', (SLOT + 12, SLOT + 12), (139, 139, 139, 255))

    van = Image.open(os.path.join(REF, 'recovery_compass_16.png')).convert('RGBA')
    big = up(van, S)
    sheet.paste(big, (col_x(0), y1), big)
    c = slot_bg.copy()
    c.paste(up(van, 4), (6, 6), up(van, 4))
    sheet.paste(c, (col_x(0) - 6, y2))
    txt(d, (col_x(0), y2 + SLOT + 16), '改造前', 18, (200, 160, 160))
    txt(d, (col_x(0), y2 + SLOT + 38), '原版回响罗盘', 14, (150, 154, 166))

    for i, (pid, cn, motif, fn) in enumerate(ICONS):
        x = col_x(i + 1)
        im = res[pid][0]
        big = up(im, S)
        sheet.paste(big, (x, y1), big)
        s4 = up(im, 4)
        c = slot_bg.copy()
        c.paste(s4, (6, 6), s4)
        sheet.paste(c, (x - 6, y2))
        txt(d, (x, y2 + SLOT + 16), cn, 18, (250, 224, 140))
        txt(d, (x, y2 + SLOT + 38), pid, 13, (150, 154, 166))

    p = os.path.join(OUT, '预览_副手7件.png')
    sheet.convert('RGB').save(p)
    print('sheet ->', p, sheet.size)

    # ---------------- 22× 细节 ----------------
    S2, PAD2, COLS = 22, 10, 4
    CW = 16 * S2 + PAD2
    rows = (len(ICONS) + COLS - 1) // COLS
    det = Image.new('RGBA', (PAD2 + COLS * CW, PAD2 + rows * (16 * S2 + PAD2 + 20)),
                    (24, 26, 31, 255))
    dd = ImageDraw.Draw(det)
    for i, (pid, cn, motif, fn) in enumerate(ICONS):
        big = up(res[pid][0], S2)
        x = PAD2 + (i % COLS) * CW
        y = PAD2 + (i // COLS) * (16 * S2 + PAD2 + 20)
        det.paste(big, (x, y), big)
        txt(dd, (x, y + 16 * S2 + 2), cn, 15, (236, 238, 244))
    pd = os.path.join(OUT, '_细节_22x.png')
    det.convert('RGB').save(pd)
    print('detail ->', pd, det.size)

    # ---------------- 备选对比 ----------------
    alt_imgs = [(pid, lab, fn()[0]) for pid, lab, fn in ALTS]
    rowsh = len(alt_imgs)
    aw = PAD2 + 3 * CW
    ah = PAD2 + rowsh * (16 * S2 + PAD2 + 20)
    alt = Image.new('RGBA', (aw, ah), (24, 26, 31, 255))
    ad = ImageDraw.Draw(alt)
    for r, (pid, lab, im) in enumerate(alt_imgs):
        y = PAD2 + r * (16 * S2 + PAD2 + 20)
        cur = res[pid][0]
        for k, (im2, l2) in enumerate([(cur, '当前（正式）'), (im, lab)]):
            x = PAD2 + k * CW
            big = up(im2, S2)
            alt.paste(big, (x, y), big)
            txt(ad, (x, y + 16 * S2 + 2), '%s · %s' % (pid, l2), 15, (236, 238, 244))
    pa = os.path.join(OUT, '_备选方案.png')
    alt.convert('RGB').save(pa)
    print('alt ->', pa, alt.size)

    # ---------------- 炽天使之翼 · 配色对比 ----------------
    cells = [('旧版 elytra（对照）', art_seraph_wing_elytra()[0])]
    for pal in WING_PALS:
        cells.append((SERAPH_PALS[pal]['cn'], art_seraph_wing(pal)[0]))
    S3 = 22
    COLS3 = 5
    CW3 = 16 * S3 + 12
    SL3 = 16 * 5
    ht3 = 34 + 16 * S3 + 10 + SL3 + 34 + 12
    w3 = 12 + COLS3 * CW3
    wing = Image.new('RGBA', (w3, ht3), (24, 26, 31, 255))
    dw = ImageDraw.Draw(wing)
    txt(dw, (12, 8), '炽天使之翼 · 现实翼形 v3 · 配色候选（16×16 原尺寸 → 22× 放大）',
        20, (246, 246, 250))
    for i, (lab, im) in enumerate(cells):
        x = 12 + i * CW3
        big = up(im, S3)
        wing.paste(big, (x, 34), big)
        s5 = up(im, 5)
        c = Image.new('RGBA', (SL3 + 10, SL3 + 10), (139, 139, 139, 255))
        c.paste(s5, (5, 5), s5)
        wing.paste(c, (x, 34 + 16 * S3 + 10))
        txt(dw, (x, 34 + 16 * S3 + SL3 + 22), lab, 16,
            (250, 224, 140) if i else (198, 164, 164))
    pw = os.path.join(OUT, '_翼配色对比.png')
    wing.convert('RGB').save(pw)
    print('wing ->', pw, wing.size)

    # ---------------- 配色对照表 ----------------
    def main_color(C):
        if 'b' in C and isinstance(C['b'][0], int):
            return C['b']
        if 'ramp' in C and isinstance(C['ramp'], list):
            r = C['ramp']
            return r[len(r) * 2 // 3]
        ramp = list(C.values())[0]
        return ramp[len(ramp) // 2]

    lines = ['# 副手物品 · 原版风图标配色对照表', '',
             '> 生成器 `.workbuddy/build_offhand_icons.py`（幂等）。',
             '> **v2**：有机形状走「原版贴图掩码逐像素照抄 + 亮度映射」；',
             '> 几何形状走「超采样矢量（128× → 16×）+ 程序化打光」。',
             '> **v3**：炽天使之翼改「现实翼形」——翼根在背部中线、前缘平滑外弧、',
             '> 后缘 4 根飞羽带羽尖锯齿；配色 4 选 1，**定稿 = 白金 · 白羽金尖**',
             '> （候补对比见 `_翼配色对比.png`）。',
             '> 配色锚 = 各件 `give` 的 `item_name.color`。', '',
             '| id | 名称 | 名色 | 主题 | 形状来源 | 主色 |',
             '|---|---|---|---|---|---|']
    for pid, cn, motif, fn in ICONS:
        C = res[pid][1]
        lines.append('| `%s` | %s | %s | %s | %s | %s |' % (
            pid, cn, NAMECOL[pid], motif, SRC[pid],
            '#%02X%02X%02X' % main_color(C)[:3]))
    lines += ['', '## 调色板明细', '']
    for pid, cn, motif, fn in ICONS:
        C = res[pid][1]
        lines.append('### %s（%s）' % (cn, pid))
        lines.append('')
        if 'b' in C and isinstance(C['b'][0], int):
            lines.append('- ' + ' · '.join('`%s` #%02X%02X%02X' % (k, v[0], v[1], v[2])
                                           for k, v in C.items()))
        else:
            for reg, v in C.items():
                if isinstance(v, list):
                    lines.append('- `%s`：%s' % (
                        reg, ' → '.join('#%02X%02X%02X' % r[:3] for r in v)))
                else:
                    lines.append('- `%s` #%02X%02X%02X' % (reg, v[0], v[1], v[2]))
        lines.append('')
    with open(os.path.join(OUT, '配色对照表.md'), 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))
    print('md ->', os.path.join(OUT, '配色对照表.md'))


if __name__ == '__main__':
    main()
