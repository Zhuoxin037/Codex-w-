# -*- coding: utf-8 -*-
"""
_rename_ns.py —— 把命名空间前缀 sweetdream 全量改成 fallendream
================================================================
范围(2026-11-23 用户确认「全量重命名」):
  · 目录   sweetdream/            -> fallendream/
  · 目录   sweetdream_rp_完整版/  -> fallendream_rp_完整版/
  · 目录   sweetdream-arsenal/    -> fallendream-arsenal/
  · 文本   sweetdream      -> fallendream       (命名空间 / 路径 / item_model / 计分项 / bossbar)
           Sweetdream      -> Fallendream
           SWEETDREAM      -> FALLENDREAM
  · 递归   data/sweetdream_boss、assets/sweetdream_boss 目录名同样跟改

指定不动:
  · 二进制(.png .ogg .zip .glb ...): 不读不写
  · .workbuddy/ 只改**顶层** *.py(验证链/部署/生成器脚本);
    各批次证据目录(_chk_ 输出、table.json 备份)保持原样 = 当时的事实记录
  · 根目录历史设计稿/审阅报告的 md 不动(只改活文档 AGENTS.md / README.md / 使用教程.md)
  · 模型设计/ 下的 .bbmodel 源工程不动(里面记的是当时的贴图路径)

用法:
  python .workbuddy/_rename_ns.py           # 试运行, 只报告
  python .workbuddy/_rename_ns.py --apply   # 真改
"""
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 整棵树都改的目录(内容 + 目录名)
TREE_DIRS = ['sweetdream', 'sweetdream_rp_完整版', 'sweetdream-arsenal']
# 只改内容、目录名不改的目录(前置包里的跨包调用)
CONTENT_ONLY_DIRS = ['manacore-1.0.0']
# 只在顶层认领 *.py
SCRIPT_DIR = '.workbuddy'
# 根目录下单个文件
ROOT_FILES = ['AGENTS.md', 'README.md', '使用教程.md',
              'deploy.ps1', '部署到存档.bat', '同步五世恶咒显示.bat']

TEXT_EXT = {'.mcfunction', '.json', '.mcmeta', '.py', '.txt', '.md', '.yml',
            '.yaml', '.bat', '.cmd', '.ps1', '.js', '.html', '.css', '.csv',
            '.xml', '.toml', '.cfg', '.ini', '.properties', '.snbt', '.lang'}

SUBS = [('sweetdream', 'fallendream'),
        ('Sweetdream', 'Fallendream'),
        ('SWEETDREAM', 'FALLENDREAM')]


def conv(s):
    for a, b in SUBS:
        s = s.replace(a, b)
    return s


SELF = os.path.basename(os.path.abspath(__file__))


def rewrite(path, apply):
    """返回 (命中次数, 是否已写)"""
    # ★ 本脚本自己不改：改了之后 TREE_DIRS / SUBS 会自相矛盾, 也没法回滚
    if os.path.basename(path) == SELF:
        return 0, False
    ext = os.path.splitext(path)[1].lower()
    if ext not in TEXT_EXT:
        return 0, False
    try:
        if os.path.getsize(path) > 8 * 1024 * 1024:
            return 0, False
        raw = open(path, 'rb').read()
        txt = raw.decode('utf-8')
    except (UnicodeDecodeError, OSError):
        return 0, False
    n = 0
    for a, _ in SUBS:
        n += txt.count(a)
    if not n:
        return 0, False
    new = txt
    for a, b in SUBS:
        new = new.replace(a, b)
    if apply:
        with open(path, 'wb') as f:
            f.write(new.encode('utf-8'))
    return n, apply


def main():
    apply = '--apply' in sys.argv
    report = []
    total_hits = 0
    total_files = 0
    per_dir = {}

    jobs = []      # (标签, 绝对目录, 是否递归, 仅某扩展名)
    for d in TREE_DIRS + CONTENT_ONLY_DIRS:
        p = os.path.join(ROOT, d)
        if os.path.isdir(p):
            jobs.append((d, p, True, None))
    sd = os.path.join(ROOT, SCRIPT_DIR)
    if os.path.isdir(sd):
        jobs.append((SCRIPT_DIR + '/*.py', sd, False, '.py'))
    for f in ROOT_FILES:
        p = os.path.join(ROOT, f)
        if os.path.isfile(p):
            jobs.append(('<root>', ROOT, False, f))

    for label, base, recurse, only in jobs:
        hits = 0
        files = 0
        if label == '<root>':
            n, _ = rewrite(os.path.join(base, only), apply)
            if n:
                hits += n
                files += 1
                report.append('  %-46s %6d' % (only, n))
        else:
            walker = os.walk(base) if recurse else [(base, [], [x for x in os.listdir(base)])]
            for dp, dn, fn in walker:
                if '.git' in dp.replace('\\', '/').split('/'):
                    continue
                for x in fn:
                    if only and os.path.splitext(x)[1].lower() != only:
                        continue
                    p = os.path.join(dp, x)
                    n, _ = rewrite(p, apply)
                    if n:
                        hits += n
                        files += 1
                        report.append('  %-46s %6d'
                                      % (os.path.relpath(p, ROOT)[:46], n))
        per_dir[label] = (hits, files)
        total_hits += hits
        total_files += files
        print('[%s] 命中 %d 次 / %d 个文件' % (label, hits, files))

    # ---- 目录改名(自底向上) ----
    renamed = []
    for d in TREE_DIRS:
        base = os.path.join(ROOT, d)
        if not os.path.isdir(base):
            continue
        # 先改内部同名子目录(如 data/sweetdream -> data/fallendream)
        for dp, dn, fn in os.walk(base, topdown=False):
            for name in dn:
                if 'sweetdream' in name.lower():
                    src = os.path.join(dp, name)
                    dst = os.path.join(dp, conv(name))
                    renamed.append((os.path.relpath(src, ROOT),
                                    os.path.relpath(dst, ROOT)))
                    if apply:
                        os.rename(src, dst)
        # 再改顶层目录本身
        dst = os.path.join(ROOT, conv(d))
        renamed.append((d, conv(d)))
        if apply:
            os.rename(base, dst)

    print()
    print('目录改名 %d 处:' % len(renamed))
    for a, b in renamed:
        print('  %s  ->  %s' % (a, b))

    out = os.path.join(ROOT, SCRIPT_DIR, '_rename_ns_report.txt')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('模式: %s\n' % ('APPLY' if apply else 'DRY-RUN'))
        f.write('总命中 %d 次 / %d 个文件\n\n' % (total_hits, total_files))
        f.write('按目录:\n')
        for k, v in per_dir.items():
            f.write('  %-24s %6d 次 / %5d 文件\n' % (k, v[0], v[1]))
        f.write('\n明细(前 2000 行):\n')
        f.write('\n'.join(report[:2000]))
    print()
    print('报告: %s' % out)
    if not apply:
        print('(试运行; 加 --apply 真正写入)')


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                                 errors='replace')
    main()
