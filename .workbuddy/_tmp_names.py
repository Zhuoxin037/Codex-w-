import io, os, sys
sys.stdout.reconfigure(encoding='utf-8')
ROOT = r'D:/数据包/sweetdream/data/sweetdream/function/equipment'

names = ['退汐', '命缕', '彼岸', '眠羽', '盲烛', '丧铃', '重溟',
         '断页', '归息', '续火', '醒梦钟', '长夜', '渡梦', '回潮扣']
# 全包搜中文名（只搜 equipment 目录的 give 行）
hits = {n: [] for n in names}
for dp, ds, fs in os.walk(ROOT):
    for f in fs:
        if not f.endswith('.mcfunction'):
            continue
        p = os.path.join(dp, f)
        try:
            t = io.open(p, encoding='utf-8').read()
        except Exception:
            continue
        for n in names:
            if 'text:"%s"' % n in t:
                rel = os.path.relpath(p, ROOT).replace('\\', '/')
                hits[n].append(rel)

for n in names:
    v = hits[n]
    g = [x for x in v if x.endswith('/give.mcfunction')]
    print('%-5s %s  %s' % (n, '已实装' if g else '★未找到 give', g[:1] or v[:2]))
