# -*- coding: utf-8 -*-
"""重写 sweetdream:tag/icon_render.mcfunction（字形是私有区字符，必须脚本生成）。

为什么要有这个生成器：
  · 图标字形是 U+E000..U+E009 的**不可见字符**，手写/复制极易丢失或串位；
  · "剩余 ≤3 秒换淡色字形"要把每个标签写成**两行**(淡色 / 普通)，共 10 行，
    顺序还必须与 tag/icon_refresh 的位掩码一一对应 —— 生成器里由 ORDER 保证。
  · 改结构请改本文件再重跑；U+E00x 的映射由 sweetdream_rp/tools/make_icons.py 决定，
    两者必须一致(ORDER 顺序相同)。

用法： python .workbuddy/_gen_tag_icons.py
"""
import io
from pathlib import Path

ROOT = Path(r'D:\数据包')
OUT = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'tag' / 'icon_render.mcfunction'

# 顺序必须与 tag/icon_refresh 的位掩码一致（位 0..4 = 1/2/4/8/16，淡出位 5..9 = 32/64/128/256/512）
ORDER = ['yuanhai', 'liuhuo', 'yehuo', 'shixin', 'dream']
NORM = 0xE000          # 普通字形 U+E000..U+E004
DIM = 0xE000 + len(ORDER)   # 淡色字形 U+E005..U+E009
THRESHOLD = 3          # 剩余秒数 <= 这个值时变淡（必须与 tag/icon_refresh 一致）

HEAD = '''# @s 仍是生物。只有 mask 改变或新建显示实体时才拼接文字。
# fallback 让非中英文客户端也能使用这套字体；顺序固定、没有空槽。
# ============================================================
# 【剩余 <= 3 秒 -> 换"淡色字形"】(2026-10-06 加)
#   每个标签在自己的 zx.tt.<mark> 上剩余秒数 <= 3 时用淡色字形(U+E005..E009)，
#   否则用普通字形(U+E000..U+E004)。淡色副本由 sweetdream_rp/tools/make_icons.py
#   与图集一起生成(降不透明度 + 轻微去饱和；形状与字宽完全不变，所以整排不跳动)。
# 【★ 为什么不能用 text_opacity ★】
#   它作用在整个 text_display 上 —— 一行最多 5 个图标，弄淡"刚到 3 秒的那个"
#   会把同排还早的图标一起弄淡。所以只能换字形(一个字形配一份"淡"副本)。
# 【★ 为什么"跨进 <= 3 秒"能触发重渲染 ★】
#   本文件只在 tag/icon_sync 发现掩码变化时才被调用；而掩码里带了"淡出位"
#   (32/64/128/256/512，见 tag/icon_refresh) —— 跨进 <= 3 秒就是一次状态变化。
#   两边的阈值与位值必须一致：check.py 规则 dimflag 盯着。
# 【★ "没分数" != 0 ★】`if score @s zx.tt.x matches ..3` 在这条分数**不存在**时
#   直接失败(不是按 0 算) -> 旧存档里没分数的老标签这一帧不变淡；
#   下一秒 tag/ttl_tick 会兜底补上分数，之后就正常了。
# 【本文件由 .workbuddy/_gen_tag_icons.py 生成】字形是私有区字符，手改容易丢字符；
#   要改结构请改生成器再重跑(make_icons.py 决定 U+E00x 的映射，两边顺序必须一致)。
# ============================================================
data modify storage zx:tag row set value {text:"",font:"sweetdream:icons",extra:[]}
'''

TAIL = '''$data modify entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] text set from storage zx:tag row
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask $(mask)
'''


def line(mark, dim):
    key = 'sweetdream.icon.dim.' + mark if dim else 'sweetdream.icon.' + mark
    ch = chr((DIM if dim else NORM) + ORDER.index(mark))
    cond = ('if score @s zx.tt.%s matches ..%d' % (mark, THRESHOLD) if dim
            else 'unless score @s zx.tt.%s matches ..%d' % (mark, THRESHOLD))
    return ('execute if entity @s[tag=zx.status.%s] %s run data modify storage zx:tag row.extra '
            'append value {"translate":"%s","fallback":"%s"}' % (mark, cond, key, ch))


def main():
    out = [HEAD]
    for m in ORDER:
        out.append(line(m, True) + '\n')
        out.append(line(m, False) + '\n')
    out.append(TAIL)
    OUT.write_text(''.join(out), encoding='utf-8', newline='\n')
    # 自检: 字形顺序必须与掩码位一一对应
    txt = OUT.read_text(encoding='utf-8')
    assert len(ORDER) * 2 == txt.count('row.extra append value'), '字形行数不对'
    for i, m in enumerate(ORDER):
        assert chr(NORM + i) in txt and chr(DIM + i) in txt, '字形缺失: ' + m
    print('wrote %s (%d 行字形)' % (OUT.name, len(ORDER) * 2))


if __name__ == '__main__':
    main()
