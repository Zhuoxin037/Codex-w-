# ============================================================
# sweetdream:equipment/bow/lucid_dream/shot —— 每次射击(清醒梦)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/lucid_dream(触发器 shot_crossbow)。
# 【文案】每次射击若射中附加「白昼梦」或处于时停的生物, 则累计一层「梦回」(上限 5)。
#   当「梦回」≥3 层后, 再次射击附有「白昼梦」的生物时对其造成 自身当前魔力值 ×0.X
#   的伤害, 之后清除该生物的「白昼梦」并清除自身「梦回」, 之后召唤一个术阵。
#   召唤术阵后该生物每次受到攻击都会使自身 2 格内的全部生物额外受到一次相当于
#   自身最大魔力值 ×0.0X 的真实伤害, 持续 X 秒。若持续时间内该生物被附加了「白昼梦」
#   则延长至该生物的「白昼梦」结束。(X 为「梦回」层数)
# 【★ 命中判定交给附魔回调 ★】射击本身只扣魔力 + 记"这一发有效";
#   真·命中由附魔 hook_victim 判定(它才知道射中了谁)。
# 【★ 魔力是射出去之后才扣的 ★】没蓝就不生效。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/lucid_dream
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.ld_dream 0

# ① 扣魔力(固定 180)
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay

# ② 魔力不足 -> 这一发不生效
execute if data storage manacore:out r{success:0b} run data modify storage zx:work ld.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/lucid_dream/clear with storage zx:work ld
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有清醒梦效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 写归属(命中时要用)
data modify storage zx:work ld set value {uuid:"",ok:1b,combo:0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work ld.uuid set from storage zx:data self.uuid
execute store result storage zx:work ld.combo int 1 run scoreboard players get @s zx.ld_dream
execute store result storage zx:work ld.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ld.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ld.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ld.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/lucid_dream/store with storage zx:work ld
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/lucid_dream/snapshot with storage zx:work ld

# ④ 表现
execute at @s run particle minecraft:end_rod ~ ~1.3 ~ 0.3 0.3 0.3 0.05 10 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.1

# ⑤ 「启示录」记页: 清醒梦这一发固定扣 180 魔力, 够 100 —— 以前因为弩不抛 cooldown_start 而一页都记不到。
function sweetdream:equipment/staff/apocalypse/spend
