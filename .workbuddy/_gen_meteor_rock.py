# -*- coding: utf-8 -*-
"""
生成「陨星·陨石」的资源包素材(幂等, 改数字重跑即可)。

产出(都在 sweetdream_rp_完整版/assets/sweetdream/ 下):
  textures/item/meteor_rock.png  16x16  燃烧的岩石(深褐底 + 橙红裂纹)
  models/item/meteor_rock.json   9 块不规则碎石拼成的陨石
  items/meteor_rock.json         item_model 分发

------------------------------------------------------------
★★ 最大的坑(2026-10-08 实际踩到) : MC 1.21.5 的模型元素 `rotation.angle`
   只接受 **-45 / -22.5 / 0 / 22.5 / 45** 这五个离散值, 不是"±45 以内任意值"。
   写 22 / 38 或 60 会让**整份模型加载失败** —— 日志里是
   `Invalid rotation 22.0 found, only -45/-22.5/0/22.5/45 allowed`,
   游戏里看到的是**一坨紫黑方块**(missing model)。
   所以本文件所有角度都必须从 LEGAL_ANGLES 里取, chunk() 里有 assert 兜底。
★ 为什么是"多块拼 + 各自带 rotation"
  单个立方体贴同样 3 张图 = 一眼就是个盒子。多块不同大小/不同朝向的碎块叠在一起,
  轮廓才有"不规则的石头"感。rotation 绕**每块自己的中心**转, 让贴图接缝错开、
  剪影不再是直角盒子, 而组合关系不变(绕公共中心转 45° 会散架)。
★ 元素**不写 uv** ⇒ MC 用 auto-uv(按元素在模型里的位置去贴图对应区域取样),
  各块就会各自显示贴图的不同部位, 不会每块长得一模一样。
★ 尺寸口径(锚点 = 暗海/光束): 物品模型 [0,16] 以实体位置为中心, 且**均匀** scale N
  ⇒ 模型 16 单位 = N 格。数据包侧用 scale 1.4 ⇒ 陨石约 1.4 格大。
------------------------------------------------------------
"""
import json
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


# ---------------------------------------------------------------- 燃烧岩石贴图
def gen_rock(size=16):
    """确定性伪随机(不用 random 模块, 保证每次重跑字节一致)。

    ★ 2026-10-08 改版: 原来底色用 n<0.22 / 0.44 / 0.52 分四档, 明暗差到 (64,45,38)
      对 (30,21,18) —— 在 16x16 上就是几块大色斑, 石头看起来像"花掉的大理石"。
      改成**只做 ±10 的细微起伏**, 把对比度全部让给裂纹: 这样近看是黑乎乎的熔壳、
      裂纹是唯一亮的东西, 才像"刚砸下来的陨石"。
    ★ 预览图会显糊: mc-model-preview 的双线性采样把 16x16 放大成大软斑, 而游戏里是
      最近邻 —— 刀刃级的像素裂纹在游戏里才看得见, 别照预览图去判断贴图锐度。
    """
    px = []
    for y in range(size):
        for x in range(size):
            n = ((x * 7349 + y * 9151 + (x * y) * 577) % 1024) / 1024.0
            if n < 0.18:
                rgb = (52, 37, 31)        # 凸面微微提亮
            elif n < 0.30:
                rgb = (32, 22, 19)        # 凹处/坑
            else:
                rgb = (43, 30, 26)        # 基色(熔壳)
            px.append(rgb + (255,))

    def put(x, y, rgb, a=255):
        if 0 <= x < size and 0 <= y < size:
            px[y * size + x] = rgb + (a,)

    def line(x0, y0, x1, y1, rgb, rim=True):
        """Bresenham 画裂纹。rim=True 时先给一圈**暗缝**, 亮缝压在中间 ——
        暗底 + 亮缝才有"裂开露出岩浆"的读法; 原来那圈半亮橙反而把缝晕开了。"""
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx - dy
        while True:
            if rim:
                for ox, oy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    put(x0 + ox, y0 + oy, (24, 15, 13))
            put(x0, y0, rgb)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x0 += sx
            if e2 < dx:
                err += dx
                y0 += sy

    HOT = (255, 150, 52)
    line(2, 4, 7, 8, HOT)
    line(7, 8, 12, 12, HOT)
    line(3, 13, 8, 9, HOT)
    line(8, 9, 12, 5, HOT)
    line(7, 1, 9, 6, HOT)
    line(9, 6, 8, 14, HOT)
    line(0, 9, 5, 10, (255, 196, 96))
    line(12, 2, 13, 7, (255, 196, 96))
    # 两条主缝补一圈极淡的余晖(只补一条, 免得整张图都在发光)
    line(2, 3, 7, 7, (120, 62, 28), rim=False)
    line(8, 10, 12, 13, (120, 62, 28), rim=False)
    return png(size, size, px)


ROCK = gen_rock()
(TEX / 'meteor_rock.png').write_bytes(ROCK)


# ------------------------------------------------------------ 模型
def all_faces(tex):
    return {k: {"texture": tex} for k in
            ('down', 'up', 'north', 'south', 'west', 'east')}


# ★★ MC 1.21.5 的元素 rotation.angle **只接受 -45 / -22.5 / 0 / 22.5 / 45 这五个离散值** ★★
#   不是"±45 以内任意值"! 写 22 或 38 会让**整份模型加载失败**(日志:
#   `Invalid rotation 22.0 found, only -45/-22.5/0/22.5/45 allowed`),
#   游戏里看到的是一坨"紫黑方块"(missing model)。2026-10-08 实际踩到。
LEGAL_ANGLES = (-45, -22.5, 0, 22.5, 45)


def chunk(name, frm, to, axis='y', angle=0.0):
    """一块碎石。★ rotation 的原点取**这一块自己的中心**:
    绕模型中心(8,8,8)转 45° 会把块整个甩到旁边 —— 角度上限收紧到 45 以后,
    再绕公共原点转就散架了; 绕自己中心转只是"翻个身", 六块的组合关系不变。"""
    assert angle in LEGAL_ANGLES, (name, angle)
    el = {"name": name, "from": frm, "to": to, "faces": all_faces("#rock")}
    if angle:
        org = [round((frm[i] + to[i]) / 2.0, 2) for i in range(3)]
        el["rotation"] = {"origin": org, "axis": axis, "angle": angle}
    return el


MODEL = {
    "credit": (
        "陨星·陨石(9 块不规则碎石拼成, 各自绕**自己中心**翻一个身, 轮廓与贴图接缝都错开)。"
        "★ 元素刻意不写 uv ⇒ 走 auto-uv, 每块各自取贴图不同部位, 不会每块长得一样。"
        "★ ★ MC 1.21.5 的 rotation.angle 只有 -45/-22.5/0/22.5/45 五个合法值 —— "
        "写 22 或 38 会让**整份模型加载失败**(游戏里是一坨'紫黑方块')。2026-10-08 踩过。"
        "★ 原点用**各自中心**而不是(8,8,8): 角度上限收到 45 之后, 再绕公共原点转会把块甩出去、散架。"
        "★ MC 的元素 rotation 一次只能挂**一个轴**(多轴必须拆元素), 所以靠'不同块用不同轴+正负号'造不规则。"
        "★ 尺寸: 物品模型 [0,16] 以实体位置为中心 + 均匀 scale ⇒ 16 单位 = scale 那么多格; "
        "数据包侧 scale 1.4 ⇒ 陨石约 1.4 格。"
        "★ 落地炸开在数据包侧(meteor/rock_tick), 这里只管那块石头。"
    ),
    "ambientocclusion": False,
    "gui_light": "front",
    "textures": {"rock": "sweetdream:item/meteor_rock",
                 "particle": "sweetdream:item/meteor_rock"},
    "elements": [
        chunk("核",       [3.5, 3, 3.5],     [12.5, 12, 12.5],   'y', 22.5),
        chunk("左突块",   [0, 4.5, 4],       [5, 10, 10],        'x', 22.5),
        chunk("右突块",   [10, 2, 2],        [16, 7, 8],         'y', -45),
        chunk("顶块",     [4, 11, 5],        [11.5, 16.5, 11.5], 'z', 22.5),
        chunk("上碎块",   [10.5, 9, 9.5],    [15.5, 14, 15],     'x', -22.5),
        chunk("下碎块",   [1.5, 1, 8.5],     [7.5, 6, 14.5],     'z', -45),
        chunk("前突块",   [2.5, 6.5, 10.5],  [8.5, 12, 16],      'y', 45),
        chunk("后碎块",   [1, 8, 0.5],       [6.5, 13, 5.5],     'x', -45),
        chunk("侧小块",   [11.5, 11, 3],     [16, 15, 7.5],      'z', -22.5),
    ],
    "display": {
        "ground": {"rotation": [0, 0, 0], "translation": [0, 2, 0],
                   "scale": [0.25, 0.25, 0.25]},
        "gui": {"rotation": [30, 45, 0], "translation": [0, 0, 0],
                "scale": [0.3, 0.3, 0.3]},
    },
}

ITEMS = {
    "hand_animation_on_swap": False,
    "model": {"type": "minecraft:model", "model": "sweetdream:item/meteor_rock"},
}

(MDL / 'meteor_rock.json').write_text(
    json.dumps(MODEL, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
(ITM / 'meteor_rock.json').write_text(
    json.dumps(ITEMS, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
for f in ('textures/item/meteor_rock.png', 'models/item/meteor_rock.json',
          'items/meteor_rock.json'):
    p = NS / f
    print('  %8d  %s' % (p.stat().st_size, f))
