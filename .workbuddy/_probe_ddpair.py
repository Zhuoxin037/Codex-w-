# -*- coding: utf-8 -*-
"""反向探针(坑 138 · ddpair): 证明新规则真的会报警。
   三幕, 每幕临时改一处、跑 check.py 数命中、再看还原。
   ★ 还原必须比断言更可靠: 写盘重试 + atexit/信号兜底。
"""
import atexit
import signal
import subprocess
import sys
from pathlib import Path

BASE = Path(r'D:/数据包/sweetdream/data/sweetdream/function/equipment/armor/dusk_dawn')
ADV = Path(r'D:/数据包/sweetdream/data/sweetdream/advancement/equipment/armor')
WRAP = BASE / 'kill_mark_yuanhai.mcfunction'
KI = BASE / 'kill_init.mcfunction'
MERGED = ADV / 'dusk_dawn_kill_mark.json'

# ★ 一律走 bytes: 文本模式 read_text/write_text 在 Windows 上会把 CRLF<->LF 来回换,
#   还原出来的字节就和原文件不一样(源↔存档逐字节核对立刻报警)。
_ORIG = {p: p.read_bytes() for p in (WRAP, KI)}
_PENDING = set()


def _restore():
    for p, raw in _ORIG.items():
        for _ in range(3):
            try:
                p.write_bytes(raw)
                break
            except OSError:
                pass
    for _ in range(3):
        try:
            if MERGED.exists():
                MERGED.unlink()
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


def _scenario(name, path, old, new, expect):
    orig = _ORIG[path]
    o_b, n_b = old.encode('utf-8'), new.encode('utf-8')
    assert o_b in orig, '[%s] 探针前提不成立: 找不到 %r' % (name, old)
    _PENDING.add(path)
    path.write_bytes(orig.replace(o_b, n_b))
    try:
        out = _run()
        hits = [l for l in out.splitlines() if expect in l]
        print('[%s] 命中行数: %d' % (name, len(hits)))
        for l in hits[:4]:
            print('    ' + l.strip()[:170])
    finally:
        _restore()
        print('[%s] 已还原(逐字节): %s' % (name, path.read_bytes() == orig))


# 幕 1: wrapper 首行 revoke 换成了别人的进度 —— 应报"首行必须是 ...自己那条"
_scenario('A wrapper 首行 revoke 错进度', WRAP,
          'advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark_yuanhai',
          'advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill_mark_liuhuo',
          '黄昏黎明 100×X(坑 138)')

# 幕 2: kill_init 不归零 dd_n —— 应报"第二次击杀接着上次涨"
_scenario('B kill_init 不归零 dd_n', KI,
          'scoreboard players set @s zx.dd_n 0\n',
          '',
          '黄昏黎明 100×X(坑 138)')

# 幕 3: 把旧的**合并版**进度文件放回来 —— 应报"会同刻触发两遍, X 虚高"
MERGED.write_text('{"criteria": {}, "rewards": {}}', encoding='utf-8')
try:
    out = _run()
    hits = [l for l in out.splitlines() if '黄昏黎明 100×X(坑 138)' in l]
    print('[C 恢复合并版进度] 命中行数: %d' % len(hits))
    for l in hits[:4]:
        print('    ' + l.strip()[:170])
finally:
    _restore()
    print('[C 恢复合并版进度] 已还原(文件删除): %s' % (not MERGED.exists()))
