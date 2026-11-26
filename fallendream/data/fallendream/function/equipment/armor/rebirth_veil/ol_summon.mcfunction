# ============================================================
# fallendream:equipment/armor/rebirth_veil/ol_summon —— 超限·复纱：提前召回的爆发
# ------------------------------------------------------------
# 【执行者】本我者(玩家本人)
# 【文案】若同生体死亡后自身在 12 秒内将其重新召唤出来，则召唤时对自身 12 格内的
#   生物造成一次相当于自身最大魔力值 ×0.03 的伤害并击退 2 格，且自身最大魔力值
#   +20%，持续 12 秒。之后本我者和同生体每秒恢复 8% 生命值，持续 4 秒。
# 【12 秒怎么判】zx.rbv_die 在 profession/twin/died 记死亡当刻, 这里 #now−死亡刻 ≤ 240。
#   ★ 判完立刻清零: 同一具同生体只给一次爆发, 而且清零后旧值不会在下一轮误触发。
# 【★ 为什么只挂在 reborn_due ★】twin/tick 是 j_reborn 归 0 才走到这里 —— 也就是
#   "重新召唤出来"那一刻的唯一入口; enter 那条路要求 j_reborn 已经归 0/-1(同生体活着),
#   本来就不可能落在 12 秒窗口里。
# ============================================================

execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run return 0

scoreboard players operation #rbv_dt zx.meta = #now manacore.meta
scoreboard players operation #rbv_dt zx.meta -= @s zx.rbv_die
scoreboard players set @s zx.rbv_die 0
execute if score #rbv_dt zx.meta matches 241.. run return 0
execute if score #rbv_dt zx.meta matches ..-1 run return 0

# ---- ① 12 格内生物: 最大魔力值 ×0.03 ----
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=..12]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra

# ---- ② 击退 2 格 ----
# 【位移手法】包内现役那套(异彩 eff_3 / 杂纹 b_yuanhai 同款): facing 到圆心(自己),
#   `^-2` 就是"从自己往外退 2 格"; `if block … replaceable` = 撞墙就不推。
#   ★ 圆心必须打临时标签: 下面 `as 生物` 之后 @s 已经不是玩家了。
#   ★ distance 从 0.01 起, 排除玩家自己站的圆心。
tag @a remove zx.rbv_own
tag @s add zx.rbv_own
execute as @e[type=!#fallendream:no_damage,distance=0.01..12] at @s facing entity @a[tag=zx.rbv_own,limit=1] feet positioned ^ ^ ^-2 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @a remove zx.rbv_own

# ---- ③ 自身最大魔力值 +20%, 12 秒 ----
#   ★ 已在生效就只续时间 —— 否则两次窗口重叠会变成 +40% 且到期不同步。
scoreboard players add @s zx.rbv_mm 0
execute if score @s zx.rbv_mm matches 0 run function fallendream:equipment/armor/rebirth_veil/mm_add
execute if score @s zx.rbv_mm matches 1.. run scoreboard players operation @s zx.rbv_mm_end = #now manacore.meta
execute if score @s zx.rbv_mm matches 1.. run scoreboard players add @s zx.rbv_mm_end 240

# ---- ④ 之后每秒回 8% 生命, 4 秒 ----
# 【为什么 end 是 +100 而不是 +80】回血是每秒判一次 `next <= #now`, 到 end 那一秒
#   条件已经不成立; +100 才能在 20/40/60/80 这四拍各回一口 = 文案的"持续 4 秒"。
scoreboard players operation @s zx.rbv_rg_end = #now manacore.meta
scoreboard players add @s zx.rbv_rg_end 100
scoreboard players operation @s zx.rbv_rg_next = #now manacore.meta
scoreboard players add @s zx.rbv_rg_next 20
