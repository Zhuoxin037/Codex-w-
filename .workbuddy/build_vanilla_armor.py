# -*- coding: utf-8 -*-
"""
build_vanilla_armor.py —— 「原版风 · 盔甲」贴图生成器（件数见 P 表）

口径（与剑/斧/弩/杖一致）：
  轮廓：alpha 掩码逐像素照抄**该件所用的原版底物**
        · 图标 = 原版盔甲物品贴图（iron/diamond/netherite + 部位）
        · 穿戴层 = 原版 entity/equipment/humanoid[_leggings] 贴图（64x32）
  明暗：读原版每像素亮度 → 线性映射到该件自己的色阶（ramp）。
  => 原版的描边 / 受光面 / 暗面结构原样保留，只换色相。

配色依据 = 逐件读 give.mcfunction 的技能原文（2026-10-10 逐件核对）。

产出：
  模型设计/原版风_盔甲_20261010/图标/<id>.png        16x16
  模型设计/原版风_盔甲_20261010/盔甲层/<id>.png      64x32
  模型设计/原版风_盔甲_20261010/预览_<槽位>.png      对照大图
"""
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_icons import hx, build, up, txt, REF, load   # noqa: E402
from PIL import Image, ImageDraw                                # noqa: E402

OUT = r'D:\数据包\模型设计\原版风_盔甲_20261010'
ICON_DIR = os.path.join(OUT, '图标')
LAYER_DIR = os.path.join(OUT, '盔甲层')
os.makedirs(ICON_DIR, exist_ok=True)
os.makedirs(LAYER_DIR, exist_ok=True)

SLOT_CN = {'helmet': '头盔', 'chestplate': '胸甲', 'leggings': '护腿', 'boots': '靴子'}
SLOT_FOLDER = {'helmet': 'humanoid', 'chestplate': 'humanoid', 'boots': 'humanoid',
               'leggings': 'humanoid_leggings'}


def region_body(x, y, c):
    """盔甲：整件走同一条色阶（原版明暗结构自带分层）"""
    return 'body'


def RIM(col, tmin=0.80):
    """轮廓边的高光"""
    return (lambda x, y, r, t, e: e and t >= tmin, col)


def HOT(col, tmin=0.95):
    """最亮处的点光"""
    return (lambda x, y, r, t, e: t >= tmin, col)


def DARK(col, tmax=0.16):
    """最暗处的描边"""
    return (lambda x, y, r, t, e: t <= tmax, col)


# ============================================================ 叠加元素（逐像素手绘）
# build() 只管"整件换色阶"；少数件需要在原版轮廓上**再画一层具体元素**
# （脊椎 / 肋骨 / 月桂叶 / 葡萄 / 虹彩）⇒ 用 tint 在 build 之后逐像素覆盖。
import colorsys                                                   # noqa: E402


def _hsv(h, s, v):
    r, g, b = colorsys.hsv_to_rgb(h % 1.0, s, v)
    return (int(round(r * 255)), int(round(g * 255)), int(round(b * 255)), 255)


def _lum(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def apply_tint(im, fn):
    """fn(x, y, col) -> col | None；None = 保留原色"""
    if fn is None:
        return im
    px = im.load()
    out = im.copy()
    o = out.load()
    for y in range(im.height):
        for x in range(im.width):
            c = px[x, y]
            if c[3] == 0:
                continue
            nc = fn(x, y, c)
            if nc is not None:
                o[x, y] = nc
    return out


# —— 骨（脊骨共生）——
BONE_HI = hx('#FFFBF0')
BONE = hx('#EDE4CE')
BONE_SH = hx('#B6A98E')


def spine_icon(x, y, c):
    """diamond_chestplate 图标：板 x3-12 / y5-13；脊椎 x7-8，肋三对"""
    if 7 <= x <= 8 and 5 <= y <= 13:
        return BONE_HI if x == 7 else BONE_SH
    if y in (6, 9, 12) and (4 <= x <= 6 or 9 <= x <= 11):
        return BONE
    return None


def spine_layer(x, y, c):
    """layer1 正面 (20,20)-(27,31)：脊椎 x23-24，肋三对"""
    if 23 <= x <= 24 and 21 <= y <= 30:
        return BONE_HI if x == 23 else BONE_SH
    if y in (24, 27, 30) and (21 <= x <= 22 or 25 <= x <= 26):
        return BONE
    return None


# —— 月桂冠 + 葡萄（狄俄尼索斯）——
GOLD_L = hx('#FFE79A')
GOLD_D = hx('#A87A22')
LEAF_L = hx('#B6D46A')
LEAF_D = hx('#5E8A2A')
GRAPE = hx('#7E3A96')


def laurel_icon(x, y, c):
    """netherite_helmet 图标（穹顶 x3-12 / y3-10）：
    前额一圈「V 形」月桂枝（左右各一枝向中心收拢）+ 上翘叶尖 + 酒神葡萄串"""
    band = {(3, 5), (4, 5), (5, 6), (6, 6), (7, 7), (8, 7), (9, 6), (10, 6), (11, 5), (12, 5)}
    if (x, y) in band:
        return LEAF_L if (x + y) % 2 else LEAF_D
    if y == 4 and x in (4, 6, 9, 11):
        return LEAF_L
    if y == 3 and x in (5, 7, 8, 10):
        return GOLD_L
    if (y, x) in ((8, 10), (8, 11), (9, 10), (9, 11), (10, 11)):
        return GRAPE
    return None


def laurel_layer(x, y, c):
    """layer1 头部正面 (8,8)-(15,15)：前额 V 形叶带 + 葡萄；头顶点缀"""
    band = {(8, 8), (9, 8), (14, 8), (15, 8), (10, 9), (13, 9), (11, 10), (12, 10)}
    if (x, y) in band:
        return LEAF_L if (x + y) % 2 else LEAF_D
    if y == 11 and x in (11, 12):
        return GRAPE
    if 0 <= y <= 7 and 8 <= x <= 15 and (x in (8, 15) or y in (0, 7)):
        return LEAF_D if (x + y) % 2 else LEAF_L
    return None


# —— 虹彩（异彩）——
def _irid(x, y, c, k):
    L = _lum(c) / 255.0
    return _hsv((2 * x + 3 * y) * k, 0.82, 0.28 + 0.72 * L)


def irid_icon(x, y, c):
    """图标：以穹顶为中心铺满一圈光谱（否则占用区只覆盖半圈）"""
    return _irid(x - 8, y - 7, c, 0.030)


def irid_layer(x, y, c):
    """穿戴层：斜向铺满光谱，各面呈不同色相"""
    return _irid(x, y, c, 0.013)


# —— 明烛（白昼梦 · 烛火）——
# 意象：蜡烛本身 + 一枚点着的烛焰。所以主体是**蜡白/奶黄**（区别于余烬的暖橙），
#   只在焰部用金/白 —— 暗部压到焦褐，让"蜡"与"焰"在同一张图里分得开。
FLAME_OUT = hx('#F0A93C')      # 外焰 金橙
FLAME_EDGE = hx('#C4701C')     # 焰缘 深金（和蜡身拉开）
FLAME_IN = hx('#FFFBD8')       # 焰心 近白
FLAME_CORE = hx('#FFFFFF')     # 焰芯 纯白（只有 1~2 像素）
WAX_DRIP = hx('#EBD49C')       # 熔蜡 亮奶白
WAX_SH = hx('#B08A52')         # 蜡痕阴影


def candle_icon(x, y, c):
    """netherite_helmet 图标（穹顶 x3-12 / y3-11）：前额正中一支烛焰 + 蜡座。

    ★ 只占 y4-8 五行、最宽 4 像素：16×16 里再宽就糊成一团。
        y4        x8          焰尖（单像素）
        y5      x7-8          焰身（x7 焰心）
        y6      x7-8          焰身（x7 焰心）
        y7    x6-9            焰根（两侧深金）
        y8    x6-9            蜡座（两侧阴影）
    y9 以下不画 —— 原版穹顶在 y11 中间本来就是镂空(两条腿)，往下挂蜡会被看成"嘴"。
    """
    if y == 4 and x == 8:
        return FLAME_OUT
    if y in (5, 6) and x in (7, 8):
        return FLAME_IN if x == 7 else FLAME_OUT
    if y == 7 and 6 <= x <= 9:
        return FLAME_EDGE if x in (6, 9) else FLAME_OUT
    if y == 8 and 6 <= x <= 9:
        return WAX_SH if x in (6, 9) else WAX_DRIP
    return None


def candle_layer(x, y, c):
    """layer1 头部正面 (8,8)-(15,15) —— 只有 8×8，画单列竖焰。

    实心行：y8-10 满、y11-12 只有 x8/x11-12/x15。
        y8    x11-12    焰尖
        y9    x11-12    焰身
        y10   x11-12    蜡座
    """
    if y == 8 and x in (11, 12):
        return FLAME_IN if x == 11 else FLAME_OUT
    if y == 9 and x in (11, 12):
        return FLAME_CORE if x == 11 else FLAME_IN
    if y == 10 and x in (11, 12):
        return WAX_DRIP if x == 11 else WAX_SH
    return None


# —— 白昼梦 · 其余七件（2026-10-27）——
# 口径同明烛：不做成"通体发光"，主体压在暗部，只在**技能意象那一小块**放亮色。
#   每件的亮色位置都按原版掩码算过（图标 / 穿戴层正面各一套坐标），见各函数注释。

# 借火（胸甲）：被人烧 ⇒ 借一粒火种。主体焦黑炭化，火种只在胸口正中 2×3 像素。
BORROW_CORE = hx('#FFFFFF')
BORROW_HOT = hx('#FFC24C')
BORROW_MID = hx('#E06A10')
BORROW_EMBER = hx('#7A2A06')


def borrow_icon(x, y, c):
    """netherite_chestplate 图标：胸板 x3-12 / y5-13，正中 (7-8, 7-9)"""
    if (x, y) in ((7, 7), (8, 7)):
        return BORROW_CORE
    if (x, y) in ((7, 8), (8, 8)):
        return BORROW_HOT
    if (x, y) in ((7, 9), (8, 9)):
        return BORROW_MID
    if y in (6, 10) and 6 <= x <= 9:
        return BORROW_EMBER
    return None


def borrow_layer(x, y, c):
    """layer1 躯干正面 (20,20)-(27,31)，正中 (23-24, 23-25)"""
    if (x, y) in ((23, 23), (24, 23)):
        return BORROW_CORE
    if (x, y) in ((23, 24), (24, 24)):
        return BORROW_HOT
    if (x, y) in ((23, 25), (24, 25)):
        return BORROW_MID
    if y in (22, 26) and 22 <= x <= 25:
        return BORROW_EMBER
    return None


# 心脉（胸甲）：一条从心口往下的血管 + 两对分支 + 一枚搏动点。
VEIN_HI = hx('#FFDCE4')
VEIN = hx('#E06478')
VEIN_D = hx('#8A2438')


def heart_icon(x, y, c):
    """胸板正中：主脉 x7 (y6-13)；分支 y7/y10 向左、y9/y12 向右"""
    if x == 7 and 6 <= y <= 13:
        return VEIN
    if y in (7, 10) and x in (5, 6):
        return VEIN_D
    if y in (9, 12) and x in (9, 10):
        return VEIN_D
    if (x, y) == (7, 8):
        return VEIN_HI          # 搏动点
    return None


def heart_layer(x, y, c):
    """layer1 躯干正面：主脉 x22 (y21-30)"""
    if x == 22 and 21 <= y <= 30:
        return VEIN
    if y in (22, 26) and x == 21:
        return VEIN_D
    if y in (24, 28) and x == 23:
        return VEIN_D
    if (x, y) == (22, 24):
        return VEIN_HI
    return None


# 剖面（护腿）：一条斜切进去的剖面线 + 切面内的层理。
PEEL_HI = hx('#7FF0E0')
PEEL = hx('#2E9E96')
PEEL_D = hx('#123C3E')


def peel_icon(x, y, c):
    """两条腿走同一条斜线 (x+y)%6 —— 16×16 里刚好一条斜向切口"""
    if (x + y) % 6 == 0:
        return PEEL_HI if (x + y) % 12 == 0 else PEEL
    if y == 6 and 3 <= x <= 12:
        return PEEL_D           # 切面下的层理
    return None


def peel_layer(x, y, c):
    """穿戴层整片走斜线 (x+y)%9，另在缠腿中腰压一道纵缝"""
    if (x + y) % 9 == 0:
        return PEEL_HI if (x + y) % 18 == 0 else PEEL
    if y == 25 and 16 <= x <= 27:
        return PEEL_D
    return None


# 折潮（头盔）：前额竖着一道折起来的水墙 + 一道横向折痕。
FOLD_HI = hx('#E8FFFF')
FOLD = hx('#4FC8E8')
FOLD_D = hx('#124E7A')


def fold_icon(x, y, c):
    """穹顶 x3-12 / y3-11：水墙占 x7-8 y4-10"""
    if y == 3 and x == 7:
        return FOLD_HI           # 浪尖
    if x == 7 and 4 <= y <= 10:
        return FOLD
    if x == 8 and 4 <= y <= 10:
        return FOLD_D
    if y == 7 and 4 <= x <= 11:
        return FOLD              # 折痕
    return None


def fold_layer(x, y, c):
    """layer1 头部正面 (8,8)-(15,15)：水墙 x11-12 y8-13"""
    if y == 8 and x == 11:
        return FOLD_HI
    if x == 11 and 9 <= y <= 13:
        return FOLD
    if x == 12 and 9 <= y <= 13:
        return FOLD_D
    if y == 11 and 9 <= x <= 14:
        return FOLD
    return None


# 返汐（靴子）：脚下一道退潮浪纹。
WAVE_HI = hx('#FFFFFF')
WAVE = hx('#5AD8D8')
WAVE_D = hx('#1A6470')


def wave_icon(x, y, c):
    """双靴：浪线压在 y10/y11（靴口以下）"""
    if y == 10:
        return WAVE_HI
    if y == 11:
        return WAVE
    if y == 12:
        return WAVE_D
    return None


def wave_layer(x, y, c):
    """穿戴层：每 4 行一道起伏浪线（隔道加亮点），不做满铺网格"""
    if y < 16:
        return None
    k = (y + x // 2) % 4
    if k == 0:
        return WAVE_HI if (y + x // 2) % 8 == 0 else WAVE
    if k == 1:
        return WAVE_D
    return None


# 浮光（头盔）：红/绿/黄三粒光 + 集齐后的那粒白。
GLIM_R = hx('#FF5A4E')
GLIM_G = hx('#6EE06A')
GLIM_Y = hx('#FFE066')
GLIM_W = hx('#FFFFFF')


def glimmer_icon(x, y, c):
    """穹顶四角各一粒：左上红 / 右上绿 / 左下黄 / 右下白"""
    return {(5, 5): GLIM_R, (10, 5): GLIM_G,
            (5, 9): GLIM_Y, (10, 9): GLIM_W}.get((x, y))


def glimmer_layer(x, y, c):
    """头部正面四角同一套顺序"""
    return {(9, 9): GLIM_R, (14, 9): GLIM_G,
            (9, 13): GLIM_Y, (14, 13): GLIM_W}.get((x, y))


# 迟暮（护腿）：暮色底 + 一道道记账刻度。
TICK_HI = hx('#FFE0A0')
TICK = hx('#C2803A')


def dusk_icon(x, y, c):
    if y in (4, 7, 10, 13) and 3 <= x <= 12:
        return TICK
    if y in (4, 13) and 3 <= x <= 12:
        return TICK_HI
    return None


def dusk_layer(x, y, c):
    if y % 4 == 0:
        return TICK_HI if y % 8 == 0 else TICK
    return None


# ============================================================ P 表（件数动态）
# (id, 中文名, 槽位, 原版底材, 色阶, 覆盖, 技能意象)
P = [
    # ── 头盔 6 ──────────────────────────────────────────────────────────
    dict(id='brain_leech', cn='脑髓蛭', slot='helmet', mat='diamond',
         motif='魔力换攻击 · 触须',
         ramp=[hx('#241028'), hx('#4A2050'), hx('#7A3A82'), hx('#A868AE'), hx('#D8A8D0'), hx('#F0DCE8')],
         acc=[RIM('#E8C0DC'), DARK('#180A1C')]),

    dict(id='dionysus_helmet', cn='狄俄尼索斯之桂冠', slot='helmet', mat='netherite',
         motif='桂冠 · 酒神',
         ramp=[hx('#2A1A08'), hx('#4E3410'), hx('#8A6A1E'), hx('#BFA03C'), hx('#E8D070'), hx('#FFF4C0')],
         acc=[RIM('#FFF0A8'), DARK('#1A1006'), HOT('#FFFCE0')],
         tint_icon=laurel_icon, tint_layer=laurel_layer),

    dict(id='iridescent', cn='异彩', slot='helmet', mat='netherite',
         motif='五重随机效果 · 幻彩',
         ramp=[hx('#0E0A16'), hx('#2A2438'), hx('#4A4460'), hx('#6E688A'), hx('#9E98B8'), hx('#D8D4E8'), hx('#FFF6FF')],
         acc=[],
         tint_icon=irid_icon, tint_layer=irid_layer),

    dict(id='mana_helm', cn='聚魔头盔', slot='helmet', mat='iron',
         motif='魔力上限 · 聚魔',
         ramp=[hx('#171E20'), hx('#2C3A3E'), hx('#4A6066'), hx('#6E8A90'), hx('#98B4B8'), hx('#C4D8DA')],
         acc=[RIM('#BFE8EE'), DARK('#0E1315'), HOT('#3FD8E8')]),

    dict(id='spirit_sight', cn='灵视', slot='helmet', mat='iron',
         motif='看见标签 · 灵光',
         ramp=[hx('#141A14'), hx('#2A3626'), hx('#485A3E'), hx('#6E8654'), hx('#9AB46C'), hx('#D0E88E')],
         acc=[RIM('#C8F07A'), DARK('#0C110C'), HOT('#E8FFA0')]),

    dict(id='styx_walk', cn='漫步冥河之上', slot='helmet', mat='netherite',
         motif='暗海 · 噬心',
         ramp=[hx('#05181A'), hx('#0C2E2C'), hx('#144E46'), hx('#1E7264'), hx('#309A84'), hx('#58C4AC')],
         acc=[RIM('#6FE0C4'), DARK('#03100F'), HOT('#9CFFE8')]),

    # 白昼梦 · 明烛（2026-10-27 试样）：主体是"暗烛台"，亮面只留给蜡与焰 ——
    #   与余烬（通体暖橙）区分开；暗部压焦黑，中间四阶全是褐/铜，蜡白只在最亮 1~2 像素。
    dict(id='bright_candle', cn='明烛', slot='helmet', mat='netherite',
         motif='烛火 · 流火熬成夜火',
         ramp=[hx('#100A05'), hx('#221706'), hx('#3A2A10'), hx('#5E461C'), hx('#9A7228'), hx('#D8B468')],
         acc=[RIM('#C4A058'), DARK('#0C0703'), HOT('#FFE07A')],
         tint_icon=candle_icon, tint_layer=candle_layer),

    # ── 胸甲 7 ──────────────────────────────────────────────────────────
    dict(id='blaze_armor', cn='焱', slot='chestplate', mat='diamond',
         motif='抗火 · 视为金甲',
         ramp=[hx('#3A0C02'), hx('#7A1E06'), hx('#C4400C'), hx('#F07A1E'), hx('#FFC24C'), hx('#FFF0B8')],
         acc=[RIM('#FFE07A'), DARK('#240700'), HOT('#FFFCE0')]),

    dict(id='eternity', cn='永恒', slot='chestplate', mat='netherite',
         motif='标签反复附着 · 恒常',
         ramp=[hx('#2A2414'), hx('#5E5024'), hx('#A08C3C'), hx('#D4BC6E'), hx('#EFE0A8'), hx('#FFFAE0')],
         acc=[RIM('#FFF4C0'), DARK('#1A160C'), HOT('#FFFFFF')]),

    dict(id='furnace_core', cn='炉心', slot='chestplate', mat='netherite',
         motif='燃灰层数 · 炉膛',
         ramp=[hx('#1C1612'), hx('#3A2E24'), hx('#5E4A38'), hx('#8A7050'), hx('#B09870'), hx('#D8C09A')],
         acc=[RIM('#E8CFA8'), DARK('#120D0A'), HOT('#FF7614')]),

    dict(id='intravenous_pump', cn='静脉泵', slot='chestplate', mat='diamond',
         motif='满血回魔 · 静脉',
         ramp=[hx('#1A1030'), hx('#362058'), hx('#563C90'), hx('#7E62C0'), hx('#A894DE'), hx('#CCC0F0')],
         acc=[RIM('#C8B8F4'), DARK('#100A20'), HOT('#4FD6C8')]),

    dict(id='mana_plate', cn='聚魔胸甲', slot='chestplate', mat='iron',
         motif='魔力上限 · 聚魔',
         ramp=[hx('#171E20'), hx('#2C3A3E'), hx('#4A6066'), hx('#6E8A90'), hx('#98B4B8'), hx('#C4D8DA')],
         acc=[RIM('#BFE8EE'), DARK('#0E1315'), HOT('#3FD8E8')]),

    dict(id='resonance', cn='共振', slot='chestplate', mat='iron',
         motif='每个术阵 +10% · 共振',
         ramp=[hx('#161A20'), hx('#2E343E'), hx('#4C5666'), hx('#707C8E'), hx('#9AA6B8'), hx('#D2DAE6')],
         acc=[RIM('#F0F4FA'), DARK('#0D1014'), HOT('#FFFFFF')]),

    dict(id='spine_symbiote', cn='脊骨共生', slot='chestplate', mat='diamond',
         motif='魔力换护甲与生命 · 脊骨',
         ramp=[hx('#1C1226'), hx('#382748'), hx('#5A4070'), hx('#7E6694'), hx('#A692B4'), hx('#CCBED8')],
         acc=[RIM('#E0D0D8'), DARK('#160F1C'), HOT('#B47AE0')],
         tint_icon=spine_icon, tint_layer=spine_layer),

    # ── 护腿 7 ──────────────────────────────────────────────────────────
    dict(id='ember', cn='余烬', slot='leggings', mat='netherite',
         motif='流火 / 夜火 · 余烬',
         ramp=[hx('#1A120E'), hx('#3E2616'), hx('#7A461C'), hx('#C06E22'), hx('#E8A63C'), hx('#FFD98A')],
         acc=[RIM('#FFCF70'), DARK('#0F0A07'), HOT('#8A4AC0')]),

    dict(id='external_power', cn='体外供能装置', slot='leggings', mat='diamond',
         motif='满魔回再生 · 外置供能',
         # 2026-10-10 用户定稿：改用「备选」= 能量青绿整支（暗青绿钢壳 + 青辉），
         # 高光那点紫色 = 能量指示灯（原方案是冷靛蓝钢，已弃）。
         ramp=[hx('#0C1418'), hx('#1A2A30'), hx('#28464E'), hx('#3A7280'), hx('#5FA8B4'), hx('#9AD6DE'), hx('#D8F6FA')],
         acc=[RIM('#BFF2F0'), DARK('#060C0E'), HOT('#B48CE8')]),

    dict(id='fade', cn='息影', slot='leggings', mat='iron',
         motif='停手 10 秒 · 减冷却',
         ramp=[hx('#14161A'), hx('#2C3037'), hx('#474D57'), hx('#656D79'), hx('#8C95A1'), hx('#B8C0CC')],
         acc=[RIM('#AEB8C4'), DARK('#0B0D10'), HOT('#E4ECF4')]),

    dict(id='hex_belt', cn='魔化腰带', slot='leggings', mat='iron',
         motif='魔力上限 · 二件套',
         ramp=[hx('#1A0F26'), hx('#36205A'), hx('#56368A'), hx('#7E58B4'), hx('#A88AD4'), hx('#CFB8EC')],
         acc=[RIM('#C6ACEC'), DARK('#100818'), HOT('#6FBF3A')]),

    dict(id='mirage', cn='幻昼', slot='leggings', mat='netherite',
         motif='白昼梦 · 时停',
         ramp=[hx('#4A4236'), hx('#847860'), hx('#B8AC94'), hx('#DCD4C0'), hx('#F2EDE0'), hx('#FFFDF6')],
         acc=[RIM('#FFF6DC'), DARK('#2A241A'), HOT('#CFE2FF')]),

    dict(id='stellar_elegy', cn='群星坠落之挽歌', slot='leggings', mat='netherite',
         motif='受击反击 · 群星',
         ramp=[hx('#0B0D20'), hx('#182048'), hx('#28346C'), hx('#404E92'), hx('#6878B8'), hx('#A8B8EC')],
         acc=[RIM('#C0CCF8'), DARK('#060712'), HOT('#FFF8D0')]),

    dict(id='withered_garden', cn='枯枝园', slot='leggings', mat='netherite',
         motif='朽木 · 渊海',
         ramp=[hx('#13170D'), hx('#262E16'), hx('#3E4A20'), hx('#5C6B2E'), hx('#80903C'), hx('#A8B45C')],
         acc=[RIM('#BCC868'), DARK('#0B0E07'), HOT('#6B4A2A')]),

    # ── 靴子 5 ──────────────────────────────────────────────────────────
    dict(id='dusk_dawn', cn='黄昏黎明之交界', slot='boots', mat='netherite',
         motif='击杀转上限 · 黄昏与黎明',
         ramp=[hx('#2A1830'), hx('#5E2E42'), hx('#A8523A'), hx('#E08A3C'), hx('#F8C878'), hx('#FFF0C8')],
         acc=[RIM('#FFE0A0'), DARK('#190E1D'), HOT('#66D8E0')]),

    dict(id='flesh_mill', cn='血肉磨坊', slot='boots', mat='iron',
         motif='受伤后每秒回魔 · 血肉',
         ramp=[hx('#2A0A0C'), hx('#5E1618'), hx('#9A2E28'), hx('#C65448'), hx('#E08A78'), hx('#F0C0B0')],
         acc=[RIM('#F0B0A0'), DARK('#1A0608'), HOT('#E8DED0')]),

    dict(id='immolate', cn='焚舟', slot='boots', mat='netherite',
         motif='烈空 · 焚舟',
         ramp=[hx('#120A08'), hx('#3C0E0A'), hx('#841E10'), hx('#D24A12'), hx('#F89426'), hx('#FFD070'), hx('#FFF4D8')],
         acc=[RIM('#FFE39A'), DARK('#0A0505'), HOT('#FFFFFF')]),

    dict(id='lethe_shore', cn='沉溺忘川彼岸', slot='boots', mat='netherite',
         motif='残念 · 忘川彼岸',
         ramp=[hx('#170C1C'), hx('#33183E'), hx('#52265E'), hx('#7A4080'), hx('#A870A0'), hx('#D0A8C4')],
         acc=[RIM('#D8B4D0'), DARK('#0E0711'), HOT('#D92840')]),

    dict(id='lightless_sea', cn='无光海', slot='boots', mat='netherite',
         motif='暗潮 · 渊海',
         ramp=[hx('#05080F'), hx('#0C1524'), hx('#16293F'), hx('#24425E'), hx('#38648A'), hx('#5A90BC')],
         acc=[RIM('#4E88B4'), DARK('#02040A'), HOT('#2EC4D6')]),

    # ── 白昼梦 · 其余七件（2026-10-27，与明烛同一套画法）────────────────
    dict(id='borrow_fire', cn='借火', slot='chestplate', mat='netherite',
         motif='借燃烧 · 削甲转移',
         ramp=[hx('#080505'), hx('#16100B'), hx('#2A1C12'), hx('#4A3018'), hx('#7A4A18'), hx('#C88A30')],
         acc=[RIM('#E8A050'), DARK('#080504'), HOT('#FFF0C0')],
         tint_icon=borrow_icon, tint_layer=borrow_layer),

    dict(id='heart_vein', cn='心脉', slot='chestplate', mat='netherite',
         motif='噬心 · 泵动',
         ramp=[hx('#16060A'), hx('#320E16'), hx('#5E1A28'), hx('#8E2E42'), hx('#BE5A70'), hx('#E8A6B4')],
         acc=[RIM('#F0BCC8'), DARK('#0C0306'), HOT('#FFE8EE')],
         tint_icon=heart_icon, tint_layer=heart_layer),

    dict(id='profile', cn='剖面', slot='leggings', mat='netherite',
         motif='耗魔换噬心 · 切面',
         ramp=[hx('#101418'), hx('#232B33'), hx('#3B4852'), hx('#5A6C78'), hx('#8AA0AA'), hx('#C8DCE2')],
         acc=[RIM('#E0F2F6'), DARK('#080B0E'), HOT('#7FF0E0')],
         tint_icon=peel_icon, tint_layer=peel_layer),

    dict(id='late_dusk', cn='迟暮', slot='leggings', mat='netherite',
         motif='回光记账 · 暮色结算',
         ramp=[hx('#140A18'), hx('#2E1628'), hx('#55243A'), hx('#8A3A40'), hx('#C26A3E'), hx('#E8A758')],
         acc=[RIM('#FFD08A'), DARK('#0A050C'), HOT('#FFF0C8')],
         tint_icon=dusk_icon, tint_layer=dusk_layer),

    dict(id='tide_fold', cn='折潮', slot='helmet', mat='netherite',
         motif='水墙 · 渊海',
         ramp=[hx('#050B1C'), hx('#0C1C3A'), hx('#143562'), hx('#1E5C96'), hx('#2E92C4'), hx('#6FD2E8')],
         acc=[RIM('#A8F0FF'), DARK('#03060F'), HOT('#E8FFFF')],
         tint_icon=fold_icon, tint_layer=fold_layer),

    dict(id='glimmer', cn='浮光', slot='helmet', mat='netherite',
         motif='三色光效 · 集齐转白',
         ramp=[hx('#0A0612'), hx('#171024'), hx('#241838'), hx('#352450'), hx('#4A3268'), hx('#6A4A88')],
         acc=[RIM('#F0E0F4'), DARK('#08050C'), HOT('#FFFFFF')],
         tint_icon=glimmer_icon, tint_layer=glimmer_layer),

    dict(id='ebb_tide', cn='返汐', slot='boots', mat='netherite',
         motif='海浪 · 速度差换伤害',
         ramp=[hx('#04121A'), hx('#0A2836'), hx('#12485A'), hx('#1E7488'), hx('#3AA8B4'), hx('#8FE0E0')],
         acc=[RIM('#C8FFFF'), DARK('#020A0E'), HOT('#FFFFFF')],
         tint_icon=wave_icon, tint_layer=wave_layer),

    # ── 批 20 · 终端盔甲 8 件（2026-10-27）──────────────────────────────
    # 配色依据 = give.mcfunction 的技能原文。分两个家族，避免 8 件挤在同一色相：
    #   术阵系（枢 / 承 / 屏息）：玄金甲壳 + **翡翠点光**（HOT 用 #5CE8B0 系）
    #     —— "金框里嵌一枚青芯"，包内 33 件没有一件这么用（mana_helm 的 HOT 是
    #        #3FD8E8 青蓝，这里偏绿，且 ramp 是暗玄金而非青灰，不会混）。
    #   生存系（空营 / 独行 / 溢流 / 蓄意 / 踏空）：各按语义取冷调外壳，HOT 留给"技能
    #     触发那一瞬"的颜色（余火 / 银 / 血光 / 金 / 雪白）。
    # ★ 与「胜利誓约之剑」同批：剑是"香槟金白刃 + 亮金护手 + 宝石红柄"，
    #   这里承 / 蓄意的金与红是对得上的；其余件的冷调是为了让 8 件彼此分得开。

    # 枢（头盔）：`formation_limit +1` —— 术阵位上限。
    #   玄金甲壳，点光翡翠 = 甲面上透出的阵纹。
    dict(id='pivot', cn='枢', slot='helmet', mat='netherite',
         motif='魔力上限 · 术阵位上限',
         ramp=[hx('#2A1E0A'), hx('#564016'), hx('#8A6A1E'), hx('#BE9428'), hx('#E6C25C'), hx('#FFF2B8')],
         acc=[RIM('#FCF0C0'), DARK('#140E04'), HOT('#5CE8B0')]),

    # 承（护腿）：术阵每占 1 位 → 护甲/韧性；套装与枢同源。
    #   ★ 同族但整体压暗一档：护腿在下半身，天然该比头盔沉。
    dict(id='bearing', cn='承', slot='leggings', mat='netherite',
         motif='术阵层数换护甲 · 与枢同族',
         ramp=[hx('#241A08'), hx('#4C3812'), hx('#7C5E1A'), hx('#B08624'), hx('#D8B254'), hx('#F8E6A8')],
         acc=[RIM('#F4E4B0'), DARK('#120C02'), HOT('#5CE8B0')]),

    # 空营（胸甲）：8 格内每 1 敌对 → 护甲；无敌对 → 每秒回魔。
    #   冷铁外壳（"空营"= 熄了火的营地），胸口一点余火橙。
    dict(id='empty_camp', cn='空营', slot='chestplate', mat='netherite',
         motif='敌对数目换护甲 · 空营',
         ramp=[hx('#1C1C1E'), hx('#303032'), hx('#48484A'), hx('#66666C'), hx('#8E8E94'), hx('#C6C6CA')],
         acc=[RIM('#E4F2F2'), DARK('#0C1418'), HOT('#FFA22E')]),

    # 独行（靴）：移速 +8%；8 格内敌对 ≤2 时技能伤害 +8%。
    #   暗紫灰 + 银白点光：低调、不反光 —— "一个人走"的调子。
    dict(id='lone_walk', cn='独行', slot='boots', mat='netherite',
         motif='移速 · 人少则增伤',
         ramp=[hx('#1E1A28'), hx('#322C40'), hx('#4C4560'), hx('#6E6688'), hx('#9C94B4'), hx('#D2CAE0')],
         acc=[RIM('#E4DCF0'), DARK('#100C16'), HOT('#F0E8FF')]),

    # 溢流（护腿）：过量治疗 50% → 临时生命。
    #   血色主体；这是"多出来的那部分"，所以最亮档偏粉白（不是纯白）。
    dict(id='overflow', cn='溢流', slot='leggings', mat='netherite',
         motif='过量治疗转临时生命',
         ramp=[hx('#241010'), hx('#40201E'), hx('#643430'), hx('#8E4E48'), hx('#BA7870'), hx('#E4B0A8')],
         acc=[RIM('#FFDCD6'), DARK('#140606'), HOT('#FFF0F2')]),

    # 蓄意（胸甲）：每消耗 50 魔力 → +2 临时生命；清空后抗性Ⅱ/迅捷Ⅲ。
    #   暗绛甲 + 金点光（"蓄"的是金光）；与承同为金红调，但更暗更红。
    dict(id='intent', cn='蓄意', slot='chestplate', mat='netherite',
         motif='耗魔积临时生命',
         ramp=[hx('#221010'), hx('#3E1C18'), hx('#623226'), hx('#8A5038'), hx('#B07C5C'), hx('#D8B494')],
         acc=[RIM('#F0D0A0'), DARK('#120606'), HOT('#FFC84A')]),

    # 踏空（靴）：落地 → 4 格内全部生物受伤 + 击飞。
    #   高空冷调（H≈200），点光雪白 = 落地那一瞬间的空气压缩。
    dict(id='air_step', cn='踏空', slot='boots', mat='netherite',
         motif='落地冲击 · 击飞',
         ramp=[hx('#18202A'), hx('#283844'), hx('#405864'), hx('#5E7C8A'), hx('#88A8B4'), hx('#C0D8E2')],
         acc=[RIM('#E8F8FF'), DARK('#0A1016'), HOT('#FFFFFF')]),

    # 屏息（头盔）：每个空闲术阵位 → 每秒回 2 魔力。
    #   苔玉绿（H≈140）—— 包内绿只有 75/89 两支，140 是空着的色相，专给这件。
    dict(id='breath_hold', cn='屏息', slot='helmet', mat='netherite',
         motif='空闲术阵位回魔',
         ramp=[hx('#101A12'), hx('#1C2E1E'), hx('#2C4830'), hx('#426846'), hx('#668E6A'), hx('#9CBC9E')],
         acc=[RIM('#D0E8D4'), DARK('#080F09'), HOT('#E8F8E8')]),
]


def spec_of(p):
    """→ (图标模板名, 层模板名)"""
    icon = '%s_%s' % (p['mat'], p['slot'])
    layer = ('layer2_%s' if p['slot'] == 'leggings' else 'layer1_%s') % p['mat']
    return icon, layer


def make(p, save=True):
    icon_tpl, layer_tpl = spec_of(p)
    ramps = {'body': p['ramp'], '_default': p['ramp']}
    ic = apply_tint(build(icon_tpl, region_body, ramps, p['acc']), p.get('tint_icon'))
    ly = apply_tint(build(layer_tpl, region_body, ramps, p['acc']), p.get('tint_layer'))
    if save:
        ic.save(os.path.join(ICON_DIR, p['id'] + '.png'))
        ly.save(os.path.join(LAYER_DIR, p['id'] + '.png'))
    return ic, ly


def main():
    icons, layers = {}, {}
    for p in P:
        ic, ly = make(p)
        icons[p['id']], layers[p['id']] = ic, ly
        print('%-20s %-11s icon %s  layer %s' % (p['id'], SLOT_CN[p['slot']], ic.size, ly.size))

    # ---------------- 分组对照大图 ----------------
    FONT = r'C:\Windows\Fonts\msyh.ttc'
    from PIL import ImageFont
    for slot in ('helmet', 'chestplate', 'leggings', 'boots'):
        group = [p for p in P if p['slot'] == slot]
        SI, SL = 9, 6                      # 图标 / 层 放大倍数
        icw = 16 * SI                      # 图标列宽 144
        lw = 64 * SL                       # 层列宽 384
        PAD, GAP = 16, 26
        W = PAD * 2 + icw * 2 + lw * 2 + GAP * 3
        ch = 32 * SL
        ROWH = max(ch, icw) + 74
        H = PAD + 62 + len(group) * ROWH + PAD
        sheet = Image.new('RGBA', (W, H), (22, 24, 29, 255))
        d = ImageDraw.Draw(sheet)
        txt(d, (PAD, 12), '原版风 · 盔甲 · %s（%d 件）—— 形状逐像素照抄原版底物，只换该件自己的配色'
            % (SLOT_CN[slot], len(group)), 21, (246, 246, 250))
        txt(d, (PAD, 40), '① 原版图标   ② 我们的图标   ③ 原版穿戴层（64×32）   ④ 我们的穿戴层', 15, (152, 158, 172))
        slot_bg = Image.new('RGBA', (16 * SI + 14, 16 * SI + 14), (139, 139, 139, 255))
        y = PAD + 62
        for p in group:
            x = PAD
            icon_tpl, layer_tpl = spec_of(p)
            # ① 原版图标
            org = up(Image.open(os.path.join(REF, icon_tpl + '.png')).convert('RGBA'), SI)
            c = slot_bg.copy(); c.paste(org, (7, 7), org); sheet.paste(c, (x, y))
            x += icw + GAP
            # ② 我们的图标
            ours = up(icons[p['id']], SI)
            c = slot_bg.copy(); c.paste(ours, (7, 7), ours); sheet.paste(c, (x, y))
            x += icw + GAP
            # ③ 原版层
            ol = Image.open(os.path.join(REF, layer_tpl + '.png')).convert('RGBA')
            b1 = Image.new('RGBA', (ol.width * SL, ol.height * SL), (139, 139, 139, 255))
            b1.paste(up(ol, SL), (0, 0), up(ol, SL)); sheet.paste(b1, (x, y))
            x += lw + GAP
            # ④ 我们的层
            ml = layers[p['id']]
            b2 = Image.new('RGBA', (ml.width * SL, ml.height * SL), (139, 139, 139, 255))
            b2.paste(up(ml, SL), (0, 0), up(ml, SL)); sheet.paste(b2, (x, y))
            # 文字
            try:
                f1 = ImageFont.truetype(FONT, 30)
                f2 = ImageFont.truetype(FONT, 16)
                f3 = ImageFont.truetype(FONT, 14)
            except Exception:
                f1 = f2 = f3 = ImageFont.load_default()
            d.text((PAD, y + ch + 8), p['cn'], font=f1, fill=(250, 224, 140))
            d.text((PAD + 260, y + ch + 16), p['motif'], font=f2, fill=(160, 166, 180))
            d.text((PAD + 260, y + ch + 38), '%s · %s' % (p['mat'], p['slot']), font=f3, fill=(112, 118, 130))
            y += ROWH
        path = os.path.join(OUT, '预览_%s.png' % SLOT_CN[slot])
        sheet.save(path)
        print('sheet ->', path, sheet.size)

    # ---------------- 总览（图标一排铺开） ----------------
    SI = 5
    cols = 9
    cw = 16 * SI + 14
    rows = (len(P) + cols - 1) // cols
    W = 16 + cols * (cw + 8)
    H = 16 + 40 + rows * (cw + 44)
    sheet = Image.new('RGBA', (W, H), (22, 24, 29, 255))
    d = ImageDraw.Draw(sheet)
    txt(d, (16, 12), '原版风 · 盔甲 %d 件 · 图标总览（1× 实际尺寸见每组预览）' % len(P), 21, (246, 246, 250))
    try:
        f = ImageFont.truetype(FONT, 15)
    except Exception:
        f = ImageFont.load_default()
    for i, p in enumerate(P):
        r, cc = divmod(i, cols)
        x = 16 + cc * (cw + 8)
        y = 56 + r * (cw + 44)
        b = up(icons[p['id']], SI)
        bg = Image.new('RGBA', (cw, cw), (139, 139, 139, 255))
        bg.paste(b, (7, 7), b)
        sheet.paste(bg, (x, y))
        d.text((x, y + cw + 4), p['cn'], font=f, fill=(240, 226, 168))
    path = os.path.join(OUT, '总览_%d件.png' % len(P))
    sheet.save(path)
    print('sheet ->', path, sheet.size)


if __name__ == '__main__':
    main()
