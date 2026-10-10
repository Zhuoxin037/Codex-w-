#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
_probe_beamoff —— check.py 「坑 69: 与视线共线的粒子光束」规则的反向探针。

跑法:  python .workbuddy/_probe_beamoff.py
它做三件事:
  A) 把 beam.mcfunction 的 `^-0.35` 全部删掉(变成轴线上)   -> 必须报 beamoff
  B) 负向对照: 只留 2 条轴线粒子行的 immolate/hurt          -> 必须**不**报(阈值 5 条)
  C) 还原                                                     -> 必须 0
全过 = 规则真的能抓, 不是假绿。
"""
import io
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PY = sys.executable
CHECK = ROOT / '.workbuddy' / 'check.py'
BEAM = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
        / 'staff' / 'final_revelation' / 'beam.mcfunction')
IMMO = (ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
        / 'armor' / 'immolate' / 'hurt.mcfunction')


def run_check():
    p = subprocess.run([PY, str(CHECK)], capture_output=True, text=True, encoding='utf-8',
                       errors='replace', cwd=str(ROOT))
    out = p.stdout or ''
    # 真正的"命中行" = 缩进 4 空格开头的那种; 方括号开头的是**规则标题行**(永远存在),
    # 不能算进去(否则 0 命中也会被误判成 1 条)。
    hits = [ln for ln in out.splitlines()
            if ln.startswith('    ') and ('beamoff' in ln or '视线轴线' in ln)]
    total = None
    m = re.search(r'合计问题:\s*(\d+)', out)
    if m:
        total = int(m.group(1))
    return total, hits, out


def main():
    orig_beam = BEAM.read_bytes()
    results = []
    try:
        # --- A) 改坏: 删掉本地 Y 偏移 -> 轴线上 ---
        bad = orig_beam.decode('utf-8').replace('positioned ^ ^-0.35 ^', 'positioned ^ ^ ^')
        BEAM.write_bytes(bad.encode('utf-8'))
        total_a, hits_a, _ = run_check()
        results.append(('A 删掉^-0.35(改坏)', '报错', bool(hits_a),
                        '合计 %s, 命中 %d 条' % (total_a, len(hits_a))))

        # --- B) 负向对照: 只 2 条轴线粒子行, 不该报 ---
        #   直接把 beam 恢复成"只有 2 行轴线粒子"的最小文件, 但落在 immolate 那种位置上
        #   更简单: 恢复 beam, 然后确认 immolate/hurt 那 2 条**没有**被点名
        BEAM.write_bytes(orig_beam)
        total_b, hits_b, out_b = run_check()
        named_immo = any('immolate' in h for h in hits_b)
        results.append(('B 只有 2 条轴线粒子的文件(负向对照)', '不报', not named_immo,
                        'immolate/hurt 未被点名; 合计 %s' % total_b))

        # --- C) 还原 ---
        BEAM.write_bytes(orig_beam)
        total_c, hits_c, _ = run_check()
        results.append(('C 还原', '0', (total_c == 0 and not hits_c),
                        '合计 %s, 命中 %d 条' % (total_c, len(hits_c))))
    finally:
        BEAM.write_bytes(orig_beam)

    ok = True
    print('=' * 64)
    for name, expect, passed, info in results:
        ok = ok and passed
        print('[%s] %-34s 期望=%s  -> %s' % ('PASS' if passed else 'FAIL', name, expect, info))
    print('=' * 64)
    print('探针结果: %s' % ('全部通过 (不是假绿)' if ok else '★ 有失败项, 规则不可信'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
