# -*- coding: utf-8 -*-
"""盔甲改版对照：原版 / 现版 / 新版 / 备选 —— 逐件一行"""
import os
import sys
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, r'D:\数据包\.workbuddy')
import build_vanilla_armor as m                                   # noqa: E402

OUT = r'D:\数据包\模型设计\原版风_盔甲_20261010'
TMP = r'D:\数据包\.workbuddy\tmp\armor_prev'
FONT = r'C:\Windows\Fonts\msyh.ttc'
BY = {p['id']: p for p in m.P}

# —— 备选色（只给 3 件纯改色的）——
ALT = {
    'immolate': dict(
        ramp=[m.hx('#14100C'), m.hx('#33241A'), m.hx('#5E3C22'),
              m.hx('#96602A'), m.hx('#C89040'), m.hx('#EEC468'), m.hx('#FFF0C0')],
        acc=[m.RIM('#FFD98A'), m.DARK('#0A0705'), m.HOT('#FFE9B0')]),
    'external_power': dict(
        ramp=[m.hx('#0C1418'), m.hx('#1A2A30'), m.hx('#28464E'), m.hx('#3A7280'),
              m.hx('#5FA8B4'), m.hx('#9AD6DE'), m.hx('#D8F6FA')],
        acc=[m.RIM('#BFF2F0'), m.DARK('#060C0E'), m.HOT('#B48CE8')]),
    'mirage': dict(
        ramp=[m.hx('#2E2C3C'), m.hx('#565268'), m.hx('#8A86A0'),
              m.hx('#B8B4CC'), m.hx('#DEDCEC'), m.hx('#FBFAFF')],
        acc=[m.RIM('#EDE8FF'), m.DARK('#1A1826'), m.HOT('#BFE4FF')]),
}

SI, SL = 8, 4                    # 图标 / 层 放大
IW, LH, LW = 16 * SI, 32 * SL, 64 * SL
CW = LW                          # 单元格宽 256
ICX = (CW - IW) // 2
CELL_H = 6 + IW + 8 + LH
ROWH = CELL_H + 40


def cell(sheet, x, y, icon, layer):
    bg = Image.new('RGBA', (CW, CELL_H), (139, 139, 139, 255))
    if icon is not None:
        b = m.up(icon, SI)
        bg.paste(b, (ICX, 6), b)
    if layer is not None:
        b = m.up(layer, SL)
        bg.paste(b, (0, 6 + IW + 8), b)
    sheet.paste(bg, (x, y))


def fnt(sz, bold=False):
    try:
        return ImageFont.truetype(FONT, sz)
    except Exception:
        return ImageFont.load_default()


def sheet_for(ids, path, title):
    PAD, GAP = 18, 14
    cols = 4
    W = PAD * 2 + cols * CW + (cols - 1) * GAP
    H = PAD + 52 + len(ids) * (ROWH) + PAD
    sh = Image.new('RGBA', (W, H), (24, 26, 32, 255))
    d = ImageDraw.Draw(sh)
    d.text((PAD, 12), title, font=fnt(22), fill=(246, 246, 250))
    f_pn, f_lb, f_sub = fnt(24), fnt(15), fnt(14)
    y = PAD + 52
    for pid in ids:
        p = BY[pid]
        icon_tpl, layer_tpl = m.spec_of(p)
        org_ic = Image.open(os.path.join(m.REF, icon_tpl + '.png')).convert('RGBA')
        org_ly = Image.open(os.path.join(m.REF, layer_tpl + '.png')).convert('RGBA')
        old_ic = Image.open(os.path.join(TMP, 'icon_%s.png' % pid)).convert('RGBA')
        old_ly = Image.open(os.path.join(TMP, 'layer_%s.png' % pid)).convert('RGBA')
        new_ic = Image.open(os.path.join(OUT, '图标', pid + '.png')).convert('RGBA')
        new_ly = Image.open(os.path.join(OUT, '盔甲层', pid + '.png')).convert('RGBA')
        cells = [('① 原版', org_ic, org_ly), ('② 现版', old_ic, old_ly), ('③ 新版', new_ic, new_ly)]
        if pid in ALT:
            p2 = dict(p); p2.update(ALT[pid])
            a_ic, a_ly = m.make(p2, save=False)
            cells.append(('④ 备选', a_ic, a_ly))
        d.text((PAD, y), p['cn'], font=f_pn, fill=(250, 224, 140))
        d.text((PAD + 300, y + 8), p['motif'], font=f_sub, fill=(158, 164, 178))
        y += 32
        for i, (lab, icim, lyim) in enumerate(cells):
            x = PAD + i * (CW + GAP)
            cell(sh, x, y, icim, lyim)
            d.text((x + 6, y + 2), lab, font=f_lb, fill=(236, 240, 248))
        y += ROWH - 32
    sh.save(path)
    print('->', path, sh.size)


sheet_for(['immolate', 'external_power', 'mirage'],
          os.path.join(OUT, '改版对照_改色3件.png'),
          '盔甲改版 · 改色三件 —— 焚舟 / 体外供能装置 / 幻昼（每格：上=背包图标 下=穿戴层）')
sheet_for(['spine_symbiote', 'dionysus_helmet', 'iridescent'],
          os.path.join(OUT, '改版对照_元素3件.png'),
          '盔甲改版 · 元素三件 —— 脊骨共生（脊椎肋骨）/ 狄俄尼索斯之桂冠（月桂叶+葡萄）/ 异彩（全光谱）')
