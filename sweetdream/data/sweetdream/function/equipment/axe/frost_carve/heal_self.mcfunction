# ============================================================
# sweetdream:equipment/axe/frost_carve/heal_self —— 恢复最大生命值 10%
# ------------------------------------------------------------
# 【谁调用它】cast ⑩ (只在本次解除冰冻 ≥2 只时)   【执行者】施法者(**必须是玩家**)
# 【为什么这么绕】lib/heal 的入参 #heal_pt 是**整点数**, 而文案给的是百分比。
#   ⇒ 先从面板取最大生命值(api/stats/get 的 r.value, 用 `data get ... 1000` 折成整数),
#     再连除两次 #100: ×1000 → ÷100 = ×10 → ÷100 = ×1/10 = 10%。
#   例: 最大生命 400.0 -> 400000 -> 4000 -> 40。
# 【为什么回血不能直接写 Health】原版禁止写玩家 NBT(坑 160-164);
#   lib/heal 走的是"压上限 -> instant_health 顶满 -> 下一拍撤上限"那条唯一可行路线。
# ============================================================

# ① 取面板最大生命值(r.value 是 double, ×1000 转成整数)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #frc_mh zx.meta run data get storage manacore:out r.value 1000

# ② 百分比 -> 整点数(pct = 10 常态 / 20 超限, 由 cast ⑦.5 写进 zx:work frc.pct)
#   r.value 已经被 ×1000 放大过: ÷10000 先折成 10% 的整点, 再 ×pct ÷10 得到 pct%。
execute store result score #frc_pct zx.meta run data get storage zx:work frc.pct
scoreboard players operation #heal_pt zx.meta = #frc_mh zx.meta
scoreboard players operation #heal_pt zx.meta /= #10000 zx.meta
scoreboard players operation #heal_pt zx.meta *= #frc_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #10 zx.meta

# ③ 回血(撤上限由 core/tick 在下一拍做, 详见 lib/heal 文件头)
function sweetdream:lib/heal

# ④ 表现
execute at @s run particle minecraft:heart ~ ~1.4 ~ 0.4 0.4 0.4 0.0 6 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.4
tellraw @s [{"text":"剜霜解冻回响（恢复最大生命值 ","color":"aqua"},{"score":{"name":"#frc_pct","objective":"zx.meta"},"color":"aqua"},{"text":"%）","color":"aqua"}]
