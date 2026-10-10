# -*- coding: utf-8 -*-
"""_chk_gen_drift.py —— 守卫: 「生成器 ↔ 磁盘」是否已漂移。

【为什么需要它】2026-10-06/07 连踩两次同一类坑:
  · 6 件装备的「✦ 小标题」只加在了磁盘的 give 上, 生成器里没有;
  · 「启示录」的自定义模型(item_model)只加在了磁盘的 give 上。
  ⇒ 每次重跑 `_gen_batch5.py` 都会把这些"只存在于磁盘"的改动**打掉**, 而 diff
     只会显示"文件变了", 看不出是回退。属于**静默数据损坏**。

【判据】在临时目录里重跑一遍生成器 + lore_fmt 规范化, 再与磁盘上的 give 对比:
  · **忽略 `#` 注释行**(生成器负责重写头注释, 注释差异是正常的);
  · 其余部分(especially give 那一行: 底材/属性/名字/lore)必须**逐字节一致**。

【用法】python .workbuddy/_chk_gen_drift.py     ->  0 条 = 同步; 有输出 = 漂移
【修法】把磁盘上的写法补进 `_gen_batch5.py`(或反过来删掉磁盘上多出的部分),
  然后重跑生成器 + lore_fmt, 再跑本脚本确认归零。
"""
import importlib.util
import io
import os
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DISK = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment')


def _load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def _body(p):
    """去掉注释行与空行后的正文(give 行等)"""
    return '\n'.join(l for l in io.open(p, encoding='utf-8').read().split('\n')
                     if l.strip() and not l.startswith('#'))


# 所有"直接写 equipment/*/give.mcfunction"的生成器都要登记在这里。
GENERATORS = ('_gen_batch5.py', '_gen_batch6.py')


def main():
    lf = _load(os.path.join(ROOT, '.workbuddy', 'lore_fmt.py'), 'lore_fmt_chk')

    tmp = tempfile.mkdtemp(prefix='gendrift_')
    problems = []
    try:
        base = os.path.join(tmp, 'equipment')
        for gf in GENERATORS:
            gen = _load(os.path.join(ROOT, '.workbuddy', gf), gf[:-3] + '_chk')
            gen.BASE = base
            gen.main()
        # 规范化(与真实流程一致: 生成器 -> lore_fmt --write)
        for dirpath, _dirs, files in os.walk(base):
            for f in files:
                if not f.endswith('.mcfunction'):
                    continue
                p = os.path.join(dirpath, f)
                src = io.open(p, encoding='utf-8').read()
                new, _n = lf.patch_text(src, 37)
                if new != src:
                    io.open(p, 'w', encoding='utf-8', newline='\n').write(new)

        # 逐件对比
        n = 0
        for dirpath, _dirs, files in os.walk(base):
            for f in files:
                if not f.endswith('.mcfunction'):
                    continue
                newp = os.path.join(dirpath, f)
                rel = os.path.relpath(newp, base)
                diskp = os.path.join(DISK, rel)
                n += 1
                if not os.path.exists(diskp):
                    problems.append((rel, '磁盘上不存在这个文件'))
                    continue
                a, b = _body(diskp), _body(newp)
                if a == b:
                    continue
                la, lb = a.split('\n'), b.split('\n')
                detail = '正文长度 %d vs %d 行' % (len(la), len(lb))
                for i in range(max(len(la), len(lb))):
                    x = la[i] if i < len(la) else ''
                    y = lb[i] if i < len(lb) else ''
                    if x != y:
                        detail += '; 首个不同 @行%d' % i
                        break
                problems.append((rel, detail))
        print('---- 生成器管理 %d 件, 漂移 %d 件' % (n, len(problems)))
        for rel, why in problems:
            print('  [漂移] %-44s %s' % (rel, why))
        if problems:
            print('\n★ 处理: 把改动补进对应生成器(.workbuddy/_gen_batch5.py 或 _gen_batch6.py),')
            print('  重跑生成器 + lore_fmt, 再跑本脚本确认为 0。否则下次重跑生成器会把磁盘上的改动**静默打掉**。')
        return 1 if problems else 0
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
