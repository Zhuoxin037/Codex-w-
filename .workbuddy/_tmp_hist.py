import io, json, sys
sys.stdout.reconfigure(encoding='utf-8')
p = r'C:/Users/qq303/.workbuddy/projects/d-数据包/5e2e995f-da31-4472-aef0-8b835690a6d1.jsonl'

# 取末尾若干行
import collections
tail = collections.deque(maxlen=4000)
with io.open(p, encoding='utf-8', errors='replace') as f:
    for line in f:
        tail.append(line)

msgs = []
for line in tail:
    line = line.strip()
    if not line:
        continue
    try:
        o = json.loads(line)
    except Exception:
        continue
    if o.get('type') != 'user':
        continue
    m = o.get('message') or {}
    c = m.get('content')
    t = ''
    if isinstance(c, str):
        t = c
    elif isinstance(c, list):
        parts = []
        for x in c:
            if isinstance(x, dict) and x.get('type') == 'text':
                parts.append(x.get('text', ''))
        t = ' '.join(parts)
    t = t.strip()
    if not t:
        continue
    if 'system-reminder' in t[:60]:
        continue
    msgs.append(t)

print('user msgs in tail:', len(msgs))
for t in msgs[-15:]:
    print('=' * 30)
    print(t[:300])
