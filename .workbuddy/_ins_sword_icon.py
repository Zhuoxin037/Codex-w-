# -*- coding: utf-8 -*-
"""_ins_sword_icon.py —— 给「剑类平面图标」那 13 件剑的物品串补上 item_model

【为什么不用改 give 的了事】
  这 12 件剑里只有 7 件是生成器产出的（`_gen_batch5/6.py`），另外 5 件
  （横刀/燎原/流光/热熔/影刃）的 give 是**手写**的；再加上「万念 ↔ 千散」互换时
  会把整串组件**复制一份**写进 `put_qian/put_my`，一共 16 处。
  这几处只能机械地补 —— 本脚本就是干这个的。

【为什么不干脆不写 item_model, 全靠每秒的 sword_icon_sync】
  那样新 give 出来的剑会先露 1 秒原版贴图再"变脸"。存量由 sync 补（那是它的活），
  新发的必须在 give 里一步到位。

【做法】在物品的组件列表 `[...]` **最前面**插入 `item_model="sweetdream:<id>",`。
  放最前面是为了和 `_gen_batch5/6.py` 的产出**逐字一致**（`_chk_gen_drift.py` 逐字比）。
  插入位置只认"紧跟物品 id 的那个 `[`"，不改其余任何一个字符。

【幂等】已经有 item_model= 的行直接跳过；连跑两遍第二遍 0 改动。

【用法】
    python .workbuddy/_ins_sword_icon.py            # 试运行, 只报告
    python .workbuddy/_ins_sword_icon.py --write    # 真写
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FUNC = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')

SWORDS = ['everfrost', 'hengdao', 'hush', 'liaoyuan', 'liuguang', 'myriad',
          'qiansan', 'rebound', 'remelt', 'rogue_star', 'shadow_blade', 'verdict']

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
    head = line[:b]
    zx = re.search(r'custom_data=\{zx:\["([a-z_]+)"', line)
    if not zx or zx.group(1) not in SWORDS:
        return line, False
    # ★ 幂等判据必须看 '[' **之后**、custom_data 之前的那一段 ——
    #   写成 'item_model=' in head 恒为假(head 只到 '['), 会重复插入。
    seg = line[b + 1:zx.start()]
    if 'item_model=' in seg:
        return line, False                      # 已经有, 幂等跳过
    sid = zx.group(1)
    return line[:b + 1] + 'item_model="sweetdream:%s",' % sid + line[b + 1:], True


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
