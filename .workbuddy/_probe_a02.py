# -*- coding: utf-8 -*-
r"""_probe_a02.py —— A01/A02/A03/A04 新守门规则的**反向探针**。

规矩(见 RULES): 每加一条形态锁, 必须"反向证明它会报警" —— 逐条把源码破坏一次,
确认 check.py 真的报出**那一条**(靠 why 文本里的独特片段认领), 再还原。
只看"合计 0"不算证明(可能是死规则: 正则写错, 永远不命中)。

★ 认领片段必须落在 check.py **真正打印出来的文本**里:
  · 形态锁消息 = `缺少"修复标志"(应含 \`<must>\`) —— <说明>`
  · never 锁   = `又写回了已修掉的老写法 —— <说明>`
  · order 锁   = `「<应更晚者>」(第 n 行) 排在「<应更早者>」(第 m 行) 之前 —— <说明>`
  且 check.py 对**非 regress 桶**按 180 字截断行 —— 长 must 会把 `—— 说明` 挤出去。
  所以: ① 认领一律用**说明里靠前**的独特片段; ② check.py 的 regress 桶已改成不截断
  (见 check.py 打印处注释), 否则 effect_2/migrate 这类长 must 的锁根本没法认领。
  *(2026-10-11 实测教训: 第一版探针 18/31"未命中", 全部是**认领片段被截断**导致 ——
   锁本身一条不落全触发了。)*

用法:
    python .workbuddy/_probe_a02.py
    python .workbuddy/_probe_a02.py --only effect_2      # 只跑名字含该子串的几条
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

# ---- 关键整行(逐字) ----
L_MIG_1 = ('$execute if data storage manacore:players "$(h0)" unless data storage manacore:players '
           '"$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"')
L_MIG_3 = ('$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players '
           '"$(h0)" unless data storage manacore:players "$(uuid)".reg run data modify storage '
           'manacore:players_all list append value "$(uuid)"')
L_MIG_4 = ('$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players '
           '"$(uuid)".reg run data modify storage manacore:players "$(uuid)".reg set value 1b')
L_REG_A = ('$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players '
           '"$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"')
L_REG_B = ('$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players '
           '"$(uuid)".reg run data modify storage manacore:players "$(uuid)".reg set value 1b')

PR = 'function sweetdream:internal/attr/cleanup'
E1_SLOT = ('execute unless entity @s[tag=zx.ret_off] store result storage zx:work a.slot int 1 '
           'run data get entity @s SelectedItemSlot')
E1_ENQ = 'function sweetdream:internal/itembackup/enqueue with storage zx:work a'
ENQ_MIR = ('$execute if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot '
           'run data get storage zx:ret p."$(uuid)".q[0].slot')
ENQ_APP = ('$execute if data storage zx:ret p."$(uuid)".stage.$(src).id run data modify '
           'storage zx:ret p."$(uuid)".q append value {slot:$(slot)}')

E2 = None  # 运行期填(需要按正则找整行)

MUL_HARD = '$scoreboard players operation #q manacore.math = $(src) $(obj)'
REST_POP = 'execute if score #ret_ok zx.meta matches 1 run data remove storage zx:ret p."probe"'
SRC_LINE = 'data modify storage zx:work a.src set value "mainhand"'
BG_FREEZE = ('execute unless score @s zx.ret_pend matches 1.. run function '
             'sweetdream:internal/itembackup/backup with storage zx:work a')
CLEAN_ADD = 'attribute @s minecraft:attack_speed modifier add sweetdream:probe 1.0 add_multiplied_base'
LOAD_WAIT = ('execute unless data storage zx:config obj_ret_wait run scoreboard objectives '
             'add zx.ret_wait dummy')


def LINES(rel):
    with open(os.path.join(ROOT, rel), encoding='utf-8') as f:
        return f.read().split('\n')


def find_line(rel, needle):
    for l in LINES(rel):
        if needle in l:
            return l
    raise SystemExit('[探针自检失败] %s 里找不到含 `%s` 的行' % (rel, needle))


# (名字, 文件, 操作, 参数, 期望片段)
def build_probes():
    e2 = SD + '/internal/itembackup/effect_2.mcfunction'
    e2_hot8 = find_line(e2, 'dst:"hotbar.8"')
    e2_inv26 = find_line(e2, 'dst:"inventory.26"')
    e2_pref = find_line(e2, 'dst:"hotbar.$(slot)"')
    e2_pop = find_line(e2, 'if score #ret_ok zx.meta matches 1 run data remove storage')
    e2_reset = find_line(e2, 'if score @s zx.ret_pend matches 1.. unless data storage zx:ret '
                             'p."$(uuid)".q[0] run scoreboard players set @s zx.ret_slot -2')
    e2_pend = find_line(e2, 'if score @s zx.ret_pend matches 1.. unless data storage zx:ret '
                            'p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 0')
    e2_mir = find_line(e2, 'if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot')
    e2_h0 = find_line(e2, 'dst:"hotbar.0"')
    pr_first = find_line(SD + '/event/player_reset.mcfunction', 'scoreboard players reset @s zx.ab_age')

    P = [
        # ---- mul_pct(A01 出参 objective 参数化) ----
        ('mul_pct #lo 减号', MC + '/internal/damage/mul_pct.mcfunction', 'del',
         '$scoreboard players operation #lo $(obj) -= #r $(obj)', '#lo $(obj) -= #r $(obj)'),
        ('mul_pct #mul_out 出参', MC + '/internal/damage/mul_pct.mcfunction', 'del',
         '$scoreboard players operation #mul_out $(obj) += #lo $(obj)',
         '#mul_out $(obj) += #lo $(obj)'),
        ('mul_pct 禁止硬编码 objective', MC + '/internal/damage/mul_pct.mcfunction', 'ins',
         MUL_HARD, '硬编码'),
        # ---- A03: uuid/migrate 双键漏登记 + 运维入口 ----
        ('migrate ①登记守卫', MC + '/internal/uuid/migrate.mcfunction', 'del',
         L_MIG_1, '终身清单登记必须'),
        ('migrate ③双键补登记', MC + '/internal/uuid/migrate.mcfunction', 'del',
         L_MIG_3, '旧键已不在'),
        ('migrate reg 后置于登记', MC + '/internal/uuid/migrate.mcfunction', 'swap',
         (L_MIG_1, L_MIG_4), '报告 A03 那个场景'),
        ('registry_add append 守卫', MC + '/debug/registry_add.mcfunction', 'del',
         L_REG_A, '照抄守门条件'),
        ('registry_add reg 幂等', MC + '/debug/registry_add.mcfunction', 'del',
         L_REG_B, '打 reg 标志的条件与登记完全一致'),
        # ---- A04: 重置前摘状态型修饰符 ----
        ('player_reset cleanup 先于清分', SD + '/event/player_reset.mcfunction', 'swap',
         (PR, pr_first), '第一条 reset 排在 cleanup 之后'),
        ('cleanup 摘 meteor', SD + '/internal/attr/cleanup.mcfunction', 'del',
         'attribute @s minecraft:attack_speed modifier remove sweetdream:meteor', '熔星的攻速倍率必须显式摘'),
        ('cleanup 摘 lethe_speed', SD + '/internal/attr/cleanup.mcfunction', 'del',
         'attribute @s minecraft:movement_speed modifier remove sweetdream:lethe_speed',
         '残念的速度倍率必须显式摘'),
        ('cleanup 去 zx.lethe', SD + '/internal/attr/cleanup.mcfunction', 'del',
         'tag @s remove zx.lethe', '状态标签**必须一起摘'),
        ('cleanup 只许摘不许挂', SD + '/internal/attr/cleanup.mcfunction', 'ins',
         CLEAN_ADD, '只许摘'),
        # ---- A02: effect_1 / enqueue / effect_2 / restore / return_go / recover_go / backup_go ----
        ('effect_1 读 SelectedItemSlot', SD + '/internal/itembackup/effect_1.mcfunction', 'del',
         E1_SLOT, '读进 zx:work a.slot'),
        ('effect_1 必须入队', SD + '/internal/itembackup/effect_1.mcfunction', 'del',
         E1_ENQ, '消耗当刻必须**入队**'),
        ('enqueue 按队首重算镜像', SD + '/internal/itembackup/enqueue.mcfunction', 'del',
         ENQ_MIR, '按队首重算'),
        ('enqueue 条目 append', SD + '/internal/itembackup/enqueue.mcfunction', 'del',
         ENQ_APP, '队列条目'),
        ('effect_2 首选原格(②-a)', e2, 'del', e2_pref, 'R01 的正写形态 ②-a'),
        ('effect_2 兜底扫快捷栏', e2, 'del', e2_hot8, '兜底扫描(快捷栏 0..8)'),
        ('effect_2 兜底扫主背包', e2, 'del', e2_inv26, '兜底扫描(主背包'),
        ('effect_2 落地才出队', e2, 'del', e2_pop, '出队: **落地成功'),
        ('effect_2 出队后重算镜像', e2, 'del', e2_mir, '出队后重算队首镜像'),
        ('effect_2 出队后销账', e2, 'del', e2_pend, '出队后销账'),
        ('effect_2 镜像复位先于销账', e2, 'swap', (e2_reset, e2_pend), 'ret_pend 清零之前'),
        ('effect_2 禁止 items…air 判空', e2, 'repl',
         (e2_h0, e2_h0.replace('unless items entity @s hotbar.0 *', 'if items entity @s hotbar.0 air')),
         '又写回了已修掉的老写法'),
        ('effect_2 禁止固定快照键', e2, 'repl',
         (e2_pref, e2_pref.replace('q[0].item.id', 'mainhand.id')), 'A02(2026-10-11 三审) ⑦'),
        ('restore 不删/不销账', SD + '/internal/itembackup/restore.mcfunction', 'ins',
         REST_POP, '只负责"把队首 q[0].item 写进这一格'),
        ('return_go 不再备 src', SD + '/internal/itembackup/return_go.mcfunction', 'ins',
         SRC_LINE, '别再写 a.src'),
        ('recover_go 不再备 src', SD + '/internal/itembackup/recover_go.mcfunction', 'ins',
         SRC_LINE, '不再备 $(src)'),
        ('backup_go 不冻结', SD + '/internal/itembackup/backup_go.mcfunction', 'ins',
         BG_FREEZE, '暂存区(stage.*)不再需要'),
        ('load 声明 zx.ret_wait', SD + '/core/load.mcfunction', 'del',
         LOAD_WAIT, '新增 zx.ret_wait'),
    ]
    return P


# rel -> 该文件此刻的原始文本(尚未还原)。任何异常路径下靠 _sweep() 兜底。
_PENDING = {}


def _write(p, text):
    """★ 写盘必须能扛**瞬时**错误: 实测 `open(w)` 偶发 OSError Errno 22(疑似句柄/杀软),
    而它恰好发生在 finally 的**还原**里 ⇒ 源码留在被破坏态(2026-10-11 实际踩到:
    migrate.mcfunction 被留在"reg 排在登记之前"的换序态)。"""
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
    """返回还原用的原始文本。"""
    p = os.path.join(ROOT, rel)
    with open(p, encoding='utf-8') as f:
        orig = f.read()
    _PENDING[rel] = orig                  # ★ 先登记兜底表, 再动盘
    lines = orig.split('\n')
    if op == 'del':
        assert arg in lines, 'del 目标行不在: %s' % arg[:60]
        lines.remove(arg)
    elif op == 'ins':
        # 插在第一条非注释命令之前(避免落在注释里)
        idx = next(i for i, l in enumerate(lines) if l.strip() and not l.strip().startswith('#'))
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
    """★ 只取 **stdout**: check.py 的 stderr 里带两条 SyntaxWarning(消息里会回显自身
    源码片段), 拼进来会把"最后一行"判定污染成一行源码。"""
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
    # 还原后必须 0
    tail = run_check().strip().split('\n')[-1]
    print('\n探针 %d/%d 命中; 还原后: %s' % (ok, len(probes), tail))
    if miss:
        print('未命中清单: ' + '; '.join(miss))
    if ok != len(probes) or '合计问题: 0' not in tail:
        raise SystemExit(1)


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    atexit.register(_sweep)                # ★ 任何正常/异常退出都兜底还原
    for _s in ('SIGTERM', 'SIGINT', 'SIGBREAK'):   # 被 timeout 杀掉时也要还原
        if hasattr(signal, _s):
            try:
                signal.signal(getattr(signal, _s), _on_signal)
            except (ValueError, OSError):
                pass
    main()
