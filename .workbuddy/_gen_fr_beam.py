# -*- coding: utf-8 -*-
"""
生成「终末天启·实体光柱」的资源包素材(幂等, 改数字重跑即可)。

产出(都在 sweetdream_rp/assets/sweetdream/ 下):
  textures/item/fr_beam_glow.png   16x16  外辉: 暖白, 四边渐隐 (alpha 中心 0.72)
  textures/item/fr_beam_core.png   16x16  亮核: 纯白, 四边渐隐 (alpha 中心 1.00)
  models/item/fr_beam.json         四片**正交薄片**(外辉 16px 宽 / 亮核 6px 宽), 沿 model Z 铺

------------------------------------------------------------
★ 用户口径(2026-10-08): "把天使核心那个光柱也搞到终末天启里" ——
  即"同款质感": 十字正交薄片(没有实心体积、没有直角棱) + "中间实心亮芯 / 快速渐隐"
  的软边贴图。和 `.workbuddy/_gen_angel_beam.py` 是同一套做法, 只是**方向不同**:
  天使核心是**竖直**柱子(薄片法线 ±X / ±Z, 沿 Y 铺), 这里是**水平**光束
  (薄片法线 ±X / **±Y**, 沿 Z 铺)。
------------------------------------------------------------
★ 为什么"正交薄片"而不是原来那根 12×12 的方条
  方条有 4 条直角棱: 任何角度都能看到"盒子的边", 观感是根塑料棍(用户 2026-10-07
  就说过"太丑了")。薄片只有两个大面, 不渲染的面 = 透明 ⇒ 任何角度看都只是 1~2 张
  **平面**, 没有棱、没有体积感。
  水平光束要两张片的原因: 只留竖直片的话, **从上方/玩家自己视角看是一条线**(片是侧着的);
  再补一张**水平**片, 从上往下看才是完整的一条光带。
★ 为什么贴图必须是**四边对称**的
  两个薄片的大面 uv 轴不一样:
  · 水平片(up/down 面): u = 宽度(x), v = 长度(z);
  · 竖直片(east/west 面): u = 长度(z), v = 宽度(y)。
  一张贴图要给"长度轴"和"宽度轴"都吃到同一条曲线, 只能让图案**转置对称**
  (四边都渐隐), 这样两个轴吃同一条曲线, 结果都对。
★ 为什么元素沿 z 铺 0..16 且亮核短一截
  数据包侧 `scale [1,1,16]` 把 16px 拉成 16 格; 模型以实体位置为中心 ⇒ 前后各 8 格。
  亮核铺 2..14、外辉铺 0..16 —— 亮核比外辉短, 两端才有"芯先没、光环还在"的层次。
  ★ 改 from/to 的 z 跨度会破坏"以实体为中心"的对齐(光柱会从半截处开始)。
★ 曲线口径抄 _gen_angel_beam.py 的 SIDE_GLOW / SIDE_CORE(那边已实装、观感过关):
  横向 5px 内从 1.0 收到 0(快速渐隐, 不留"塑料边"), 中心满值。
------------------------------------------------------------
★ 光柱的显示参数在数据包侧(不是这里):
  transformation.scale = [1,1,16]; 生成点 = 眼睛下 0.45、视线前方 8 格。
"""
import json
import struct
import zlib
from pathlib import Path

ROOT = Path(r'D:/数据包/sweetdream_rp')
NS = ROOT / 'assets' / 'sweetdream'
TEX = NS / 'textures' / 'item'
MDL = NS / 'models' / 'item'
for d in (TEX, MDL):
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


# ------------------------------------------------------------ 渐隐曲线
def soft(d, table):
    """d = 到最近边缘的距离(0..7); table 给前几档, 再往外是 1.0。"""
    return table[d] if d < len(table) else 1.0


# 抄天使核心的横向曲线(那边的"快速渐隐 + 中心满值"已经过用户验收)
EDGE_GLOW = (0.00, 0.08, 0.24, 0.50, 0.78, 1.00)   # 外辉: 5px 内收到透明
EDGE_CORE = (0.00, 0.20, 0.55, 0.85, 1.00)         # 亮核: 更窄更硬


def gen(size, rgb, base_alpha, table):
    """四边对称的软边色块: alpha = f(x)·f(y)·base。★ 四边对称 = 转置不变 ⇒
    水平片与竖直片(uv 互相转置)吃到的曲线是一样的。"""
    px = []
    for y in range(size):
        dy = min(y, size - 1 - y)
        for x in range(size):
            dx = min(x, size - 1 - x)
            a = soft(dx, table) * soft(dy, table) * base_alpha
            px.append((rgb[0], rgb[1], rgb[2], clamp(round(a * 255))))
    return png(size, size, px)


GLOW = gen(16, (255, 250, 232), 0.72, EDGE_GLOW)    # 暖白外辉
CORE = gen(16, (255, 255, 255), 1.00, EDGE_CORE)    # 纯白亮核


# ------------------------------------------------------------ 模型
def plane(tex, fnames, name, frm, to):
    return {"name": name, "from": frm, "to": to,
            "faces": {f: {"texture": tex, "uv": [0, 0, 16, 16]} for f in fnames}}


def h_plane(tex, name, half_t, frm_z=0, to_z=16, half_w=8):
    """法线朝 ±Y 的**水平**薄片(半厚 half_t, 沿 Z 铺 = 长度, 沿 X 铺 = half_w 是半宽),
    只渲染 up/down 两个大面。★ 它的 uv: u = x(宽), v = z(长)。"""
    return plane(tex, ('up', 'down'), name,
                 [8 - half_w, 8 - half_t, frm_z], [8 + half_w, 8 + half_t, to_z])


def v_plane(tex, name, half_t, frm_z=0, to_z=16, half_h=8):
    """法线朝 ±X 的**竖直**薄片(半厚 half_t, 沿 Z 铺 = 长度, 沿 Y 铺 = half_h 是半高),
    只渲染 east/west 两个大面。★ 它的 uv: u = z(长), v = y(宽)。"""
    return plane(tex, ('east', 'west'), name,
                 [8 - half_t, 8 - half_h, frm_z], [8 + half_t, 8 + half_h, to_z])


MODEL = {
    "credit": (
        "终末天启·实体光柱(以撒风)。★ 2026-10-08 二改(用户: '把天使核心那个光柱也搞到"
        "终末天启里' = 同款质感): 原来是两根**方条**(外辉 12×12 / 亮核 6×6), 四条直角棱"
        "一眼就是塑料棍; 现在换成**四片正交薄片** —— 不渲染的面就是透明的, 任何角度看过去"
        "都只有 1~2 张平面, 没有棱、没有体积。水平方向必须**两张**(竖直 + 水平), 否则从上方"
        "看那条光束只是根线。"
        "元素沿 model Z 铺 0..16px = 1 格, 由 beam_new 的 scale [1,1,16] 拉成 16 格长条; "
        "模型在 display 上以实体位置为中心 ⇒ 前后各 8 格, 生成点定在'眼睛下方 0.45、前方 8 格'。"
        "★ 别改 from/to 的 z 跨度(改了'中心对齐'就破, 光柱会从半截处开始); "
        "★ 贴图必须是**四边对称**的软边图(见 _gen_fr_beam.py): 水平片与竖直片的 uv 互相转置, "
        "只有转置对称的图案才能让两个轴吃到同一条曲线。"
    ),
    "ambientocclusion": False,
    "gui_light": "front",
    "textures": {
        "glow": "sweetdream:item/fr_beam_glow",
        "core": "sweetdream:item/fr_beam_core",
        "particle": "sweetdream:item/fr_beam_glow",
    },
    "elements": [
        h_plane("#glow", "外辉_横(法线±Y, 从上方才看得见)", 0.5),
        v_plane("#glow", "外辉_竖(法线±X)", 0.5),
        h_plane("#core", "亮核_横(法线±Y, 比外辉短一截)", 0.3,
                frm_z=2, to_z=14, half_w=3),
        v_plane("#core", "亮核_竖(法线±X, 比外辉短一截)", 0.3,
                frm_z=2, to_z=14, half_h=3),
    ],
}


def main():
    (TEX / 'fr_beam_glow.png').write_bytes(GLOW)
    (TEX / 'fr_beam_core.png').write_bytes(CORE)
    (MDL / 'fr_beam.json').write_text(
        json.dumps(MODEL, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    for f in ('textures/item/fr_beam_glow.png',
              'textures/item/fr_beam_core.png',
              'models/item/fr_beam.json'):
        p = NS / f
        print('  %8d  %s' % (p.stat().st_size, f))


if __name__ == '__main__':
    main()
