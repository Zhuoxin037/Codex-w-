import re
p = 'sweetdream/data/sweetdream/function/overlimit/def/load.mcfunction'
t = open(p, encoding='utf-8').read()
for m in re.finditer(r'oldef\.("?\w+"?) set value \{label:"([^"]+)",name:', t):
    start = m.end()
    note = re.search(r'note:"([^"]*)"', t[start:start+400])
    print(m.group(1).strip('"'), '|', m.group(2), '|', note.group(1) if note else '?')
