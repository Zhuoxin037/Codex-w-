# -*- coding: utf-8 -*-
"""
生成「威霆·领域法阵」的资源包素材(幂等, 改数字重跑即可)。

产出(都在 sweetdream_rp_完整版/assets/sweetdream/ 下):
  textures/item/domain.png        64x1536 = 24 帧 x 64x64  暗紫符文法阵(自转)
  textures/item/domain.png.mcmeta                          动画声明(每 2 刻一帧)
  textures/item/domain_rune.png   16x16                    竖立的符文碎片贴图
  models/item/domain.json         水平法阵盘 + 8 片环绕符文碎片(十字薄片)
  items/domain.json               item_model 分发

------------------------------------------------------------
★★ 最大的坑(2026-10-08 实际踩到): MC 1.21.5 的模型元素 `rotation.angle`
   只接受 **-45 / -22.5 / 0 / 22.5 / 45** 这五个离散值。原来想"6 片符文每 60° 朝切向"
   写了 angle=0/60/120/180/240/300 ⇒ **整份模型加载失败**(日志
   `Invalid rotation 60.0 found, only -45/-22.5/0/22.5/45 allowed`),
   游戏里看到的是**一坨紫黑方块**(missing model)。现在改成不带 rotation 的十字薄片。
★ 用户口径(2026-10-08): 领域主色 = **暗紫**; 环绕元素 = **符文碎片**。
★ 为什么"自转"靠贴图动画而不是每刻改 display 的 rotation
  领域由 field_tick **每秒**跳一次; 想每刻转就得再挂一条每刻链 + 每刻算三角函数
  (MC 没有现成的 tan/cos)。做成 24 帧的旋转贴图后, MC 自己逐帧播 —— 数据包侧零开销,
  和海棠漩涡(vortex, 同一套路)保持一致。
★ 为什么是**均匀** scale
  法阵盘要"直径 12 格"(半径 6 = 落雷判定范围), 而环绕符文要"约 1.9 格高"。
  若用非均匀 scale(宽 12 / 高 1)会把符文压成一条线; 均匀 scale 12 下:
  模型 16 单位 = 12 格 ⇒ 盘直径正好 12, 符文高 2.54 单位 = 1.9 格 —— 两者都对。
★ 16 单位 = 1 格的锚点(见 _gen_angel_beam / 暗海): 物品模型 [0,16] 以实体位置为中心。
  法阵盘的元素 y 取 7.94~8.06(中心 8.0) ⇒ 缩放后正好落在实体所在平面(贴地)。
------------------------------------------------------------
"""
import json
import math
import struct
import zlib
from pathlib import Path

ROOT = Path(r'D:/数据包/sweetdream_rp_完整版')
NS = ROOT / 'assets' / 'sweetdream'
TEX = NS / 'textures' / 'item'
MDL = NS / 'models' / 'item'
ITM = NS / 'items'
for d in (TEX, MDL, ITM):
    d.mkdir(parents=True, exist_ok=True)

# 暗紫四阶
BRIGHT = (198, 136, 255)
MID = (148, 82, 234)
DARK = (90, 42, 158)
GLOW = (124, 62, 205)

FRAMES = 24          # 24 帧 x 15 度 = 一整圈
SIZE = 64            # 每帧 64x64
TWO_PI = 2.0 * math.pi


def png(w, h, px):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(px[y * w + x])

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff))
    return (b'\x89PNG\r\n\x1a\n'
            + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def frac(v):
    return v - math.floor(v)


def on_spoke(a, spokes, width):
    """a 是归一化角度 0..1; 判断是否落在 spokes 条等分射线的 ±width 内。"""
    m = frac(a * spokes)
    return m < width or m > 1.0 - width


def disc_frame(t):
    """第 t 帧: 整张图案绕中心转 t*15 度"""
    rot = t / float(FRAMES)
    half = (SIZE - 1) / 2.0
    px = []
    for y in range(SIZE):
        for x in range(SIZE):
            dx = (x - half) / half
            dy = (y - half) / half
            r = math.hypot(dx, dy)
            if r > 1.0:
                px.append((0, 0, 0, 0))
                continue
            a = frac(math.atan2(dy, dx) / TWO_PI + rot)
            col = None
            if 0.955 <= r < 0.99:                       # 外环(最亮)
                col = (BRIGHT, 240)
            elif 0.905 <= r < 0.932:                    # 外细环
                col = (MID, 165)
            elif 0.660 <= r < 0.716:                    # 内环
                col = (MID, 210)
            elif 0.746 <= r < 0.905 and on_spoke(a, 24, 0.075):   # 24 道刻度
                col = (BRIGHT, 185)
            elif r < 0.660 and on_spoke(a, 6, 0.030):   # 6 道粗射线
                fade = 1.0 - r / 0.66
                col = (BRIGHT if r < 0.34 else MID, int(60 + 150 * fade))
            elif r < 0.230:                             # 中心光晕
                g = 1.0 - r / 0.23
                col = (GLOW, int(190 * g * g))
            if col is None:
                px.append((0, 0, 0, 0))
            else:
                (cr, cg, cb), al = col
                px.append((cr, cg, cb, al))
    return px


# 拼成竖条(MC 的动画贴图 = 竖直排帧)
rows = []
for t in range(FRAMES):
    f = disc_frame(t)
    for y in range(SIZE):
        rows.extend(f[y * SIZE:(y + 1) * SIZE])
(TEX / 'domain.png').write_bytes(png(SIZE, SIZE * FRAMES, rows))
(TEX / 'domain.png.mcmeta').write_text(
    json.dumps({"animation": {"width": SIZE, "height": SIZE, "frametime": 2}},
               indent=None, separators=(',', ':')) + '\n', encoding='utf-8')


# ------------------------------------------------------------- 符文碎片贴图
def gen_rune(size=16):
    px = [(0, 0, 0, 0)] * (size * size)
    px = list(px)
    c = (size - 1) / 2.0

    def put(x, y, rgb, a=255):
        if 0 <= x < size and 0 <= y < size:
            px[y * size + x] = rgb + (a,)

    for y in range(size):
        for x in range(size):
            d = abs(x - c) + abs(y - c)          # 菱形
            if 6.0 <= d <= 6.9:                  # 菱形外框
                put(x, y, BRIGHT)
            elif 3.6 <= d <= 4.3:                # 内菱形(细, 暗一点)
                put(x, y, MID, 210)
    for y in range(3, 13):                       # 中心竖线
        put(7, y, BRIGHT)
        put(8, y, MID, 200)
    for x in range(5, 11):                       # 上下短横
        put(x, 2, BRIGHT, 220)
        put(x, 13, BRIGHT, 220)
    return png(size, size, px)


(TEX / 'domain_rune.png').write_bytes(gen_rune())


# ------------------------------------------------------------ 模型
elements = [{
    "name": "法阵盘(水平薄片, 只渲染上下两面)",
    "from": [0, 7.94, 0],
    "to": [16, 8.06, 16],
    "faces": {"up": {"texture": "#disc", "uv": [0, 0, 16, 16]},
              "down": {"texture": "#disc", "uv": [0, 0, 16, 16]}},
}]

RADIUS = 7.0     # 模型单位; x12/16 = 5.25 格(在半径 6 的圈内)
SHARDS = 8       # 8 片, 每 45° 一片

# ★★ 为什么符文碎片**不能用 rotation 摆角度** ★★
#   MC 1.21.5 的 rotation.angle 只有 -45/-22.5/0/22.5/45 五个合法值 ——
#   想"每 60° 摆一片、各自朝切向"就必须写 60/120/180/240/300, 整份模型会加载失败
#   (日志 `Invalid rotation 60.0 found, ...`, 游戏里是一坨紫黑方块)。
#   所以改成:**每片都是一对正交的薄片(十字)** —— 十字对 90° 旋转是**不变量**,
#   摆哪儿都不用转、从任何水平角度都看得见 1~2 张平面(和天使核心圣光柱同一招)。
#   uv 必须**显式**写 [0,0,16,16]: 不写的话 auto-uv 会按元素位置去贴图上取一小块,
#   符文就只剩中间一条缝了。
HALF_T = 0.05    # 薄片半厚
HALF_W = 0.8     # 薄片半宽
Y0, Y1 = 8.06, 10.6   # 2.54 单位 = 1.9 格高


def rune_shards(idx, cx, cz):
    uv = [0, 0, 16, 16]
    return [
        {"name": "符文碎片%d-A(法线±X)" % idx,
         "from": [round(cx - HALF_T, 2), Y0, round(cz - HALF_W, 2)],
         "to": [round(cx + HALF_T, 2), Y1, round(cz + HALF_W, 2)],
         "faces": {"east": {"texture": "#rune", "uv": uv},
                   "west": {"texture": "#rune", "uv": uv}}},
        {"name": "符文碎片%d-B(法线±Z)" % idx,
         "from": [round(cx - HALF_W, 2), Y0, round(cz - HALF_T, 2)],
         "to": [round(cx + HALF_W, 2), Y1, round(cz + HALF_T, 2)],
         "faces": {"north": {"texture": "#rune", "uv": uv},
                   "south": {"texture": "#rune", "uv": uv}}},
    ]


for i in range(SHARDS):
    th = math.radians(i * (360.0 / SHARDS))
    cx = 8 + RADIUS * math.cos(th)
    cz = 8 + RADIUS * math.sin(th)
    elements.extend(rune_shards(i + 1, cx, cz))

MODEL = {
    "credit": (
        "威霆·领域法阵(水平符文盘 + 8 片环绕符文碎片)。贴图 domain.png 是 24 帧自转动画, "
        "所以**数据包侧不需要每刻驱动**。★ 均匀 scale 12: 模型 16 单位 = 12 格, 盘直径正好 12 "
        "(半径 6 = 落雷判定范围), 符文高 2.54 单位 = 1.9 格。"
        "★ 盘元素 y 取 7.94~8.06(中心 8.0): 物品模型 [0,16] 以实体位置为中心, 中心 y=8 才落在实体平面(贴地)。"
        "★ ★ 符文碎片**故意不带 rotation**: MC 1.21.5 的 rotation.angle 只有 -45/-22.5/0/22.5/45 "
        "五个合法值, 想'每 60° 摆一片朝切向'必然越界、整份模型加载失败(游戏里是一坨紫黑方块)。"
        "改成'每片一对正交薄片(十字)' —— 十字对 90° 旋转是不变量, 不用转、任何角度都看得见。"
        "★★ 薄片 uv 必须显式写 [0,0,16,16], 否则 auto-uv 只取到贴图中间一条缝。"
    ),
    "ambientocclusion": False,
    "gui_light": "front",
    "textures": {"disc": "sweetdream:item/domain",
                 "rune": "sweetdream:item/domain_rune",
                 "particle": "sweetdream:item/domain"},
    "elements": elements,
    "display": {
        "ground": {"rotation": [0, 0, 0], "translation": [0, 2, 0],
                   "scale": [0.25, 0.25, 0.25]},
        "gui": {"rotation": [30, 45, 0], "translation": [0, 0, 0],
                "scale": [0.3, 0.3, 0.3]},
    },
}

ITEMS = {
    "hand_animation_on_swap": False,
    "model": {"type": "minecraft:model", "model": "sweetdream:item/domain"},
}

(MDL / 'domain.json').write_text(
    json.dumps(MODEL, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
(ITM / 'domain.json').write_text(
    json.dumps(ITEMS, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
for f in ('textures/item/domain.png', 'textures/item/domain.png.mcmeta',
          'textures/item/domain_rune.png', 'models/item/domain.json',
          'items/domain.json'):
    p = NS / f
    print('  %8d  %s' % (p.stat().st_size, f))
