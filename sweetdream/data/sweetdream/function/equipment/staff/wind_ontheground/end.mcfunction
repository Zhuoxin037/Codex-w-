# ============================================================
# sweetdream:equipment/staff/wind_ontheground/end —— 风声回响收尾
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【要擦干净的三样】
#   ① 还掉 aura 期间加的最大魔力(数值就是当时记下的 zx.wg_mana)
#   ② 夹一下当前魔力(上限变小了, 可能超上限)
#   ③ 清空「风声」和倒计时
# ============================================================

# ① 还掉最大魔力加成(传负数回 stats/add)
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double -1 run scoreboard players get @s zx.wg_mana
function manacore:api/stats/add
scoreboard players set @s zx.wg_mana 0

# ② 夹紧当前魔力(读出来再 set, set 内部会夹到 [0,max])
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set

# ③ 结束: 清空「风声」+ 收掉倒计时
scoreboard players set @s zx.wg_sound 0
scoreboard players set @s zx.wg_aura 0

# ④ 表现
execute at @s run particle minecraft:small_gust ~ ~1 ~ 2.0 0.8 2.0 0.05 20 normal
execute at @s run playsound minecraft:entity.breeze.idle_ground player @a ~ ~ ~ 0.7 1.3
tellraw @s [{"text":"风声散去。","color":"gray","italic":true}]
