# -*- coding: utf-8 -*-
"""
build_vanilla_swords.py —— 「原版风 · 技能版」剑类图标生成器（13 件）

口径（2026-10-10 用户定）：
  · 只做**没有独立建模**的剑（有建模的 极光与幻梦 / 深海的回响 / 烈火，残躯 / 引梦镰 跳过）。
  · 风格 = B 档「表达」并**再放大胆**：允许刃口崩缺、轮廓外补像素等改动。

硬约束仍然是"贴近原版"：轮廓逐像素照抄该武器**当前所用的原版底物**
（铁剑 / 钻石剑 / 下界合金剑），只换配色 + 加技能纹样。

设计依据 = 逐件读 give.mcfunction 的技能原文（见 _sword_info.py 输出）。
输出：模型设计/原版风_资源包_20261010/剑_预览/
"""
import os
import sys

sys.path.insert(0, r'D:\数据包\.workbuddy')
from build_vanilla_icons import (build, region_sword, region_sword_neth,
                                 hx, up, txt, REF, load)
from PIL import Image, ImageDraw

OUT = r'D:\数据包\模型设计\原版风_资源包_20261010\剑_预览'
os.makedirs(OUT, exist_ok=True)

FS = region_sword
FN = region_sword_neth


def A(pts, col):
    """指定坐标上色"""
    s = set(pts)
    return (lambda x, y, r, t, e: (x, y) in s, col)


def RG(rname, cond, col):
    """某区域内满足条件上色；cond(x,y,t,e)"""
    return (lambda x, y, r, t, e: r == rname and cond(x, y, t, e), col)


def MID(col, rname='blade'):
    """刃中线（原版斜刃的中缝，x+y==15）"""
    return RG(rname, lambda x, y, t, e: (x + y) == 15, col)


def EDGE(col, rname='blade'):
    return RG(rname, lambda x, y, t, e: e, col)


# ============================================================================ 13 件
# (key, 中文名, 技能一句话, 模板, 区域函数, 色阶, 覆盖, 掏空, 轮廓外像素)
SPECS = [
    # ── 永霜：冰冻 5 格内 8 个生物 3 秒 —— 「永霜」= 一把冻透的剑
    #    ★ 二次重做（2026-10-10）：上一版整圈**外扩 1px 半透明冰壳**，用户否掉 ——
    #      "太宽大了"。教训：外扩会把整把剑横向吹胖一圈，16×16 里等于换了把武器。
    #      ⇒ 这一版轮廓与钻石剑**逐像素一致（零外扩）**，"冰"全部做进**刃身内部**：
    #        · 刃锋（外缘靠右下那一侧）＝ 结霜的亮白 —— 冷到发亮的刀刃，最锐的那条线
    #        · 刃背（外缘靠左上那一侧）＝ 深冷阴影 —— 把厚度"压"回去，不是加出来
    #        · 刃身中缝（原版凹槽）     ＝ 冻结的芯（深冰蓝）—— 保留原版的血槽结构
    #        · 剑尖裹霜：越靠尖越白（霜从尖端往上爬）
    #        · 护手中心一块碎冰 + 柄上结霜
    #      对比度刻意拉开（暗端压到 #0A1E30）：均匀明亮的冰会读成"一块冰砖"。
    dict(key='everfrost', cn='永霜', motif='冻结 5 格 · 冰封', tpl='diamond_sword', rfn=FS,
         ramp={
             'blade':  [hx('#0D2A42'), hx('#123C58'), hx('#1A5578'), hx('#2A7A9E'), hx('#469EC2'), hx('#6EC4DE'), hx('#9EE0F2')],
             'guard':  [hx('#0A2438'), hx('#164A66'), hx('#2E7C9E'), hx('#6CB2CC'), hx('#A8DCEC')],
             'grip':   [hx('#071826'), hx('#0E2C40'), hx('#173F58'), hx('#245C78')],
             'pommel': [hx('#0A2438'), hx('#2E7C9E'), hx('#8CCEE4')],
             '_default': [hx('#22648A'), hx('#8CCEE4'), hx('#F4FEFF')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and (x + y) > 15, '#F2FDFF'),   # 刃锋的霜（唯一的白）
             RG('blade', lambda x, y, t, e: e and (x + y) < 15, '#0A2136'),   # 刃背的深冷（蓝，不压黑）
             MID('#1A5578'),                                                  # 中缝：冻结的芯
             RG('blade', lambda x, y, t, e: y <= 2 and t >= 0.5, '#DCF6FF'),   # 剑尖裹霜
             A([(7, 9), (8, 9)], '#CFEFFA'),                                  # 护手中心的碎冰
             RG('grip', lambda x, y, t, e: t > 0.72, '#7FC4DC'),              # 柄上结霜
         ],
         carve=None,
         # 轮廓外只留**剑尖一粒霜屑** —— 不外扩，避免再"宽大"
         extra=[((12, 0), hx('#CFEFFA'))]),

    # ── 横刀：向前突进 3 格 —— 唐横刀，单刃、镡（护手）短而宽、黄铜
    dict(key='hengdao', cn='横刀', motif='突进 3 格 · 单刃', tpl='iron_sword', rfn=FS,
         ramp={
             'blade':  [hx('#0A0D12'), hx('#1B222C'), hx('#333D4A'), hx('#5A6674'), hx('#8E9AA8'), hx('#C6D0DA'), hx('#F4F8FC')],
             'guard':  [hx('#1A1408'), hx('#3A2C10'), hx('#6E5620'), hx('#A89040'), hx('#D8BE70')],
             'grip':   [hx('#100F0C'), hx('#22201A'), hx('#383428'), hx('#56503E')],
             'pommel': [hx('#1A1408'), hx('#6E5620'), hx('#D8BE70')],
             '_default': [hx('#1B222C'), hx('#8E9AA8'), hx('#F4F8FC')],
         },
         acc=[
             # 单刃：背侧压暗、锋侧提亮（x < 15-y 为上/背，x > 15-y 为下/锋）
             RG('blade', lambda x, y, t, e: e and x < 15 - y, '#0C1015'),
             RG('blade', lambda x, y, t, e: e and x > 15 - y, '#F4F8FC'),
             MID('#AEB8C4'),
             A([(4, 9)], '#D8BE70'),          # 黄铜镡上的一点金
         ],
         carve=lambda x, y: False, extra=[]),

    # ── 无息：突进 8 格穿身而过、闪回 —— 无声、残影
    dict(key='hush', cn='无息', motif='穿透 8 格 · 残影', tpl='diamond_sword', rfn=FS,
         ramp={
             'blade':  [hx('#0A0B0E'), hx('#171A20'), hx('#2C313A'), hx('#4E5561'), hx('#7E8794'), hx('#B0B8C4'), hx('#E4E8EE')],
             'guard':  [hx('#0A0B0E'), hx('#14161C'), hx('#24272F'), hx('#3C404A'), hx('#5C626C')],
             'grip':   [hx('#08090C'), hx('#121418'), hx('#1E2026'), hx('#2E3138')],
             'pommel': [hx('#0A0B0E'), hx('#2C313A'), hx('#7E8794')],
             '_default': [hx('#171A20'), hx('#4E5561'), hx('#E4E8EE')],
         },
         acc=[
             MID('#8C96A4'),                  # 抽掉血色的一条冷光
             RG('blade', lambda x, y, t, e: e and t > 0.8, '#EEF2F6'),
             A([(3, 7), (4, 6)], '#3A4048'),  # 柄侧的静默颗粒
         ],
         carve=None,
         # 残影：沿刃的**外缘**补一排更暗的像素（穿身而过的"过去式"）
         extra=[((13, 0), hx('#4E5561')), ((10, 4), hx('#3C424C')),
                ((8, 7), hx('#343A44')), ((6, 9), hx('#2E343C'))]),

    # ── 燎原：18 秒每 2 秒 5 格 AOE，每 3 次附加「流火」—— 野火燎原
    dict(key='liaoyuan', cn='燎原', motif='18 秒持续 · 流火', tpl='netherite_sword', rfn=FN,
         ramp={
             'blade':  [hx('#1A0C06'), hx('#3E1508'), hx('#8A2E0C'), hx('#E04A10'), hx('#FF8A24'), hx('#FFC45C'), hx('#FFEBB0')],
             'guard':  [hx('#140A06'), hx('#2E1508'), hx('#5A2A0E'), hx('#9A5A20'), hx('#C89A50')],
             'grip':   [hx('#080505'), hx('#161010'), hx('#261A12'), hx('#3A2818')],
             '_default': [hx('#3E1508'), hx('#E04A10'), hx('#FFEBB0')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.72, '#FFD98A'),   # 刃口余火
             MID('#FFB03C'),                                              # 刃中火线
             RG('guard', lambda x, y, t, e: t > 0.85, '#FF7A18'),
         ],
         carve=None,
         # 飞散的火星（轮廓外）—— 野火"燎"出来的
         extra=[((9, 2), hx('#FF9A30')), ((5, 6), hx('#FFC24A')), ((12, 6), hx('#FF8A24'))]),

    # ── 流光：锁定 8 格目标，3 秒后基础攻击 ×2 —— 一线天光
    dict(key='liuguang', cn='流光', motif='锁定 3 秒 · 光矢', tpl='iron_sword', rfn=FS,
         ramp={
             'blade':  [hx('#0C0E12'), hx('#20242C'), hx('#41474F'), hx('#767E88'), hx('#B2BAC4'), hx('#E0E6EE'), hx('#FFFFFF')],
             'guard':  [hx('#101216'), hx('#22262E'), hx('#3E444E'), hx('#6E7884'), hx('#A8B2C0')],
             'grip':   [hx('#0A0C10'), hx('#161A20'), hx('#262C34'), hx('#3A424C')],
             'pommel': [hx('#101216'), hx('#41474F'), hx('#B2BAC4')],
             '_default': [hx('#20242C'), hx('#767E88'), hx('#FFFFFF')],
         },
         acc=[
             MID('#EAF6FF'),                                  # 贯穿刃身的一线流光
             RG('blade', lambda x, y, t, e: e and t > 0.82, '#FFFFFF'),
             RG('blade', lambda x, y, t, e: (x + y) == 14, '#9FD8F0'),   # 流光的副线（偏冷）
         ],
         carve=None,
         extra=[((14, 0), hx('#FFFFFF')), ((12, 9), hx('#8FC8E8'))]),

    # ── 万念：切换为「千散」+ 3 格 AOE —— 万千念头
    dict(key='myriad', cn='万念', motif='化为千散 · 念动', tpl='iron_sword', rfn=FS,
         ramp={
             'blade':  [hx('#100C1A'), hx('#221A34'), hx('#3E3058'), hx('#6A5290'), hx('#9A80C0'), hx('#C8B4E4'), hx('#EFE8FB')],
             'guard':  [hx('#0E0A16'), hx('#1E1630'), hx('#362A54'), hx('#5A4880'), hx('#8C76B4')],
             'grip':   [hx('#0A0810'), hx('#14101E'), hx('#221C30'), hx('#342C48')],
             'pommel': [hx('#0E0A16'), hx('#3E3058'), hx('#9A80C0')],
             '_default': [hx('#221A34'), hx('#6A5290'), hx('#EFE8FB')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.8, '#E4D8F8'),
             MID('#7C64B8'),
             # 念珠：刃侧一串等距的紫点（对应"万念"）
             A([(4, 8), (5, 7), (7, 5), (3, 11), (2, 13)], '#B79BE4'),
         ],
         carve=None,
         extra=[((6, 6), hx('#8A6EC4')), ((9, 8), hx('#6A5290'))]),

    # ── 千散：切换为「万念」+ 3 格 AOE —— 念头四散
    dict(key='qiansan', cn='千散', motif='化为万念 · 散', tpl='iron_sword', rfn=FS,
         ramp={
             'blade':  [hx('#141008'), hx('#2A2210'), hx('#4C4020'), hx('#7E6A32'), hx('#B09848'), hx('#E0C878'), hx('#FBF0C0')],
             'guard':  [hx('#121008'), hx('#28220E'), hx('#463C18'), hx('#746430'), hx('#A89450')],
             'grip':   [hx('#0C0A06'), hx('#181510'), hx('#282218'), hx('#3C3424')],
             'pommel': [hx('#121008'), hx('#4C4020'), hx('#B09848')],
             '_default': [hx('#2A2210'), hx('#7E6A32'), hx('#FBF0C0')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.8, '#FBF0C0'),
             MID('#C8AC58'),
             # 与「万念」对称：点从刃身向**外**散（越远越疏）
             A([(2, 9), (4, 12), (1, 14), (3, 15)], '#D8C070'),
         ],
         carve=None,
         extra=[((2, 5), hx('#E0C878')), ((0, 10), hx('#C8AC58')), ((6, 15), hx('#B09848'))]),

    # ── 回锋：断刃 3 层，前方 3×5，消耗全部断刃重复 —— 崩口的刀刃
    dict(key='rebound', cn='回锋', motif='断刃 3 层 · 连击', tpl='iron_sword', rfn=FS,
         ramp={
             'blade':  [hx('#0C0A08'), hx('#1E1814'), hx('#3A2C22'), hx('#6E523A'), hx('#A8825A'), hx('#C8A878'), hx('#EFDCB4')],
             'guard':  [hx('#140C06'), hx('#2E1A0C'), hx('#5A3418'), hx('#8E5828'), hx('#C08A48')],
             'grip':   [hx('#0A0806'), hx('#181410'), hx('#28201A'), hx('#3C3026')],
             'pommel': [hx('#140C06'), hx('#5A3418'), hx('#C08A48')],
             '_default': [hx('#1E1814'), hx('#6E523A'), hx('#EFDCB4')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.82, '#F2E0B8'),
             MID('#96703E'),
             A([(6, 11), (5, 12)], '#C08A48'),       # 柄首两点铜
         ],
         # 崩口：从刃的**外缘**咬掉两块（断刃）
         carve=lambda x, y: (x, y) in {(11, 4), (10, 5), (8, 8)},
         extra=[((9, 3), hx('#8E6A42'))]),

    # ── 热熔：把「流火」烧成「夜火」+ 护甲归 0 —— 熔芯、滴落
    dict(key='remelt', cn='热熔', motif='夜火 · 破甲', tpl='netherite_sword', rfn=FN,
         ramp={
             'blade':  [hx('#140A06'), hx('#361206'), hx('#7A2408'), hx('#D0400A'), hx('#FF7A18'), hx('#FFB84C'), hx('#FFF0C8')],
             'guard':  [hx('#120806'), hx('#2A120A'), hx('#54200C'), hx('#8E4418'), hx('#C4823C')],
             'grip':   [hx('#0A0606'), hx('#161010'), hx('#241810'), hx('#382618')],
             '_default': [hx('#361206'), hx('#D0400A'), hx('#FFF0C8')],
         },
         acc=[
             MID('#FFF0C8'),                                  # 熔到发白的芯
             RG('blade', lambda x, y, t, e: e and t > 0.7, '#FFC45C'),
             RG('guard', lambda x, y, t, e: t > 0.86, '#FF9A30'),
         ],
         carve=None,
         # 熔滴（轮廓外，从刃口往下淌）
         extra=[((11, 8), hx('#FF7A18')), ((9, 11), hx('#D0400A'))]),

    # ── 游星：锁定 10 格内 3 个生物，2 格 AOE 基础攻击 ×4 —— 游走的星
    dict(key='rogue_star', cn='游星', motif='锁定 3 目标 · 星坠', tpl='diamond_sword', rfn=FS,
         ramp={
             'blade':  [hx('#060A18'), hx('#0E1830'), hx('#1C3058'), hx('#2E5490'), hx('#5084C0'), hx('#8CB8E4'), hx('#DCF0FF')],
             'guard':  [hx('#060A18'), hx('#101A32'), hx('#1E3458'), hx('#365E90'), hx('#5E8CC0')],
             'grip':   [hx('#05070E'), hx('#0C1220'), hx('#162034'), hx('#26344C')],
             'pommel': [hx('#060A18'), hx('#1C3058'), hx('#5084C0')],
             '_default': [hx('#0E1830'), hx('#2E5490'), hx('#DCF0FF')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.8, '#E8F6FF'),
             MID('#7CB8E8'),
             # 星芒（十字）落在刃身
             A([(13, 2), (12, 3), (14, 3), (13, 4)], '#FFFFFF'),
         ],
         carve=None,
         extra=[((10, 1), hx('#B8DCFF')), ((7, 8), hx('#8CB8E4'))]),

    # ── 影刃：瞬移 10 格最近生物；5 秒内击杀刷新冷却 —— 暗影、残像
    dict(key='shadow_blade', cn='影刃', motif='瞬移 · 击杀刷新', tpl='diamond_sword', rfn=FS,
         ramp={
             'blade':  [hx('#04040A'), hx('#0C0A18'), hx('#1C1630'), hx('#332650'), hx('#5A4488'), hx('#8A70B8'), hx('#C0A8E0')],
             'guard':  [hx('#080610'), hx('#12101E'), hx('#221C34'), hx('#3A3050'), hx('#5C4E78')],
             'grip':   [hx('#040406'), hx('#0C0C12'), hx('#16161E'), hx('#24242E')],
             'pommel': [hx('#080610'), hx('#221C34'), hx('#5A4488')],
             '_default': [hx('#0C0A18'), hx('#332650'), hx('#C0A8E0')],
         },
         acc=[
             RG('blade', lambda x, y, t, e: e and t > 0.78, '#8A6EC8'),   # 紫边
             MID('#2A2048'),                                              # 暗芯
             RG('guard', lambda x, y, t, e: t > 0.86, '#9C7CD8'),
         ],
         carve=None,
         # 影子（轮廓外的暗紫残像，往左下落）
         extra=[((12, 0), hx('#2A2048')), ((10, 3), hx('#241C40')),
                ((7, 9), hx('#1E1836')), ((4, 12), hx('#181230'))]),

    # ── 火种 · 熄灭态：焦炭剑身，只剩几粒暗红余烬 —— 一眼"冷"
    dict(key='tinder_off', cn='火种', motif='熄灭态 · 余烬', tpl='netherite_sword', rfn=FN,
         ramp={
             'blade':  [hx('#0A0706'), hx('#171008'), hx('#261A10'), hx('#3A2A1C'), hx('#51402C')],
             'guard':  [hx('#0A0706'), hx('#150E08'), hx('#241810'), hx('#362618')],
             'grip':   [hx('#080605'), hx('#120E0A'), hx('#1C1610'), hx('#282018')],
             '_default': [hx('#171008'), hx('#3A2A1C'), hx('#51402C')],
         },
         acc=[
             # 刃中一条**断续**的暗红 —— 靠护手那一段还留有余温
             RG('blade', lambda x, y, t, e: (x + y) == 15 and y >= 7, '#5A1C08'),
             A([(6, 9), (5, 10)], '#6B2108'),
             RG('blade', lambda x, y, t, e: e and t > 0.9 and y >= 8, '#6E2A10'),
             RG('grip', lambda x, y, t, e: y >= 14, '#6E2208'),      # 柄尾：火种还没死透
         ],
         carve=None, extra=[]),

    # ── 火种 · 燃烧态：整把剑烧起来，柄尾（火种）最炽白，剑尖飘出火舌
    #    与熄灭态共用同一轮廓 —— 区分全靠**明度 + 火焰**，一眼可辨。
    dict(key='tinder_on', cn='火种', motif='燃烧态 · 烈焰', tpl='netherite_sword', rfn=FN,
         ramp={
             'blade':  [hx('#2A0A04'), hx('#4E1406'), hx('#8A2A08'), hx('#C84A0C'), hx('#F08A1C'), hx('#FFC44E')],
             'guard':  [hx('#3A0C04'), hx('#6E1A06'), hx('#A83208'), hx('#E0640E'), hx('#FF9E2A')],
             'grip':   [hx('#2A0A04'), hx('#5A1406'), hx('#8E2808'), hx('#C44A0C')],
             '_default': [hx('#4E1406'), hx('#C84A0C'), hx('#FFC44E')],
         },
         acc=[
             MID('#FFD24A'),                                        # 刃中熔芯
             EDGE('#FFF0C0'),                                       # 白热刃口
             # 温度沿刃长：靠柄/护手的高光烧到发白；剑尖端（远端）反而更冷更暗
             RG('blade', lambda x, y, t, e: y >= 8 and t > 0.55, '#FFE49A'),
             RG('blade', lambda x, y, t, e: y <= 3 and t < 0.35, '#8A2008'),
             RG('guard', lambda x, y, t, e: t > 0.7, '#FFB63C'),
             A([(0, 15), (1, 15)], '#FFF6D0'),                        # 火种最中心：一点白（须排在 grip 规则之前）
             RG('grip', lambda x, y, t, e: y >= 14, '#FFE49A'),      # 柄尾「火种」本身
         ],
         carve=None,
         # 火舌/火星**向上**（y 减小方向）飘，沿剑身左上散开
         extra=[((12, 0), hx('#FFD24A')), ((11, 1), hx('#FF9A30')),
                ((9, 3), hx('#FF7A18')), ((7, 5), hx('#D8480A')),
                ((5, 7), hx('#A82E08'))]),

    # ── 神裁：25% 概率附加虚弱/缓慢/发光 + 领域 —— 圣光、审判
    dict(key='verdict', cn='神裁', motif='审判领域 · 降罚', tpl='netherite_sword', rfn=FN,
         ramp={
             'blade':  [hx('#0A0A0C'), hx('#1E2028'), hx('#3A4050'), hx('#6E7890'), hx('#A8B4C8'), hx('#D8E0EC'), hx('#F8FBFF')],
             'guard':  [hx('#1A1206'), hx('#3E2C0C'), hx('#8A6420'), hx('#C89E38'), hx('#F0D070')],
             'grip':   [hx('#0A0A0C'), hx('#16161A'), hx('#26262C'), hx('#3A3A42')],
             '_default': [hx('#1E2028'), hx('#A8B4C8'), hx('#F8FBFF')],
         },
         acc=[
             MID('#FFFFFF'),                                        # 刃中一道圣光
             RG('blade', lambda x, y, t, e: e and t > 0.8, '#EAF0FA'),
             RG('guard', lambda x, y, t, e: t > 0.78, '#FFE9A0'),   # 鎏金护手
         ],
         carve=None,
         extra=[((11, 1), hx('#FFF6D0')), ((9, 5), hx('#F0E0A0')), ((14, 5), hx('#FFF6D0'))]),
]

# ============================================================================ 生成
BASE = {'iron_sword': FS, 'diamond_sword': FS, 'netherite_sword': FN}


def main():
    icons = {}
    legacy = os.path.join(OUT, 'tinder.png')       # 旧单态火种（已拆成两态）
    if os.path.isfile(legacy):
        os.remove(legacy)
        print('removed legacy -> tinder.png')

    for sp in SPECS:
        im = build(sp['tpl'], sp['rfn'], sp['ramp'], sp['acc'], sp['carve'])
        for (x, y), col in sp['extra']:
            # extra = 轮廓外的像素；只在**空位**落笔，避免盖掉刃身
            if 0 <= x < 16 and 0 <= y < 16 and im.getpixel((x, y))[3] == 0:
                im.putpixel((x, y), col)
        im.save(os.path.join(OUT, sp['key'] + '.png'))
        icons[sp['key']] = im
        print('icon -> %-14s %s' % (sp['key'], im.size))

    # ---------------- 对照大图 ----------------
    S, PAD = 9, 14
    CELL = 16 * S
    LBLH = 24
    ROWH = CELL + LBLH + 16
    W = PAD * 4 + CELL * 3 + 150
    HEAD = 46
    H = PAD + HEAD + len(SPECS) * ROWH + 150
    sheet = Image.new('RGBA', (W, H), (20, 22, 27, 255))
    d = ImageDraw.Draw(sheet)
    txt(d, (PAD, 12), '原版风 · 技能版 · 剑类（B 档 · 再放大胆）—— 轮廓逐像素照抄各件所用的原版底物', 22, (246, 246, 250))
    txt(d, (PAD, 40), '① 原版底物 ② 我们的图标 ③ 背包格内实际观感', 15, (150, 156, 170))

    slot = Image.new('RGBA', (CELL + 16, CELL + 16), (139, 139, 139, 255))
    y = PAD + HEAD
    for sp in SPECS:
        x = PAD
        v = Image.open(os.path.join(REF, sp['tpl'] + '.png')).convert('RGBA')
        b = up(v, S)
        c = slot.copy(); c.paste(b, (8, 8), b)
        sheet.paste(c, (x, y))
        x += CELL + 26

        b = up(icons[sp['key']], S)
        c = slot.copy(); c.paste(b, (8, 8), b)
        sheet.paste(c, (x, y))
        x += CELL + 26

        b = up(icons[sp['key']], S)
        c = slot.copy(); c.paste(b, (8, 8), b)
        sheet.paste(c, (x, y))
        x += CELL + 34

        txt(d, (x, y + 24), sp['cn'], 26, (250, 224, 140))
        txt(d, (x, y + 66), sp['motif'], 15, (156, 162, 176))
        txt(d, (x, y + 92), sp['tpl'].replace('_', ' '), 13, (110, 116, 128))
        y += ROWH

    # 实际尺寸行
    txt(d, (PAD, y + 6), '④ 实际尺寸（1× = 背包真实大小 / 2× / 4×）', 15, (150, 156, 170))
    y += 32
    cx = PAD
    for sp in SPECS:
        for s in (1, 2):
            b = up(icons[sp['key']], s)
            sheet.paste(b, (cx, y), b)
            cx += 16 * s + 8
        cx += 10
    p = os.path.join(OUT, '剑_技能版_13件试作.png')
    sheet.save(p)
    print('sheet ->', p, sheet.size)


if __name__ == '__main__':
    main()
