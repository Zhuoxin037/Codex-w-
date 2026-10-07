# ============================================================
# sweetdream:equipment/tool/wrath/hook_calc —— 愠怒: 最大魔力类技能 +20%（独立乘区）
# ------------------------------------------------------------
# @calc: indep   ← "独立乘区"型 hook: 必须排在 lib/dmg_add_apply **之后**
# 【谁调用它】#manacore:event/damage_calc(与炽天使之翼同一个事件)
# 【文案】血量低于 20% 时，自身有关**最大魔力值**的技能伤害提升 20%（独立乘区）。
# 【★ 按通道区分(和炽天使之翼互为镜像)★】
#   判据: 本次技能的 max_mana_mul 是不是 > 0 —— 读 **zx:work ch**(lib/dmg_ch 在
#   事件最前面拍的快照), **不要**读 manacore:work a:同事件里的
#   resonance/hook_calc 会调 api/formation/count 把那个节点整份重置掉,
#   直接读会永远读到 0 = 本件一次都不生效且不报错。详见 lib/dmg_ch 头注释。
# 【★ 独立乘区 ★】文案明写"(独立乘区)" ⇒ 在所有加成算完之后再乘一次。
#   r.damage 到这里已经过"三通道 + 加算池"(lib/dmg_add_apply), 再乘一道 1.20
#   正是独立乘区语义 —— 和加算那档(先合并百分比再乘)不同。
#   ★ 这就是它必须排在 lib/dmg_add_apply **之后**的原因: 独立乘区乘在加算之后。
#   ★ 面板同步: wrath/scan_mul 把同一个 1.20 折进 zx:work pl.independent_multiplier
#     ("独立乘区"那一行) —— **不是** smul_mm。折 smul_mm 会让面板把它显示成
#     "通道 +20%", 与这里"整体乘"的语义对不上(2026-10-06 用户反馈)。
# 【血量判据复用 low_hp】见 wrath/low_hp 的头注释。
# ============================================================

# ⓪ 不是玩家 -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 副手没拿「愠怒」-> 不参与
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] run return 0

# ② 血量低于 20% 吗
function sweetdream:equipment/tool/wrath/low_hp
execute unless score #wr_hp zx.meta matches ..-1 run return 0

# ③ 本次技能走的是"最大魔力值"通道吗
scoreboard players set #wr_m zx.meta 0
execute store result score #wr_m zx.meta run data get storage zx:work ch.max_mana_mul 100
execute unless score #wr_m zx.meta matches 1.. run return 0

# ④ 伤害 ×1.20(独立乘区)
execute store result score #d zx.meta run data get storage manacore:out r.damage 100
scoreboard players operation #d zx.meta *= #120 zx.meta
scoreboard players operation #d zx.meta /= #100 zx.meta
execute store result storage manacore:out r.damage double 0.01 run scoreboard players get #d zx.meta
