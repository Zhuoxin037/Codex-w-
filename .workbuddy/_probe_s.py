# -*- coding: utf-8 -*-
r"""_probe_s.py —— 五审修复(S01~S03)新增守门规则的**反向探针**。

背景: 五审报告指出 S01/S02/S03 三条 P2, 修复流程已在 .workbuddy/check.py 里
新增 11 条 `_REGRESS` 形态锁, 但**没有反向探针记录**。本脚本按项目铁律补做:
逐条把源码破坏一次, 确认 check.py 真的报出**那一条**(靠 why 里的独特片段认领),
再还原。只看"合计 0"不算证明(可能是死规则)。

★ 认领片段的规矩(见 RULES 坑 113): 取 why 里**靠前**且**不含 Markdown 星号**的
  连续片段; `regress` 桶已改成不截断(四审), 所以靠前片段一定在 stdout 里。
★ 本脚本会**临时改源码** —— 运行期间不要并发跑 check.py / 部署。
★ 写盘重试 + `_PENDING` 兜底 + `atexit`/信号 `_sweep`(四审事故的三道保险)。

用法:
    python .workbuddy/_probe_s.py
    python .workbuddy/_probe_s.py --only S03
"""
import atexit
import io
import os
import signal
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
CHECK = os.path.join(ROOT, '.workbuddy', 'check.py')

SD = 'sweetdream/data/sweetdream/function'
MC = 'manacore-1.0.0/data/manacore/function'
LS = SD + '/equipment/armor/lightless_sea/passive.mcfunction'
WT = SD + '/equipment/armor/withered_garden/wood_tick.mcfunction'
JN = MC + '/internal/join/new.mcfunction'
PPN = SD + '/event/player_prepare_new.mcfunction'
T1 = 'manacore-1.0.0/data/manacore/tags/function/event/player_prepare_new.json'
T2 = 'sweetdream/data/manacore/tags/function/event/player_prepare_new.json'
LR = SD + '/lib/ledger_resync_go.mcfunction'


def LINES(rel):
    with open(os.path.join(ROOT, rel), encoding='utf-8') as f:
        return f.read().split('\n')


def find_line(rel, needle):
    for l in LINES(rel):
        if needle in l:
            return l
    raise SystemExit('[探针自检失败] %s 里找不到含 `%s` 的行' % (rel, needle))


def build_probes():
    ls_ok = find_line(LS, 'nbt={active_effects:')
    ls_bad = ls_ok.replace('active_effects', 'ActiveEffects')
    wt_ok = find_line(WT, 'nbt={active_effects:')
    wt_bad = wt_ok.replace('active_effects', 'ActiveEffects')

    ppn_call = find_line(JN, 'function #manacore:event/player_prepare_new')
    ba_line = find_line(JN, 'record.stats.base_attack double 1 run attribute')
    sf_line = find_line(JN, '#slot_full manacore.meta matches 1 run return 0')

    t1_line = find_line(T1, 'manacore:event/noop')
    t1_bad = t1_line.replace('manacore:event/noop', 'manacore:event/nope')
    t2_line = find_line(T2, 'sweetdream:event/player_prepare_new')
    t2_bad = t2_line.replace('sweetdream:event/player_prepare_new', 'sweetdream:event/nope')

    ls_add = find_line(LR, 'lightless_sea/atk_add with storage zx:work x')
    ls_rm = find_line(LR, 'modifier remove sweetdream:eqp_ls_atk')
    mr_add = find_line(LR, 'mirage/set_atk_add with storage zx:work x')
    mr_rm = find_line(LR, 'modifier remove sweetdream:eqp_mr_set_atk')

    return [
        # ---- S01 ----
        ('S01 无光之海 写回 ActiveEffects', LS, 'repl', (ls_ok, ls_bad),
         'S01: 无光之海缓慢源必须读'),
        ('S01 枯萎花园 写回 ActiveEffects', WT, 'repl', (wt_ok, wt_bad),
         'S01: 枯萎花园缓慢伤害圈必须读'),
        # ---- S02 ----
        ('S02 join/new 缺建档前清理', JN, 'del', ppn_call,
         'S02: 应用清旧属性必须早于建档读取'),
        ('S02 建档前清理排到读取之后', JN, 'mv_after', (ppn_call, ba_line),
         'S02: 应用清旧属性必须早于建档读取'),
        ('S02 建档前清理排到槽位检查之前', JN, 'mv_before', (ppn_call, sf_line),
         'S02: 槽位耗尽时不得清属性'),
        ('S02 前置包标签丢失', T1, 'repl', (t1_line, t1_bad),
         'S02: 前置包必须定义建档前事件标签'),
        ('S02 sweetdream 未挂钩子', T2, 'repl', (t2_line, t2_bad),
         'S02: sweetdream 必须挂载建档前清理'),
        ('S02 建档前清理调了 uuid/API', PPN, 'ins', 'function sweetdream:lib/uuid',
         'S02: 未登记时只摘属性'),
        # ---- S03 ----
        ('S03 无光之海 漏重挂', LR, 'del', ls_add,
         'S03: 无光之海账本兼作三秒宽限缓存'),
        ('S03 无光之海 清零账本', LR, 'ins', 'scoreboard players set @s zx.ls_buf 0',
         'S03: 无光之海账本兼作三秒宽限缓存'),
        ('S03 无光之海 漏先摘', LR, 'del', ls_rm,
         'S03: 无光之海重挂必须先摘同 id'),
        ('S03 蜃楼 漏重挂', LR, 'del', mr_add,
         'S03: 蜃楼保留面板与旧账只重挂属性'),
        ('S03 蜃楼 漏先摘', LR, 'del', mr_rm,
         'S03: 蜃楼重挂必须先摘同 id'),
    ]


_PENDING = {}


def _write(p, text):
    last = None
    for _ in range(8):
        try:
            with open(p, 'w', encoding='utf-8', newline='\n') as f:
                f.write(text)
            return
        except OSError as e:
            last = e
            time.sleep(0.5)
    raise SystemExit('[探针写盘失败] %s: %s' % (p, last))


def _sweep():
    for _rel, _orig in list(_PENDING.items()):
        try:
            _write(os.path.join(ROOT, _rel), _orig)
            _PENDING.pop(_rel, None)
            print('[sweep] 已兜底还原 %s' % _rel)
        except BaseException as _e:                      # noqa: BLE001
            print('[sweep] !! 兜底还原失败 %s: %s' % (_rel, _e))


def _on_signal(signum, _frame):
    print('\n[signal %d] 终止信号 —— 先兜底还原再退' % signum)
    _sweep()
    sys.stdout.flush()
    os._exit(2)


def mutate(rel, op, arg):
    p = os.path.join(ROOT, rel)
    with open(p, encoding='utf-8') as f:
        orig = f.read()
    _PENDING[rel] = orig                  # ★ 先登记兜底表, 再动盘
    lines = orig.split('\n')
    if op == 'del':
        assert arg in lines, 'del 目标行不在: %s' % arg[:60]
        lines.remove(arg)
    elif op == 'ins':
        idx = next(i for i, l in enumerate(lines)
                   if l.strip() and not l.strip().startswith('#'))
        lines.insert(idx, arg)
    elif op == 'repl':
        a, b = arg
        assert a in lines, 'repl 目标行不在: %s' % a[:60]
        assert a != b, 'repl 前后相同'
        lines[lines.index(a)] = b
    elif op in ('mv_after', 'mv_before'):
        a, b = arg
        assert a in lines and b in lines, 'mv 目标行不在'
        lines.remove(a)
        ib = lines.index(b)
        lines.insert(ib + 1 if op == 'mv_after' else ib, a)
    else:
        raise SystemExit('未知 op ' + op)
    _write(p, '\n'.join(lines))
    return orig


def restore(rel, orig):
    _write(os.path.join(ROOT, rel), orig)
    _PENDING.pop(rel, None)


def run_check():
    r = subprocess.run([PY, CHECK], cwd=ROOT, capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    return r.stdout or ''


def main():
    only = None
    if '--only' in sys.argv:
        only = sys.argv[sys.argv.index('--only') + 1]
    probes = build_probes()
    if only:
        probes = [p for p in probes if only in p[0]]
        print('# --only %s => %d 条' % (only, len(probes)))
    ok = 0
    miss = []
    for name, rel, op, arg, frag in probes:
        orig = mutate(rel, op, arg)
        try:
            out = run_check()
        finally:
            restore(rel, orig)
        hit = frag in out
        print('%-38s %s' % (name, '命中 ✓' if hit else '**未命中** ✗  (期望片段: %s)' % frag))
        sys.stdout.flush()
        if hit:
            ok += 1
        else:
            miss.append(name)
    tail = run_check().strip().split('\n')[-1]
    print('\n探针 %d/%d 命中; 还原后: %s' % (ok, len(probes), tail))
    if miss:
        print('未命中清单: ' + '; '.join(miss))
    if ok != len(probes) or '合计问题: 0' not in tail:
        raise SystemExit(1)


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    atexit.register(_sweep)
    for _s in ('SIGTERM', 'SIGINT', 'SIGBREAK'):
        if hasattr(signal, _s):
            try:
                signal.signal(getattr(signal, _s), _on_signal)
            except (ValueError, OSError):
                pass
    main()
