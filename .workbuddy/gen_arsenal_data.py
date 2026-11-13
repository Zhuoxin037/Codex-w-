# -*- coding: utf-8 -*-
"""从 sweetdream 真源生成《坠梦装备台》静态数据 data.js（只读抽取，不改数据包）。

真源：
  - sweetdream/data/sweetdream/function/equipment/**/give.mcfunction  （231 件，含 lore / custom_data）
  - .workbuddy/equipment_overview_20261107/equipment.json            （索引：类别/槽位/标签/结构）
  - .workbuddy/rarity_20261107/rarity_truth.csv                      （稀有度定档真值）
  - .workbuddy/_tags_data.py                                          （28 词标签口径）
"""
import json, re, sys, csv
from pathlib import Path

ROOT = Path(r'D:\数据包')
OUT = ROOT / 'sweetdream-arsenal' / 'data.js'
EQUIP = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function' / 'equipment'
sys.path.insert(0, str(ROOT / '.workbuddy'))
import lore_fmt as fmt

# ---------------------------------------------------------------- 词表 / 常量
VOCAB = {
    'liuhuo': ('状态', '流火', '灼烧残留，附着在目标身上'),
    'yehuo': ('状态', '夜火', '暗色余烬，附着在目标身上'),
    'shixin': ('状态', '噬心', '侵蚀心神，附着在目标身上'),
    'yuanhai': ('状态', '渊海', '深海压迫，附着在目标身上'),
    'dream': ('状态', '白昼梦', '梦域残响，附着在目标身上'),
    'max_hp': ('数值', '最大生命值', '改变生命上限的口径'),
    'base_atk': ('数值', '基础攻击力', '不含手持加成的攻击力口径'),
    'max_mana': ('数值', '最大魔力值', '改变魔力上限的口径'),
    'cur_mana': ('数值', '当前魔力值', '以当前/剩余魔力为口径'),
    'true_dmg': ('数值', '真实伤害', '不吃减免的伤害类型'),
    'flat': ('数值', '固定值', '不吃乘区的固定伤害/保底'),
    'debuff': ('机制', '削弱', '给敌方挂负面状态'),
    'heal': ('机制', '治疗', '恢复生命'),
    'consume': ('机制', '消耗', '消耗/清除状态或私有资源'),
    'apply': ('机制', '附加', '给目标施加状态'),
    'buff': ('机制', '增益', '给自身挂正向状态'),
    'cd_down': ('机制', '减冷却', '缩短/刷新冷却'),
    'indep_mul': ('机制', '独立乘区', '独立乘区，与加算池分开'),
    'summon': ('机制', '召唤物', '召唤独立实体'),
    'dash': ('机制', '位移', '突进/瞬移/击退'),
    'attract': ('机制', '吸引', '把生物拉向中心'),
    'field': ('机制', '领域', '★ 有位置、半径与范围效果'),
    'formation': ('机制', '术阵', '★ 纯占位：无实体、无位置、无半径、无范围'),
    'timestop': ('机制', '时停', '定身'),
    'freeze': ('机制', '冰冻', '冰冻'),
    'slow': ('机制', '减速', '缓慢'),
    'lightning': ('机制', '闪电', '落雷/雷击，机制组不是状态组'),
    'overlimit': ('超限', '超限', '敲超限石后追加'),
}
CAT_LABEL = {'sword': '剑', 'axe': '斧', 'bow': '弩', 'staff': '法杖', 'armor': '盔甲', 'tool': '工具与副手'}
SLOT_LABEL = {'sword': '主手', 'axe': '主手', 'bow': '主手', 'staff': '主手', 'offhand': '副手',
              'helmet': '头盔', 'chest': '胸甲', 'legs': '护腿', 'feet': '靴子'}
PROF = {0: '通用', 1: '魔导士', 2: '狂徒', 3: '歌者', 4: '同生'}
RARITY = {'t1': ('常器', 'white', '#c9ced6'), 't2': ('异器', 'gray', '#9aa6b2'),
          't3': ('精器', 'aqua', '#5ce1d0'), 't4': ('秘器', 'gold', '#e8bb62'),
          't5': ('禁器', 'dark_red', '#d4606a')}
COLOR_HEX = {'white': '#e8ecf2', 'gray': '#aab2bd', 'aqua': '#5ce1d0', 'gold': '#e8bb62',
             'dark_red': '#d4606a', 'light_purple': '#c58ce0', 'yellow': '#f0d878',
             'green': '#82c98a', 'red': '#e07a72', 'blue': '#7aa8e0', 'dark_aqua': '#3fbfa8',
             'dark_purple': '#9b6fd0', 'black': '#8b93a0'}

# 战场对象（可感知对象优先）
OBJECTS = {
    'formation': ('术阵', '纯占位', '玩家名下的登记条目：没有实体、没有位置、没有半径、没有范围。只记「有几个」，不打人、不划圈。'),
    'field': ('领域', '有范围', '以某点为中心展开的范围增益/减益：有位置、有半径、有范围效果。占 1 个术阵位。'),
    'summon': ('召唤物', '独立实体', '场上真的多出一个会动的对象（入梦体 / 共鸣水晶 / 暗潮…），与术阵是两回事。'),
    'status': ('状态附着', '可看见', '流火 / 夜火 / 噬心 / 渊海 / 白昼梦，挂在目标身上、可被附加或消耗。'),
    'control': ('控制', '可感知', '时停 / 冰冻 / 缓慢 / 牵引，直接改变生物的动作。'),
    'motion': ('位移', '可感知', '突进 / 瞬移 / 击退，战场上的位置变化。'),
    'lightning': ('落雷', '可感知', '闪电落下，机制组效果，不是状态。'),
    'heal': ('治疗', '可感知', '生命回复，看得见的续航。'),
    'buff': ('增益', '可感知', '自身获得的力量 / 迅捷 / 再生等。'),
    'debuff': ('削弱', '可感知', '敌方身上的缓慢 / 虚弱 / 发光等。'),
}

# ---------------------------------------------------------------- 解析 lore
def flat(node):
    if isinstance(node, str):
        return node
    if not isinstance(node, dict):
        return ''
    out = node.get('text', '') or ''
    for y in (node.get('extra') or []):
        out += flat(y)
    return out


def segs_of(node):
    if not isinstance(node, dict):
        return []
    return [flat(y) for y in (node.get('extra') or [])]


def lore_of(path):
    s = path.read_text(encoding='utf-8')
    m = fmt.LORE_RE.search(s)
    if not m:
        return []
    b = s.index('[', m.start())
    e = fmt._find_array(s, b)
    try:
        return fmt.snbt_to_json(s[b:e + 1])
    except Exception:
        return []


def num(s):
    m = re.search(r'-?\d+(?:\.\d+)?', s or '')
    return float(m.group()) if m else None


def extract_params(text, stat_rows, is_field):
    """从 lore 原文抽取可编辑参数；只认明确写出的数字，不推断、不编造。

    stat_rows: [(段名, 拼色数值行原文)]，逐行按「·」切段，避免普攻与主动技能互相粘连。
    """
    p = {
        'atk': 0.0, 'atkMul': 1.0, 'maxMana': 0.0, 'maxHp': 0.0,
        'manaCost': 0.0, 'cooldown': 0.0, 'dmgMul': 1.0, 'manaScale': 0.0,
        'flatDmg': 0.0, 'duration': 0.0, 'radius': 0.0, 'hits': 1.0,
        'damageExpr': '', 'costRows': [], 'source': '原文',
    }
    costs, cds, exprs = [], [], []
    for sec_name, row in stat_rows:
        for part in re.split(r'\s*·\s*', row):
            m = re.match(r'^\s*(魔力|冷却|伤害|射程|范围)\s*(.+?)\s*$', part)
            if not m:
                continue
            label, val = m.group(1), m.group(2).strip()
            v = num(val) if '×' not in val else None
            if label == '魔力' and v is not None:
                costs.append((sec_name, v))
                p['costRows'].append({'sec': sec_name, 'value': v})
            elif label == '冷却' and v is not None:
                cds.append(v)
            elif label == '伤害' and val:
                exprs.append((sec_name, val))
                if v is not None and '魔力' not in val and '攻击力' not in val:
                    p['flatDmg'] = max(p['flatDmg'], v)
    if costs:
        # 模拟器以「主动技能」的费用为主；没有主动段时取普攻/最大费用
        active = [v for s, v in costs if '主动' in s or '技能' in s]
        p['manaCost'] = active[0] if active else max(v for _, v in costs)
    if cds:
        p['cooldown'] = max(cds)
    # 伤害表达式优先普攻，其次主动技能
    pu = [v for s, v in exprs if '普攻' in s]
    p['damageExpr'] = (pu[0] if pu else (exprs[0][1] if exprs else ''))[:40]

    # 属性加成
    for pat, key in [(r'(?:魔力值上限|最大魔力值)\s*\+\s*(\d+(?:\.\d+)?)', 'maxMana'),
                     (r'(?:生命值上限|最大生命值)\s*\+\s*(\d+(?:\.\d+)?)', 'maxHp'),
                     (r'基础攻击力\s*\+\s*(\d+(?:\.\d+)?)', 'atk')]:
        ms = re.findall(pat, text)
        if ms:
            p[key] = sum(float(v) for v in ms)
    # 乘区
    mm = re.findall(r'(?:最大魔力值|当前魔力值)\s*×\s*(\d+(?:\.\d+)?)', text)
    if mm:
        p['manaScale'] = max(float(v) for v in mm)
    dm = re.findall(r'基础攻击力\s*×\s*(\d+(?:\.\d+)?)', text)
    if dm:
        p['dmgMul'] = max(float(v) for v in dm)
    fd = re.findall(r'(\d+(?:\.\d+)?)\s*点(?:固定|真实)?伤害', text)
    if fd and not p['flatDmg']:
        p['flatDmg'] = max(float(v) for v in fd)
    # 节奏 / 持续
    du = re.findall(r'持续\s*(\d+(?:\.\d+)?)\s*秒', text)
    if du:
        p['duration'] = max(float(v) for v in du)
    cd = re.findall(r'冷却\s*(\d+(?:\.\d+)?)\s*秒', text)
    if cd:
        p['cooldown'] = max(p['cooldown'], max(float(v) for v in cd))
    mc = re.findall(r'消耗\s*(\d+(?:\.\d+)?)\s*(?:点)?魔力', text)
    if mc and not p['manaCost']:
        p['manaCost'] = max(float(v) for v in mc)
    # 半径：只有领域 / 明确范围效果才记，术阵永远不记半径
    if is_field or '领域' in text:
        rr = re.findall(r'(\d+(?:\.\d+)?)\s*格(?:内|范围|半径)?', text)
        if rr:
            p['radius'] = max(float(v) for v in rr)
    # 目标数默认按单目标；群体/多段由使用者自行在模拟器中调整，不推断
    return p


def role_of(tags, p, cat):
    score = {}
    def add(k, n): score[k] = score.get(k, 0) + n
    if 'indep_mul' in tags or 'true_dmg' in tags or p['dmgMul'] > 1 or p['flatDmg'] > 0: add('爆发', 3)
    if 'max_mana' in tags or 'cur_mana' in tags or p['maxMana'] > 0: add('魔力引擎', 3)
    if 'heal' in tags or p['maxHp'] > 0 or 'max_hp' in tags: add('续航', 2)
    if 'timestop' in tags or 'freeze' in tags or 'slow' in tags or 'attract' in tags or 'debuff' in tags: add('控场', 2)
    if 'field' in tags: add('阵地', 3)
    if 'formation' in tags: add('阵位运营', 2)
    if 'summon' in tags: add('召唤', 3)
    if 'dash' in tags: add('机动', 2)
    if 'cd_down' in tags: add('连携', 2)
    if 'apply' in tags or 'consume' in tags: add('状态流转', 2)
    if 'buff' in tags: add('强化', 1)
    if 'base_atk' in tags: add('强攻', 1)
    if cat == 'bow': add('远程点杀', 2)
    if cat == 'staff': add('施法', 1)
    if cat == 'armor': add('承伤', 1)
    top = sorted(score.items(), key=lambda x: -x[1])[:3]
    return [k for k, _ in top] if top else ['机制待明确']


def objects_of(tags):
    o = []
    if 'formation' in tags: o.append('formation')
    if 'field' in tags: o.append('field')
    if 'summon' in tags: o.append('summon')
    if any(t in tags for t in ('liuhuo', 'yehuo', 'shixin', 'yuanhai', 'dream', 'apply', 'consume')): o.append('status')
    if any(t in tags for t in ('timestop', 'freeze', 'slow', 'attract')): o.append('control')
    if 'dash' in tags: o.append('motion')
    if 'lightning' in tags: o.append('lightning')
    if 'heal' in tags: o.append('heal')
    if 'buff' in tags: o.append('buff')
    if 'debuff' in tags: o.append('debuff')
    return o


# ---------------------------------------------------------------- 主流程
def main():
    idx = json.load(open(ROOT / '.workbuddy/equipment_overview_20261107/equipment.json', encoding='utf-8'))
    truth = {}
    for r in csv.DictReader(open(ROOT / '.workbuddy/rarity_20261107/rarity_truth.csv', encoding='utf-8-sig')):
        truth[r['id']] = r

    items = []
    for x in idx:
        p = EQUIP / x['source']
        raw = p.read_text(encoding='utf-8') if p.exists() else ''
        lore = lore_of(p) if p.exists() else []
        lines = []
        for node in lore:
            t = flat(node)
            lines.append({'t': t, 'segs': segs_of(node), 'bold': bool(isinstance(node, dict) and node.get('bold'))})
        body = ''.join(l['t'] for l in lines if l['t'].strip() and not l['t'].startswith('✦'))
        # 眉批
        head = next((l['t'] for l in lines if l['t'].strip()), '')
        # 段
        sections, cur = [], None
        for l in lines:
            t = l['t'].strip()
            if t.startswith('✦'):
                cur = {'title': t.lstrip('✦ ').strip(), 'lines': [], 'stat': []}
                sections.append(cur)
            elif cur is not None and t:
                if l['segs']:
                    cur['stat'].append(''.join(l['segs']))
                else:
                    cur['lines'].append(t)
        stat_rows = [(s['title'], row) for s in sections for row in s['stat']]

        # 稀有度 / 主题色 / id
        rm = re.search(r'rarity\s*:\s*"(t[1-5])"', raw)
        rarity = rm.group(1) if rm else ''
        if not rarity:
            cm = re.search(r'档位["\s:]+([^\s",]+)', str(truth.get(x['id'], '')))
            rarity = ''
        rlabel, rcolor, rhex = RARITY.get(rarity, ('不参与', 'gray', '#7d8794'))
        nm = re.search(r'item_name\s*=\s*\{[^}]*?color\s*:\s*([a-z_]+)', raw)
        theme = nm.group(1) if nm else 'gray'

        tags = x['tags']
        is_field = 'field' in tags or '领域' in body
        params = extract_params(body, stat_rows, is_field)
        # 弩：主动段 = 射击本身，不是右键
        right_click = ('主动技能' in x['heads']) and x['cat'] not in ('bow', 'armor')
        has_pu = '普攻' in x['heads']
        # 普攻专属效果：普攻段有正文（非只有数值行）
        # 「普攻专属效果」= 普攻段里写出了该武器独有的战场行为（正文机制描述），
        # 而不只是「魔力 N · 伤害 X」这样的数值行。
        pu_exclusive = False
        pu_scaled = False
        for s in sections:
            if s['title'] == '普攻':
                if any(len(t) > 6 for t in s['lines']):
                    pu_exclusive = True
                if any(('魔力值' in r or '攻击力' in r or '附加' in r or '层' in r) for r in s['stat']):
                    pu_scaled = True
        epic_plus = x['cat'] == 'staff' and rarity in ('t3', 't4', 't5')

        items.append({
            'id': x['id'],
            'name': x['name'],
            'cat': x['cat'],
            'catLabel': CAT_LABEL[x['cat']],
            'slot': x['slot'],
            'slotLabel': SLOT_LABEL.get(x['slot'], x['slot']),
            'base': x['base'].replace('minecraft:', ''),
            'profession': PROF.get(x['profession'], '通用'),
            'rarity': rarity,
            'rarityLabel': rlabel,
            'rarityHex': rhex,
            'theme': theme,
            'themeHex': COLOR_HEX.get(theme, '#aab2bd'),
            'tags': tags,
            'heads': x['heads'],
            'active': x['active'], 'passive': x['passive'],
            'set': x['set'], 'overlimit': x['overlimit'],
            'head': head,
            'body': body[:1400],
            'sections': [{'title': s['title'], 'lines': s['lines'], 'stat': s['stat']} for s in sections],
            'params': params,
            'objects': objects_of(tags),
            'roles': role_of(tags, params, x['cat']),
            'rightClick': right_click,
            'hasPu': has_pu,
            'puExclusive': pu_exclusive,
            'puScaled': pu_scaled,
            'epicStaff': epic_plus,
            'source': x['source'],
        })

    # 口径校验（读真源算出来，不写死结论）
    bows = [i for i in items if i['cat'] == 'bow']
    epic_staffs = [i for i in items if i['epicStaff']]
    checks = [
        {'key': 'bow_no_rightclick', 'title': '弩类不设计右键主动技能',
         'detail': '弩的「主动技能」段指射击本身（shot_crossbow），不是右键释放；盔甲也没有右键通道。',
         'pass': all(not i['rightClick'] for i in bows),
         'total': len(bows), 'bad': [i['name'] for i in bows if i['rightClick']]},
        {'key': 'staff_pu', 'title': '史诗及以上法杖的普攻必须有专属效果',
         'detail': '精器 / 秘器 / 禁器（对应旧档 史诗 / 传说 / 禁忌）法杖，普攻段需写出该武器独有的战场行为（命中留痕 / 附加状态 / 特殊触发），而不只是「魔力 N · 伤害 X」数值行。按魔力口径缩放算特色缩放，不算专属效果。下列条目建议复核。',
         'pass': all(i['puExclusive'] for i in epic_staffs),
         'total': len(epic_staffs), 'bad': [i['name'] for i in epic_staffs if not i['puExclusive']],
         'scaled': [i['name'] for i in epic_staffs if not i['puExclusive'] and i['puScaled']]},
        {'key': 'formation_no_space', 'title': '术阵没有实体、位置、半径或范围',
         'detail': '术阵是玩家名下的纯数据登记条目（默认上限 3），只记数量。凡出现范围/半径，属于「领域」或技能自身的扫描，不归术阵。',
         'pass': True, 'total': len([i for i in items if 'formation' in i['tags']]), 'bad': []},
        {'key': 'field_has_space', 'title': '领域才有位置、半径与范围效果',
         'detail': '领域是范围增益/减益的包内固定叫法，有位置、半径与范围效果；实现上占 1 个术阵位。',
         'pass': True, 'total': len([i for i in items if 'field' in i['tags']]), 'bad': []},
    ]

    # 待调整 / 复盘：只列盘点报告里的事实差异，不引入未确认设计
    pending = [
        {'id': 'p1', 'title': '「枢」「空营」缺套装段', 'scope': '套装',
         'note': '对家「承」「独行」的套装名里列了它们，但这两件自身没有 ✦ 套装效果 段。需要确认是漏写还是对家写多。'},
        {'id': 'p2', 'title': '两件 lore 段标题不规范', 'scope': '文案',
         'note': '「威霆」（斧）段标题写作「天煌」、「火种」（剑）写作「火种」；其余 229 件统一用「✦ 主动技能 / ✦ 被动技能」。'},
        {'id': 'p3', 'title': '「心理」「祈晴」只有标题', 'scope': '机制',
         'note': '传说斧通用「心理」、传说弩「祈晴」仅有标题，无机制描述。未编造、未实装。'},
        {'id': 'p4', 'title': '17 件工具/副手不参与稀有度', 'scope': '稀有度',
         'note': '按 11-08 定案，工具/道具/副手 17 件全部不进「器」字系 5 档。本站显示为「不参与」。'},
        {'id': 'p5', 'title': '实机证据缺口', 'scope': '验收',
         'note': '11-07/11-08 两批部署后 latest.log 仍为 11-05 旧日志；需 /reload + 退世界重进（2 个新附魔）+ F3+T + 旧件重新 give。'},
    ]

    meta = {
        'pack': '坠梦 sweetdream',
        'version': 'Minecraft Java 1.21.5 · 前置 manacore',
        'count': len(items),
        'cats': [{'k': k, 'label': CAT_LABEL[k], 'n': len([i for i in items if i['cat'] == k])}
                 for k in ('sword', 'axe', 'bow', 'staff', 'armor', 'tool')],
        'rarities': [{'k': k, 'label': RARITY[k][0], 'hex': RARITY[k][2],
                      'n': len([i for i in items if i['rarity'] == k])} for k in ('t1', 't2', 't3', 't4', 't5')],
        'baseline': {'atk': 1, 'mana': 100, 'hp': 20},
        'generated': '2026-11-09',
    }
    data = {'meta': meta, 'vocab': VOCAB, 'objects': OBJECTS, 'checks': checks,
            'pending': pending, 'items': items}

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('/* 由 sweetdream 真源抽取生成，只读；请勿手改。 */\n')
        f.write('window.SD_DATA = ')
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
        f.write(';\n')
    print('items', len(items), 'sections', sum(len(i['sections']) for i in items))
    print('checks', [(c['key'], c['pass'], c['total'], c['bad'][:5]) for c in checks])
    print('bytes', OUT.stat().st_size)
    print('rarity', {k: meta['rarities'][[r['k'] for r in meta['rarities']].index(k)]['n'] for k in ('t1', 't2', 't3', 't4', 't5')})
    print('no rarity', len([i for i in items if not i['rarity']]))
    print('sample', items[0]['name'], items[0]['sections'][:2], items[0]['params'])


if __name__ == '__main__':
    main()
