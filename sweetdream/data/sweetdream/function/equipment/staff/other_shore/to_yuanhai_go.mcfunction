# ============================================================
# sweetdream:equipment/staff/other_shore/to_yuanhai_go —— 只有「噬心」者: 转化为「渊海」
# ------------------------------------------------------------
# 【执行者】施法者(玩家)   【位置】施法者处
# 【入参】zx.os_sel + zx.os_s = 本轮**只有**「噬心」的那些
# 【技能原文】"若其只附有「噬心」，则将其转化为「渊海」，并造成一次相当于自身
#   最大魔力值 ×0.08 的**真实伤害**。"
# 【★ 与 to_shixin_go 唯一的差别 ★】① 换的是反方向; ② 伤害是**真伤**(×0.08),
#   不是普通伤害。其余(先摘后附、不走消耗链)完全同构。
# ============================================================

# ① 摘掉「噬心」
function sweetdream:tag/unmark {target:"@e[tag=zx.os_sel,tag=zx.os_s,distance=0..]",mark:"shixin"}

# ② 附上「渊海」
function sweetdream:tag/mark {target:"@e[tag=zx.os_sel,tag=zx.os_s,distance=0..]",mark:"yuanhai"}

# ③ 算 ×0.08 真实伤害
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 打(真伤类型)
data modify storage zx:in arg set value {target:"@e[tag=zx.os_sel,tag=zx.os_s,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑤ 表现: 噬心被冲回渊海
execute at @e[tag=zx.os_sel,tag=zx.os_s,distance=0..,limit=1] run particle minecraft:bubble ~ ~1 ~ 0.6 0.6 0.6 0.04 18 normal
execute at @e[tag=zx.os_sel,tag=zx.os_s,distance=0..,limit=1] run playsound minecraft:block.bubble_column.upwards_inside player @a ~ ~ ~ 0.6 1.3
