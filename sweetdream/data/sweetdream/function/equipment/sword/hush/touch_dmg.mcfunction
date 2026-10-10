# ============================================================
# sweetdream:equipment/sword/hush/touch_dmg —— 突击途中"碰到生物"那一下
# ------------------------------------------------------------
# 【宏参数】zx:work hs {uuid:"<施法者 uuid 文本>"}
# 【谁调用它】dash_mark ③(仅当这一刻身边 3 格内出现了"本局还没打过的生物"时才调)
# 【执行者】施法者本人; 【位置】他此刻所在的位置
# 【技能原文】"若碰到生物则立即对**附近 3 格内的全部生物**造成一次
#   相当于自身最大魔力值 ×0.1 的伤害" —— 注意是**打一片**, 不是只打碰到的那只!
# 【伤害】身边 3 格内的**全部**生物, 最大魔力值 ×0.1(mm 通道)
# 【每只一次怎么保证】dash_mark ③ 给"还没被本局打过(tag=!zx.hs_hit_<uuid>)且
#   进入 3 格"的生物打临时标签 zx.hs_new_<uuid>; 这里打完把**身边 3 格内的全部**
#   生物转成 zx.hs_hit_<uuid>(本局已覆盖)。★ 标记带施法者 uuid ⇒ 别人打过的不会
#   让本局漏打, 本局打过的也不会替别人"占坑"; 残留由 tag_clear 在每次施法开头按
#   自己的 uuid 清掉。
# 【uuid 走宏参数】dash_mark 已经把施法者 uuid 传进来了, 不再现取 lib/uuid。
# 【★ 每行带 $(uuid) 的都必须带前导 $】否则会被当字面量字符串、静默失效。
# ============================================================

# ① 算伤害: 最大魔力 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:work hs.uuid
function manacore:api/damage/calc

# ② 表现: 施法者身周 3 格范围一小簇星火 + 一声轻击(用 weak, 不盖过环境音)
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 1.5 0.9 1.5 0.1 20 normal
execute at @s run playsound minecraft:entity.player.attack.weak player @a ~ ~ ~ 0.35 1.6

# ③ 打身边 3 格内的**全部**生物
#   distance=..3 在这里既给选择器一个位置基准(锁当前维度), 也是"碰到"的范围。
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute store result score #dbg_sel zx.meta run execute if entity @e[type=!#sweetdream:no_damage,distance=..3]
execute at @s run function sweetdream:api/damage

# ④ 把身边 3 格内的全部生物标成"本局已覆盖", 再清掉触发用的临时标签
#   (顺序: 先 add 后 remove; remove 用 zx.hs_new_<uuid> 选 —— 它只在"触发这一刻"存在)
$execute as @e[type=!#sweetdream:no_damage,distance=..3] run tag @s add zx.hs_hit_$(uuid)
$execute as @e[type=!#sweetdream:no_damage,tag=zx.hs_new_$(uuid),distance=..3] run tag @s remove zx.hs_new_$(uuid)
