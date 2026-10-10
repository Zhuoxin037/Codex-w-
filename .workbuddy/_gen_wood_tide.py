# -*- coding: utf-8 -*-
"""
生成「枯枝园·朽木」与「无光海·暗潮」的资源包素材。

产出（都在 sweetdream_rp/assets/sweetdream/ 下）:
  textures/item/withered_wood.png   64x64   枯木树皮 + 菌菇/苔藓/焦黑色块
  textures/item/tide_deep.png       64x64   暗潮底层: 深暗海水(圆形 alpha 裁边)
  textures/item/tide_ripple.png     64x1024 暗潮波纹层: 16 帧动画(透明底 + 亮波纹)
  textures/item/tide_ripple.png.mcmeta
  models/item/withered_wood.json    枯木模型(立方体堆出来的枯树立姿)
  models/item/tide_deep.json        暗潮底平面
  models/item/tide_ripple.json      暗潮波纹平面(悬在底层上方一点)
  items/withered_wood.json          物品模型定义
  items/tide.json                   物品模型定义(composite 两层)

★ 约定(和包里现有模型一致)
  · 模型坐标是 [0,16] 的"物品空间", 1 单位 = 1/16 格, 元素取值必须在 [-16,32]。
  · UV 单位 0..16 = **整张贴图**(和贴图分辨率无关), 所以 64x64 的贴图里
    1 个 UV 单位 = 4 像素。把贴图切成 4x4 的 16 个 16x16 色块来当"调色板"。
  · 不用 parent, textures 用具名键, ambientocclusion:false + gui_light:"front"。
"""
import json, math, random, struct, zlib
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
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    hdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', hdr)
            + chunk(b'IDAT', zlib.compress(bytes(raw), 9)) + chunk(b'IEND', b''))


def clamp(v, a=0, b=255):
    return a if v < a else (b if v > b else int(v))


# ================================================================ 枯木贴图
def gen_withered_wood(size=64):
    rnd = random.Random(20261005)
    px = []
    # 树皮基色: 深灰褐 -> 随高度(贴图的 y)略微变冷
    base = (0x46, 0x3a, 0x2d)
    for y in range(size):
        for x in range(size):
            # 纵向裂纹: 用几个不同频率的正弦叠噪声, 沿 x 方向形成竖条
            n = 0.0
            n += math.sin(x * 0.55 + math.sin(y * 0.21) * 2.2) * 0.5
            n += math.sin(x * 1.70 + math.sin(y * 0.09 + 2.0) * 3.1) * 0.28
            n += rnd.uniform(-0.35, 0.35)
            k = 0.55 + 0.45 * (n * 0.5 + 0.5)
            # 越靠上(贴图 y 小 = 模型 y 大? 无所谓) 稍微偏冷灰
            cool = 1.0 - y / size * 0.18
            r = clamp(base[0] * k * cool + (1 - cool) * 40)
            g = clamp(base[1] * k * cool + (1 - cool) * 44)
            b = clamp(base[2] * k * cool + (1 - cool) * 50)
            # 零星苔藓(暗绿)斑块
            if (x % 17 == (y // 3) % 17) and ((x * 7 + y * 13) % 23 < 4):
                r, g, b = 0x39, 0x47, 0x28
            px.append((r, g, b, 255))
    # ---- 右下 16x16 的"调色板"色块(UV 12..16 区间) ----
    #   注意: UV v=0 对应贴图顶部, 所以 [v0,v1] = [0,4] 是贴图最上面那格
    def block(u0, v0, col):
        """u0,v0 是 UV 单位(0..16), 每格 4 像素"""
        for j in range(v0 * 4, v0 * 4 + 16):
            for i in range(u0 * 4, u0 * 4 + 16):
                px[j * size + i] = col
    block(12, 0, (0x4a, 0x33, 0x50, 255))   # 紫菌菇
    block(12, 4, (0x3c, 0x4a, 0x2c, 255))   # 暗绿苔藓
    block(12, 8, (0x1d, 0x17, 0x13, 255))   # 焦黑(断口)
    block(12, 12, (0x54, 0x46, 0x38, 255))  # 枝梢(浅枯木)
    return png(size, size, px)


# ================================================================ 暗潮底层
def gen_tide_deep(size=64):
    """深暗海水: 径向渐变 + 漩涡暗纹, 圆形 alpha 裁边(二值, cutout 友好)"""
    rnd = random.Random(7788)
    c = (size - 1) / 2.0
    px = []
    for y in range(size):
        for x in range(size):
            dx, dy = x - c, y - c
            r = math.hypot(dx, dy) / c                       # 0..~1.41
            ang = math.atan2(dy, dx)
            # 漩涡: 角度随半径扭, 再叠正弦做暗纹
            swirl = math.sin(ang * 3.0 + r * 7.5)
            wave = math.sin(r * 16.0 - swirl * 1.2)
            # 中心亮一点(深青), 边缘沉进黑蓝
            t = max(0.0, 1.0 - r)
            base_r = 10 + 26 * t + 9 * (wave * 0.5 + 0.5)
            base_g = 22 + 58 * t + 12 * (wave * 0.5 + 0.5)
            base_b = 38 + 74 * t + 16 * (swirl * 0.5 + 0.5)
            base_r += rnd.uniform(-5, 5)
            base_g += rnd.uniform(-6, 6)
            base_b += rnd.uniform(-6, 6)
            # alpha: 半径 ~0.86 以内不透明, 之外按波纹锯齿轮廓裁掉
            # ★ 2026-10-06 晚: 用户要"像现实里正常的湖泊" —— 原来 9 瓣 ±0.09 + 21 瓣 ±0.03
            #   在 8 格的海面上看是**一圈棱角**; 现在改成 5 瓣 ±0.045 + 13 瓣 ±0.015 的缓岸。
            edge = 0.86 + 0.045 * math.sin(ang * 5.0) + 0.015 * math.sin(ang * 13.0)
            a = 255 if r <= edge else 0
            px.append((clamp(base_r), clamp(base_g), clamp(base_b), a))
    return png(size, size, px)


# ================================================================ 暗潮波纹(动画)
def gen_tide_ripple(size=64, frames=16):
    """16 帧竖条: 透明底 + **真正向外推**的同心波纹环
    ★ 2026-10-05 重写 ★
      旧版是"三个不同频率/方向的正弦叠加取绝对值" —— 那出来的图案是云状斑纹,
      帧与帧之间只是斑纹在蠕动, 平均半径几乎不动(实测 15.7~17.6, 变化 < 2px),
      放到 8 格的海面上看就是"整片轻微闪烁", 玩家直接反馈"暗潮没用动画"。
      新版改成货真价实的同心环: 三道环的半径随帧号整体外移(每帧走 1/16 圈),
      rk=0 处淡入、rk=1 处淡出(sin(pi*rk)), 所以环从中心冒出来、推到边缘散掉,
      16 帧刚好无缝循环。
    """
    rnd = random.Random(31415)
    c = (size - 1) / 2.0
    rings = 3
    out = []
    for f in range(frames):
        p = f / frames                       # 环整体外移的相位 0 .. 15/16
        px = []
        for y in range(size):
            for x in range(size):
                dx, dy = x - c, y - c
                r = math.hypot(dx, dy) / c    # 0..~1.41(归一化到半径 1)
                ang = math.atan2(dy, dx)
                # ★ 2026-10-06 晚: 岸线同 gen_tide_deep 一起放缓(原来 9 瓣 ±0.08)
                #   波纹层要比底层略小一点, 环推到岸边时才有"散在滩上"的感觉。
                edge = 0.84 + 0.035 * math.sin(ang * 5.0)
                if r > edge:
                    px.append((0, 0, 0, 0))
                    continue
                best = 0.0
                for k in range(rings):
                    rk = (k / rings + p) % 1.0          # 这道环此刻的半径
                    rk += 0.018 * math.sin(ang * 5.0 + k * 2.1)   # 环不是完美圆
                    d = abs(r - rk)
                    w = 0.060 + 0.030 * rk              # 越往外散得越宽
                    if d < w:
                        core = 1.0 - d / w
                        fade = math.sin(math.pi * min(rk, 0.90) / 0.90)  # 中心淡入 / 边缘淡出
                        fade = fade ** 0.6 if fade > 0.0 else 0.0
                        v = core * (0.25 + 0.75 * fade)
                        if v > best:
                            best = v
                if best < 0.12:
                    px.append((0, 0, 0, 0))
                    continue
                v = min(1.0, best)
                # 波峰颜色: 暗青 -> 亮青白
                r0 = 0x2e + (0x9f - 0x2e) * v
                g0 = 0x86 + (0xe8 - 0x86) * v
                b0 = 0xa8 + (0xfa - 0xa8) * v
                px.append((clamp(r0), clamp(g0), clamp(b0),
                           255 if v > 0.5 else 180))
        out.extend(px)
    return png(size, size * frames, out)


# ================================================================ 模型
def load_display():
    """复用 sweetdream:item/look 的 display(包里验证过能用的那套)"""
    try:
        d = json.loads((MDL / 'look.json').read_text(encoding='utf-8'))
        return d.get('display', {})
    except Exception:
        return {}


def box(name, frm, to, uvbox=None, rescale=False):
    """uvbox = (u0,v0) 调色板起点; None = 用树皮区按面尺寸取"""
    x0, y0, z0 = frm
    x1, y1, z1 = to
    w, h, d = x1 - x0, y1 - y0, z1 - z0
    if uvbox is None:
        # 树皮区是 UV [0,0,12,16]; 每个面按自己的尺寸取一块, 起点错开避免重复感
        def cap(a, m):
            return max(1.0, min(float(a), m))
        uw, uh = cap(w, 12), cap(h, 16)
        ud = cap(d, 12)
        faces = {
            'up':    [0, 0, uw, ud],
            'down':  [0, 0, uw, ud],
            'north': [0, 0, uw, uh],
            'south': [0, 0, uw, uh],
            'east':  [0, 0, ud, uh],
            'west':  [0, 0, ud, uh],
        }
    else:
        u0, v0 = uvbox
        f = [u0, v0, u0 + 4, v0 + 4]
        faces = {k: list(f) for k in ('up', 'down', 'north', 'south', 'east', 'west')}
    fs = {}
    for k, uv in faces.items():
        fs[k] = {'texture': '#wood', 'uv': [round(v, 4) for v in uv]}
    return {'name': name, 'from': [round(v, 4) for v in frm],
            'to': [round(v, 4) for v in to], 'faces': fs}


def gen_wood_model(display):
    """★ 目标: **高瘦的枯树立姿** —— 生成后用 item_display 等比 scale 5.0 放大
    (1 模型单位 = 5/16 = 0.3125 格): 树高 ~16.8u = 5.25 格, 树干基部 4.0u = 1.25 格,
    枝展 ±6.5u ≈ 4.1 格。★ 要改尺寸就按比例重画 + 等比 scale; 非等比拉伸会把
    阶梯状的枝拉成悬空的板子(踩过)。想更细就把 trunk/branch 的厚度整体再收一点。"""
    e = []
    # ---- 主干: 6 段由粗到细(基部 4.0u → 顶部 1.6u) ----
    trunk = [
        ('主干_根盘', [6.0, 0.0, 6.0], [10.0, 1.0, 10.0]),
        ('主干_下段', [6.3, 1.0, 6.3], [9.7, 5.0, 9.7]),
        ('主干_中段', [6.6, 5.0, 6.6], [9.4, 8.6, 9.4]),
        ('主干_上段', [6.8, 8.6, 6.8], [9.2, 11.6, 9.2]),
        ('主干_梢段', [7.0, 11.6, 7.0], [9.0, 14.2, 9.0]),
        ('主干_顶段', [7.2, 14.2, 7.2], [8.8, 15.6, 8.8]),
    ]
    for n, a, b in trunk:
        e.append(box(n, a, b))
    # ---- 断口(焦黑) + 两根焦茬, 顶到 16.8u ----
    e.append(box('断口', [7.5, 15.6, 7.5], [8.5, 16.2, 8.5], uvbox=(12, 8)))
    e.append(box('焦茬_a', [7.6, 16.2, 7.6], [8.0, 16.8, 8.0], uvbox=(12, 8)))
    e.append(box('焦茬_b', [8.2, 16.2, 7.9], [8.5, 16.6, 8.2], uvbox=(12, 8)))
    # ---- 露地根: 四向(两段阶梯) + 四斜向(一短段) ----
    roots = [
        ('根_东', [(10.0, 0.0, 7.2), (11.9, 1.5, 8.8)], [(11.6, 0.0, 7.4), (13.4, 0.7, 8.6)]),
        ('根_西', [(4.1, 0.0, 7.2), (6.0, 1.5, 8.8)], [(2.6, 0.0, 7.4), (4.4, 0.7, 8.6)]),
        ('根_南', [(7.2, 0.0, 10.0), (8.8, 1.5, 11.9)], [(7.4, 0.0, 11.6), (8.6, 0.7, 13.4)]),
        ('根_北', [(7.2, 0.0, 4.1), (8.8, 1.5, 6.0)], [(7.4, 0.0, 2.6), (8.6, 0.7, 4.4)]),
    ]
    for n, s1, s2 in roots:
        e.append(box(n + '_内', s1[0], s1[1]))
        e.append(box(n + '_外', s2[0], s2[1]))
    for n, a, b in (('根_东北', [9.9, 0.0, 9.9], [11.4, 1.0, 11.4]),
                    ('根_西北', [4.6, 0.0, 9.9], [6.1, 1.0, 11.4]),
                    ('根_东南', [9.9, 0.0, 4.6], [11.4, 1.0, 6.1]),
                    ('根_西南', [4.6, 0.0, 4.6], [6.1, 1.0, 6.1])):
        e.append(box(n, a, b))
    # ---- 六条枯枝: 细(0.9~1.0u 粗 = 0.3 格), 三段阶梯斜向上, 末端收梢;
    #      y 起点错开, 让树冠是"错落的枯枝"而不是一圈栅栏
    branches = [
        ('枝_东', [(9.0, 9.2, 7.55), (11.8, 10.1, 8.45)],
                  [(11.4, 10.5, 7.6), (13.6, 11.3, 8.4)],
                  [(13.3, 11.7, 7.7), (14.4, 12.3, 8.3)]),
        ('枝_西', [(4.2, 11.5, 7.55), (7.0, 12.4, 8.45)],
                  [(2.4, 12.8, 7.6), (4.6, 13.6, 8.4)],
                  [(1.3, 14.0, 7.7), (2.4, 14.6, 8.3)]),
        ('枝_南', [(7.55, 12.9, 8.8), (8.45, 13.8, 11.6)],
                  [(7.6, 14.1, 11.4), (8.4, 14.9, 13.4)],
                  [(7.7, 15.3, 13.2), (8.3, 15.9, 14.2)]),
        ('枝_北', [(7.55, 8.3, 4.2), (8.45, 9.2, 7.0)],
                  [(7.6, 9.5, 2.4), (8.4, 10.3, 4.6)],
                  [(7.7, 10.7, 1.3), (8.3, 11.3, 2.4)]),
        ('枝_东北', [(8.8, 10.5, 8.8), (10.6, 11.3, 10.6)],
                    [(10.4, 11.7, 10.4), (11.9, 12.4, 11.9)],
                    [(11.7, 12.8, 11.7), (12.7, 13.3, 12.7)]),
        ('枝_西南', [(5.0, 7.1, 5.0), (6.8, 7.9, 6.8)],
                    [(4.0, 8.2, 4.0), (5.6, 9.0, 5.6)],
                    [(3.4, 9.4, 3.4), (4.6, 10.0, 4.6)]),
    ]
    for n, s1, s2, s3 in branches:
        e.append(box(n + '_一段', s1[0], s1[1], uvbox=(12, 12)))
        e.append(box(n + '_二段', s2[0], s2[1], uvbox=(12, 12)))
        e.append(box(n + '_梢', s3[0], s3[1], uvbox=(12, 12)))
    # ---- 菌菇(紫) / 苔藓(绿) 点缀(小尺寸, 贴着树身) ----
    e.append(box('菌菇_a', [5.9, 4.2, 7.0], [6.9, 5.2, 8.0], uvbox=(12, 0)))
    e.append(box('菌菇_b', [9.2, 7.4, 9.2], [10.1, 8.3, 10.1], uvbox=(12, 0)))
    e.append(box('菌菇_c', [7.0, 2.2, 9.8], [7.9, 3.1, 10.7], uvbox=(12, 0)))
    e.append(box('苔藓_下', [6.6, 3.0, 6.2], [8.8, 3.35, 6.9], uvbox=(12, 4)))
    e.append(box('苔藓_上', [8.9, 10.0, 7.0], [9.6, 10.4, 8.4], uvbox=(12, 4)))
    m = {
        'credit': 'sweetdream 枯枝园·朽木 (程序化生成, 改数字请改 .workbuddy/_gen_wood_tide.py)',
        'ambientocclusion': False,
        'gui_light': 'front',
        'textures': {'wood': 'sweetdream:item/withered_wood',
                     'particle': 'sweetdream:item/withered_wood'},
        'elements': e,
    }
    if display:
        m['display'] = display
    return m


def gen_plane(name, credit, tex, y0, y1, faces=('up', 'down')):
    """水平薄板: 默认渲染上/下两个面, UV 吃满整张贴图"""
    fs = {}
    for f in faces:
        fs[f] = {'texture': '#tex', 'uv': [0, 0, 16, 16]}
    return {
        'credit': credit,
        'ambientocclusion': False,
        'gui_light': 'front',
        'textures': {'tex': tex, 'particle': tex},
        'elements': [{'name': name,
                      'from': [0, y0, 0], 'to': [16, y1, 16],
                      'faces': fs}],
        # 平面不需要手持姿态; 给一份最小 display, 免得万一拿到手上时姿态离谱
        'display': {'ground': {'rotation': [0, 0, 0], 'translation': [0, 2, 0],
                               'scale': [0.25, 0.25, 0.25]},
                    'gui': {'rotation': [30, 45, 0], 'translation': [0, 0, 0],
                            'scale': [0.3, 0.3, 0.3]}},
    }


def main():
    disp = load_display()
    # ---- 贴图 ----
    (TEX / 'withered_wood.png').write_bytes(gen_withered_wood())
    (TEX / 'tide_deep.png').write_bytes(gen_tide_deep())
    (TEX / 'tide_ripple.png').write_bytes(gen_tide_ripple())
    (TEX / 'tide_ripple.png.mcmeta').write_text(
        '{"animation":{"width":64,"height":64,"frametime":3}}\n', encoding='utf-8')
    # ---- 模型 ----
    (MDL / 'withered_wood.json').write_text(
        json.dumps(gen_wood_model(disp), ensure_ascii=False, indent=1), encoding='utf-8')
    (MDL / 'tide_deep.json').write_text(
        json.dumps(gen_plane('暗潮_底层', '无光海·暗潮 底层海面(静态深色)',
                             'sweetdream:item/tide_deep', 8.0, 9.0),
                   ensure_ascii=False, indent=1), encoding='utf-8')
    (MDL / 'tide_ripple.json').write_text(
        json.dumps(gen_plane('暗潮_波纹', '无光海·暗潮 波纹层(16 帧动画, 悬在底层上方)',
                             'sweetdream:item/tide_ripple', 10.0, 10.5,
                             faces=('up',)),
                   ensure_ascii=False, indent=1), encoding='utf-8')
    # ---- 物品模型定义 ----
    (ITM / 'withered_wood.json').write_text(
        json.dumps({'hand_animation_on_swap': False,
                    'model': {'type': 'minecraft:model',
                              'model': 'sweetdream:item/withered_wood'}},
                   ensure_ascii=False, indent=1), encoding='utf-8')
    (ITM / 'tide.json').write_text(
        json.dumps({'hand_animation_on_swap': False,
                    'model': {'type': 'minecraft:composite',
                              'models': [
                                  {'type': 'minecraft:model',
                                   'model': 'sweetdream:item/tide_deep'},
                                  {'type': 'minecraft:model',
                                   'model': 'sweetdream:item/tide_ripple'}]}},
                   ensure_ascii=False, indent=1), encoding='utf-8')
    print('withered_wood elements:',
          len(json.loads((MDL / 'withered_wood.json').read_text(encoding='utf-8'))['elements']))
    for p in sorted(list(TEX.glob('withered_wood.png')) + list(TEX.glob('tide_*.png'))
                    + list(MDL.glob('withered_wood.json')) + list(MDL.glob('tide_*.json'))
                    + list(ITM.glob('*.json'))):
        print('  %8d  %s' % (p.stat().st_size, p.as_posix().replace(str(ROOT.parent) + '/', '')))


if __name__ == '__main__':
    main()
