# -*- coding: utf-8 -*-
"""
生成「崩裂·裂缝」的资源包素材(幂等, 改数字重跑即可)。

产出(都在 sweetdream_rp/assets/sweetdream/ 下):
  textures/item/fissure.png   16x16  俯视裂缝: 透明底 + 6 条放射状裂纹(中心暖橙红 -> 末端暗红)
  models/item/fissure.json    横平面贴地(元素 y 8..9, 照 vortex/sea/tide), 只给 up/down 面
  items/fissure.json          item_model 分发(让 item_display 认得出 sweetdream:fissure)

★ 尺寸口径(锚点 = 暗海/漩涡): 物品模型 [0,16] 以实体位置为中心 ⇒ scale N ⇒ 平面直径 N 格。
  裂缝的伤害半径 = 3(fissure/field_tick 的 `distance=..3`) ⇒ 直径 6 ⇒ 数据包侧 scale 6.0f。
★ 留白: 贴图最外沿一圈完全透明(裂纹不顶到边), 平面边缘才不会出现"被裁平"的硬切面。
"""
import json
import math
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

SIZE = 16
CRACKS = 6


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


# ------------------------------------------------------------ 裂缝图案
def crack_px(size):
    """俯视裂缝: 透明底 + N 条从中心放射的裂纹(中心暖橙红 -> 末端暗红)。"""
    half = size / 2.0
    out = []
    for y in range(size):
        for x in range(size):
            cx = (x + 0.5) - half
            cy = (y + 0.5) - half
            r = math.hypot(cx, cy)
            if r > half - 0.3:
                out.append((0, 0, 0, 0))
                continue
            a = math.atan2(cy, cx)
            t = r / half                        # 0(中心) .. 1(边缘)
            # 到最近一条裂纹中线的横向弧距
            best = 9.0
            for k in range(CRACKS):
                base = 2.0 * math.pi * k / CRACKS
                wob = 0.55 * math.sin(t * 3.1 + k * 1.9)      # 让裂纹弯一点, 不要太规整
                da = ((a - base - wob + math.pi) % (2.0 * math.pi)) - math.pi
                best = min(best, abs(da) * r)
            w_core = 0.80 * (1.0 - t) + 0.30        # 裂纹芯半宽
            w_glow = 1.20 * (1.0 - t) + 0.55        # 外辉半宽
            if best <= w_core:
                k = 1.0 - t
                out.append((255, clamp(46 + 168 * k * k), clamp(28 + 64 * k),
                            clamp(220 + 35 * k)))
            elif best <= w_glow:
                k = (w_glow - best) / max(w_glow - w_core, 1e-6)
                out.append((132, 26, 20, clamp(130 * k * (0.45 + 0.55 * (1.0 - t)))))
            else:
                out.append((0, 0, 0, 0))
    return png(size, size, out)


# ------------------------------------------------------------ 模型 / 分发
MODEL = {
    "credit": (
        "崩裂·裂缝(横平面贴地, 照 vortex/sea/tide 的 y 8..9 做法)。俯视贴图, 只给 up/down 两面。"
        "★ 尺寸口径: 物品模型 [0,16] 以实体位置为中心 ⇒ scale N ⇒ 平面直径 N 格; "
        "数据包侧 scale 6.0f = 直径 6 = 伤害半径 3。"
    ),
    "ambientocclusion": False,
    "gui_light": "front",
    "textures": {"tex": "sweetdream:item/fissure",
                 "particle": "sweetdream:item/fissure"},
    "elements": [
        {"name": "裂缝", "from": [0, 8.0, 0], "to": [16, 9.0, 16],
         "faces": {"up": {"texture": "#tex", "uv": [0, 0, 16, 16]},
                   "down": {"texture": "#tex", "uv": [0, 0, 16, 16]}}},
    ],
}

ITEMS = {
    "hand_animation_on_swap": False,
    "model": {"type": "minecraft:model", "model": "sweetdream:item/fissure"},
}


def main():
    (TEX / 'fissure.png').write_bytes(crack_px(SIZE))
    (MDL / 'fissure.json').write_text(
        json.dumps(MODEL, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    (ITM / 'fissure.json').write_text(
        json.dumps(ITEMS, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
    for f in ('textures/item/fissure.png', 'models/item/fissure.json',
              'items/fissure.json'):
        p = NS / f
        print('  %8d  %s' % (p.stat().st_size, f))


if __name__ == '__main__':
    main()
