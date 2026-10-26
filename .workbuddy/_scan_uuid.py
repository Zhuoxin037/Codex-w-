import re, os, collections

root = r'D:/数据包/sweetdream/data/sweetdream/function'
pat = re.compile(r'@[ae]\[[^\]]*nbt=\{UUID:\[I;([^\]]*)\]')
variants = collections.Counter()
files = collections.Counter()
for dp, dn, fn in os.walk(root):
    for f in fn:
        if not f.endswith('.mcfunction'):
            continue
        p = os.path.join(dp, f)
        try:
            txt = open(p, encoding='utf-8').read()
        except Exception:
            continue
        for line in txt.splitlines():
            for m in pat.finditer(line):
                variants[m.group(1)] += 1
                files[p] += 1
print('variants:')
for k, v in variants.most_common(30):
    print('  ', v, k)
print('files:', len(files))
for k, v in files.most_common():
    print('  ', v, k)
