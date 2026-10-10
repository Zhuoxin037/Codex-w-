# -*- coding: utf-8 -*-
"""_ins_axe_icon.py —— 给「斧类平面图标」那 14 件斧的物品串补上 item_model

与 `_ins_sword_icon.py` 同构（那份是剑）。为什么需要它：

  14 件斧里只有 9 件是生成器产出的（`_gen_batch5/6.py`），另外 5 件
  （负离子 / 超•负•荷 / 沉渊 / 陨星 / 天穹）的 give 是**手写**的。
  生成器的那份已经在 spec 里写了 `item_model='sweetdream:<id>'`，
  这 5 件只能机械地补 —— 本脚本就是干这个的（对已经有的一律跳过，幂等）。

【为什么不干脆不写 item_model, 全靠每秒的 axe_icon_sync】
  那样新 give 出来的斧会先露 1 秒原版贴图再"变脸"。存量由 sync 补（那是它的活），
  新发的必须在 give 里一步到位。

【做法】在物品的组件列表 `[...]` **最前面**插入 `item_model="sweetdream:<模型键>",`。
  放最前面是为了和 `_gen_batch5/6.py` 的产出**逐字一致**（`_chk_gen_drift.py` 逐字比）。
  插入位置只认"紧跟物品 id 的那个 `[`"，不改其余任何一个字符。

【★★ 崩裂写 sweetdream:fissure_axe, 不是 sweetdream:fissure】
  后者在资源包里已经是崩裂技能的「地面裂缝」平面模型（fissure/field.mcfunction 用
  item_display + item_model="sweetdream:fissure" 召唤）。斧叫同一个名字会显示成
  一块贴地的裂缝。

【幂等】已经有 item_model= 的行直接跳过；连跑两遍第二遍 0 改动。

【用法】
    python .workbuddy/_ins_axe_icon.py            # 试运行, 只报告
    python .workbuddy/_ins_axe_icon.py --write    # 真写
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FUNC = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')

# 武器 id(zx[0]) -> 模型键。默认相同；崩裂例外（见上面 ★★）
AXES = {
    'agony': 'agony', 'anion': 'anion', 'azure_star': 'azure_star',
    'ballad': 'ballad', 'charge': 'charge', 'chenyuan': 'chenyuan',
    'draught': 'draught', 'dream_reader': 'dream_reader',
    'fissure': 'fissure_axe',
    'meteor': 'meteor', 'pyre': 'pyre', 'red_lotus': 'red_lotus',
    'skyvault': 'skyvault', 'thunderclap': 'thunderclap',
}

# 物品串的两种形态: give @s <item>[...] / item replace entity @s weapon.<slot> with <item>[...]
# ★ 物品 id 用 [^\s\[]+ —— 不能用 \S+ : SNBT 里没有空格, \S+ 会把整个 [ ... ] 一起吞掉。
HEAD = re.compile(r'(?m)^\s*give\s+@s\s+[^\s\[]+|'
                  r'item\s+replace\s+entity\s+@s\s+weapon\.\w+\s+with\s+[^\s\[]+')


def patch(line):
    """返回 (新行, 是否改动)。不属于目标武器的行原样返回。"""
    if 'custom_data={zx:' not in line:
        return line, False
    m = HEAD.search(line)
    if not m:
        return line, False
    # 定位物品 id 之后的第一个 '[' —— 那才是组件表
    b = line.find('[', m.end())
    if b < 0:
        return line, False
    zx = re.search(r'custom_data=\{zx:\["([a-z_]+)"', line)
    if not zx or zx.group(1) not in AXES:
        return line, False
    # ★ 幂等判据必须看 '[' **之后**、custom_data 之前的那一段 ——
    #   写成 'item_model=' in line[:b] 恒为假(那段只到 '['), 会重复插入。
    seg = line[b + 1:zx.start()]
    if 'item_model=' in seg:
        return line, False                      # 已经有, 幂等跳过
    key = AXES[zx.group(1)]
    return line[:b + 1] + 'item_model="sweetdream:%s",' % key + line[b + 1:], True


def main():
    write = '--write' in sys.argv
    changed = []
    touched = 0
    for r, _, fns in os.walk(FUNC):
        for fn in sorted(fns):
            if not fn.endswith('.mcfunction'):
                continue
            p = os.path.join(r, fn)
            raw = io.open(p, encoding='utf-8').read()
            lines = raw.split('\n')
            hit = []
            for i, ln in enumerate(lines):
                new, ok = patch(ln)
                if ok:
                    lines[i] = new
                    hit.append(i + 1)
            if hit:
                touched += 1
                changed.append((os.path.relpath(p, ROOT), hit))
                if write:
                    io.open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))

    for p, hit in changed:
        print('  %-72s L%s' % (p, ','.join(map(str, hit))))
    print()
    print('%s：%d 个文件 / %d 行'
          % ('已写入' if write else '试运行(未写)', touched, sum(len(h) for _, h in changed)))


if __name__ == '__main__':
    main()
