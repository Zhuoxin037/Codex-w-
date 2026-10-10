# -*- coding: utf-8 -*-
"""汉字「固定框归一化」实验：验证 16×16 里能否让每个字严格居中 + 视觉重量一致

思路（解决"大字无法同步在中间"）：
  1. 超采样域渲染（SS=8 ⇒ 128×128），字号足够大
  2. 取**墨迹 bbox**（不是字体 ascent/descent）
  3. 把 bbox **强制等比缩放**到统一的目标框（BOX=10 或 11）
  4. 居中贴回 16×16，BOX 降采样 + **自适应阈值**（让墨水量逼近目标）
⇒ 每个字外框一致、位置一致、墨水量一致

用法: python .workbuddy/_proto_hanzi_fit.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\数据包'
OUT = os.path.join(ROOT, '模型设计', '超限石_重设计_20261010')
os.makedirs(OUT, exist_ok=True)

W = H = 16
SS = 8                      # 超采样倍数
HEI = r'C:\Windows\Fonts\simhei.ttf'
SONG = r'C:\Windows\Fonts\simsun.ttc'
YAHEI = r'C:\Windows\Fonts\msyh.ttc'

WORDS = ['流', '念', '游', '刃', '海', '霜', '焰', '引', '刀', '负', '荷', '莲',
         '梦', '骨', '鸦', '响', '棠', '偏', '蛭', '脊', '星', '昏', '冠', '炉']
# 笔画更少的替代表（供对比）
ALT = {'霜': '冰', '焰': '火', '引': '引', '离': '负', '梦': '梦', '棠': '棠',
       '偏': '偏', '蛭': '蛭'}


def fit_mask(ch, box, target_ink, font_path=HEI, ss=SS):
    """把汉字渲染后强制归一化到 box×box 的框，居中，墨水量逼近 target_ink"""
    N = W * ss
    f = ImageFont.truetype(font_path, box * ss)
    im = Image.new('L', (N, N), 0)
    ImageDraw.Draw(im).text((N // 4, N // 4), ch, font=f, fill=255)
    bw = im.getbbox()
    if bw is None:
        return [[False] * W for _ in range(H)]
    crop = im.crop(bw)
    cw, chh = crop.size
    side = max(cw, chh)
    # 等比放进 box（在超采样域里 = box*ss）
    k = (box * ss) / float(side)
    nw, nh = max(1, int(round(cw * k))), max(1, int(round(chh * k)))
    crop = crop.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new('L', (N, N), 0)
    ox = (N - nw) // 2
    oy = (N - nh) // 2
    canvas.paste(crop, (ox, oy))

    # 自适应阈值：二分找到使墨水量最接近 target_ink 的阈值
    small = canvas.resize((W, H), Image.BOX)
    p = small.load()
    vals = sorted((p[x, y] for y in range(H) for x in range(W)), reverse=True)
    best, best_t = None, 108
    for t in range(30, 210, 2):
        ink = sum(1 for y in range(H) for x in range(W) if p[x, y] >= t)
        if ink == 0:
            continue
        d = abs(ink - target_ink)
        if best is None or d < best:
            best, best_t = d, t
            if d == 0:
                break
    return [[p[x, y] >= best_t for x in range(W)] for y in range(H)]


def bbox_of(m):
    xs = [x for y in range(H) for x in range(W) if m[y][x]]
    ys = [y for y in range(H) for x in range(W) if m[y][x]]
    if not xs:
        return None
    return min(xs), min(ys), max(xs), max(ys)


def render(m, ink=(240, 244, 255), bg=(24, 26, 32), frame=True):
    im = Image.new('RGBA', (W, H), bg + (255,))
    px = im.load()
    for y in range(H):
        for x in range(W):
            if m[y][x]:
                px[x, y] = ink + (255,)
    if frame:
        d = ImageDraw.Draw(im)
        d.rectangle([0, 0, W - 1, H - 1], outline=(70, 74, 88))
        # 十字中线，检查是否居中
        for i in range(H):
            px[7, i] = (90, 60, 60, 255) if not m[i][7] else px[7, i]
            px[8, i] = (90, 60, 60, 255) if not m[i][8] else px[8, i]
        for i in range(W):
            px[i, 7] = (90, 60, 60, 255) if not m[7][i] else px[i, 7]
            px[i, 8] = (90, 60, 60, 255) if not m[8][i] else px[i, 8]
    return im


def sheet(tiles, cols, scale, pad, labels=None, title=None, sub=None,
          bg=(26, 26, 32)):
    n = len(tiles)
    rows = (n + cols - 1) // cols
    cw = W * scale + pad
    chh = H * scale + pad + 16
    top = 46 if title else pad
    img = Image.new('RGB', (pad + cols * cw, top + rows * chh), bg)
    d = ImageDraw.Draw(img)
    ft = ImageFont.truetype(YAHEI, 17)
    fs = ImageFont.truetype(YAHEI, 12)
    if title:
        d.text((pad, 8), title, font=ft, fill=(240, 240, 248))
    if sub:
        d.text((pad, 32), sub, font=fs, fill=(150, 152, 166))
    for i, t in enumerate(tiles):
        x = pad + (i % cols) * cw
        y = top + (i // cols) * chh
        img.paste(t.resize((W * scale, H * scale), Image.NEAREST), (x, y))
        if labels:
            d.text((x + 2, y + H * scale + 2), labels[i], font=fs,
                   fill=(224, 224, 232))
    return img


def report(box, target, fp=HEI, tag=''):
    rows = []
    for ch in WORDS:
        m = fit_mask(ch, box, target, fp)
        b = bbox_of(m)
        ink = sum(1 for y in range(H) for x in range(W) if m[y][x])
        if b is None:
            rows.append((ch, None, 0))
            continue
        rows.append((ch, b, ink))
    print('--- box=%d target=%d %s ---' % (box, target, tag))
    tops = {}
    for ch, b, ink in rows:
        if b:
            tops.setdefault((b[0], b[1], b[2], b[3]), []).append(ch)
    for k, v in sorted(tops.items(), key=lambda kv: -len(kv[1])):
        print('  bbox x[%d..%d] y[%d..%d] (%dx%d) : %s' % (
            k[0], k[2], k[1], k[3], k[2] - k[0] + 1, k[3] - k[1] + 1,
            ' '.join(v)))
    print('  墨水 min=%d max=%d' % (min(r[2] for r in rows),
                                    max(r[2] for r in rows)))
    return rows


def main():
    # 1) 居中一致性报告
    report(10, 40, HEI, tag='simhei')
    print()
    report(11, 44, HEI, tag='simhei')
    print()
    report(12, 48, HEI, tag='simhei')

    # 2) 出图
    jobs = []
    for box, tgt in ((10, 40), (11, 44), (12, 48)):
        tiles, labs = [], []
        for ch in WORDS:
            m = fit_mask(ch, box, tgt, HEI)
            tiles.append(render(m))
            b = bbox_of(m)
            labs.append('%s %dx%d' % (ch, b[2] - b[0] + 1, b[3] - b[1] + 1)
                        if b else ch)
        jobs.append(('_汉字归一_box%d.png' % box,
                     sheet(tiles, 8, 8, 10, labs,
                           '汉字固定框归一化 box=%d（红线=16×16 中线）' % box,
                           '所有字强制缩放到同一框 + 居中 + 自适应墨水量 ⇒ 位置/视觉重量一致')))
    for fp, tag in ((HEI, 'simhei'), (YAHEI, 'msyh')):
        tiles, labs = [], []
        for ch in WORDS:
            m = fit_mask(ch, 11, 44, fp)
            tiles.append(render(m))
            labs.append(ch)
        jobs.append(('_汉字归一_%s.png' % tag,
                     sheet(tiles, 8, 8, 10, labs,
                           '字体对比：%s（box=11）' % tag,
                           '挑选在 16×16 下最清晰的字体')))
    for name, img in jobs:
        p = os.path.join(OUT, name)
        img.save(p)
        print('->', p, img.size)


if __name__ == '__main__':
    main()
