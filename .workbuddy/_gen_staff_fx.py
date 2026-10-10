# -*- coding: utf-8 -*-
"""
生成两件法杖特效的 item_display 素材（2026-10-08 用户要求）:

  ① 调色盘「色彩」—— 可见的小光球（三色）
     用户: "主动技能没有召唤召唤物" —— 原来“色彩”只是一个 marker(完全隐形),
     玩家只看到几颗 dust, 观感上就是"什么都没召唤出来"。
     ⇒ 换成 item_display + billboard:"center" 的小光球 sprite, 按色码挑贴图。
     产出: textures/item/pal_orb_{r,y,b,w}.png  32x32   软光晕小球(w=两槽皆空的中性色)
           models/item/pal_orb_{r,y,b,w}.json  竖平面(朝向摄像机)
           items/pal_orb_{r,y,b,w}.json        单项模型定义

  ② 海棠「漩涡」—— 蓝色旋转漩涡贴图（**不能和暗潮/暗海撞**）
     用户: "把漩涡替换为display贴图…我希望是一个蓝色的漩涡, 具体看你"。
     暗潮 = 青白波纹圆盘 / 暗海 = 墨黑蓝湖泊 —— 这一版走**螺旋臂**路线:
     3 条亮蓝臂 + 同心涟漪 + 亮核, 16→24 帧整体旋转一圈(无缝循环)。
     产出: textures/item/vortex.png + .png.mcmeta   64x(64*24)  24 帧动画
           models/item/vortex.json                 横平面(贴地)
           items/vortex.json                       单项模型定义

★ 尺寸约定（照 _gen_sea.py，别乱改）
  · 模型是 [0,16] 的物品空间，整张贴图铺满 16x16 的 UV。
  · item_display 的物品模型 [0,16] 以实体位置为中心 ⇒ 平面直径 = scale 格。
    漩涡 scale 8 ⇒ 直径 8 格 = **半径 4**(技能文案「4 格内的全部生物」; 伤害核半径 2 只在中心一小圈)。
      ★ 2026-10-08 修正: 原写 scale 5(直径 5=半径 2.5) 被用户指出"完全不符合半径4格", 已改 8。
      ★ 实际 scale 写在 begonia/vortex_make.mcfunction 的 summon 里, 这里只是口径备忘。
    光球 scale 0.6 ⇒ 直径 0.6 格。
  · 横平面 y 取 8..9（照暗海/暗潮），召唤时 translation y +0.02 抬离地面防闪面。
★ 幂等：同参数重跑永远出同一批图。
★ 预览：python .workbuddy/_gen_staff_fx.py --preview  → logs/staff_fx_preview.png
"""
import json, math, struct, sys, zlib
from pathlib import Path

ROOT = Path(r'D:/数据包/sweetdream_rp')
NS = ROOT / 'assets' / 'sweetdream'
TEX = NS / 'textures' / 'item'
MDL = NS / 'models' / 'item'
ITM = NS / 'items'
LOG = Path(r'D:/数据包/logs')
for d in (TEX, MDL, ITM, LOG):
    d.mkdir(parents=True, exist_ok=True)

TAU = math.pi * 2.0


# ---------------------------------------------------------------- PNG 编码
def png(w, h, px):
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            raw.extend(px[y * w + x])

    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    hdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', hdr)
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def clamp(v, a=0, b=255):
    return a if v < a else (b if v > b else int(v))


def lerp(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


# ★ 1.21.5 物品渲染 = **cutout**(RULES §48): 贴图 alpha < 0.1 的像素整个丢弃,
#   0<a<1 的半透明会被**切成不透明** ⇒ 直接用渐隐 alpha 会渲染成一块硬边实心饼。
#   想要"柔光边"只能: 二值 alpha + **Bayer 4x4 有序抖动** 近似(远看 = 渐隐)。
BAYER4 = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))


def dith(a, x, y):
    """把目标 alpha a(0..255) 用 4x4 抖动二值化成 0 / 255。"""
    thr = (BAYER4[y & 3][x & 3] + 0.5) * 16.0
    return 255 if a > thr else 0


# ---------------------------------------------------------------- ① 色彩 光球
ORBS = {
    'r': ('红', (236,  74,  62), (255, 236, 226)),
    'y': ('黄', (242, 200,  58), (255, 252, 214)),
    'b': ('蓝', ( 84, 150, 246), (224, 242, 255)),
    'w': ('白', (196, 208, 234), (255, 255, 255)),   # 两槽皆空 = 没颜色时的中性色
}


def gen_orb(base, bright, size=32):
    """中心亮核 + 软光晕的小光球(圆形 alpha 裁边)。"""
    c = (size - 1) / 2.0
    R = size / 2.0
    px = []
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / R
            if d > 1.0:
                px.append((0, 0, 0, 0))
                continue
            alpha = 255.0 * ((1.0 - d) ** 0.55)          # 核心实、边缘虚
            cw = max(0.0, 1.0 - d * 2.4)                 # 中心偏白
            col = lerp(base, bright, cw)
            e = 1.0 - 0.45 * max(0.0, (d - 0.5) / 0.5)   # 外圈压暗 -> 体积感
            px.append((clamp(col[0] * e), clamp(col[1] * e), clamp(col[2] * e),
                       dith(alpha, x, y)))
    return png(size, size, px)


# ---------------------------------------------------------------- ② 漩涡
DARK = ( 10,  34,  74)
MID  = ( 38, 112, 192)
HI   = (152, 222, 255)
CORE = (234, 249, 255)


def vortex_frame(size, f, frames=24, arms=3):
    """单帧(顶视图): 3 条实心螺旋臂收敛向中心 + 亮核; 臂间透明。
    · 螺旋: `sin(arms*ang + 4.4*r - ph)` —— 半径越大相位越偏 -> 视觉上是**向内卷**的涡。
    · 臂**实心**(cover≈1) + 边缘硬边, 只在最外 16% 半径上做抖动柔化;
      臂间留透明 => 贴地看就是一块"蓝色涡旋"贴花, 不与暗潮(波纹圆盘)/暗海(湖泊)撞。
    · 每帧 ph 递增 1/frames 圈, 首尾无缝(24 帧转一圈)。"""
    c = (size - 1) / 2.0
    R = size / 2.0
    ph = f / frames * TAU
    px = []
    for y in range(size):
        for x in range(size):
            dx, dy = x - c, y - c
            r = math.hypot(dx, dy) / R
            if r > 1.0:
                px.append((0, 0, 0, 0))
                continue
            ang = math.atan2(dy, dx)
            s = math.sin(arms * ang + 4.4 * r - ph)
            arm = max(0.0, s) ** 0.62                 # 0..1, 越靠臂心越粗亮
            tex = 0.5 + 0.5 * math.sin(r * 26.0 - ph * 3.0 + ang * 2.0)  # 臂上细纹
            ring = 0.5 + 0.5 * math.sin(r * 12.0 - ph * 2.0)             # 同心涟漪
            corew = max(0.0, 1.0 - r * 3.0)           # 中心亮核
            rim = 1.0 if r < 0.84 else max(0.0, (1.0 - r) / 0.16)
            cover = min(1.0, (arm * 1.06 + corew * 1.30) * 1.32) * rim
            if cover <= 0.0:
                px.append((0, 0, 0, 0))
                continue
            t = min(1.0, (min(1.0, arm * 0.86 + 0.14 * ring)) * 0.84 + 0.16 * tex)
            col = lerp(DARK, MID, t / 0.5) if t < 0.5 else lerp(MID, HI, (t - 0.5) / 0.5)
            col = lerp(col, CORE, corew)
            px.append((clamp(col[0]), clamp(col[1]), clamp(col[2]),
                       dith(cover * 255.0, x, y)))
    return px


def gen_vortex(size=64, frames=24, arms=3):
    """24 帧竖条(每帧一块 size×size)。"""
    out = []
    for f in range(frames):
        out.extend(vortex_frame(size, f, frames, arms))
    return png(size, size * frames, out)


# ---------------------------------------------------------------- 模型
DISPLAY = {'ground': {'rotation': [0, 0, 0], 'translation': [0, 2, 0], 'scale': [0.25, 0.25, 0.25]},
           'gui': {'rotation': [30, 45, 0], 'translation': [0, 0, 0], 'scale': [0.3, 0.3, 0.3]}}


def model_flat_h(name, credit, tex, y0=8.0, y1=9.0, faces=('up', 'down')):
    """横平面(贴地, 照暗海/暗潮)。"""
    return {'credit': credit, 'ambientocclusion': False, 'gui_light': 'front',
            'textures': {'tex': tex, 'particle': tex},
            'elements': [{'name': name, 'from': [0, y0, 0], 'to': [16, y1, 16],
                          'faces': {f: {'texture': '#tex', 'uv': [0, 0, 16, 16]} for f in faces}}],
            'display': DISPLAY}


def model_billboard(name, credit, tex):
    """竖平面(配 entity 的 billboard:"center" 用 —— 永远正对摄像机)。"""
    return {'credit': credit, 'ambientocclusion': False, 'gui_light': 'front',
            'textures': {'tex': tex, 'particle': tex},
            'elements': [{'name': name, 'from': [0, 0, 7.5], 'to': [16, 16, 8.5],
                          'faces': {'north': {'texture': '#tex', 'uv': [0, 0, 16, 16]},
                                    'south': {'texture': '#tex', 'uv': [0, 0, 16, 16]}}}],
            'display': DISPLAY}


def write_item_def(name, model):
    (ITM / ('%s.json' % name)).write_text(
        json.dumps({'hand_animation_on_swap': False,
                    'model': {'type': 'minecraft:model', 'model': model}},
                   ensure_ascii=False, indent=1), encoding='utf-8')


def write_model(name, obj):
    (MDL / ('%s.json' % name)).write_text(json.dumps(obj, ensure_ascii=False, indent=1),
                                          encoding='utf-8')


# ---------------------------------------------------------------- 预览
def preview():
    """把 3 个光球 + 漩涡的 6 帧拼成一张大图, 方便肉眼看效果。"""
    import io
    # 简单起见: 直接读回生成的 PNG 里我们自己的像素数据(重新算一遍)
    tiles = []          # (w,h,px)
    for k in ('r', 'y', 'b', 'w'):
        _, base, bright = ORBS[k]
        # 用 32x32 的光球放大 3 倍当预览
        sz = 32
        c = (sz - 1) / 2.0
        R = sz / 2.0
        px = []
        for y in range(sz):
            for x in range(sz):
                d = math.hypot(x - c, y - c) / R
                if d > 1.0:
                    px.append((0, 0, 0, 0))
                    continue
                alpha = 255.0 * ((1.0 - d) ** 0.55)
                cw = max(0.0, 1.0 - d * 2.4)
                col = lerp(base, bright, cw)
                e = 1.0 - 0.45 * max(0.0, (d - 0.5) / 0.5)
                px.append((clamp(col[0] * e), clamp(col[1] * e), clamp(col[2] * e),
                           dith(alpha, x, y)))
        tiles.append((sz, sz, px))
    # 漩涡取 6 个均匀帧
    sz, frames = 64, 24
    for f in (0, 4, 8, 12, 16, 20):
        tiles.append((sz, sz, vortex_frame(sz, f, frames)))

    # 排布: 3 光球一列 + 6 漩涡 3x2 —— 统一放大 4 倍, 底色深灰
    SC = 4
    cols = 6
    cellw = max(t[0] for t in tiles) * SC
    rows = 3
    cellh = max(t[1] for t in tiles) * SC
    W, H = cols * cellw, rows * cellh
    bg = (26, 26, 32)
    canvas = [[(bg[0], bg[1], bg[2], 255) for _ in range(W)] for _ in range(H)]
    for i, (w, h, px) in enumerate(tiles):
        cx, cy = i % cols, i // cols
        ox, oy = cx * cellw + (cellw - w * SC) // 2, cy * cellh + (cellh - h * SC) // 2
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[y * w + x]
                if a == 0:
                    continue
                for sy in range(SC):
                    for sx in range(SC):
                        yy, xx = oy + y * SC + sy, ox + x * SC + sx
                        if 0 <= yy < H and 0 <= xx < W:
                            canvas[yy][xx] = (r, g, b, 255)
    flat = []
    for row in canvas:
        flat.extend(row)
    (LOG / 'staff_fx_preview.png').write_bytes(png(W, H, flat))
    print('preview ->', LOG / 'staff_fx_preview.png', '%dx%d' % (W, H))


# ---------------------------------------------------------------- main
def main():
    made = []
    for k, (cn, base, bright) in ORBS.items():
        tex = 'sweetdream:item/pal_orb_%s' % k
        (TEX / ('pal_orb_%s.png' % k)).write_bytes(gen_orb(base, bright))
        write_model('pal_orb_%s' % k,
                    model_billboard('色彩光点%s' % cn,
                                    '调色盘「色彩」光点(%s) —— 面朝摄像机的小光球' % cn, tex))
        write_item_def('pal_orb_%s' % k, tex)
        made.append((16 + 96, 'pal_orb_%s' % k))

    (TEX / 'vortex.png').write_bytes(gen_vortex())
    (TEX / 'vortex.png.mcmeta').write_text(
        '{"animation":{"width":64,"height":64,"frametime":2}}\n', encoding='utf-8')
    write_model('vortex', model_flat_h('海棠漩涡', '海棠·漩涡(24 帧旋转蓝色螺旋)', 'sweetdream:item/vortex'))
    write_item_def('vortex', 'sweetdream:item/vortex')

    print('--- 产出 ---')
    for p in sorted(list(TEX.glob('pal_orb_*.png')) + list(TEX.glob('vortex.png*'))
                    + list(MDL.glob('pal_orb_*.json')) + [MDL / 'vortex.json']
                    + list(ITM.glob('pal_orb_*.json')) + [ITM / 'vortex.json']):
        print('  %8d  %s' % (p.stat().st_size, p.as_posix().replace(str(ROOT.parent) + '/', '')))


if __name__ == '__main__':
    if '--preview' in sys.argv:
        preview()
    else:
        main()
