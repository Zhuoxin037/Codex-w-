# -*- coding: utf-8 -*-
"""_chk_lore_src.py —— 守卫: `lore/base_dispatch` 与「发放函数」是否同步。

【为什么需要它】debug/lore 的"硬刷新"靠 base_dispatch 这张表。表是**生成物**,
  改了某件装备的 give 描述却忘了重跑生成器 -> 表里还是旧文案 -> 用户刷完发现
  "又没变"。这是典型的静默失效(命令都成功、日志干净)。
  另外: 同一件装备的描述如果在 give 和 put_*/return_item 两处各写一份, 早晚分叉。

【判据】
  · 重跑一遍生成器(内存里), 与磁盘上的 base_dispatch **逐字节比对**;
  · 生成器自己的冲突警告(同 id 多来源 + 内容不一致)也一并报出来。

【用法】python .workbuddy/_chk_lore_src.py   -> 0 处 = 同步
【修法】python .workbuddy/_gen_lore_src.py --write
"""
import importlib.util
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _load():
    p = os.path.join(ROOT, '.workbuddy', '_gen_lore_src.py')
    spec = importlib.util.spec_from_file_location('_gen_lore_src_chk', p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def main():
    m = _load()
    chosen, warn = m.build()
    text = m.render(chosen)
    old = io.open(m.OUT, encoding='utf-8').read() if os.path.exists(m.OUT) else None

    bad = 0
    if old is None:
        print('[chk] 缺少 lore/base_dispatch —— 跑 `_gen_lore_src.py --write`')
        bad += 1
    elif old != text:
        print('[chk] lore/base_dispatch 与发放函数**已漂移** —— 重跑 `_gen_lore_src.py --write`')
        bad += 1
    for w in warn:
        print('[chk] ' + w)
        bad += 1

    print('[chk] lore_src: 收录 %d 条 id / %d 处问题' % (len(chosen), bad))
    return bad


if __name__ == '__main__':
    sys.exit(main())
