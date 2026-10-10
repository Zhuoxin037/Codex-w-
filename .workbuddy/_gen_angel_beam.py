# -*- coding: utf-8 -*-
"""
生成「天使核心·圣光柱」的资源包素材(幂等, 改数字重跑即可)。

产出(都在 sweetdream_rp/assets/sweetdream/ 下):
  textures/item/angel_glow.png   16x16  外辉: 暖白, 横向中间亮两侧渐隐 + 纵向下实上散
  textures/item/angel_core.png   16x16  亮核: 纯白, 同曲线但更硬更亮
  models/item/angel_beam.json    十字交叉薄片(竖直) —— 外辉 2 片 + 亮核 2 片
  items/angel_beam.json          item_model 分发(让 item_display 认得出 sweetdream:angel_beam)

------------------------------------------------------------
★ 为什么本版推翻了第一版(v1 = 12x16x12 方柱, 用户: "特别丑, 像一个很短的水管")
  v1 是等宽**方柱**, 六面全贴同一张 16x16。方柱有四条直角棱, 不管贴图怎么渐隐,
  轮廓线上都还是一条条**直线** ⇒ 一眼就是"管子"。而且 v1 直接复用了 fr_beam 的
  **四边对称**渐变图, 那图纵向两端都会淡 ⇒ 柱子"两头敞开、浮在空中", 更像悬空水管。
  本版三处改动:
    ① 几何: 方柱 → **两片正交薄片**(法线朝 ±X / ±Z)。从任何水平角度都只看到
       1~2 张**平面**, 没有实心体积感和直角棱 —— 这是 MC 里光柱/光束的标准做法。
    ② 贴图: 纵向改成"**底边不透明、往上渐隐**" ⇒ 柱子从地面实起、顶端自然消散。
    ③ 尺寸: 数据包侧 scale 4 → 6(高 4 格 → 6 格), 解决"很短"。
★ 为什么横向要"中间亮、两侧透明"
  薄片的左右边缘是直线; 让 alpha 在两侧收到 0, 边缘就"化开"成光带,
  否则会看见两条笔直的硬边(又会像板子)。
★ 贴图坐标方向(别搞反)
  竖直面的 uv 的 v 轴总是指向"下": uv[1] 对应面的**上**边缘。贴图 y=0 是图片顶行。
  ⇒ 贴图 y=0(顶行) 给 alpha=0(柱顶消散), y=15(底行) 给满(接地)。
★ 尺寸口径: 物品模型 [0,16] 以实体位置为中心 ⇒ 竖直 scale N ⇒ 高 N 格、上下各占一半;
  所以数据包侧的生成点要抬到"柱底 + N/2"(见 angel_core/beam, N=6 ⇒ 抬 3 格)。
★ 贴图**不复用** fr_beam_glow / fr_beam_core —— 那是给"水平光条"的四边对称图,
  纵向曲线对本柱是错的(会让柱子浮空)。本脚本自带两张专用图。
------------------------------------------------------------
"""
import json
import struct
import zlib
from pathlib import Path

ROOT = Path(r'D:/数据包/sweetdream_rp')
NS = ROOT / 'assets' / 'sweetdream'
TEX = NS / 'textures' / 'item'
MDL = NS / 'models' / 'item'
ITM = NS / 'items'
for d in (TEX, MDL, ITM):
    d.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------- PNG 编码
def png(w, h, px):
    """px: 长度 w*h 的 [(r,g,b,a), ...]"""
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(px[y * w + x])

    def chunk(t, d):
        return (struct.pack('>I', len(d)) + t + d
                + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff))
    hdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', hdr)
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def clamp(v, a=0, b=255):
    return a if v < a else (b if v > b else int(v))


def soft(d, table):
    """d = 到最近边缘的距离(以 px); table 给 0/1/2/3 档, 再往外是 1.0。"""
    return table[d] if d < len(table) else 1.0


# 横向(到左右最近边的距离, px)渐隐曲线 —— 让薄片的左右硬边化开。
# ★ v2 教训: v1 只渐隐 3px、base 0.62 ⇒ 中心 alpha 仅 158/255(62%) ⇒ 整根柱子是
#   "半透明玻璃管", 用户还是不满意。v2 把**中心做成实心亮芯**(dx>=5 即满值)、
#   两侧在 5px 内快速收到 0 ⇒ 中间一条实心光带 + 两侧虚化。
SIDE_GLOW = (0.00, 0.08, 0.24, 0.50, 0.78, 1.00)    # 外辉: 5px 内收到透明
SIDE_CORE = (0.00, 0.20, 0.55, 0.85, 1.00)          # 亮核: 更窄更硬

# 纵向(贴图行号, 0 = 柱顶)曲线 —— 底实上散。索引 = 行号, 超出取最后一个。
VERT_GLOW = (0.00, 0.28, 0.55, 0.76, 0.90, 0.97, 1.00)
VERT_CORE = (0.00, 0.20, 0.42, 0.64, 0.82, 0.93, 1.00)


def vmask(y, table):
    return table[y] if y < len(table) else table[-1]


def gen(size, rgb, base_alpha, side, vert):
    """横向对称渐隐 · 纵向下实上散 的软边色块"""
    px = []
    for y in range(size):
        vy = vmask(y, vert)
        for x in range(size):
            dx = min(x, size - 1 - x)
            a = soft(dx, side) * vy * base_alpha
            px.append((rgb[0], rgb[1], rgb[2], clamp(round(a * 255))))
    return png(size, size, px)


GLOW = gen(16, (255, 249, 230), 0.62, SIDE_GLOW, VERT_GLOW)   # 暖白外辉
CORE = gen(16, (255, 255, 255), 1.00, SIDE_CORE, VERT_CORE)   # 纯白亮核


# ------------------------------------------------------------ 模型
def plane(tex, faces, name, frm, to):
    return {"name": name, "from": frm, "to": to,
            "faces": {f: {"texture": tex, "uv": [0, 0, 16, 16]} for f in faces}}


def x_plane(tex, name, half_w, frm_y=0, to_y=16):
    """法线朝 ±X 的薄片(厚 2px, 沿 Z 铺 = 宽度), 只渲染 east/west 两个大面。"""
    return plane(tex, ('east', 'west'), name,
                 [8 - 1, frm_y, 8 - half_w], [8 + 1, to_y, 8 + half_w])


def z_plane(tex, name, half_w, frm_y=0, to_y=16):
    """法线朝 ±Z 的薄片(厚 2px, 沿 X 铺 = 宽度), 只渲染 north/south 两个大面。"""
    return plane(tex, ('north', 'south'), name,
                 [8 - half_w, frm_y, 8 - 1], [8 + half_w, to_y, 8 + 1])


MODEL = {
    "credit": (
        "天使核心·圣光柱(十字交叉薄片: 两片正交的竖直光带, 外辉 16px 宽 + 亮核 7px 宽)。"
        "★ 只有 north/south 与 east/west 四个大面被渲染 —— 这是刻意的: 不渲染的面就是透明的, "
        "所以整根柱子没有实心体积感, 从任意水平角度看都是 1~2 张平面(光柱而非'方管')。"
        "★ 贴图纵向必须'底实上散'(见 _gen_angel_beam.py), 换成四边对称的 fr_beam 图会让柱子两头敞开、浮在空中。"
        "★ 尺寸口径: 物品模型 [0,16] 以实体位置为中心 ⇒ 数据包侧 scale [1,6,1] ⇒ 高 6 格、上下各 3 格; "
        "生成点抬 3 格让柱底正好贴地(见 angel_core/beam)。"
    ),
    "ambientocclusion": False,
    "gui_light": "front",
    "textures": {"glow": "sweetdream:item/angel_glow",
                 "core": "sweetdream:item/angel_core",
                 "particle": "sweetdream:item/angel_glow"},
    "elements": [
        x_plane("#glow", "外辉_A(法线±X)", 8),
        z_plane("#glow", "外辉_B(法线±Z)", 8),
        x_plane("#core", "亮核_A(法线±X)", 3.5),
        z_plane("#core", "亮核_B(法线±Z)", 3.5),
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
    "model": {"type": "minecraft:model", "model": "sweetdream:item/angel_beam"},
}


def main():
    (TEX / 'angel_glow.png').write_bytes(GLOW)
    (TEX / 'angel_core.png').write_bytes(CORE)
    (MDL / 'angel_beam.json').write_text(
        json.dumps(MODEL, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    (ITM / 'angel_beam.json').write_text(
        json.dumps(ITEMS, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    for f in ('textures/item/angel_glow.png', 'textures/item/angel_core.png',
              'models/item/angel_beam.json', 'items/angel_beam.json'):
        p = NS / f
        print('  %8d  %s' % (p.stat().st_size, f))


if __name__ == '__main__':
    main()
