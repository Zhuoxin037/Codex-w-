# ============================================================
# sweetdream:equipment/staff/other_shore/to_shixin_go —— 只有「渊海」者: 转化为「噬心」
# ------------------------------------------------------------
# 【执行者】施法者(玩家)   【位置】施法者处
# 【入参】zx.os_sel + zx.os_y = 本轮**只有**「渊海」的那些
# 【技能原文】"若其只附有「渊海」，则将其转化为「噬心」，并造成一次相当于自身
#   最大魔力值 ×0.1 的伤害。"
# 【★ 转化 = tag/unmark + tag/mark, 不走 lib/mark_consume ★】
#   走消耗链的话, 穿「永恒」会把「渊海」原地补回来 ⇒ 变成"渊海 + 噬心"双状态
#   (热熔/余烬那两处记过的刷资源漏洞, 见 lib/mark_consume 头部的"转换类不走这里")。
#   顺带: 转化也不该触发"技能消耗状态后…"的装备被动(回潮扣/杂纹), 语义正好对上。
# 【★ 顺序: 先摘后附 ★】先 unmark 再 mark; 反过来的话 mark_one 的"已有该状态"分支
#   会让新状态直接跳过(等于没转化)。
# ============================================================

# ① 摘掉「渊海」
function sweetdream:tag/unmark {target:"@e[tag=zx.os_sel,tag=zx.os_y,distance=0..]",mark:"yuanhai"}

# ② 附上「噬心」
function sweetdream:tag/mark {target:"@e[tag=zx.os_sel,tag=zx.os_y,distance=0..]",mark:"shixin"}

# ③ 算 ×0.1 伤害(普通伤害)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 打(仍在 zx.os_y 标签下 —— 这是本轮快照, 与状态本身已经换成噬心无关)
data modify storage zx:in arg set value {target:"@e[tag=zx.os_sel,tag=zx.os_y,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ⑤ 表现: 渊海被翻成噬心
execute at @e[tag=zx.os_sel,tag=zx.os_y,distance=0..,limit=1] run particle minecraft:dust{color:[0.55,0.05,0.05],scale:1.5} ~ ~1 ~ 0.5 0.6 0.5 0.02 16 normal
execute at @e[tag=zx.os_sel,tag=zx.os_y,distance=0..,limit=1] run playsound minecraft:block.soul_soil.break player @a ~ ~ ~ 0.6 0.9
