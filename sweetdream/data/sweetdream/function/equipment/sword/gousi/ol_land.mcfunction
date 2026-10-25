# ============================================================
# sweetdream:equipment/sword/gousi/ol_land —— 超限·钩丝 拉到位置(宏)
# ------------------------------------------------------------
# 【执行者】被拉到的那只生物；位置在它脚下
# 【宏参数】zx:work gs3 {own}
# 【结算】5 秒缓慢Ⅱ + 最大魔力值 ×0.12 的伤害 + 施法者「下三次技能伤害 +10%」
# 【★ 加成必须给**施法者** ★】本文件 @s 是怪物, `scoreboard players add @s`
#   会把加成写到怪物身上(它永远不施法, 于是静默失效) —— 用 zx.gs3_src 换回玩家。
# ============================================================

# ① 5 秒缓慢Ⅱ(药水等级参数是放大器: Ⅱ 写 1)
effect give @s minecraft:slowness 5 1 true

# ② 伤害: 最大魔力 ×0.12(#gs_k 交给 ol_hit 当系数)
scoreboard players set #gs_k zx.meta 12
function sweetdream:equipment/sword/gousi/ol_hit

# ③ 加成(施法者侧)
execute as @e[tag=zx.gs3_src,limit=1] run function sweetdream:equipment/sword/gousi/ol_buff_land

# ④ 表现 + 摘标签(摘掉之后 ol_step 那一步 tp 就不会再跑)
execute at @s run particle minecraft:crit ~ ~0.9 ~ 0.5 0.6 0.5 0.1 20 normal
execute at @s run particle minecraft:enchanted_hit ~ ~0.9 ~ 0.4 0.5 0.4 0.08 12 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.9 1.0
$tag @s remove zx.gs3_$(own)
