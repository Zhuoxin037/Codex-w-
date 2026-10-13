# -*- coding: utf-8 -*-
"""_gen_reset_scores.py —— 生成 sweetdream:event/player_reset 的"逐项清账清单"。

背景(审查报告 2026-10-11 · N05/N06):
  · N06: 旧写法 `scoreboard players reset @s`(**不带 objective**)= 清该玩家在**所有**
    计分项上的分数 —— 连别的数据包的分一起清。本包目录里就住着第二个数据包
    `sweetdream/data/naturewind`(nw.anim / nw.cast_t) ⇒ 旧写法会把它一起清掉
    (现场可证, 不是假想)。改成**逐项清单**: 只 reset 本包 zx.*。
  · 单一真源 = **源码**: 扫所有 `scoreboard objectives add zx.<名字>` 去重排序,
    生成 `scoreboard players reset @s zx.<名字>` 逐行写进 player_reset.mcfunction
    的**命令段**(标记行以下)。文件头(人写的说明)原样保留。
  · 守门: check.py 的 `resetset` 规则**双向对账**(源码 zx.* 集合 == 清单 reset 集合),
    并禁止回归"不带 objective 的全清"。新增账本忘了重跑本生成器会被拦下。

【幂等】连跑两遍第二遍 0 改动。命令段完全由脚本托管, 不要手改。

【★ 尾标记(2026-10-11 四审 Q02 加)★】
  只写 `@@GEN-SCORES-BELOW@@` 时, 标记行**以下全部**算托管区 —— 于是想在清单
  **之后**补一段手写逻辑(例如"清完账按返还队列重建镜像" Q02 的 resync)就没地方放:
  加了会被下次生成覆盖掉。
  现在支持可选的 `@@GEN-SCORES-ABOVE@@`: 托管区 = 两个标记**之间**;
  尾标记行**及其之后**原样保留(手写区)。没有尾标记 = 老行为(整段托管)。

用法:
    python .workbuddy/_gen_reset_scores.py           # 试运行(只报告)
    python .workbuddy/_gen_reset_scores.py --write   # 真写
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCAN_DIRS = [
    os.path.join(ROOT, 'manacore-1.0.0', 'data'),
    os.path.join(ROOT, 'sweetdream', 'data'),
]
TARGET = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream',
                      'function', 'event', 'player_reset.mcfunction')
MARK = '# @@GEN-SCORES-BELOW@@'
# ★ Q02(2026-10-11 四审): 可选尾标记 —— 见文件头"尾标记"一节。
#   托管区 = MARK 行(含) ~ END_MARK 行(不含); END_MARK 行及其之后一律原样保留。
END_MARK = '# @@GEN-SCORES-ABOVE@@'

# 与 check.py 的 obj_add_re 完全同款: 只认 `<name>` 这个标识符形态的计分项名。
ADD_RE = re.compile(r'scoreboard\s+objectives\s+add\s+([A-Za-z0-9_.]+)')


def collect_zx():
    """扫源码里所有 `scoreboard objectives add zx.*`, 去重 + 排序。"""
    names = set()
    for d in SCAN_DIRS:
        if not os.path.isdir(d):
            continue
        for r, _ds, fs in os.walk(d):
            for f in fs:
                if not f.endswith('.mcfunction'):
                    continue
                p = os.path.join(r, f)
                try:
                    with open(p, encoding='utf-8', errors='ignore') as fh:
                        txt = fh.read()
                except OSError:
                    continue
                for m in ADD_RE.finditer(txt):
                    if m.group(1).startswith('zx.'):
                        names.add(m.group(1))
    return sorted(names)


def build_body(names):
    return ['scoreboard players reset @s %s' % n for n in names]


def main():
    write = '--write' in sys.argv
    names = collect_zx()
    if not names:
        print('[中止] 源码里一个 zx.* 计分项都没扫到 —— 路径/正则不对?')
        return
    if not os.path.exists(TARGET):
        print('[中止] 目标文件不存在: %s' % TARGET)
        return

    with open(TARGET, encoding='utf-8') as fh:
        old = fh.read().split('\n')

    # 找到标记行(取第一条包含 MARK 的行), 保留到它为止。
    #   · 有尾标记 END_MARK(且在 MARK 之后) => 托管区 = 两标记之间; 尾标记及其之后保留。
    #   · 没有尾标记 => 老行为: 标记行以下(旧命令段)整段丢弃。
    mark_idx = next((i for i, l in enumerate(old) if MARK in l), None)
    if mark_idx is None:
        print('[中止] 目标文件里找不到标记行 `%s` —— 先补上标记再跑。' % MARK)
        return
    end_idx = next((i for i, l in enumerate(old) if END_MARK in l), None)
    has_tail = end_idx is not None and end_idx > mark_idx
    head = old[:mark_idx + 1]
    tail = old[end_idx:] if has_tail else []
    body_slice = old[mark_idx + 1:end_idx] if has_tail else old[mark_idx + 1:]
    new = head + build_body(names) + ([''] if tail else []) + tail
    new_txt = '\n'.join(new)
    if not new_txt.endswith('\n'):
        new_txt += '\n'
    old_txt = '\n'.join(old)
    if not old_txt.endswith('\n'):
        old_txt += '\n'

    if new_txt == old_txt:
        print('[OK] 清单已是最新: %d 项 zx.*, 0 改动。' % len(names))
        return

    # 差异报告
    old_body = set(l.strip() for l in body_slice if l.strip())
    new_body = set(build_body(names))
    missing = sorted(old_body - new_body)
    added = sorted(new_body - old_body)
    print('清单更新: %d 项 zx.*  (新增 %d / 移除 %d)'
          % (len(names), len(added), len(missing)))
    for l in added[:20]:
        print('   + %s' % l)
    if len(added) > 20:
        print('   … 还有 %d 条新增' % (len(added) - 20))
    for l in missing[:20]:
        print('   - %s' % l)
    if len(missing) > 20:
        print('   … 还有 %d 条移除' % (len(missing) - 20))

    if not write:
        print('\n(试运行; 加 --write 真正写入)')
        return
    with open(TARGET, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(new_txt)
    print('\n[写入] %s' % TARGET)


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                                  errors='replace')
    main()
