# -*- coding: utf-8 -*-
"""_gen_oldef_j3.py —— 批 J3：包内原本没有超限的 32 件，逐批生成 oldef（超限定义）

【为什么从 give + 设计稿反推，而不是手抄】
  超限的 lore 是**整段替换**（见 overlimit/def/load 头部）：敲上石头后物品描述
  整份换成 oldef.lore。手抄 32 件 × 十几个折行必然和 lore_fmt 的口径漂移，
  所以这里一律：① 基础段头/信息行/空行结构照抄 give 的 lore；
  ② 被超限改写的段正文换成设计稿原文（`_ol_j2.json` 里已解析好）；
  ③ 折行/留白/罗马数字全部走 `lore_fmt.nfmt/wrap`（与 give 同一套）。

【口径】
  · `dmg / mana / cd` 一律 0.0 —— 本批超限后的数值**写死在文案里**（420 蓝就是
    420 蓝），再叠乘区就是双重加成。
  · `name` 的颜色 = 该装备 give 里 `item_name.color`（check.py 规则 26 反查）。
  · 段 = 基础段顺序；基础有、超限没写的段（bent_ray 的「折光」）原样保留。

【分批】BATCH 决定这次写哪几件；每次重跑会先删掉本生成器负责的 id 再追加，
  所以幂等。守门：`python .workbuddy/_chk_oldef_gen.py`。
"""
import glob
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from lore_fmt import nfmt, patch_text, wrap  # noqa: E402

LOAD = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                    'overlimit', 'def', 'load.mcfunction')
META_PATH = os.path.join(HERE, '_ol_j2.json')
DOC = os.path.join(HERE, '超限设计整理_20261023.md')

# ★ 普攻「伤害」值超限后变了的两件（其余普攻伤害不变）。
#   来源：整理稿「参数」行 —— poursack「伤害 12→16」、bent_ray「伤害 8→20」。
DMG = {'pour_sack': '16', 'bent_ray': '20'}

# 分批：一次只写一批，跑完一批验一批（用户要求"分批来做"）
BATCH = {
    1: ['yebu', 'rebound', 'tidemark', 'grayscale', 'backflow_tide',
        'profane', 'way_back', 'gousi', 'thunder_wedge'],                      # 剑 9
    2: ['xiugou', 'draught', 'skyvault', 'frost_carve', 'ballad',
        'chenyuan', 'anchor', 'scorch_bone', 'deep_brine', 'meteor'],          # 斧 10
    3: ['backstring', 'reverse_string', 'dark_sun', 'dragon_tongue',
        'five_curses', 'pour_sack', 'burst_bank', 'apocalypse',
        'fate_thread', 'cage_day', 'fallen_dream', 'thunderrod', 'bent_ray'],  # 弩 4 + 法杖 9
}
# ★ 本生成器总共负责的 id（重跑时的清理范围 = 全部，避免分批之间互相踩）
ALL_IDS = [u for b in sorted(BATCH) for u in BATCH[b]]

META = json.load(io.open(META_PATH, encoding='utf-8'))


# ------------------------------------------------------------------ 基础数据

def give_path(uid):
    g = glob.glob(os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                               'equipment', '*', uid, 'give.mcfunction'))
    if not g:
        raise SystemExit('找不到 give: %s' % uid)
    return g[0]


def base_lore(uid):
    t = io.open(give_path(uid), encoding='utf-8').read()
    i = t.find('lore=')
    j = t.find('],custom_data=', i)
    if j < 0:
        j = t.find('],', i)
    if i < 0 or j < 0:
        raise SystemExit('give 里没有 lore=[...]: %s' % uid)
    return json.loads(t[i + 5:j + 1])


def name_color(uid):
    t = io.open(give_path(uid), encoding='utf-8').read()
    Q = chr(34)
    m = re.search(r'item_name=\{text:' + Q + r'[^' + Q + r']*' + Q
                  + r',bold:true,color:' + Q + r'?([a-z_]+)' + Q + r'?\}', t)
    if not m:
        raise SystemExit('give 里找不到 item_name 颜色: %s' % uid)
    return m.group(1)


def parse_segs(arr):
    """lore 行数组 -> [{head, info, body}]，丢掉段间空行（后面统一补）。"""
    segs = []
    cur = None
    for r in arr:
        s = r.get('text', '')
        if s.startswith('✦'):
            cur = {'head': s.replace('✦', '').strip(), 'info': None, 'body': []}
            segs.append(cur)
            continue
        if cur is None:
            continue
        if 'extra' in r:
            cur['info'] = r
            continue
        if s.strip() == '':
            continue
        cur['body'].append(s)
    for s in segs:
        s['body'] = ''.join(s['body'])
    return segs


def notes():
    """从整理稿的总览表抓「超限要点」当 note（不显示，只给文档/脚本看）。"""
    out = {}
    if not os.path.exists(DOC):
        return out
    for ln in io.open(DOC, encoding='utf-8').read().split('\n'):
        if not ln.startswith('|'):
            continue
        p = [x.strip() for x in ln.split('|')]
        if len(p) < 8 or not p[1].isdigit():
            continue
        out[p[3]] = p[7]
    return out


NOTES = notes()


# ------------------------------------------------------------------ 构造段

def build_parts(uid):
    """基础段结构 + 超限正文 -> [(✦ 段名, 魔力, 冷却, 正文)]"""
    d = META[uid]
    sec = {}
    for (lab, mana, cd, body) in d['sections']:
        sec[lab] = (mana, cd, body)

    parts = []
    for seg in parse_segs(base_lore(uid)):
        head = seg['head']
        if head in sec:
            mana, cd, body = sec[head]
        else:
            # 基础有、超限没改写（目前只有 bent_ray 的「折光」）-> 原样保留
            mana, cd, body = None, None, seg['body']
        if seg['info'] is not None:
            # 信息行沿用原文的**字段构成**（魔力 / 冷却 / 伤害），只换数值
            old_mana = old_cd = old_dmg = None
            ex = seg['info'].get('extra') or []
            for k, e in enumerate(ex):
                prev = ex[k - 1].get('text', '') if k else ''
                v = e.get('text', '')
                if e.get('color') == 'aqua' and '魔力' in prev:
                    old_mana = v
                elif e.get('color') == 'yellow' and '冷却' in prev:
                    old_cd = v
                elif e.get('color') == 'yellow' and '伤害' in prev:
                    old_dmg = v
            # ★ 伤害只在该段**本来就有**伤害字段时替换。写成 DMG.get(uid, old_dmg)
            #   会让「倾囊」的普攻伤害 16 漏到主动段(主动本来没有伤害字段)。
            info = (mana or old_mana, cd or old_cd,
                    DMG.get(uid, old_dmg) if old_dmg else None)
        else:
            info = None
        body = nfmt(body)
        # ★ nfmt 的乘号规则只认 `x0.1`(紧贴数字)。原稿里有 `x 0.1`(带空格),
        #   不处理的话描述里会留着半角 x —— 与全包「乘号写 ×」不一致。
        body = re.sub(r'(?<![A-Za-z×])[xX*]\s+(?=\d)', '×', body)
        # ★ 原稿里有「✦ 普攻｜魔力 80   ·   伤害 20每次普攻命中后…」——
        #   伤害值和后一句黏在一起(竖线只出现在段头), 解析后正文会以
        #   「伤害 20」开头, 与信息行重复一遍。把这段前缀削掉。
        if info is not None and info[2] and body.startswith('伤害 %s' % info[2]):
            body = body[len('伤害 %s' % info[2]):].lstrip()
        if info is not None and body:
            # ★ 设计稿里有几段是「✦ 普攻｜魔力 60   ·   伤害 X」—— 竖线后面那段
            #   其实就是信息行本身，没有别的正文。照抄会让玩家看到「伤害 X」两遍。
            #   判据: 把正文和"信息行纯文本"都去掉空白/句读后, 正文是它的子串。
            im, ic, idm = info
            itxt = '魔力' + (im or '')
            if ic:
                itxt += '冷却' + (ic if ic.endswith('秒') else ic + ' 秒')
            if idm:
                itxt += '伤害' + idm
            norm = lambda x: re.sub(r'[\s。，、；：]', '', x)
            if norm(body) in norm(nfmt(itxt)):
                body = ''
        parts.append((head, info, body))
    used = set(x[0] for x in parts)
    extra = [k for k in sec if k not in used]
    if extra:
        raise SystemExit('%s: 超限里有基础没有的段 %s —— 需要单独决定插在哪' % (uid, extra))
    return parts


def esc(s):
    return s.replace('\\', '\\\\').replace('"', '\\"')


def head_json(mana, cd, dmg):
    segs = [('魔力 ', 'gray'), (mana, 'aqua')]
    if cd:
        segs += [('   ·   ', 'dark_gray'), ('冷却 ', 'gray'), (cd if cd.endswith('秒')
                                                              else cd + ' 秒', 'yellow')]
    if dmg:
        segs += [('   ·   ', 'dark_gray'), ('伤害 ', 'gray'), (dmg, 'yellow')]
    inner = ','.join('{"text":"%s","color":"%s"}' % (esc(t), c) for (t, c) in segs)
    return '{"text":"","italic":false,"extra":[%s]}' % inner


def lore_json(parts):
    out = []
    for k, (title, info, body) in enumerate(parts):
        if k:
            out.append('{"text":" ","italic":false}')
        out.append('{"text":"✦ %s","color":"gold","bold":true,"italic":false}' % esc(title))
        if info:
            out.append(head_json(*info))
            if body:
                out.append('{"text":" ","italic":false}')
        for line in wrap(body, 37):
            out.append('{"text":"%s","color":"gray","italic":false}' % esc(line))
    return '[' + ','.join(out) + ']'


def line(uid, label, note, parts):
    raw = ('data modify storage zx:config oldef."%s" set value {label:"%s",'
           'name:{"text":"%s","bold":true,"color":"%s"},note:"%s",'
           'dmg:0.0,mana:0.0,cd:0.0,lore:%s}\n'
           % (uid, esc(label), esc(label), name_color(uid), esc(note),
              lore_json(parts)))
    # ★ 最后必须过一遍 lore_fmt.patch_text: 它是 check.py 规则 31 的口径。
    #   典型差异: 法杖的「魔力 当前魔力值的 50%   ·   冷却 20 秒」宽 52 > ROW_CAP(40),
    #   rebuild 会拆成两行 —— 自己拼的字符串过不了这条硬判据。
    return patch_text(raw)[0]


def build_defs(ids):
    out = []
    for uid in ids:
        label = '超限·' + META[uid]['name']
        note = NOTES.get(uid, META[uid]['name'] + ' 的超限')
        out.append((uid, label, note, build_parts(uid)))
    return out


# 守门 `_chk_oldef_gen.py` 会遍历 DEFS 并调 line() 与磁盘逐字比 —— 所以 DEFS
# 必须是「本生成器负责的全部 id」，而不是只这一次写的批次。
DEFS = build_defs(ALL_IDS)


def main():
    which = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    ids = BATCH[which]
    txt = io.open(LOAD, encoding='utf-8').read()
    lines = txt.split('\n')
    drop = re.compile(r'oldef\."(' + '|'.join(ALL_IDS) + r')"\s+set\s+value')
    # ★ 已经写过的批次不能因为"这一批只跑 2"被删掉: 先看磁盘上哪些 id 已在,
    #   写回集合 = 已在的 ∪ 本批(按 ALL_IDS 顺序)。批 1->9, 批 2->19, 批 3->32。
    existed = set()
    for l in lines:
        m = drop.search(l)
        if m:
            existed.add(m.group(1))
    kept = [l for l in lines if not drop.search(l)]
    removed = len(lines) - len(kept)
    write_ids = [u for u in ALL_IDS if (u in existed or u in ids)]
    body = '\n'.join(kept).rstrip('\n') + '\n'

    gen = {}
    for (uid, label, note, parts) in DEFS:
        gen[uid] = line(uid, label, note, parts)
    add = ''.join(gen[u] for u in write_ids)
    io.open(LOAD, 'w', encoding='utf-8', newline='\n').write(body + add)
    print('批 %d: 本次新增 %d 条（%s）；文件里 J3 共 %d 条；清理旧行 %d'
          % (which, len(ids), ','.join(ids), len(write_ids), removed))


if __name__ == '__main__':
    main()
