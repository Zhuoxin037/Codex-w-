# ============================================================
# sweetdream:equipment/axe/frost_carve/apply —— 逐只"冻 or 解冻"的二分处理
# ------------------------------------------------------------
# 【谁调用它】cast ⑨   【执行者】**施法者本人**   【位置】他所在处
# 【做什么】
#   ① 把本轮命中者按"当前有没有 zx.freeze"分成两拨
#   ② 解冻那拨: 逐只走 lib/unfreeze_one(顺带广播「苦寒」钩子), 并数出人数 #frc_thaw
#   ③ 解冻那拨: 用**施法者身份**再打一次 基础攻击力 ×2
#   ④ 没冻的那拨: 集体冰冻 20 刻(= 1 秒)
# 【★ 额外伤害为什么不在 `as 生物` 里打 ★】api/damage 会读**执行者**的 UUID 当击杀归属;
#   在 `as 生物` 里执行 -> 执行者不是玩家 -> 归属全 0 -> 不算玩家的击杀(不掉经验、
#   死亡提示不写名字)。所以先给它们打标签, 再用玩家身份一次性投递。
# 【★ 解冻信号必须在投递之前发 ★】lib/unfreeze_one 会摘 zx.freeze, 之后就没法再判
#   "原本是不是冻着的" —— 所以先分拨、再处理。
# ============================================================

# ① 分拨: 已冻的进 zx.frc_thaw, 没冻的进 zx.frc_cold
tag @e[tag=zx.frc_thaw,distance=0..] remove zx.frc_thaw
tag @e[tag=zx.frc_cold,distance=0..] remove zx.frc_cold
execute as @e[tag=zx.frc_hit,distance=0..] if entity @s[tag=zx.freeze] run tag @s add zx.frc_thaw
execute as @e[tag=zx.frc_hit,distance=0..] unless entity @s[tag=zx.freeze] run tag @s add zx.frc_cold

# ② 数出"本次解除了几个" —— 只数得到, 后面 cast ⑩ 判 2 个
scoreboard players set #frc_thaw zx.meta 0
execute as @e[tag=zx.frc_thaw,distance=0..] run scoreboard players add #frc_thaw zx.meta 1

# ③ 真解冻(逐只; lib/unfreeze_one 的执行者必须是它自己)
execute as @e[tag=zx.frc_thaw,distance=0..] run function sweetdream:lib/unfreeze_one

# ④ 解冻的额外伤害 = 基础攻击力 ×2(施法者身份 -> 击杀归属正确)
data modify storage zx:in arg set value {target:"@e[tag=zx.frc_thaw,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work frc.dmg2
execute if entity @e[tag=zx.frc_thaw,distance=0..,limit=1] run function sweetdream:api/damage

# ⑤ 没冻的: 冰冻 1 秒(= 20 刻) / 超限 3 秒(= 60 刻)
#   lib/freeze 要宏参数 {target, ticks}; target 可以直接给范围选择器(内部 execute as 逐个处理)
#   ★ 刻数从 zx:work frc.icz 取(cast ⑦.5 按是否超限写好), 不要在这里再判一次物品
data modify storage zx:work fz set value {target:"",ticks:20}
data modify storage zx:work fz.ticks set from storage zx:work frc.icz
data modify storage zx:work fz.target set value "@e[tag=zx.frc_cold,distance=0..]"
execute if entity @e[tag=zx.frc_cold,distance=0..,limit=1] run function sweetdream:lib/freeze with storage zx:work fz

# ⑥ 表现
execute at @e[tag=zx.frc_thaw,distance=0..,limit=1] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.5 0.4 0.08 20 normal
execute at @e[tag=zx.frc_cold,distance=0..,limit=1] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.5 0.4 0.05 16 normal
execute as @e[tag=zx.frc_thaw,distance=0..] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.6 1.4
