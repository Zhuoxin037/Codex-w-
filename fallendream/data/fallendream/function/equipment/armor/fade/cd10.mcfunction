# ============================================================
# fallendream:equipment/armor/fade/cd10 —— 超限·息影: 常驻「技能冷却 −10%」
# ------------------------------------------------------------
# 【谁调用它】fade/on_cast（挂在 #manacore:event/cooldown_start）
# 【★ 为什么不在 on_cast 里直接做、要拆出来 ★】
#   cooldown/get 与 cooldown/reduce 都会 `data modify storage manacore:work a set value {...}`
#   整份重置 manacore:work a；而 internal/skill/go 在 cooldown_start 之后还有
#   `damage/calc with storage manacore:work a` —— 不还原的话，穿息影那一次技能会
#   **算不出伤害**（只扣蓝不打人，且不报错）。这是 backlight/on_cast 记过的坑。
# 【文案】"自身技能冷却时间 −10%"（常驻，每个刚进冷却的技能都减 10%）
# 【★ 不写 stats.cooldown_reduction ★】那条被 upgrade/api/cd_stat 独占、每秒整体覆盖；
#   改成对这一个技能 reduce 10%（与 bearing/on_cast / resonance/on_cast 同款）。
# 【★★ 为什么要分 cd10 / cd10_go 两层 ★★】
#   cd10_go 内有 early return（不足 10 刻 / 拿不到 uuid）。若还原写在有 return 的
#   同一层，那些路径会跳过还原 → manacore:work a 永久损坏。故"做事"全放子函数，
#   "备份/还原"放本层，无条件执行（子函数的 return 只返回它自己）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["fade"],ol:"fade"}] run return 0
execute unless data storage manacore:ctx skill run return 0

# ① 整份备份技能参数节点 + 公共输入口
data modify storage zx:work fd_bak set from storage manacore:work a
function fallendream:lib/in_bak

# ② 做事（内部可以随意 early return，不会跳过下面的还原）
function fallendream:equipment/armor/fade/cd10_go

# ③ 无条件还原（两个 api 都读过/写过 in arg 与 work a）
function fallendream:lib/in_restore
data modify storage manacore:work a set from storage zx:work fd_bak
data remove storage zx:work fd_bak
