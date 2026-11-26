# ============================================================
# fallendream:profession/mage/imbue_repeat/victim_body —— 注魔主动的 X 次延迟伤害
# ------------------------------------------------------------
# 【执行者】施法的玩家（vx_uuid 已被打中的生物）
# 【原版】每次 10 刻跳一次，共 zx.j_im_n 次，单次 = 最大魔力 ×0.08
# 【超限】多带一个 im_aoe:1b，交给 profession/delayed/hit 做 2 格 80% 溅射。
#   ★ 判定必须在这里做（@s 还是玩家）；下一行起 @s 会变成被命中的生物。
#   ★ 只打一次标记，delayed 每次跳都会读到，所以 X 次各溅射一次 —— 累计正好
#     是总伤害的 80%，与文案的单次描述等价。
# ============================================================
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work jdelay set value {num:0.0,type:"fallendream:skill",u0:0,u1:0,u2:0,u3:0,count:1}
data modify storage zx:work jdelay.num set from storage manacore:out r.damage
data modify storage zx:work jdelay.u0 set from storage zx:work jhit.u0
data modify storage zx:work jdelay.u1 set from storage zx:work jhit.u1
data modify storage zx:work jdelay.u2 set from storage zx:work jhit.u2
data modify storage zx:work jdelay.u3 set from storage zx:work jhit.u3
execute store result storage zx:work jdelay.count int 1 run scoreboard players get @s zx.j_im_n
data modify storage zx:work jdelay.chain set from storage zx:combat events[-1].event.chain

# 超限：给这一批延迟伤害打上"要溅射"的标记
scoreboard players set #im_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run scoreboard players set #im_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run scoreboard players set #im_ol zx.meta 1
execute if score #im_ol zx.meta matches 1 run data modify storage zx:work jdelay.im_aoe set value 1b

scoreboard players set @s zx.j_im_n 0
$execute as $(vx_uuid) at @s run function fallendream:profession/delayed/new
