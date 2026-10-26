# -*- coding: utf-8 -*-
"""lib/heal 重入修复的离线时序模拟器（2026-10-19）

为什么要有它：这个 bug 只在"上一轮临时上限还没撤"时暴露，且 instant_health 要到
本刻 tickEffects 才生效 —— 单靠静态检查证明不了数值。这里把 lib/heal 的两版算法
连同 core/tick 的升格/收尾、tickEffects 的夹取，按刻模拟一遍，同一组场景对跑。

时序（每刻）：
  1. core/tick：heal_on → heal_off 摘修饰符；heal_p → heal_on
  2. 函数阶段：可能触发若干次 lib/heal（同刻可多次）
  3. tickEffects：本刻发过的药水生效，Health = min(Health+4194304, 临时上限)

用法：python .workbuddy/_sim_heal.py
"""

BIG = 4 * (2 ** 20)      # instant_health 等级 20 的治疗量


def _apply_v1(health, cap_real, mod, lbl_p, lbl_on, n):
    """旧版：直接读 attribute（可能带着上一轮的临时压低），基点只取 Health。"""
    cap_read = cap_real + (mod or 0)
    new = min(health + n, cap_read)
    d = new - cap_read
    return d            # 旧版只返回新修饰符值；清标签由 heal_up ① 负责


def _apply_v2(health, cap_real, mod, lbl_p, lbl_on, n):
    """新版：基点取 max(Health, 当前属性上限)，先摘旧再重读真实上限。"""
    cap_old = cap_real + (mod or 0)
    base = health
    if lbl_p or lbl_on:
        base = max(base, cap_old)
    mod = None                          # ⑤ 摘旧
    new = min(base + n, cap_real)       # ⑥ 用真实上限夹
    return new - cap_real               # ⑦


def run(version, cur, cap_real, plan, ticks=None):
    """plan = {刻: [每次请求的点数, ...]}；返回每刻结束后的 (health, 上限)。"""
    health = float(cur)
    mod = None
    lbl_p = lbl_on = False
    cast_this_tick = 0
    if ticks is None:
        ticks = (max(plan) if plan else 0) + 6
    trace = []

    for t in range(ticks):
        # ---- 1. core/tick ----
        if lbl_on:
            lbl_on = False
            mod = None                   # heal_off：先摘标签、再摘修饰符
        if lbl_p:
            lbl_on = True
            lbl_p = False

        # ---- 2. 函数阶段：本刻的所有 lib/heal ----
        cast_this_tick = 0
        for n in plan.get(t, []):
            if version == 1:
                d = _apply_v1(health, cap_real, mod, lbl_p, lbl_on, n)
                mod = d
                lbl_p, lbl_on = True, False
            else:
                d = _apply_v2(health, cap_real, mod, lbl_p, lbl_on, n)
                mod = d
                lbl_p, lbl_on = True, False
            cast_this_tick += 1

        # ---- 3. tickEffects：本刻发过的药水 ----
        if cast_this_tick:
            temp_cap = cap_real + (mod or 0)
            for _ in range(cast_this_tick):
                health = min(health + BIG, temp_cap)

        trace.append((t, round(health, 2), cap_real + (mod or 0)))
    return trace


CASES = [
    # 名字, 上限, 当前, plan, 期望(新版)
    ('单次 5 点',                 20, 5,  {0: [5]},            10),
    ('单次顶到上限',              20, 18, {0: [5]},            20),
    ('同刻两次 ×5',               20, 5,  {0: [5, 5]},         15),
    ('同刻三次 ×5',               20, 5,  {0: [5, 5, 5]},      20),
    ('隔一刻两次 ×5',             20, 5,  {0: [5], 1: [5]},    15),
    ('隔两刻两次 ×5（已收尾）',   20, 5,  {0: [5], 2: [5]},    15),
    ('同刻 绯缝6 + 殓丝30%',      20, 5,  {0: [6, 6]},         17),
    ('同刻两次但已接近满血',      20, 17, {0: [5, 5]},         20),
    ('大额 30%×2 超上限',         20, 3,  {0: [6, 6, 6, 6]},   20),
]

print('%-28s %6s %6s %8s %8s %s' % ('场景', '上限', '当前', '旧版', '新版', '期望'))
print('-' * 78)
fail = 0
for name, cap, cur, plan, expect in CASES:
    last_t = (max(plan) if plan else 0) + 4
    h1 = run(1, cur, cap, plan, last_t + 1)[last_t][1]
    h2 = run(2, cur, cap, plan, last_t + 1)[last_t][1]
    ok = abs(h2 - expect) < 1e-6
    fail += 0 if ok else 1
    print('%-28s %6d %6d %8.1f %8.1f   %d  %s'
          % (name, cap, cur, h1, h2, expect, 'OK' if ok else '<<< 不符'))

print('-' * 78)
print('新版不符合期望: %d 例' % fail)

print('\n【同刻两次的逐刻轨迹】上限 20 / 当前 5 / 每次 5')
print('%-5s %-22s %-22s' % ('刻', '旧版 (血 / 临时上限)', '新版 (血 / 临时上限)'))
tr1 = run(1, 5, 20, {0: [5, 5]}, 6)
tr2 = run(2, 5, 20, {0: [5, 5]}, 6)
for (t, a, b), (_, c, d) in zip(tr1, tr2):
    print('%-5d %-22s %-22s' % (t, '%6.1f / %6.1f' % (a, b), '%6.1f / %6.1f' % (c, d)))
