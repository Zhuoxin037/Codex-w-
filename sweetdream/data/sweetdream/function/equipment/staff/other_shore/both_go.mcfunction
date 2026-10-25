# ============================================================
# sweetdream:equipment/staff/other_shore/both_go —— 双状态者: 消耗两者 + ×0.2 真伤 + 溅射
# ------------------------------------------------------------
# 【执行者】施法者(玩家)   【位置】施法者处
# 【入参】zx.os_sel + zx.os_both = 本轮同时带「渊海」和「噬心」的那些
# 【技能原文】"若其同时附有两种效果，则消耗「渊海」和「噬心」，对其造成一次相当于
#   自身最大魔力值 ×0.2 的真实伤害，并对其 3 格内的其他生物造成一次相当于自身
#   最大魔力值 ×0.12 的伤害。"
# 【★ 这里用的是"消耗"不是"转化" ★】所以必须走 lib/mark_consume:
#   回潮扣(技能消耗渊海后拉人) / 杂纹(记录消费种类) 都挂在那条链上;
#   而"转化"那两件(to_shixin_go / to_yuanhai_go)故意不走(见 skill 头部)。
# 【★ 顺序: 先消耗、再打伤害 ★】文案是"消耗…，对其造成…"; 而且消耗会摘掉图标,
#   先摘再打, 伤害结算时的状态与文案一致。
# ============================================================

# ① 消耗「渊海」(技能发起的消耗 -> src:"skill")
data modify storage zx:work a set value {target:"@e[tag=zx.os_sel,tag=zx.os_both,distance=0..]",mark:"yuanhai",by:"@s",src:"skill"}
function sweetdream:lib/mark_consume

# ② 消耗「噬心」
data modify storage zx:work a set value {target:"@e[tag=zx.os_sel,tag=zx.os_both,distance=0..]",mark:"shixin",by:"@s",src:"skill"}
function sweetdream:lib/mark_consume

# ③ 算 ×0.2 真实伤害
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.os_sel,tag=zx.os_both,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ④ 圈"其 3 格内的其他生物"(以每个双状态者为圆心取并集; 排除同为双状态的那几只)
#   ★ 写成 `as ... at @s run ...` 而不是 `at <多实体>` ★ 后者虽然合法, 但包内
#     没有先例, 而且"逐只把圆心搬过去"的意图用 as/at 表达更直白(坑 151)。
tag @e[tag=zx.os_splash,distance=0..] remove zx.os_splash
execute as @e[tag=zx.os_sel,tag=zx.os_both,distance=0..] at @s run tag @e[type=!#sweetdream:no_damage,distance=0.01..3,tag=!zx.os_both] add zx.os_splash

# ⑤ 溅射 ×0.12(普通伤害, 默认 minecraft:player_attack)
execute if entity @e[tag=zx.os_splash,distance=0..] run function sweetdream:equipment/staff/other_shore/splash_dmg

# ⑥ 表现: 两界在它们身上合拢
execute at @e[tag=zx.os_sel,tag=zx.os_both,distance=0..,limit=1] run particle minecraft:reverse_portal ~ ~1 ~ 1.2 0.9 1.2 0.35 24 normal
execute at @e[tag=zx.os_sel,tag=zx.os_both,distance=0..,limit=1] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.55 0.7
