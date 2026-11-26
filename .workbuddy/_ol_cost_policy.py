"""2026-11-15 用户授权的存量超限魔耗/冷却修订；不改基础装备和伤害机制。"""
import json
import re

# 未列出的字段保持原超限值；弩仍按射击收费，不新增右键或冷却。
POLICY = {
    'rogue_star': {'mana': 260, 'cd': 35},
    'shadow_blade': {'mana': 200, 'cd': 45},
    'deepsea_echo': {'mana': 420, 'cd': 35},
    'everfrost': {'mana': 280, 'cd': 35},
    'flame_brokenbody': {'mana': 420, 'cd': 15},
    'sickle_dreams': {'mana': 360, 'cd': 6},
    'hengdao': {'mana': 80, 'cd': 24},
    'red_lotus': {'mana': 180, 'cd': 35},
    'charge': {'mana': 420, 'cd': 110},
    'anion': {'mana': 120, 'cd': 35},
    'dream_reader': {'mana': 280, 'cd': 45},
    'begonia': {'mana': 500, 'cd': 100},
    'polarized_light': {'mana': 180, 'cd': 30},
    'fissure': {'mana': 220, 'cd': 45},
    'chime': {'mana': 240, 'cd': 50},
    'sculk_echo': {'mana': 180},
    'arc': {'mana': 60},
    'cold_crow': {'tiers': [30, 70, 160, 400]},
    'bone_erode': {'percent': 25},
    'reverse_string': {'mana': 160},
    'burst_bank': {'cd': 35},
    'apocalypse': {'mana': 600, 'cd': 100},
    # 已有文案写 160/18，补齐此前漏掉的运行时分档。
    'rebound': {'mana': 160, 'cd': 18},
}


def leaves(component):
    if isinstance(component, dict):
        if 'text' in component:
            yield component
        for item in component.get('extra', []):
            yield from leaves(item)
    elif isinstance(component, list):
        for item in component:
            yield from leaves(item)


def rewrite_definition(uid, raw):
    """让每个旧生成器输出同一份最新参数；其他装备逐字不动。"""
    if uid not in POLICY and uid != 'dragon_tongue':
        return raw
    match = re.search(r'lore:(\[.*\])\}\s*$', raw)
    if not match:
        raise ValueError('不能定位超限 lore: ' + uid)
    lore = json.loads(match[1])
    policy = POLICY.get(uid, {})
    section = ''
    for component in lore:
        text_nodes = list(leaves(component))
        text = ''.join(x.get('text', '') for x in text_nodes)
        if text.startswith('✦ '):
            section = text
        if section == '✦ 主动技能':
            for i, node in enumerate(text_nodes[:-1]):
                label = node.get('text', '').strip()
                nxt = text_nodes[i + 1]
                if label == '魔力':
                    if 'mana' in policy:
                        nxt['text'] = str(policy['mana'])
                    elif 'percent' in policy:
                        nxt['text'] = str(policy['percent']) + '%'
                    elif 'tiers' in policy:
                        nxt['text'] = ' / '.join(map(str, policy['tiers']))
                elif label == '冷却' and 'cd' in policy:
                    nxt['text'] = str(policy['cd']) + ' 秒'
    if uid == 'dragon_tongue':
        # 范围以已确认的代码为准：普通仍 4/8，超限为 6/10。
        for node in leaves(lore):
            node['text'] = node['text'].replace('4 格内释放一次箭雨', '6 格内释放一次箭雨')
            node['text'] = node['text'].replace('8 格内附有', '10 格内附有')
        # 旧 lore 折行可能截断句子，先合并相邻正文再作替换。
        for i in range(len(lore) - 1):
            a, b = lore[i], lore[i + 1]
            if a.get('color') == b.get('color') == 'gray' and not a.get('extra') and not b.get('extra'):
                joined = a.get('text', '') + b.get('text', '')
                changed = joined.replace('4 格内释放一次箭雨', '6 格内释放一次箭雨').replace('8 格内附有', '10 格内附有')
                if changed != joined:
                    a['text'], b['text'] = changed, ''
    encoded = json.dumps(lore, ensure_ascii=False, separators=(',', ':'))
    result = raw[:match.start(1)] + encoded + raw[match.end(1):]
    from lore_fmt import patch_text
    return patch_text(result)[0]
