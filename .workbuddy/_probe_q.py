# -*- coding: utf-8 -*-
r"""_probe_q.py —— 四审 Q01~Q06 新守门规则的**反向探针**。

规矩(见 RULES): 每加一条形态锁, 必须"反向证明它会报警" —— 逐条把源码破坏一次,
确认 check.py 真的报出**那一条**(靠消息里的独特片段认领), 再还原。
只看"合计 0"不算证明(可能是死规则: 正则写错, 永远不命中)。

★ 认领片段的规矩(踩过两次):
  · `_REGRESS` 的三类消息: `缺少"修复标志"(应含 \`<must>\`) —— <说明>` /
    `又写回了已修掉的老写法 —— <说明>` / `「a」排在「b」之前 —— <说明>`。
  · 认领一律取 `<说明>` 里**靠前**且**不含 Markdown 粗体星号**的连续片段
    (星号会让逐字匹配变脆; 截断问题则见下)。
  · check.py 对非 regress 桶按 180 字截断 —— `regress` 桶已改成不截断
    (2026-10-11 三审实测: 首轮 31 条只报 13 命中, 全是认领片段被截断, 锁其实活的)。
  · ★ `_REGRESS` 的 must/never 只看**非注释行** ⇒ 注释锚点(如尾标记)必须在
    专门规则里守, 本探针第 13 条就验证那条规则真的会报警。

用法:
    python .workbuddy/_probe_q.py
    python .workbuddy/_probe_q.py --only resync      # 只跑名字含该子串的几条
输出末尾必须打印 "全部命中 / 还原 0"。
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
ML = SD + '/internal/itembackup/migrate_legacy.mcfunction'
RS = SD + '/internal/itembackup/resync.mcfunction'
RSG = SD + '/internal/itembackup/resync_go.mcfunction'
PJ = SD + '/event/player_join.mcfunction'
PRJ = 'sweetdream/data/manacore/tags/function/event/player_join.json'
PR = SD + '/event/player_reset.mcfunction'
CU = SD + '/internal/attr/cleanup.mcfunction'
BFP = '.workbuddy/build_full_pack.py'
MP = MC + '/internal/damage/mul_pct.mcfunction'
RA = MC + '/debug/registry_add.mcfunction'

# 旧式(已修掉)的 registry_add 登记行 —— 用来验证 never 锁真的会拦
RA_OLD = ('$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players '
          '"$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"')
# Q06 之前的 ③ 步写法 —— 用来验证 never 锁
MP_OLD = '$scoreboard players operation #lo $(obj) *= $(mul) $(obj)'


def LINES(rel):
    with open(os.path.join(ROOT, rel), encoding='utf-8') as f:
        return f.read().split('\n')


def find_line(rel, needle):
    for l in LINES(rel):
        if needle in l:
            return l
    raise SystemExit('[探针自检失败] %s 里找不到含 `%s` 的行' % (rel, needle))


def build_probes():
    ml_judge = find_line(ML, 'scoreboard players set #lg_main zx.meta 1')
    ml_move = find_line(ML, '.q[0].item set from storage zx:ret p."$(uuid)".mainhand')
    ml_del = find_line(ML, 'data remove storage zx:ret p."$(uuid)".mainhand')
    ml_off_append = find_line(ML, '.q append value {slot:-1}')
    ml_off_flag = find_line(ML, 'offhand.id run scoreboard players set #lg_off zx.meta 1')
    ml_resync = find_line(ML, 'function sweetdream:internal/itembackup/resync_go')

    rs_mir = find_line(RS, '.q[0].slot')
    rs_clear = find_line(RS, 'run scoreboard players set @s zx.ret_pend 0')
    rsg_call = find_line(RSG, 'resync with storage zx:work a')

    pr_resync = find_line(PR, 'function sweetdream:internal/itembackup/resync_go')
    pr_first = find_line(PR, 'scoreboard players reset @s zx.ab_age')
    pr_endmark = find_line(PR, '# @@GEN-SCORES-ABOVE@@')

    return [
        # ---- Q01(旧快照 -> 新队列的升级迁移) ----
        ('Q01 ml 判据缺 ret_pend', ML, 'del', ml_judge, 'Q01(四审): 迁移的'),
        ('Q01 ml 搬移缺 set from', ML, 'del', ml_move, '主手那笔必须把'),
        ('Q01 ml 缺删旧键', ML, 'del', ml_del, '成功搬进队列后删掉旧键'),
        ('Q01 ml 先建队列后算标志', ML, 'swap', (ml_off_append, ml_off_flag), '顺序不能反'),
        ('Q01 ml 缺 resync', ML, 'del', ml_resync, '否则下一秒 recover 的选择器'),
        ('Q01 player_join 缺迁移调用', PJ, 'del',
         find_line(PJ, 'migrate_legacy with storage zx:work a'),
         'register 末尾, 每次上线/重注册都抛'),
        ('Q01 player_join 标签未挂', PRJ, 'repl',
         ('    "sweetdream:event/player_join"', '    "sweetdream:event/noop"'),
         '新的上线收尾函数必须真的挂进跨包事件标签'),
        # ---- Q02(重置后按队列重建镜像) ----
        ('Q02 resync 缺镜像重算', RS, 'del', rs_mir, '而不是照抄旧分数'),
        ('Q02 resync 缺反向复位', RS, 'del', rs_clear, 'q 空时要把镜像复位成干净态'),
        ('Q02 resync_go 缺宏调用', RSG, 'del', rsg_call, '宏函数不能裸调'),
        ('Q02 player_reset 缺 resync', PR, 'del', pr_resync, '清账之后必须真的调用镜像重建'),
        ('Q02 player_reset resync 排太早', PR, 'swap', (pr_resync, pr_first),
         '放前面的话刚建的镜像会被清单立刻 reset 掉'),
        ('Q02 player_reset 缺尾标记', PR, 'del', pr_endmark, '缺尾标记'),
        # ---- Q04(装备型修饰符一并摘净) ----
        ('Q04 cleanup 缺 eqp_power_hp', CU, 'del',
         find_line(CU, 'modifier remove sweetdream:eqp_power_hp'), '装备型修饰符也必须摘'),
        ('Q04 cleanup 缺 eqp_mr_set_atk', CU, 'del',
         find_line(CU, 'modifier remove sweetdream:eqp_mr_set_atk'), '蜃楼套装攻击力'),
        ('Q04 cleanup 缺 status.liuhuo', CU, 'del',
         find_line(CU, 'tag @s remove zx.status.liuhuo'), 'liuhuo 的撤销只在'),
        ('Q04 cleanup 缺 rm_melt', CU, 'del',
         find_line(CU, 'tag @s remove zx.rm_melt'), 'remelt/second 每秒认这个标签'),
        # ---- Q05(增量入口保护 pack.description) ----
        ('Q05 缺 pack.description 保护', BFP, 'del',
         find_line(BFP, "metadata.append('pack.mcmeta 的 pack.description')"),
         '旧护栏只盯 65 个弩资源'),
        # ---- Q06(③ 步对倍率二次分解) ----
        ('Q06 mul_pct 缺 #q1 二次分解', MP, 'del',
         find_line(MP, '#lo $(obj) *= #q1 $(obj)'), '③ 步后半必须走'),
        ('Q06 mul_pct 缺 #r2 行', MP, 'del',
         find_line(MP, '#t $(obj) *= #r2 $(obj)'), '是二次分解的全部'),
        ('Q06 mul_pct 写回 #lo *= mul', MP, 'ins', MP_OLD, '一律不许写回'),
        # ---- Q03(registry_add 强制补登记) ----
        ('Q03 registry_add 写回 unless reg', RA, 'ins', RA_OLD, '运维入口的登记行'),
    ]


_PENDING = {}


def _write(p, text):
    """★ 写盘必须能扛**瞬时**错误(Errno 22 实测偶发) —— 它若发生在 finally 的还原里,
    源码就会留在被破坏态(2026-10-11 三审实际踩到)。"""
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
    elif op == 'swap':
        a, b = arg
        ia = lines.index(a)
        ib = lines.index(b)
        lines[ia], lines[ib] = lines[ib], lines[ia]
    elif op == 'repl':
        a, b = arg
        assert a in lines, 'repl 目标行不在: %s' % a[:60]
        assert a != b, 'repl 前后相同'
        lines[lines.index(a)] = b
    else:
        raise SystemExit('未知 op ' + op)
    _write(p, '\n'.join(lines))
    return orig


def restore(rel, orig):
    _write(os.path.join(ROOT, rel), orig)
    _PENDING.pop(rel, None)


def run_check():
    """★ 只取 stdout: stderr 里的 SyntaxWarning 会把"最后一行"污染成源码片段。"""
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
        print('%-40s %s' % (name, '命中 ✓' if hit else '**未命中** ✗  (期望片段: %s)' % frag))
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
