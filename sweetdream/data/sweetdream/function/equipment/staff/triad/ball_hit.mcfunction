# ============================================================
# sweetdream:equipment/staff/triad/ball_hit —— 很冰的斧普攻的命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit 第 ⑥ 步: `function $(hit) with entity @s data`
#   (@s = 法球本体; 命中的生物用 @e[tag=zx.ball_hit] 圈)
# 【伤害已经打过了】ball/hit 第 ④ 步按 data.dmg 结算过一次; 本回调只做两件事:
#   ① 按形态施加**被动**; ② 若球上带着 tri_extra, 补打额外几次。
# 【三形态被动】
#   冰斧(0): 20% 冰冻 1 秒      → 强化中 60%
#   热刀(1): 40% 使**下一次**攻击额外 2 次 → 强化中 100%, 且每次 -1 护甲,
#            同一目标累计 3 次后再 -1 护甲韧性(技能结束恢复)
#   重枪(2): 使**下一次**攻击为空 → 强化中不再为空, 改为使目标抗性提升失效 2 秒
# 【★ 冰冻用什么 ★】走现成的 sweetdream:lib/freeze(原版 TicksFrozen + 移动速度 -100%),
#   不是自创 —— 它会自己续冻、到点自己解, 不用本文件管生命周期。1 秒 = 20 tick。
# 【概率怎么掷】一律 lib/rnd → %= #100 → 取区间: 20% = ..19, 40% = ..39, 60% = ..59。
#   ★ 不要用"坐标小数位 + tick"那种与攻击节奏耦合的随机源(lib/rnd 头注有这个坑)。
# ============================================================

# ⓪ 先把"形态/强化/额外次数"从球上搬到 storage(宏行读 entity 不方便, 统一走节点)
data modify storage zx:work tri.form set from entity @s data.tri_form
data modify storage zx:work tri.strong set from entity @s data.tri_strong
data modify storage zx:work tri.extra set from entity @s data.tri_extra
data modify storage zx:work tri.blank set from entity @s data.tri_blank

# ========== 形态 0 · 冰斧: 冰冻 ==========
execute if data storage zx:work tri{form:0} run function sweetdream:equipment/staff/triad/passive_ice

# ========== 形态 1 · 热刀: 下次额外 2 次 (+ 强化破甲) ==========
execute if data storage zx:work tri{form:1} run function sweetdream:equipment/staff/triad/passive_fire

# ========== 形态 2 · 重枪: 下次为空 (+ 强化: 抗性失效) ==========
execute if data storage zx:work tri{form:2} run function sweetdream:equipment/staff/triad/passive_gun

# ========== 额外 2 次(由上一发热刀的被动埋下的状态位触发) ==========
execute if data storage zx:work tri{extra:2} run function sweetdream:equipment/staff/triad/hit_more
