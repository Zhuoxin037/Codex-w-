# ============================================================
# sweetdream:equipment/staff/wind_ontheground/bonus —— 风声超过 60 的奖励
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【文案】若有超过 60 点「风声」, 每超出 1 点都会让"下一次自身使用最大魔力值
#         相关的技能伤害"提升 1%。
# 【怎么存】zx:data wg_bonus."<uuid>" = 加成比例(0.15 表示 +15%)。
#   用"存一个比例"而不是"存一个点数", 是为了给别的技能用的时候只要乘一下就行。
# 【谁吃它】所有"以自身最大魔力值结算"的技能, 统一走一行:
#     function sweetdream:lib/max_mana_bonus with storage zx:work wg
#   它把比例乘进 skill_multiplier(**普通乘区**, 不是独立乘区), 用完即删,
#   只生效一次。已接: 风行(hit_pass / aura_hit)、横刀(dash_end)。
#   ⚠️ 深海**不要**接 —— 它是"当前魔力 ×0.15", 不是最大魔力, 口径不同。
# ============================================================

scoreboard players operation #ex zx.meta = @s zx.wg_sound
scoreboard players remove #ex zx.meta 60

# 【加算, 不是覆盖】把这次的加成**加到**已经存着的那一份上, 而不是覆盖掉。
#   于是"攒到两次"或"以后有别的来源也写同一个字段"时, 是
#       百分比先相加 -> 再一起乘一次倍率      (加算)
#   而不是
#       各自乘一遍 (1+b1)×(1+b2)             (乘算)
#   这样它才真的是"skill_multiplier 那一档里的加法项", 和其他技能倍率加成同性质。
#   实现: 先把已有的加成按 x100 读进计分板, 加上这次的, 再写回(0.01 = "每超出一点 +1%")
scoreboard players set #add zx.meta 0
$execute if data storage zx:data wg_bonus."$(uuid)" store result score #add zx.meta run data get storage zx:data wg_bonus."$(uuid)" 100
scoreboard players operation #ex zx.meta += #add zx.meta
$execute store result storage zx:data wg_bonus."$(uuid)" double 0.01 run scoreboard players get #ex zx.meta

tellraw @s [{"text":"风声攒够了 —— 下一次以最大魔力结算的技能伤害 +","color":"aqua"},{"score":{"name":"#ex","objective":"zx.meta"},"color":"white"},{"text":"%","color":"aqua"},{"text":"  (合计, 加算)","color":"dark_gray"}]
