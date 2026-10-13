# -*- coding: utf-8 -*-
"""批 I1: 只把新增 4 颗超限石的 16x16 贴图落到"游戏实际读的三处"

【为什么单独一个】draw_overlimit_stone_redraw.py 是"审阅包生成器", 它跑之前要先能
  读到**完整版**里的路由与旧贴图; 而新加这 4 颗两边都还没有 -> 它第一步就 KeyError。
  所以这里只用它导出的 render() 渲染 + 落盘, 顺序上先让贴图进包, 再重建完整版,
  最后才跑那个审阅脚本(那时它就能正常出 28 颗总览了)。

【三处】① 源包 sweetdream_rp ② 版本隔离副本(PCL resourcepacks) ③ 完整版
  (③ 会被 build_full_pack 重建覆盖, 这里先写是为了让审阅脚本能读到"原图")
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from draw_overlimit_stone_redraw import render, DESIGNS  # noqa: E402

NEW = ('arc', 'tinder', 'fissure', 'chime')
RP_SRC = 'D:/数据包/sweetdream_rp/assets/sweetdream/textures/item/stone'
RP_VER = ('D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10'
          '/resourcepacks/sweetdream_rp/assets/sweetdream/textures/item/stone')
RP_FULL = 'D:/数据包/sweetdream_rp_完整版/assets/sweetdream/textures/item/stone'

by_id = {row[0]: row for row in DESIGNS}
for cid in NEW:
    _, cat, name, motif, colour, rows = by_id[cid]
    im = render(cat, colour, rows)
    assert im.size == (16, 16)
    for d in (RP_SRC, RP_VER, RP_FULL):
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, 'ol_%s.png' % cid)
        im.save(p)
        print('wrote', p, '(%s / %s)' % (name, motif))
