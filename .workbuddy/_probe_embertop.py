# -*- coding: utf-8 -*-
"""反向探针(坑 137 · embertop): 证明余烬那两条新规则真的会报警。
   三幕, 每幕临时改一处、跑 check.py 数命中、再看还原。
   ★ 还原必须比断言更可靠: 写盘重试 + atexit/信号兜底。
   ★ 一律 bytes 读写 —— 文本模式在 Windows 上会做 CRLF<->LF 转换, 把文件改脏。
"""
import atexit
import signal
import subprocess
import sys
from pathlib import Path

BASE = Path(r'D:/数据包/sweetdream/data/sweetdream/function/equipment/armor/ember')
BO = BASE / 'burned_out.mcfunction'
TU = BASE / 'top_up.mcfunction'

_ORIG = {p: p.read_bytes() for p in (BO, TU)}
_PENDING = set()


def _restore():
    for p, raw in _ORIG.items():
        for _ in range(3):
            try:
                p.write_bytes(raw)
                break
            except OSError:
                pass
    _PENDING.clear()


def _on_signal(signum, frame):
    _restore()
    sys.exit(1)


atexit.register(_restore)
for _s in (signal.SIGINT, signal.SIGTERM):
    try:
        signal.signal(_s, _on_signal)
    except (ValueError, OSError):
        pass


def _run():
    r = subprocess.run([sys.executable, r'D:/数据包/.workbuddy/check.py'],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    return r.stdout


def _scenario(name, path, old, new, expect, count=1):
    orig = _ORIG[path]
    o_b, n_b = old.encode('utf-8'), new.encode('utf-8')
    assert o_b in orig, '[%s] 探针前提不成立: 找不到 %r' % (name, old)
    _PENDING.add(path)
    path.write_bytes(orig.replace(o_b, n_b))
    try:
        out = _run()
        hits = [l for l in out.splitlines() if expect in l]
        print('[%s] 命中行数: %d (期望 %d)' % (name, len(hits), count))
        for l in hits[:4]:
            print('    ' + l.strip()[:170])
    finally:
        _restore()
        print('[%s] 已还原(逐字节): %s' % (name, path.read_bytes() == orig))


CALL = ('execute if entity @s[tag=zx.status.yehuo] '
        'run function sweetdream:equipment/armor/ember/top_up')
BACK = 'execute if entity @s[tag=zx.status.yehuo] run return 0'

# 幕 1: burned_out 不再调 top_up —— 应报"没有调用 ember/top_up"(=又变回静默吞掉这一支)
_scenario('A 不调 top_up', BO, CALL + '\n', '', '余烬补流火(坑 137)')

# 幕 2: 把"见夜火即 return 0"挪到 top_up 前面 —— 应报顺序错(补流火成死代码)
_scenario('B 顺序调换(先收工再补)', BO, CALL + '\n' + BACK, BACK + '\n' + CALL,
          '余烬补流火(坑 137)')

# 幕 3: top_up 的节流闸改名 —— 应报"没有 5 秒节流"
#   ★ 替换串刻意不含 zx.em_gate 子串之外的残留, 顺带验证判据是子串判定而不是别的。
_scenario('C 节流闸被去掉', TU, 'zx.em_gate', 'zx.probe_off', '余烬补流火(坑 137)')
