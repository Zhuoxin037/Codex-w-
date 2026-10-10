# -*- coding: utf-8 -*-
"""lore_fmt.py —— 物品描述的"宽松版式"规范器（横刀 / 流光 那一套）
==========================================================================
【为什么要它】包里的描述原先各写各的: 有的写成 "上限+200"、"持续3秒"、
  "魔力值*0.05"、"迅捷3" —— 汉字和数字/符号挤在一起, 一屏看下去很闷。
  「横刀」「流光」这两件是按新规矩手写的: 数字两侧留白、乘号用 ×、等级用
  罗马数字。本模块把这套规矩固化成代码, 其余装备/材料一次刷齐,
  以后新增装备直接调它, 不会再长出第三种排版。

【四条规矩】
  1. 乘号:  `*` 和 `x`/`X`(紧跟数字时) 一律写成 `×`
     —— `魔力值*0.05` -> `魔力值 ×0.05`(× 与后面的数字相连, 前面留空格)
  2. 留白:  汉字与半角字符(数字/字母/%/+/-)相邻时补一个空格。
     标点不算 —— `15。` `（保底15）` 不补, 否则会变成 `15 。`(错)。
  3. 等级:  迅捷/缓慢/力量/反胃/抗性提升/再生/虚弱… 后面的数字改罗马数字。
     `迅捷3` -> `迅捷Ⅲ`；`冰冻2秒`(时长) 不受影响。
  4. 折行:  段落按半角宽度硬切(默认 36), 不切开数字/字母串;
     `●` 开头的条目续行带缩进(缩进宽度沿用原文)。

【★ 注意 ★】这里是**离线生成**用的: 它读 .mcfunction 里的 lore=[...],
  重新排版后写回文件。游戏里已经存在的旧物品不会自动变 ——
  要么重新 give, 要么用 debug/lore 刷(但那只从 lore_base 备份还原)。

【用法】
  python .workbuddy/lore_fmt.py            # 刷全部目标文件(默认 dry-run 打印)
  python .workbuddy/lore_fmt.py --write    # 真正写回
  from lore_fmt import nfmt, wrap, style_of, build_lore   # 供生成器调用
"""
import io
import json
import os
import re
import sys

# ---------------------------------------------------------------- 宽度 / 分类

def cw(c):
    """一个字符占几个半角宽(和 _chk_lore.py 的口径一致: >U+2000 算 2)"""
    return 1 if ord(c) < 0x2000 else 2


def tw(s):
    return sum(cw(c) for c in s)


def is_ideo(c):
    """汉字/假名 —— 会跟半角字符抢位置、需要留白的那类"""
    o = ord(c)
    return (0x4E00 <= o <= 0x9FFF or 0x3400 <= o <= 0x4DBF or
            0xF900 <= o <= 0xFAFF or 0x3040 <= o <= 0x30FF)


def is_half(c):
    """半角/半宽: 数字 字母 % + - . / ×"""
    if c in '%+-×./':
        return True
    return c.isascii() and c.isalnum()


# ---------------------------------------------------------------- 文本规范化

ROMAN = {1: 'Ⅰ', 2: 'Ⅱ', 3: 'Ⅲ', 4: 'Ⅳ', 5: 'Ⅴ', 6: 'Ⅵ', 7: 'Ⅶ', 8: 'Ⅷ', 9: 'Ⅸ', 10: 'Ⅹ'}

# 带等级的增益/减益 —— 它们后面的数字是"等级", 要写成罗马数字。
# ⚠️ 别往里加"秒/格/点/层"这类单位词, 那些后面的数字是数量, 保持阿拉伯数字。
BUFFS = ['迅捷', '缓慢', '力量', '反胃', '抗性提升', '再生', '虚弱', '失明',
         '跳跃提升', '生命恢复', '伤害吸收', '夜视', '饥饿', '中毒',
         '挖掘疲劳', '幸运', '不祥之兆', '发光', '飘浮', '缓慢降落']
_LVL_RE = re.compile('(%s)([1-9]|10)' % '|'.join(sorted(BUFFS, key=len, reverse=True)))


def _mul(t):
    """乘号统一: `*` / `x` / `X` 紧跟数字 -> ×(× 与后面的数字相连, 不拆)"""
    return re.sub(r'[xX*](?=\d)', '×', t)


def _lvl(t):
    return _LVL_RE.sub(lambda m: m.group(1) + ROMAN[int(m.group(2))], t)


def _pad(t):
    """汉字 <-> 半角 之间补一个空格(已有空格/标点则不动)"""
    out = []
    for c in t:
        if out:
            a = out[-1]
            if a != ' ' and c != ' ':
                if (is_ideo(a) and is_half(c)) or (is_half(a) and is_ideo(c)):
                    out.append(' ')
        out.append(c)
    return ''.join(out)


def nfmt(t):
    """规范化一段文本。★顺序★: 乘号 -> 等级 -> 留白。

    【为什么等级必须在留白之前】等级靠"增益名 + 数字"贴着才认得出;
      先留白的话 `反胃3` 已经变成 `反胃 3`, 正则就匹配不到了。
    """
    return _pad(_lvl(_mul(t)))


# ---------------------------------------------------------------- 折行

OPEN = '（「『【《〈'
CLOSE = '）」』】》〉。，、；：！？…～'
PAIRS = {'（': '）', '「': '」', '『': '』', '【': '】', '《': '》', '〈': '〉'}


def _tokens(text):
    """切成"不可拆"的单元: 括号/引号整段(`「流火」`)、半角串(`×0.03`)、单字。"""
    toks = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c in PAIRS:
            j = text.find(PAIRS[c], i + 1)
            if j != -1 and tw(text[i:j + 1]) <= 14:
                toks.append(text[i:j + 1])
                i = j + 1
                continue
        if is_half(c):
            j = i
            while j < n and is_half(text[j]):
                j += 1
            toks.append(text[i:j])
            i = j
            continue
        toks.append(c)
        i += 1
    return toks


def wrap(text, width=37, slack=3):
    """按半角宽硬切。三条避让规则:
      · 数字/半角串、`「流火」` 这种整段不拆
      · 不在**空格前**断行(不然新行会以空格开头)
      · 不在**收尾标点前**断行(`。，、：」…`) —— 需要时允许超出 width 最多 slack
        (标点占 1~2 格, 所以最多也就多出 4 格, 比"标点落单成一行"好看得多)
    """
    toks = _tokens(text)
    lines = []
    i = 0
    n = len(toks)
    while i < n:
        cur = ''
        curw = 0
        while i < n:
            w = tw(toks[i])
            if cur and curw + w > width:
                break
            cur += toks[i]
            curw += w
            i += 1
        extra = 0
        while i < n and extra < slack:
            t = toks[i]
            w = tw(t)
            if (t[0] in CLOSE or t == ' ') and extra + w <= slack:
                cur += t
                extra += w
                i += 1
            else:
                break
        lines.append(cur.strip())
    return [l for l in lines if l]


# ---------------------------------------------------------------- lore 重建

def _is_spacer(e):
    return isinstance(e, dict) and e.get('text') == ' ' and 'extra' not in e


def _is_info(e):
    return isinstance(e, dict) and 'extra' in e


def _is_head(e):
    return isinstance(e, dict) and e.get('bold') is True and 'extra' not in e


def _style(e, **over):
    d = {'color': e.get('color') or 'gray', 'italic': False}
    d.update(over)
    return d


def _entry(text, style):
    d = {'text': text}
    if style.get('color'):
        d['color'] = style['color']
    if style.get('bold'):
        d['bold'] = True
    d['italic'] = style.get('italic', False)
    return d


ISEP = '   ·   '
ROW_CAP = 40          # 拼色数值行超过这么宽就拆成两行(不然会被客户端硬折, 很难看)


def _split_info(text, segs, cap=ROW_CAP):
    """把过宽的"拼色数值行"拆成两行: 优先在 `   ·   ` 分隔符处断, 断点处丢分隔符。

    行宽超过 ROW_CAP 才拆 —— 包里原本就有一批 41 宽的行("伤害 · 耗蓝 · 冷却"),
    那些硬拆只会把标签和数值拆散, 不如不拆。
    """
    widths = [tw(text)] + [tw(s.get('text', '')) for s in segs]
    total = sum(widths)
    if total <= cap:
        return None
    cum = []
    acc = 0
    for w in widths:
        acc += w
        cum.append(acc)
    segpos = []          # segpos[k] = 第 k 个 extra 段左侧的累计宽度
    acc = widths[0]
    for w in widths[1:]:
        segpos.append(acc)
        acc += w
    cut = None
    for k in range(1, len(segs)):                  # 优先在第一个 `   ·   ` 处断
        if segs[k].get('text', '').strip() == '·' and segpos[k] <= cap - 2:
            cut = k
            break
    if cut is None:
        for k in range(1, len(segs)):              # 退而求其次: 找带缩进的续行
            if segs[k].get('text', '')[:1] == ' ' and segpos[k] <= cap - 2:
                cut = k
                break
    if cut is None:
        return None
    left = [dict(s) for s in segs[:cut]]
    right = [dict(s) for s in segs[cut:]]
    if segs[cut].get('text', '').strip() == '·':      # 断点就是分隔符 -> 直接丢掉
        right = right[1:]
        while len(left) > 1 and left[-1].get('text', '').strip() in ('', '·'):
            left.pop()
    while right and right[0].get('text', '')[:1] == ' ':   # 新行开头的缩进去掉
        right[0]['text'] = right[0]['text'].lstrip()
        if not right[0]['text']:
            right.pop(0)
            continue
        break
    if not left or not right:
        return None
    return [{'text': nfmt(text), 'italic': False, 'extra': left},
            {'text': '', 'italic': False, 'extra': right}]


def rebuild(lore, width=37):
    """lore 列表 -> 重排后的新列表

    合并规则:
      · 空行 / 小标题 / 拼色数值行 各占一行, 原样保留
      · 其余灰色正文: 同一节里连续的普通行合成**一个段落**再重新折行
        (原文是按旧宽度硬切的, 合并后按新宽度重切才不会越切越碎)
      · `●` 开头的独立成行, 它后面带缩进的行算它的续行
    """
    out = []
    buf = None          # 正在攒的段落/项目符号: {'kind','text','style','indent'}

    def flush():
        nonlocal buf
        if not buf:
            return
        # ★ 规范化必须在这里做: 段落是"先合并成一条、再按新宽度重切",
        #   所以乘号/留白/罗马数字都要在合并之后统一处理。
        text = nfmt(buf['text'])
        if buf['kind'] == 'bullet':
            ind = ' ' * buf['indent']
            body = text[len('● '):] if text.startswith('● ') else text
            lines = wrap(body, width - tw('● '))
            for k, ln in enumerate(lines):
                out.append(_entry(('● ' + ln) if k == 0 else (ind + ln), buf['style']))
        else:
            for ln in wrap(text, width):
                out.append(_entry(ln, buf['style']))
        buf = None

    for e in lore:
        if not isinstance(e, dict):
            flush()
            out.append(e)
            continue
        if _is_spacer(e):
            flush()
            out.append({'text': ' ', 'italic': False})
            continue
        if _is_info(e):
            flush()
            ne = {'text': nfmt(e.get('text', ''))}
            ne['italic'] = False
            ne['extra'] = []
            for seg in e.get('extra') or []:
                if isinstance(seg, dict):
                    s = dict(seg)
                    s['text'] = nfmt(seg.get('text', ''))
                    ne['extra'].append(s)
                else:
                    ne['extra'].append(seg)
            out.extend(_split_info(ne['text'], ne['extra']) or [ne])
            continue
        if _is_head(e):
            flush()
            out.append(_entry(nfmt(e.get('text', '')), _style(e, bold=True)))
            continue

        # ---- 普通正文 ----
        t = e.get('text', '')
        if t.startswith('●'):
            flush()
            buf = {'kind': 'bullet', 'text': t.rstrip(), 'style': _style(e), 'indent': 3}
        elif t[:1] == ' ' and buf:
            nm = len(t) - len(t.lstrip(' '))
            buf['indent'] = max(buf['indent'], nm) if buf['kind'] == 'bullet' else buf['indent']
            buf['text'] += t.strip()
        else:
            if buf is None:
                buf = {'kind': 'para', 'text': '', 'style': _style(e), 'indent': 0}
            buf['text'] += t
    flush()
    return out


# ---------------------------------------------------------------- 文件处理

def _find_array(s, start):
    """从 s[start] == '[' 开始, 找到配对的 ']'(跳过字符串里的括号)"""
    depth = 0
    i = start
    instr = False
    esc = False
    while i < len(s):
        c = s[i]
        if instr:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                instr = False
        else:
            if c == '"':
                instr = True
            elif c == '[':
                depth += 1
            elif c == ']':
                depth -= 1
                if depth == 0:
                    return i
        i += 1
    raise ValueError('方括号不配对')


KEY_RE = re.compile(r'([{,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:')


def snbt_to_json(s):
    return json.loads(KEY_RE.sub(r'\1"\2":', s))


def json_to_snbt(o):
    return json.dumps(o, ensure_ascii=False, separators=(',', ':'))


# 只认真正的赋值: `lore:[{` / `lore=[]`(注释里那种 `lore:[..]` 不算)
LORE_RE = re.compile(r'\blore\s*:\s*\[(?=[{])|lore=\[(?=[{])')


def patch_text(text, width=37):
    """把一段 .mcfunction/定义表里的 lore=[...] 全部重排, 返回新文本与改动数"""
    n = 0
    pos = 0
    while True:
        m = LORE_RE.search(text, pos)
        if not m:
            break
        b = text.index('[', m.start())
        e = _find_array(text, b)
        raw = text[b:e + 1]
        try:
            old = snbt_to_json(raw)
        except Exception as ex:
            raise ValueError('lore 解析失败 @%d: %s' % (b, ex))
        new = rebuild(old, width)
        text = text[:b] + json_to_snbt(new) + text[e + 1:]
        n += 1
        pos = b + 1
    return text, n


ROOT = r'D:\数据包\sweetdream\data\sweetdream'
TARGETS = []


def collect_targets():
    """所有含 lore 数组的 .mcfunction + 超限定义表。

    【为什么要全扫】物品不只由 give 造 —— 回手线(look/return_item)、强化台
      会**重建**物品, 那些地方也各有一份 lore, 漏掉就会变成"只有某一处是旧版式"。
    """
    t = []
    for dirpath, _dirs, files in os.walk(os.path.join(ROOT, 'function')):
        for f in files:
            if not f.endswith('.mcfunction'):
                continue
            p = os.path.join(dirpath, f)
            try:
                if LORE_RE.search(io.open(p, encoding='utf-8').read()):
                    t.append(p)
            except Exception:
                pass
    t.append(os.path.join(ROOT, 'function', 'overlimit', 'def', 'load.mcfunction'))
    return sorted(set(t))


def main():
    write = '--write' in sys.argv
    width = 37
    for a in sys.argv[1:]:
        if a.startswith('--width='):
            width = int(a.split('=')[1])
    total = 0
    for p in collect_targets():
        src = io.open(p, encoding='utf-8').read()
        try:
            new, n = patch_text(src, width)
        except Exception as ex:
            print('[失败] %s : %s' % (p, ex))
            continue
        rel = os.path.relpath(p, ROOT)
        flag = 'changed' if new != src else 'same'
        print('[%-7s] %-58s lore 块 %d' % (flag, rel, n))
        if new != src:
            total += 1
            if write:
                io.open(p, 'w', encoding='utf-8', newline='\n').write(new)
    print('---- 共 %d 个文件有变化 (%s)' % (total, '已写回' if write else 'dry-run'))


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    main()
