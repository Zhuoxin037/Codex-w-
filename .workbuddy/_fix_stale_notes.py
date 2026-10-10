# -*- coding: utf-8 -*-
"""
_fix_stale_notes.py —— 把 12 块升级石 + 2 颗超限石 give/item 定义里
「效果尚未实现」这类过时注释改成"已实装"的准确版本。
--------------------------------------------------------------------------
【为什么需要】这些 item/*.mcfunction 是"只发物品"阶段写的, 顶部注释当时写着
  "做效果时要补 apply/<id> + def/load 登记"。2026-10-07 效果已全部接线,
  注释还留着会误导(下一个人照着注释再补一遍)。
【幂等】找到旧块就换; 已经是新文案的不动。
用法: python .workbuddy/_fix_stale_notes.py [--check]
"""
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FN = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')

UP_IDS = ['coolant_a', 'coolant_b', 'coolant_o',
          'harden_a', 'harden_b', 'harden_o',
          'mana_surge_a', 'mana_surge_b', 'mana_surge_o',
          'vision_a', 'vision_b', 'vision_o']

STALE_HEAD = '# 【★ 效果尚未实现】'
LINK_HEAD = '# 【★ 联动要跨装备】'
OMEGA_HEAD = '# 【Ω 有第二段】'


def up_new(uid):
    return ['# 【效果已实装】apply/%s + def/load 已登记, 效果见 upgrade/'
            'api(2026-10-07)。' % uid]


def ol_new(oid):
    if oid == 'brain_leech':
        return ['# 【效果已实装】overlimit/apply/brain_leech + def/load 已登记;'
                ' 「蛊虫」机制见 equipment/armor/brain_leech(2026-10-07)。']
    return ['# 【效果已实装】overlimit/apply/spine_symbiote + def/load 已登记;'
            ' 击杀加成/蛊虫联动见 equipment/armor/spine_symbiote(2026-10-07)。']


OMEGA_NEW = ('# 【Ω 的第二段怎么落】"每秒 -1 秒"由 upgrade/api/cd_tick 每秒结算'
             '(读主手 custom_data.skill, 只减本武器那个技能), 不是一次性 -20%'
             '(2026-10-07)。')


def rewrite(src, repl):
    """repl = 旧头 -> 新块(行列表)。返回(新文本, 改动数)"""
    out = []
    skip = False
    n = 0
    for ln in src.split('\n'):
        if ln.startswith(STALE_HEAD):
            out.extend(repl)
            n += 1
            skip = True
            continue
        if skip:
            # 吃掉这个块后面的续行(#   ...)与紧跟的「联动要跨装备」块
            if ln.startswith('#   ') or ln.startswith(LINK_HEAD):
                continue
            skip = False
        if ln.startswith(OMEGA_HEAD):
            out.append(OMEGA_NEW)
            n += 1
            skip = True
            continue
        out.append(ln)
    return '\n'.join(out), n


def main():
    check = '--check' in sys.argv
    jobs = []
    for uid in UP_IDS:
        jobs.append((os.path.join(FN, 'upgrade', 'item', uid + '.mcfunction'),
                     up_new(uid)))
    for oid in ('brain_leech', 'spine_symbiote'):
        jobs.append((os.path.join(FN, 'overlimit', 'item', oid + '.mcfunction'),
                     ol_new(oid)))

    total = 0
    for p, repl in jobs:
        src = io.open(p, encoding='utf-8').read()
        new, n = rewrite(src, repl)
        total += n
        tag = os.path.relpath(p, FN)
        if new != src:
            print('[changed] %-42s 块 %d' % (tag, n))
            if not check:
                io.open(p, 'w', encoding='utf-8', newline='').write(new)
        else:
            print('[same   ] %s' % tag)
    print('---- 共 %d 处%s' % (total, ' (dry-run)' if check else ' 已写回'))


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    main()
