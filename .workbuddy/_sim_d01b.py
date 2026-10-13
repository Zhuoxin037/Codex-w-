#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""D01 口径 B 的离线等价性 / 数值仿真。

目的: 在不动游戏的情况下, 用与 mcfunction **逐字同构**的整数运算复现
「分量级」伤害链, 并对照旧口径(A)与报告给的期望值。

复现:
  mul_pct(src, mul) = floor(src*mul/100)   # 除余分解, int32 语义(见 calc/mul_pct)
  calc : seg_{m,a,o} = mul_pct(base_i, mul_i);  seg_x = custom + health;  r.im = im
  apply: tot = Σ mul_pct(seg_i, 100+add_i) + seg_x ;  tot = mul_pct(tot, im)
旧口径 A: tot = mul_pct(Σseg + seg_x, im);  tot = mul_pct(tot, 100+Σadd)

★ apply 在"加算池全 0"时早退、沿用 calc 的 r.damage —— 那种情况下 B 必须与 calc
   的老式结果**逐位相同**(本脚本第 ③ 组验证这一点)。

★★ 三审 V01 更正(2026-10-11): 计分板的 `/=` = **Math.floorDiv(向下取整)**, 不是
   向零截断。旧版这里用 `tdiv` 建模是**错的**(证据: 审查结果_2026-10-11_三审/
   选择器及除法引擎核对.json 的 `azz.floorDiv -> Math.floorDiv`)。已换成 `fdiv`。
   分解式在 floorDiv 下依然精确(见 _sim_mulpct.py 第 ① 组 20 万组)。

★★ 三审 A01 教训: 数值仿真必须按 **(持有者, objective)** 建模。本脚本第 ④ 组用
   `Score = dict[(holder, objective)] -> int` 复刻计分板, 并复现 A01 的现场症状:
   dmg_add_apply 的分数都在 zx.meta, 而 mul_pct 硬编码 manacore.math ⇒ 输入读成 0。
"""
import random
import sys

INT32 = 2 ** 31


def i32(v):
    """按 Java int 语义(32 位有符号回绕)折回。"""
    v &= 0xFFFFFFFF
    return v - 0x100000000 if v >= 0x80000000 else v


def fdiv(a, b):
    """★ MC 计分板 `/=` 的真实语义 = Math.floorDiv(向下取整, 往 −∞)。

    三审 V01 更正: 旧版这里写的是 tdiv(向零截断) —— 那是错的。
    """
    return a // b


def mul_pct(src, mul):
    """与 manacore:internal/damage/mul_pct 逐字同构(floorDiv 语义)。

    ★ Q06(2026-10-11 四审): ③ 步改成"对倍率再做一次除余分解" —— 旧式的中间量
      99·|mul| 与最终结果无关, |mul| > 约 2.17e7 就回绕。见 _sim_mulpct.py ⑤ 节。"""
    src = i32(src)
    mul = i32(mul)
    q = i32(fdiv(src, 100))          # #q  = src / 100
    q = i32(q * mul)                 # #q *= mul
    r = i32(fdiv(src, 100))          # #r  = src / 100
    r = i32(r * 100)                 # #r *= 100
    lo = i32(src - r)                # #lo = src - #r   (= r ∈ [0,100))
    q1 = i32(fdiv(mul, 100))         # #q1 = mul / 100
    t = i32(q1 * 100)                # #t  = 100*q1
    r2 = i32(mul - t)                # #r2 = mul - 100*q1  ∈ [0,100)
    t = i32(lo * r2)                 # #t  = r*r2
    t = i32(fdiv(t, 100))            # #t /= 100
    lo = i32(lo * q1)                # #lo *= q1
    lo = i32(lo + t)                 # #lo += t
    return i32(q + lo)               # #mul_out = #q + #lo


def true_mul_pct(src, mul):
    """真值(不限位宽): floor(src*mul/100) —— 用来判定分段是否等价。"""
    return fdiv(src * mul, 100)


# ----------------------------------------------------------------------
# ★ (持有者, objective) 计分板复刻 —— 专治 A01 这类"持有者对、objective 错"
# ----------------------------------------------------------------------
class Score(dict):
    """score[(holder, objective)] -> int(缺省 = 0, 与游戏里"没 set 过"一致)。"""

    def getv(self, holder, obj):
        return self.get((holder, obj), 0)

    def setv(self, holder, obj, v):
        self[holder, obj] = i32(v)


def mul_pct_scored(sc, src_h, src_o, mul_h, mul_o, out_h, out_o):
    """与 mul_pct 同构(逐行), 但每步都带 (持有者, objective) —— A01 的照妖镜。

    ★ 关键: `$(src)` / `$(mul)` / `$(obj)` 三个宏参数都体现在这里 ——
      源/倍率各有自己的 (持有者, objective), 出参与载体 out_o 必须与调用方一致。
    """
    K = ('#100', 'manacore.meta')          # 常量 100 永远住 manacore.meta

    def op(dh, do, rh, ro, fn):
        sc.setv(dh, do, fn(sc.getv(dh, do), sc.getv(rh, ro)))

    sc.setv(*K, 100)
    op('#q', out_o, src_h, src_o, lambda a, b: b)                  # #q  = src
    op('#q', out_o, *K, lambda a, b: fdiv(a, b))                    # #q /= 100
    op('#q', out_o, mul_h, mul_o, lambda a, b: a * b)               # #q *= mul
    op('#r', out_o, src_h, src_o, lambda a, b: b)                   # #r  = src
    op('#r', out_o, *K, lambda a, b: fdiv(a, b))                    # #r /= 100
    op('#r', out_o, *K, lambda a, b: a * b)                         # #r *= 100
    op('#lo', out_o, src_h, src_o, lambda a, b: b)                  # #lo = src
    op('#lo', out_o, '#r', out_o, lambda a, b: a - b)               # #lo -= #r
    # ---- ③ 后半 = r*mul/100, 对倍率再分解一次(Q06, 与 mul_pct 同构) ----
    op('#q1', out_o, mul_h, mul_o, lambda a, b: b)                  # #q1 = mul
    op('#q1', out_o, *K, lambda a, b: fdiv(a, b))                   # #q1 /= 100
    op('#t', out_o, '#q1', out_o, lambda a, b: b)                   # #t  = #q1
    op('#t', out_o, *K, lambda a, b: a * b)                         # #t *= 100
    op('#r2', out_o, mul_h, mul_o, lambda a, b: b)                  # #r2 = mul
    op('#r2', out_o, '#t', out_o, lambda a, b: a - b)               # #r2 -= #t
    op('#t', out_o, '#lo', out_o, lambda a, b: b)                   # #t  = r
    op('#t', out_o, '#r2', out_o, lambda a, b: a * b)               # #t *= #r2
    op('#t', out_o, *K, lambda a, b: fdiv(a, b))                    # #t /= 100
    op('#lo', out_o, '#q1', out_o, lambda a, b: a * b)              # #lo *= #q1
    op('#lo', out_o, '#t', out_o, lambda a, b: a + b)               # #lo += #t
    op('#mul_out', out_o, '#q', out_o, lambda a, b: b)              # out = #q
    op('#mul_out', out_o, '#lo', out_o, lambda a, b: a + b)         # out += #lo
    return sc.getv('#mul_out', out_o)


def check_equiv(n=200000):
    bad = 0
    for _ in range(n):
        src = random.randint(-10 ** 9, 10 ** 9)
        mul = random.choice([100, 130, 150, 180, 1, 50, 200, 0, -30,
                             random.randint(-200, 200)])
        a = mul_pct(src, mul)
        b = true_mul_pct(src, mul)
        if -10 ** 9 <= b <= 10 ** 9 and a != b:   # 真值也在 int32 内才比
            bad += 1
            if bad < 6:
                print('  不符: src=%d mul=%d 分段=%d 真值=%d' % (src, mul, a, b))
    return bad


def _S(v):
    """裸伤害 -> calc 的定点(x1000)。"""
    return int(round(v * 1000))


def pipe_B(seg_mm, seg_atk, seg_oth, seg_x, add, im):
    tot = 0
    for seg, key in ((seg_mm, 'mm'), (seg_atk, 'atk'), (seg_oth, 'oth')):
        tot = i32(tot + mul_pct(seg, 100 + add.get(key, 0)))
    tot = i32(tot + seg_x)
    return mul_pct(tot, im)


def pipe_A(seg_mm, seg_atk, seg_oth, seg_x, add, im):
    tot = i32(seg_mm + seg_atk + seg_oth + seg_x)
    tot = mul_pct(tot, im)
    return mul_pct(tot, 100 + sum(add.values()))


def case(name, seg_mm, seg_atk, seg_oth, seg_x, add, im, exp_B, exp_A=None):
    b = pipe_B(seg_mm, seg_atk, seg_oth, seg_x, add, im)
    a = pipe_A(seg_mm, seg_atk, seg_oth, seg_x, add, im)
    okB = abs(b / 1000.0 - exp_B) < 1e-9
    s = '%-44s B=%-9s(期望 %-7s)%s' % (name, b / 1000.0, exp_B,
                                       '' if okB else '  ★B不符')
    if exp_A is not None:
        okA = abs(a / 1000.0 - exp_A) < 1e-9
        s += '   A=%-9s(期望 %-7s)%s' % (a / 1000.0, exp_A, '' if okA else '  ★A不符')
    print(s)
    return okB and (exp_A is None or okA)


def demo_a01():
    """A01: 调用方的分数写在 zx.meta, 而 mul_pct 曾把 objective 硬编码成 manacore.math。"""
    def run(src_o, mul_o, out_o):
        sc = Score()
        sc.setv('#s_m', 'zx.meta', 100000)      # 100.000(定点 x1000)
        sc.setv('#k_m', 'zx.meta', 150)         # ×1.50
        return mul_pct_scored(sc, '#s_m', src_o, '#k_m', mul_o, '#tot', out_o)

    right = run('zx.meta', 'zx.meta', 'zx.meta')
    wrong = run('manacore.math', 'manacore.math', 'manacore.math')
    print('  场景: 100.000(x1000) × 150/100。分数实写在 zx.meta。')
    print('  obj 传对("zx.meta")        ⇒ #tot = %-8d (x1000 -> %.3f, 期望 150.000)'
          % (right, right / 1000.0))
    print('  obj 传错("manacore.math")  ⇒ #tot = %-8d ← A01 现场: 输入读成 0 ⇒ 有增伤就打出 0'
          % wrong)
    return right == 150000 and wrong == 0


def main():
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass
    print('=' * 72)
    print('① mul_pct 分段 == 单步真值(20 万组, src 取 [-1e9,1e9], mul 含负数/0)')
    print('=' * 72)
    bad = check_equiv()
    print('  不符例数: %d   %s' % (bad, 'OK' if bad == 0 else '★ 需复核'))

    print('\n' + '=' * 72)
    print('② 报告验收例(倍率 = 1.0 ⇒ seg 就等于基数)')
    print('=' * 72)
    ok = True
    ok &= case('100mm+10atk + 炽天使(+50% atk)', _S(100), _S(10), 0, 0,
               {'atk': 50}, 100, 115, 165)
    ok &= case('100mm+100atk + 漫步(+30%mm)+炽天使(+50%atk)', _S(100), _S(100), 0, 0,
               {'mm': 30, 'atk': 50}, 100, 280, 360)
    ok &= case('固定 7 + 炽天使(+50% atk)', 0, 0, 0, _S(7),
               {'atk': 50}, 100, 7, 10.5)
    # 不挑口径(愿景/共振/桂冠): B 下三条各写一份 ⇒ 整段 +30% = 143;
    #   若把这三条喂给旧口径 A 会 ×(1+0.9)=209 —— 那正是 F14 的重复计入。
    ok &= case('100mm+10atk + 不挑口径(+30%, 三条全写)', _S(100), _S(10), 0, 0,
               {'mm': 30, 'atk': 30, 'oth': 30}, 100, 143, 209)
    # 若沿用旧 put_any"只写一条": B 下 atk 段吃不到 ⇒ 140(静默欠); A 下 143。
    ok &= case('  同上但只写一条(旧 put_any 写法)', _S(100), _S(10), 0, 0,
               {'mm': 30}, 100, 140, 143)
    ok &= case('100mm+10atk + 炽天使 + im 1.2', _S(100), _S(10), 0, 0,
               {'atk': 50}, 120, 138, 198)

    print('\n' + '=' * 72)
    print('③ 早退安全性: 加算池全 0 时 B 必须与 calc(老式) 逐位相同')
    print('  (已换成 floorDiv 语义重跑 —— V01 更正)')
    print('=' * 72)
    same = True
    for _ in range(5000):
        sm, sa, so = (random.randint(0, 10 ** 7) for _ in range(3))
        sx = random.randint(0, 10 ** 7)
        im = random.choice([100, 50, 120, 200, 1000])
        calc_r = mul_pct(i32(sm + sa + so + sx), im)
        apply_r = pipe_B(sm, sa, so, sx, {}, im)
        if calc_r != apply_r:
            same = False
            print('  ★ 不等: seg=(%d,%d,%d,%d) im=%d calc=%d apply=%d'
                  % (sm, sa, so, sx, im, calc_r, apply_r))
            break
    print('  5000 组: %s' % ('全部逐位相同 OK' if same else '★ 有不一致'))

    print('\n' + '=' * 72)
    print('④ A01 照妖镜: (持有者, objective) 建模 —— 传错 objective 会读成 0')
    print('=' * 72)
    ok4 = demo_a01()
    print('  结论: %s' % ('A01 症状可复现、修复方向正确 OK' if ok4 else '★ 模型有问题'))

    print('\n结论: %s' % ('全部通过' if (bad == 0 and ok and same and ok4) else '★ 有问题'))


if __name__ == '__main__':
    main()
