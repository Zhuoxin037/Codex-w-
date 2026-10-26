import os, re, collections

root = r'D:/数据包/sweetdream/data/sweetdream/function'
pat = re.compile(r'@([ae])\[[^\]]*nbt=\{UUID')
cnt = collections.Counter()
who = collections.defaultdict(list)
for dp, dn, fn in os.walk(root):
    for f in fn:
        if not f.endswith('.mcfunction'):
            continue
        p = os.path.join(dp, f)
        for i, line in enumerate(open(p, encoding='utf-8'), 1):
            s = line.strip()
            if s.startswith('#'):
                continue
            for m in pat.finditer(line):
                cnt[m.group(1)] += 1
                who[m.group(1)].append(os.path.relpath(p, root).replace('\\', '/') + ':%d' % i)
print('剩余实体 UUID NBT 反查:', dict(cnt))
for k in who:
    print('--- @' + k)
    for v in who[k]:
        print('   ', v)
