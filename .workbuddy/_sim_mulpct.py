# -*- coding: utf-8 -*-
"""_sim_mulpct.py —— mul_pct 的两件事, 都在离线用 int32 语义跑:

① 【N10 等价性】"除余分解"分段乘法 == 单步 src*mul/100(逐位相同), 除非真值本身
   装不下 int32(那是物理上限, 不属于本设计的锅)。

② 【三审 V01 更正】计分板的 `/=` 语义 = **floorDiv**(向下取整, 往 −∞),
   **不是**向零截断(truncDiv)。证据: `审查结果_2026-10-11_三审/选择器及除法引擎核对.json`
   (`azz.floorDiv -> Math.floorDiv`);实测 1.21.5 里 `-1 / 100` 的分数结果是 -1。
   ★ 本文档旧版用 tdiv(向零截断)建模 —— 那是**错的**, 已换成 fdiv。
   ★ 分解式在 floorDiv 下**依然精确**(q 与 r 同用一个 `/=`; r 恒落在 (−100,100))。

③ 【A01 教训: 数值仿真必须按 (持有者, objective) 建模】
   旧仿真只按"值"建模(一个变量 = 一个数), 于是**看不见**"持有者名对、objective 错"
   这类错误。A01 就是这么漏掉的: mul_pct 把 objective 硬编码成 manacore.math,
   而调用方 dmg_add_apply 的分数全写在 zx.meta ⇒ 输入一律读成 0 ⇒ 有增伤就打出 0 伤害。
   本节用 `Score = dict[(holder, objective)] -> int` 复刻计分板, 并证明:
     · 传对 objective => 结果正确;
     · 传错 objective => 输入读成 0(= 现场症状)。
"""
import random
import sys

MASK = 0xFFFFFFFF


def w(x):
    """按 Java int 语义(32 位有符号回绕)折回。"""
    x &= MASK
    return x - 0x100000000 if x >= 0x80000000 else x


def tdiv(a, b):
    """向零截断(旧错误建模 —— 只留作对照, 别再用来建模 MC)。"""
    q = abs(a) // abs(b)
    return q if (a < 0) == (b < 0) else -q


def fdiv(a, b):
    """★ MC 计分板 `/=` 的真实语义 = Math.floorDiv(向下取整)。"""
    return a // b


I32MIN, I32MAX = -2 ** 31, 2 ** 31 - 1


def split_checked(B, M):
    """mul_pct.mcfunction 逐行同构, 并报告"哪一步真正越过了 int32"。

    返回 (结果, 越界的步骤名 or None)。★ 只有在**没有任何中间步越界**时,
    分段式才承诺 == 单步真值 —— 中间步越界时, 回绕后的值已无意义, 属设计域外。
    """
    steps = []

    def step(name, v):
        steps.append((name, v))
        return v

    q = step('#q=src/100', fdiv(w(B), 100))
    q = step('#q*=mul', q * w(M))
    q = step('#q->i32', w(q))
    r = step('#r=src/100', fdiv(w(B), 100))
    r = step('#r*=100', r * 100)
    lo = step('#lo=src-#r', w(B) - r)      # lo = r ∈ [0,100)
    # ---- ③ 后半 = r*M/100 —— 对 M 再做一次除余分解 ★Q06(2026-10-11 四审)★ ----
    #   旧式 `#lo *= mul` 的中间量 = r*M, |r| <= 99 ⇒ 只要 |M| > 99*M>int32 即
    #   |M| > 约 2.17e7 就回绕 —— **与最终结果大小无关**(反直觉的窄边界)。
    #   新式: M = 100*q1 + r2  ⇒  r*M/100 = r*q1 + r*r2/100
    #     前半 r*q1 <= |M|          (只要 |M| <= int32 就安全)
    #     后半 r*r2 <= 99*99 = 9801 (恒安全)
    #   ⇒ 安全边界回到"结果装得下 int32"(① 步 q*M) + "|M| <= int32"(输入本身)。
    q1 = step('#q1=mul/100', fdiv(w(M), 100))
    t = step('#t=100*q1', w(q1) * 100)
    r2 = step('#r2=mul-t', w(M) - t)       # r2 ∈ [0,100)
    t = step('#t=r*r2', lo * r2)
    t = step('#t/=100', fdiv(t, 100))
    lo = step('#lo*=q1', lo * w(q1))
    lo = step('#lo+=t', lo + t)
    lo = step('#lo->i32', w(lo))
    out = step('#out=#q+#lo', w(q) + w(lo))
    out = step('#out->i32', w(out))
    bad = next((n for n, v in steps if not (I32MIN <= v <= I32MAX)), None)
    return out, bad


def split(B, M):
    return split_checked(B, M)[0]


def split_q06_old(B, M):
    """Q06 之前的版本: ③ 步还是 `#lo *= mul; #lo /= 100`(大 M 下会先回绕)。"""
    q = w(fdiv(w(B), 100))
    q = w(q * w(M))
    r = w(fdiv(w(B), 100))
    r = w(r * 100)
    lo = w(w(B) - r)
    lo = w(lo * w(M))
    lo = w(fdiv(lo, 100))
    return w(q + lo)


def old_trunc(B, M):
    """被 N10 淘汰的老写法(先乘后除), 仍用 floorDiv —— 溢出照旧。"""
    return w(fdiv(w(w(B) * w(M)), 100))


def exact(B, M):
    """真值(不限位宽): floor(B*M/100)。"""
    return (B * M) // 100


# ----------------------------------------------------------------------
# ① 等价性
# ----------------------------------------------------------------------
def equiv():
    cases = [(30000000, 100)]
    for B in [0, 1, 99, 100, 101, 45670, 30000000, 2147483000, 2147483647,
              -1, -100, -45670, -2147483647, -2147483648]:
        for M in [0, 1, 100, 115, 150, 1000, -100, -115, -100000, 100000]:
            cases.append((B, M))
    random.seed(7)
    for _ in range(100000):
        # 现实倍率域(百分数 ×100, 含 1000 倍这种极端)
        cases.append((random.randint(-2 ** 31, 2 ** 31 - 1), random.randint(-100000, 100000)))
    for _ in range(100000):
        # 全域乱打(大量"结果本身就装不下 int32"的用例, 会被域检查滤掉)
        cases.append((random.randint(-2 ** 31, 2 ** 31 - 1),
                      random.choice([random.randint(-2000, 2000), 2147483647, -2147483648])))
    # 域外样本: 倍率极大(现实调用方不会出现, 但值得钉住"错在哪一步")
    outside = [(99, 2147483647), (-1, 2147483647), (1, 2147483647)]

    bad = []
    dom = 0          # 设计域内用例数
    oob = 0          # 中间步越界(域外)用例数
    for B, M in cases:
        s, of = split_checked(B, M)
        e = exact(B, M)
        if of is not None:
            oob += 1
            continue
        dom += 1
        if s != e:
            bad.append((B, M, s, e))
    return cases, bad, dom, oob, outside


# ----------------------------------------------------------------------
# ③ (持有者, objective) 建模 —— A01 那一类错误的"照妖镜"
# ----------------------------------------------------------------------
class Score(dict):
    """计分板: score[(holder, objective)] -> int。缺省读 0(未 set 过 = 0)。"""

    def getv(self, holder, obj):
        return self.get((holder, obj), 0)

    def setv(self, holder, obj, v):
        self[holder, obj] = w(v)


def mul_pct_scored(sc, src_h, src_o, mul_h, mul_o, out_h, out_o):
    """与 mul_pct 同构, 但 **每一步都带 (持有者, objective)** —— 这就是分量级建模。"""
    q = w(fdiv(sc.getv(src_h, src_o), 100))
    sc.setv('#q', out_o, q)
    sc.setv('#q', out_o, w(sc.getv('#q', out_o) * sc.getv(mul_h, mul_o)))
    r = w(fdiv(sc.getv(src_h, src_o), 100))
    sc.setv('#r', out_o, r)
    sc.setv('#r', out_o, w(sc.getv('#r', out_o) * 100))
    sc.setv('#lo', out_o, w(sc.getv(src_h, src_o) - sc.getv('#r', out_o)))
    # ③ 后半 = r*M/100, 对 M 再做一次除余分解(与 split_checked 同构; 见其注释)
    sc.setv('#q1', out_o, w(fdiv(sc.getv(mul_h, mul_o), 100)))
    sc.setv('#t', out_o, w(sc.getv('#q1', out_o) * 100))
    sc.setv('#r2', out_o, w(sc.getv(mul_h, mul_o) - sc.getv('#t', out_o)))
    sc.setv('#t', out_o, w(sc.getv('#lo', out_o) * sc.getv('#r2', out_o)))
    sc.setv('#t', out_o, w(fdiv(sc.getv('#t', out_o), 100)))
    sc.setv('#lo', out_o, w(sc.getv('#lo', out_o) * sc.getv('#q1', out_o)))
    sc.setv('#lo', out_o, w(sc.getv('#lo', out_o) + sc.getv('#t', out_o)))
    sc.setv('#mul_out', out_o, w(sc.getv('#q', out_o) + sc.getv('#lo', out_o)))
    return sc.getv('#mul_out', out_o)


def a01_demo():
    # 现场形态: dmg_add_apply 的分数全写在 zx.meta
    sc = Score()
    sc.setv('#s_m', 'zx.meta', 100000)     # 100.000(定点 x1000)
    sc.setv('#k_m', 'zx.meta', 150)        # ×1.50
    right = mul_pct_scored(sc, '#s_m', 'zx.meta', '#k_m', 'zx.meta', '#tot', 'zx.meta')
    # A01 的写法: mul_pct 内部**硬编码** manacore.math
    wrong = mul_pct_scored(sc, '#s_m', 'manacore.math', '#k_m', 'manacore.math',
                           '#tot', 'manacore.math')
    return right, wrong


def main():
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

    print('=' * 72)
    print('① mul_pct 分段 == 单步 floor(B*M/100)(20 万+ 组, mul 含负数/0)')
    print('   ★ 只在"没有任何中间步越过 int32"的设计域内做等价承诺')
    print('=' * 72)
    cases, bad, dom, oob, outside = equiv()
    print('  用例数 %d ; 域内 %d ; 中间步越界(域外) %d' % (len(cases), dom, oob))
    print('  域内不符例数 %d  %s' % (len(bad), 'OK' if not bad else '★ 需复核'))
    for b in bad[:10]:
        print('    B=%d M=%d 分段=%d 真值=%d' % b)
    print('  域外样本(倍率极大, 现实调用方(|mul|<=1e5)不会出现):')
    for B, M in outside:
        s, of = split_checked(B, M)
        print('    B=%d M=%d ⇒ 分段=%d ; 真值=%d ; 越界步 = %s'
              % (B, M, s, exact(B, M), of))
    print('    ⇒ 设计的"域"(Q06 四审后的新式) = ① 结果装得下 int32;')
    print('                                    ② |mul| <= int32(输入自身装得下)。')
    print('      ★ 旧式还多一条 99*|mul| <= int32(即 |mul| <= 约 2.17e7) —— 已由')
    print('        ③ 步的"对 M 再分解一次"消掉, 见 ⑤。')
    print('      现实调用方 |mul| <= 1e5, 离任一条件都差两个数量级以上。')

    print('\n' + '=' * 72)
    print('② 除法语义: floorDiv(向下取整) vs 向零截断 —— 报告点名的负例')
    print('=' * 72)
    for a, b in [(-1, 100), (1, 100), (-101, 100), (99, 100), (-99, 100)]:
        print('  %5d / %3d  ⇒  MC(floorDiv)=%-4d   旧的错误建模(trunc)=%-4d'
              % (a, b, fdiv(a, b), tdiv(a, b)))

    print('\n' + '=' * 72)
    print('③ 报告点名的溢出例(旧写法回绕归零 / 分段正确)')
    print('=' * 72)
    for B, M, want in [(30000000, 100, 30000), (45670, 115, 52.52)]:
        print('  B=%d M=%d : 旧=%d  分段=%d (x1000 -> %.3f, 期望 %s)'
              % (B, M, old_trunc(B, M), split(B, M), split(B, M) / 1000.0, want))

    print('\n' + '=' * 72)
    print('④ A01 照妖镜: (持有者, objective) 建模 —— 传错 objective 会读成 0')
    print('=' * 72)
    right, wrong = a01_demo()
    print('  分数实写在 zx.meta: #s_m=100000(x1000) #k_m=150(×1.50)')
    print('  传对 obj="zx.meta"        ⇒ #mul_out = %d (x1000 -> %.3f, 期望 150.000)'
          % (right, right / 1000.0))
    print('  传错 obj="manacore.math"  ⇒ #mul_out = %d   ← A01 的现场症状(输入读不到 => 0)'
          % wrong)
    ok4 = (right == 150000 and wrong == 0)

    print('\n' + '=' * 72)
    print('⑤ Q06 报告例: max_health=1.999 / health_ratio=250000 ⇒ #hr = 25000000(x100)')
    print('   (B = max_health x1000 = 1999 ; M = #hr = 25000000)')
    print('=' * 72)
    B5, M5 = 1999, 25000000
    e5 = exact(B5, M5)
    print('  真值 floor(B*M/100)                        = %d  (x1000 -> %.3f)'
          % (e5, e5 / 1000.0))
    print('  ① 单步老写法(N10 之前) B*M/100(直乘回绕)    = %d' % old_trunc(B5, M5))
    print('  ② 分段式(三审版, Q06 前) ③ 步 lo*=M 回绕   = %d  ← 报告说的 456800.327' % split_q06_old(B5, M5))
    print('  ③ 分段式 + ③ 步二次分解(本次修)            = %d  (x1000 -> %.3f)'
          % (split(B5, M5), split(B5, M5) / 1000.0))
    print('     ③ 的中间步: q1=floor(M/100)=%d ; r2=M-100*q1=%d ; r*q1=%d ; r*r2=%d'
          % (fdiv(M5, 100), M5 - 100 * fdiv(M5, 100), 99 * fdiv(M5, 100), 99 * (M5 - 100 * fdiv(M5, 100))))
    ok5 = (split(B5, M5) == e5 and split_q06_old(B5, M5) == 456800327)

    ok = (not bad) and ok4 and ok5
    print('\n结论: %s' % ('全部通过' if ok else '★ 有问题'))
    if not ok:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
