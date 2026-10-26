# -*- coding: utf-8 -*-
"""_tag_gap_fix.py —— 修正版缺口统计

【上一版的错误】
把 lightning 当成"和五大状态同级的可积累/可消费状态"参与期望值计算，
于是把「闪电+附加」「闪电+消耗」列成了 TOP 缺失。

口径原文（_tags_data.py 口径 16，2026-10-19 用户纠正）：
    lightning 归"状态组"只是为了查询时"涉及状态就带上它"，
    它**不是状态**，不能被附加、也没有"消耗闪电"。
⇒ 状态池只能用 STATUS_KEYS，不能用 GROUP=="状态"。

【本脚本两处排除】
  A. lightning 不参与任何"状态应有 apply/consume"的期望（口径 16）
  B. 「附加 + 冰冻」恒为 0 属口径正确（口径 17：冰冻/减速/时停走专词，不打 apply）
"""
import sys, os, itertools, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _tags_data as D

T = D.TAGS
KEYS = D.VOCAB_KEYS
CN = {v[0]: v[2] for v in D.VOCAB}
FIVE = D.STATUS_KEYS          # ★ 只认这个，不认 GROUP
EFFECT = D.EFFECT_KEYS
LIVE = [k for k in KEYS if any(k in t for t in T.values())]
N = len(T)


def cnt(k):
    return sum(1 for t in T.values() if k in t)


print('=' * 76)
print('词性（以 STATUS_KEYS / EFFECT_KEYS 为准，不看 GROUP 字段）')
print('=' * 76)
print('  五大状态 %d: %s' % (len(FIVE), '、'.join('%s(%s)' % (k, CN[k]) for k in FIVE)))
print('  效果词   %d: %s  ← 不积累不消费，不参与 apply/consume 期望' % (len(EFFECT), '、'.join('%s(%s)' % (k, CN[k]) for k in EFFECT)))
print('  闪电成员: %d 件' % cnt('lightning'))

# ---------------------------------------------------------------- 一、真实缺失对
print()
print('=' * 76)
print('一、真实缺失对（双重排除后）')
print('=' * 76)
rows, dropped = [], []
for a, b in itertools.combinations([k for k in LIVE if k != 'overlimit'], 2):
    exp = cnt(a) * cnt(b) / N
    act = sum(1 for t in T.values() if a in t and b in t)
    if act != 0 or exp < 1.5:
        continue
    # A. 闪电不是状态
    if a in EFFECT or b in EFFECT:
        dropped.append((exp, a, b, '闪电非状态'))
        continue
    # B. apply 只服务可施加状态
    if {a, b} == {'apply', 'freeze'}:
        dropped.append((exp, a, b, '冰冻走专词不打 apply'))
        continue
    rows.append((exp, a, b))
rows.sort(reverse=True)
for i, (exp, a, b) in enumerate(rows, 1):
    print('  %2d. %-10s + %-10s  期望 %5.2f' % (i, CN[a], CN[b], exp))
print()
print('  排除掉 %d 组（不是缺失）：' % len(dropped))
for exp, a, b, why in sorted(dropped, reverse=True):
    print('    %-10s + %-10s 期望 %5.2f  ← %s' % (CN[a], CN[b], exp, why))
print()
print('  ⇒ 真实缺失 %d 组（上一版报 13，减去这 %d 组）' % (len(rows), len(dropped)))

# ---------------------------------------------------------------- 二、五大状态配合
print()
print('=' * 76)
print('二、五大状态 内部配合（C(5,2)=10 组，闪电不参与）')
print('=' * 76)
OMNI = {c for c, t in T.items() if len([x for x in t if x in FIVE]) >= 4}
print('  万能件（>=4 状态）%d 件：%s' % (len(OMNI), '、'.join(sorted(OMNI))))
print('  ★ 万能件会给下面每一对都贡献共现，必须扣掉才看得出真实配合')
print()
print('  %-10s + %-10s %6s %8s %8s' % ('状态A', '状态B', '总件', '万能件', '专属件'))
zero_excl, zero_total = [], []
for a, b in itertools.combinations(FIVE, 2):
    tot = [c for c, t in T.items() if a in t and b in t]
    om = [c for c in tot if c in OMNI]
    ex = [c for c in tot if c not in OMNI]
    print('  %-10s + %-10s %6d %8d %8d  %s'
          % (CN[a], CN[b], len(tot), len(om), len(ex), '、'.join(ex) if ex else '—'))
    if len(ex) == 0:
        zero_excl.append((a, b))
    if len(tot) == 0:
        zero_total.append((a, b))
print()
print('  专属件=0 的 %d 组（只靠万能件凑出来，无专属设计）：' % len(zero_excl))
for a, b in zero_excl:
    print('    %-8s + %-8s  总 %d 件全是万能件' % (CN[a], CN[b],
          len([c for c, t in T.items() if a in t and b in t])))
print()
print('  绝对零共现 %d 组：' % len(zero_total))
for a, b in zero_total:
    print('    %-8s + %-8s' % (CN[a], CN[b]))
print()
# 白昼梦单独统计
print('  白昼梦 dream 与其它四状态的专属件数：')
for b in [k for k in FIVE if k != 'dream']:
    ex = [c for c, t in T.items() if 'dream' in t and b in t and c not in OMNI]
    print('    dream + %-8s 专属 %d 件 %s' % (CN[b], len(ex), '、'.join(ex) if ex else '—'))

# ---------------------------------------------------------------- 三、闪电正确问法
print()
print('=' * 76)
print('三、闪电该问的是什么（不问 apply/consume）')
print('=' * 76)
LIGHT = [c for c, t in T.items() if 'lightning' in t]
print('  7 件：%s' % '、'.join(LIGHT))
print()
for m in ['base_atk', 'cur_mana', 'max_mana', 'debuff', 'slow', 'freeze', 'timestop',
          'formation', 'field', 'summon', 'dash', 'heal', 'buff', 'cd_down',
          'indep_mul', 'true_dmg', 'flat', 'attract']:
    hits = [c for c in LIGHT if m in T[c]]
    print('    %-10s %-8s %d 件  %s' % (m, CN[m], len(hits), '、'.join(hits) if hits else '—'))
print()
print('  ⇒ 闪电是"触发即伤害"的效果词。合理追问是"能不能和某机制组合"，')
print('    而不是"为什么没有附加/消耗"。零共现的机制里，slow/freeze/timestop/')
print('    true_dmg/indep_mul 才是可讨论的设计方向；apply/consume 不在此列。')
