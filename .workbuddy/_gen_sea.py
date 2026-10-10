# -*- coding: utf-8 -*-
"""
生成「漫步冥河·暗海」的资源包素材 —— **三形态随机, 且都是不规则轮廓**。

★ 2026-10-06 第三次改（用户要求）:
  ★ "我不希望有过多突兀的尖角, 像现实里正常的湖泊就好" ★
  ⇒ 上一版的三个形态是**尖刺/镂空洞/被咬掉一大口**(裂星/碎云/缺月) —— 太"图形化"了。
     这一版全部改成**自然湖泊**: 岸线平滑、只有缓和的凸凹, 没有尖角、不挖洞、不咬缺口。
     做法: 控制点半径区间收窄(0.84~1.00, 不再有 0.58 这种深凹) + 高频抖动压到 0.02 上下
     + 丢掉 bite / holes。三个形态靠"控制点数 + 拉伸方向 + 湖心暗纹"区分:
       A 缓湾湖  5 个缓湾 + 长轴略偏东西 + 旋涡暗纹
       B 长湖    7 个弱凸起 + 长轴偏南北(明显被拉长的湖)
       C 半月湖  8 个缓凸起 + 一侧一个**宽缓的内湾**(不是缺口, 是湖湾) + 淡旋涡
★ 2026-10-06 第二次改（用户要求）:
  ① 每个暗海**最多存在 10 秒** -> 数据包侧(sea_cap), 与本脚本无关
  ② 暗海有**三个形态**, 每次生成随机取一个

产出（都在 sweetdream_rp/assets/sweetdream/ 下）:
  textures/item/sea_{a,b,c}_deep.png      64x64    海底色(不规则 alpha 裁边, 静态)
  textures/item/sea_{a,b,c}_ripple.png    64x1024 波纹层(16 帧动画, 透明底)
  textures/item/sea_{a,b,c}_ripple.png.mcmeta
  models/item/sea_{a,b,c}_{deep,ripple}.json
  items/sea_{a,b,c}.json                  composite 两层
  ★ 旧的单形态 sea.json / sea_deep.* / sea_ripple.* 已废弃并删除。

★ 尺寸约定（照暗潮, 别乱改）
  · 模型是 [0,16] 的物品空间, 整张贴图正好铺满 16x16 的 UV。
  · item_display 的物品模型 [0,16] 以实体位置为**中心** ⇒ 平面直径 = scale 格。
    暗海主片半径 3 格 ⇒ 直径 6 ⇒ scale 6; 次级片半径 2 ⇒ scale 4。
    (轨道表在 core/load: sea_in6/sea_out6/sea_in4/sea_out4)
  · 贴图动画靠 .png.mcmeta(frametime=4, 比暗潮的 3 慢一点 = "更沉")。
  · 平图 y 取 8..9(渲染后在实体高度 0..1/16 格), 与暗潮同款, 不用再推。
★ 配色 = 暗海自己的: 墨黑(squid_ink) 底 + 幽蓝(sculk_soul) 波纹 —— 和暗潮的
  "青白波纹" 刻意拉开, 同屏出现时分得清是哪一片。
★ 改数字重跑本脚本即可（幂等）。
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

TAU = math.pi * 2.0


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


# ---------------------------------------------------------------- 不规则轮廓
class Blob:
    """极坐标不规则轮廓。

    极径 R(θ) = 余弦插值(随机控制点) × (1 + warp·sin(kθ+φ)) × 缺口衰减
    然后整体缩放 K, 让形状**刚好填满**贴图(不留空边也不出界)。

    · n / rmin / rmax : 控制点个数与取值区间(个数少+区间窄 = 接近圆;
      个数多+区间宽 = 尖刺)
    · aniso           : (ax, ay) 在 x/y 方向拉伸(做"扁/长"的水洼)
    · bite            : (θc, 半宽, 深度) 咬掉一大口(缺月)
    · holes           : [(hx, hy, hr)] 镂空洞(单位 = 半宽 = 1)
    · warp / warp_k   : 高频抖动, 让边缘有细碎起伏(更像真水洼)
    """

    def __init__(self, seed, c, n=9, rmin=0.78, rmax=1.0, aniso=(1.0, 1.0),
                 bite=None, holes=(), warp=0.0, warp_k=13):
        rnd = random.Random(seed)
        self.knots = [rnd.uniform(rmin, rmax) for _ in range(n)]
        self.n = n
        self.c = c
        self.aniso = aniso
        self.bite = bite
        self.holes = holes
        self.warp = warp
        self.warp_k = warp_k
        self.warp_phase = rnd.uniform(0.0, TAU)
        self.K = self._fit()

    def R(self, th):
        t = (th / TAU) % 1.0 * self.n
        i = int(t) % self.n
        f = t - int(t)
        a, b = self.knots[i], self.knots[(i + 1) % self.n]
        u = (1.0 - math.cos(f * math.pi)) * 0.5          # 余弦插值: 周期且平滑
        r = a + (b - a) * u
        if self.warp:
            r *= 1.0 + self.warp * math.sin(th * self.warp_k + self.warp_phase)
        if self.bite:
            tc, hw, depth = self.bite
            d = abs(((th - tc + math.pi) % TAU) - math.pi)
            if d < hw:
                r *= 1.0 - depth * (1.0 - (d / hw) ** 1.6)
        return r

    def _s(self, dx, dy):
        ax, ay = self.aniso
        x, y = dx / ax, dy / ay
        rr = math.hypot(x, y)
        if rr < 1e-9:
            return 0.0
        return rr / self.R(math.atan2(y, x))

    def _fit(self):
        """K = 0.88c / ρmax —— 让形状**最长方向**贴到 0.88c 的圆(与暗潮圆形同视觉尺寸),
        形状完整可见、不被贴图切掉。norm = s/K, norm = 1 即边界。"""
        ax, ay = self.aniso
        rho = 0.0
        for i in range(2048):
            th = i / 2048.0 * TAU
            v = self.R(th) * math.hypot(ax * math.cos(th), ay * math.sin(th))
            if v > rho:
                rho = v
        return (0.88 * self.c / rho) if rho > 0.0 else 1.0

    def norm(self, dx, dy):
        """0 = 中心, 1 = 边界, >1 = 外部"""
        return self._s(dx, dy) / self.K

    def in_hole(self, dx, dy):
        c = self.c
        for hx, hy, hr in self.holes:
            if math.hypot(dx - hx * c, dy - hy * c) < hr * c:
                return True
        return False


# ---------------------------------------------------------------- 三形态参数
# ★ 一律"自然湖泊"口径 ★
#   · rmin 不低于 0.84  —— 岸线最深的凹也才收 16%, 出来的是一处处**缓湾**而不是尖角。
#   · warp <= 0.03      —— 高频抖动只用来"打碎完美的圆", 大到 0.07 就成锯齿了。
#   · bite / holes 全不用 —— 挖洞、咬缺口都是"图形化"的形状, 不是湖泊。
#   · rails/seeds 保持固定 —— 本脚本是幂等的, 同参数永远出同一张图。
VARIANTS = {
    'a': dict(
        cn='缓湾湖', seed=1101,
        n=5, rmin=0.84, rmax=1.00, aniso=(1.13, 0.92),
        bite=None, holes=(), warp=0.022, warp_k=7,
        rings=3, rays=0, swirl=0.45,
        base=(3, 7, 15), core=(26, 52, 96),
        ring_lo=(0x24, 0x4a, 0x8c), ring_hi=(0x8e, 0xd8, 0xf2)),
    'b': dict(
        cn='长湖', seed=2202,
        n=7, rmin=0.88, rmax=1.00, aniso=(0.90, 1.16),
        bite=None, holes=(), warp=0.018, warp_k=5,
        rings=3, rays=0, swirl=0.0,
        base=(3, 7, 16), core=(30, 50, 104),
        ring_lo=(0x2a, 0x46, 0x94), ring_hi=(0x86, 0xc4, 0xf4)),
    'c': dict(
        cn='半月湖', seed=3317,
        n=8, rmin=0.79, rmax=1.00, aniso=(1.0, 1.0),
        bite=None, holes=(), warp=0.022, warp_k=9,
        rings=3, rays=0, swirl=0.70,
        base=(3, 7, 15), core=(34, 50, 106),
        ring_lo=(0x30, 0x42, 0x90), ring_hi=(0x96, 0xc2, 0xf2)),
}


def make_blob(v, c):
    return Blob(v['seed'], c, n=v['n'], rmin=v['rmin'], rmax=v['rmax'],
                aniso=v['aniso'], bite=v['bite'], holes=v['holes'],
                warp=v['warp'], warp_k=v['warp_k'])


# ---------------------------------------------------------------- 海底(静态)
def gen_deep(v, size=64):
    """墨黑蓝死水: 径向渐变 + 中心深渊亮核 + 形态专属暗纹 + 不规则 alpha 裁边。"""
    c = (size - 1) / 2.0
    blob = make_blob(v, c)
    rnd = random.Random(v['seed'] + 7)
    br, bg, bb = v['base']
    cr, cg, cb = v['core']
    rays = v['rays']
    swirl = v['swirl']
    px = []
    for y in range(size):
        for x in range(size):
            dx, dy = x - c, y - c
            r = blob.norm(dx, dy)
            if r > 1.0 or blob.in_hole(dx, dy):
                px.append((0, 0, 0, 0))
                continue
            ang = math.atan2(dy, dx)
            t = max(0.0, 1.0 - r)
            wave = math.sin(r * 12.0) * 0.5 + 0.5
            rr = br + 9 * t + 3 * wave
            gg = bg + 18 * t + 4 * wave
            bl = bb + 32 * t + 7 * t
            # 中心深渊亮核(幽蓝): 越靠中心越亮
            glow = max(0.0, 1.0 - r * 3.4)
            rr += cr * glow
            gg += cg * glow
            bl += cb * glow
            # 形态专属暗纹
            if rays:
                sec = TAU / rays
                a = ang % sec
                d = min(a, sec - a)
                k = max(0.0, 1.0 - d / 0.055) * max(0.0, (r - 0.26) / 0.55)
                k = min(1.0, k)
                rr -= 9 * k
                gg -= 16 * k
                bl -= 6 * k
            if swirl:
                sw = math.sin(ang * 3.0 + r * 7.5) * 0.5 + 0.5
                k = swirl * (1.0 - t) * sw
                rr -= 5 * k
                gg -= 9 * k
                bl -= 3 * k
            rr += rnd.uniform(-3, 3)
            gg += rnd.uniform(-3, 3)
            bl += rnd.uniform(-4, 4)
            px.append((clamp(rr), clamp(gg), clamp(bl), 255))
    return png(size, size, px)


# ---------------------------------------------------------------- 波纹(动画)
def gen_ripple(v, size=64, frames=16):
    """16 帧竖条: 透明底 + 向外推的同心环(**沿同一不规则轮廓**做等高线)。
    环的相位 rk=(k/rings+f/frames)%1、两端 sin 归零 ⇒ 无缝循环(同暗潮做法)。"""
    c = (size - 1) / 2.0
    blob = make_blob(v, c)
    rings = v['rings']
    lo, hi = v['ring_lo'], v['ring_hi']
    out = []
    for f in range(frames):
        p = f / frames
        px = []
        for y in range(size):
            for x in range(size):
                dx, dy = x - c, y - c
                r = blob.norm(dx, dy)
                if r > 1.0 or blob.in_hole(dx, dy):
                    px.append((0, 0, 0, 0))
                    continue
                ang = math.atan2(dy, dx)
                best = 0.0
                for k in range(rings):
                    rk = (k / rings + p) % 1.0
                    rk += 0.022 * math.sin(ang * 5.0 + k * 2.1)   # 环上加细碎起伏
                    d = abs(r - rk)
                    w = 0.055 + 0.028 * rk
                    if d < w:
                        core = 1.0 - d / w
                        fade = math.sin(math.pi * min(rk, 0.90) / 0.90)
                        fade = fade ** 0.6 if fade > 0.0 else 0.0
                        val = core * (0.25 + 0.75 * fade)
                        if val > best:
                            best = val
                if best < 0.12:
                    px.append((0, 0, 0, 0))
                    continue
                val = min(1.0, best)
                px.append((clamp(lo[0] + (hi[0] - lo[0]) * val),
                           clamp(lo[1] + (hi[1] - lo[1]) * val),
                           clamp(lo[2] + (hi[2] - lo[2]) * val),
                           255 if val > 0.5 else 170))
        out.extend(px)
    return png(size, size * frames, out)


# ---------------------------------------------------------------- 模型
def gen_plane(name, credit, tex, y0, y1, faces=('up', 'down')):
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
        'display': {'ground': {'rotation': [0, 0, 0], 'translation': [0, 2, 0],
                               'scale': [0.25, 0.25, 0.25]},
                    'gui': {'rotation': [30, 45, 0], 'translation': [0, 0, 0],
                            'scale': [0.3, 0.3, 0.3]}},
    }


# ---------------------------------------------------------------- 动画轨道
SPREAD8 = [1.619, 2.563, 3.432, 4.224, 4.942, 5.584, 6.150, 6.641,
           7.056, 7.396, 7.660, 7.849, 7.962, 8.000]


def track(mul, end):
    """把暗潮那条 8 格 spread 等比缩到目标直径, 再照暗潮的收尾法出 shrink。"""
    ins = [round(v * mul, 3) for v in SPREAD8]
    outs = [round(v * mul, 3) for v in SPREAD8[::-1][1:]] + [round(end, 3)]
    fmt = lambda a: '[' + ','.join('%.3ff' % v for v in a) + ']'
    return fmt(ins), fmt(outs)


OLD = ['sea.json', 'sea_deep.json', 'sea_ripple.json', 'sea_deep.png',
       'sea_ripple.png', 'sea_ripple.png.mcmeta']


def main():
    for k, v in VARIANTS.items():
        (TEX / ('sea_%s_deep.png' % k)).write_bytes(gen_deep(v))
        (TEX / ('sea_%s_ripple.png' % k)).write_bytes(gen_ripple(v))
        (TEX / ('sea_%s_ripple.png.mcmeta' % k)).write_text(
            '{"animation":{"width":64,"height":64,"frametime":4}}\n', encoding='utf-8')

        (MDL / ('sea_%s_deep.json' % k)).write_text(
            json.dumps(gen_plane('暗海%s_底层' % v['cn'],
                                 '漫步冥河·暗海%s形态 底层海面(静态墨黑蓝)' % v['cn'],
                                 'sweetdream:item/sea_%s_deep' % k, 8.0, 9.0),
                       ensure_ascii=False, indent=1), encoding='utf-8')
        (MDL / ('sea_%s_ripple.json' % k)).write_text(
            json.dumps(gen_plane('暗海%s_波纹' % v['cn'],
                                 '漫步冥河·暗海%s形态 波纹层(16 帧动画)' % v['cn'],
                                 'sweetdream:item/sea_%s_ripple' % k, 10.0, 10.5,
                                 faces=('up',)),
                       ensure_ascii=False, indent=1), encoding='utf-8')
        (ITM / ('sea_%s.json' % k)).write_text(
            json.dumps({'hand_animation_on_swap': False,
                        'model': {'type': 'minecraft:composite',
                                  'models': [
                                      {'type': 'minecraft:model',
                                       'model': 'sweetdream:item/sea_%s_deep' % k},
                                      {'type': 'minecraft:model',
                                       'model': 'sweetdream:item/sea_%s_ripple' % k}]}},
                       ensure_ascii=False, indent=1), encoding='utf-8')

    # 废弃的单形态素材删掉(数据包已全面改用 sea_a/b/c)
    gone = []
    for name in OLD:
        for d in (TEX, MDL, ITM):
            p = d / name
            if p.exists():
                p.unlink()
                gone.append(p.name)
    if gone:
        print('已删除废弃素材:', ', '.join(sorted(set(gone))))

    print('--- 尺寸 6 格(主片, 半径 3) ---')
    print('  sea_in6  =', track(6 / 8, 0.45)[0])
    print('  sea_out6 =', track(6 / 8, 0.45)[1])
    print('--- 尺寸 4 格(次级片, 半径 2) ---')
    print('  sea_in4  =', track(4 / 8, 0.30)[0])
    print('  sea_out4 =', track(4 / 8, 0.30)[1])
    print('--- 三形态 ---')
    for k, v in VARIANTS.items():
        print('  形态 %s = %s   (控制点 %d 个 %s..%s, 镂空洞 %d, 缺口 %s)'
              % (k, v['cn'], v['n'], v['rmin'], v['rmax'], len(v['holes']),
                 '有' if v['bite'] else '无'))
    print('--- 产出 ---')
    for p in sorted(list(TEX.glob('sea_*.png*')) + list(MDL.glob('sea_*.json'))
                    + list(ITM.glob('sea_*.json'))):
        print('  %8d  %s' % (p.stat().st_size, p.as_posix().replace(str(ROOT.parent) + '/', '')))


if __name__ == '__main__':
    main()
