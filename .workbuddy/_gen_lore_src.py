# -*- coding: utf-8 -*-
"""_gen_lore_src.py —— 从「发放函数」抽出每件物品的**最新 名字 + 描述**,
生成 `sweetdream:lore/base_dispatch`, 让 debug/lore 能"硬刷新"。

==========================================================================
【为什么需要它】物品的名字/描述是**物品 NBT 快照**: 改了 give 里的字面量,
  世界里的老物品不会变。原 debug/lore 只能从物品自带的 `custom_data.lore_base`
  重建 —— 而 lore_base 是**第一次刷新时从物品身上拷下来的**, 也就是说它永远
  只能还原"当初那份", 你改了源文件再刷, 结果一模一样 (用户 2026-10-14 报的
  "刷新了没用" 就是这个)。
  本生成器把 154 个发放函数里的 `item_name=` / `lore=` 抽出来, 编成一张
  运行时查表; lore_refresh 现在先查这张表, 命中就用**源里的最新文本**覆盖,
  没命中才回落 lore_base。

【收录范围】所有「`^give ` 行 + 含 `lore=`」的函数 (equipment/ 98 +
  upgrade/item/ 28 + overlimit/item/ 28 = 154)。按物品身上的 `zx[0]` 认人。

【同一个 id 出现在多个文件】
  · 优先取 `**/give.mcfunction`(正式发放);
  · 其余(put_*/return_item 这类"归还时重建"的)与它**逐字节比对**:
      一致 -> 忽略; 不一致 -> 报警 (说明同一件物品的描述在两处写成了两份,
      早晚会分叉), 人工决定留哪份。

【★ 为什么要重新序列化 SNBT ★】
  give 的组件参数是**宽松**解析 (允许 `color:green` 这种裸字符串);
  而 `data modify ... set value` 是**严格** SNBT (字符串必须带引号)。
  直接把 give 里抠出来的文本塞进 set value, 遇到裸值那一行会整行失败。
  所以这里做个宽松解析 -> 标准序列化; 顺带把 `true/false` 写成 `1b/0b`。

【用法】
  python .workbuddy/_gen_lore_src.py            # dry-run: 只打印统计与差异
  python .workbuddy/_gen_lore_src.py --write    # 写盘
  python .workbuddy/_gen_lore_src.py --check    # 守门: 与磁盘比, 0 处 = 同步
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FUNC = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')
OUT = os.path.join(FUNC, 'lore', 'base_dispatch.mcfunction')

HEAD = '''# ============================================================
# sweetdream:lore/base_dispatch —— 「物品 id -> 最新 名字 + 描述」查表
# ------------------------------------------------------------
# 【本文件是生成物】由 .workbuddy/_gen_lore_src.py 从 154 个发放函数里
#   抽取 `item_name=` / `lore=` 自动编成。**不要手改** —— 改了下次重跑就没了。
#   改了某件装备的 give 描述之后, 重跑:
#       python .workbuddy/_gen_lore_src.py --write
#
# 【谁调用它】debug/lore -> station/api/lore_refresh 的 ② 段。
#   调用前调用方已把 `zx:work src.id` 设成物品的 `custom_data.zx[0]`;
#   命中就写 `zx:work namesrc`(名字) 与 `zx:work lore`(描述正文), 没命中则两者都空,
#   lore_refresh 回落到物品自带的 lore_base。
#
# 【为什么用 storage 中转而不用实体选择器】这里 154 组、每组两行, 若每行都带
#   `@e[tag=zx.st_tmp,limit=1]` 选择器, 一次刷新要扫 300+ 次实体; 而且写回
#   时机要排在"超限改名"之前 —— 交回 host 函数统一写, 顺序一眼可查。
#
# 【★ 为什么文本被重新序列化过】见生成器头注: give 是宽松解析、set value 是
#   严格 SNBT, 裸字符串 (`color:green`) 必须补引号, `true` 写成 `1b`。
# ============================================================

# 每次刷新先清空, 免得上一件残留
data modify storage zx:work lore set value []
data remove storage zx:work namesrc
'''


# ---------------------------------------------------------------- 宽松 SNBT

_ESCAPES = {'n': '\n', 't': '\t', 'r': '\r', '"': '"', '\\': '\\', '/': '/',
            'b': '\b', 'f': '\f'}


def _parse(s, i, is_key=False):
    """返回 (value, next_index)。is_key 时裸标量在 ':' 处断开。"""
    n = len(s)
    while i < n and s[i] in ' \t\r\n':
        i += 1
    if i >= n:
        raise ValueError('unexpected end')
    c = s[i]
    if c == '{':
        obj = {}
        i += 1
        while True:
            while i < n and s[i] in ' \t\r\n,':
                i += 1
            if i < n and s[i] == '}':
                return obj, i + 1
            key, i = _parse(s, i, True)
            while i < n and s[i] in ' \t\r\n':
                i += 1
            if s[i] != ':':
                raise ValueError('expected : at %d' % i)
            i += 1
            val, i = _parse(s, i)
            obj[key] = val
    if c == '[':
        arr = []
        i += 1
        while True:
            while i < n and s[i] in ' \t\r\n,':
                i += 1
            if i < n and s[i] == ']':
                return arr, i + 1
            val, i = _parse(s, i)
            arr.append(val)
    if c == '"':
        buf = []
        i += 1
        while i < n:
            ch = s[i]
            if ch == '\\':
                nxt = s[i + 1]
                if nxt == 'u':
                    buf.append(chr(int(s[i + 2:i + 6], 16)))
                    i += 6
                    continue
                buf.append(_ESCAPES.get(nxt, nxt))
                i += 2
                continue
            if ch == '"':
                return ''.join(buf), i + 1
            buf.append(ch)
            i += 1
        raise ValueError('unterminated string')
    # 标量: 数字 / true / false / 裸字符串
    stops = ',}]:' if is_key else ',}]'
    j = i
    while j < n and s[j] not in stops:
        j += 1
    raw = s[i:j].strip()
    low = raw.lower()
    if low == 'true':
        return True, j
    if low == 'false':
        return False, j
    m = re.fullmatch(r'([-+]?\d+)([bslBSL])', raw)
    if m:
        return int(m.group(1)), j
    m = re.fullmatch(r'([-+]?\d*\.?\d+)([fdFD])', raw)
    if m:
        return float(m.group(1)), j
    if re.fullmatch(r'[-+]?\d+', raw):
        return int(raw), j
    if re.fullmatch(r'[-+]?(\d+\.\d*|\.\d+|\d+e[-+]?\d+)', raw, re.I):
        return float(raw), j
    return raw, j


def parse_lenient(text):
    v, _ = _parse(text, 0)
    return v


# ---------------------------------------------------------------- 标准序列化

def _q(s):
    out = []
    for ch in s:
        if ch == '"':
            out.append('\\"')
        elif ch == '\\':
            out.append('\\\\')
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\t':
            out.append('\\t')
        elif ch == '\r':
            out.append('\\r')
        else:
            out.append(ch)
    return '"' + ''.join(out) + '"'


_KEY_SAFE = re.compile(r'^[A-Za-z0-9_.+-]+$')


def to_snbt(v):
    if v is True:
        return '1b'
    if v is False:
        return '0b'
    if isinstance(v, str):
        return _q(v)
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return repr(v)
    if isinstance(v, list):
        return '[' + ','.join(to_snbt(x) for x in v) + ']'
    if isinstance(v, dict):
        return '{' + ','.join(
            ((k if _KEY_SAFE.match(k) else _q(k)) + ':' + to_snbt(x))
            for k, x in v.items()) + '}'
    raise TypeError('bad type %r' % (v,))


# ---------------------------------------------------------------- 抽取

def grab(s, key):
    """抠出 `key=` 后面的整段 {} 或 [], 正确处理嵌套与字符串转义"""
    m = re.search(re.escape(key) + r'\s*[:=]\s*(?=[\[{])', s)
    if not m:
        return None
    j = m.end()
    open_c = s[j]
    close_c = ']' if open_c == '[' else '}'
    depth = 0
    k = j
    in_str = False
    esc = False
    while k < len(s):
        c = s[k]
        if in_str:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                in_str = False
        else:
            if c == '"':
                in_str = True
            elif c == open_c:
                depth += 1
            elif c == close_c:
                depth -= 1
                if depth == 0:
                    return s[j:k + 1]
        k += 1
    return None


def scan():
    hits = []
    for dirpath, _, files in os.walk(FUNC):
        for fn in files:
            if not fn.endswith('.mcfunction'):
                continue
            p = os.path.join(dirpath, fn)
            txt = io.open(p, encoding='utf-8').read()
            if not re.search(r'(?m)^give ', txt) or 'lore=' not in txt:
                continue
            hits.append(p)
    return sorted(hits)


def extract(path):
    txt = io.open(path, encoding='utf-8').read()
    line = next(l for l in txt.split('\n') if l.startswith('give '))
    m = re.search(r'zx\s*:\s*\[\s*"([^"]+)"', line)
    if not m:
        return None
    _id = m.group(1)
    zx = re.findall(r'"([^"]+)"', grab(line, 'zx') or '[]')
    name_s = grab(line, 'item_name')
    lore_s = grab(line, 'lore')
    if not name_s or not lore_s:
        return None
    return {
        'file': path,
        'id': _id,
        'zx': zx,
        'name': parse_lenient(name_s),
        'lore': parse_lenient(lore_s),
        'name_raw': name_s,
        'lore_raw': lore_s,
    }


def build():
    entries = {}
    warn = []
    for p in scan():
        e = extract(p)
        if not e:
            warn.append('[抽取失败] %s' % os.path.relpath(p, ROOT))
            continue
        _id = e['id']
        rel = os.path.relpath(p, FUNC).replace('\\', '/')
        e['rel'] = rel
        e['official'] = p.endswith('give.mcfunction')
        if _id not in entries:
            entries[_id] = [e]
        else:
            entries[_id].append(e)

    chosen = {}
    for _id, items in sorted(entries.items()):
        offs = [x for x in items if x['official']]
        if len(offs) > 1:
            warn.append('[同 id 多个 give] %s <- %s' % (_id, [x['rel'] for x in offs]))
        pick = offs[0] if offs else items[0]
        for other in items:
            if other is pick:
                continue
            if (to_snbt(other['name']) != to_snbt(pick['name'])
                    or to_snbt(other['lore']) != to_snbt(pick['lore'])):
                warn.append('[同 id 描述不一致] %s\n    pick: %s\n    diff: %s'
                            % (_id, pick['rel'], other['rel']))
        chosen[_id] = pick
    return chosen, warn


def render(chosen):
    lines = [HEAD.rstrip('\n')]
    for _id, e in sorted(chosen.items()):
        sel = ('execute if data storage zx:work src.id matches "%s"' % _id)
        lines.append('')
        lines.append('# %s  (%s)' % (_id, e['rel']))
        lines.append('%s run data modify storage zx:work namesrc set value %s'
                     % (sel, to_snbt(e['name'])))
        lines.append('%s run data modify storage zx:work lore set value %s'
                     % (sel, to_snbt(e['lore'])))
    return '\n'.join(lines) + '\n'


def main():
    argv = sys.argv[1:]
    chosen, warn = build()
    text = render(chosen)
    old = io.open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else None

    if '--check' in argv:
        if old is None:
            print('[chk] 目标文件不存在 —— 先跑 --write')
            return 1
        if old != text:
            print('[chk] lore/base_dispatch 与发放函数**已漂移** —— 重跑 --write')
            return 1
        print('[chk] ok: %d 条 id, 与源同步' % len(chosen))
        return 0

    print('收录 id: %d 条' % len(chosen))
    for w in warn:
        print('  ⚠ ' + w)
    if not warn:
        print('  (无冲突/无抽取失败)')
    print('输出: %s  (%d 行, %d 字节)'
          % (os.path.relpath(OUT, ROOT), text.count('\n'), len(text.encode('utf-8'))))
    if old is None:
        print('磁盘上还没有该文件 -> 将新建')
    elif old == text:
        print('磁盘内容已一致 (无变化)')
    else:
        print('磁盘内容**有差异** -> --write 才会写盘')
    if '--write' in argv:
        os.makedirs(os.path.dirname(OUT), exist_ok=True)
        io.open(OUT, 'w', encoding='utf-8', newline='\n').write(text)
        print('已写盘。')
    return 0


if __name__ == '__main__':
    sys.exit(main())
