$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**原本**就带「流火」（没烧着的砍了没有收益）
execute unless data storage zx:combat events[-1].event.was{liuhuo:1b} run return 0

# ⑤ 拿 uuid（回复魔力的公共输入口要它）
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑤.5 档位快照（魔力点数、1% 上限、迅捷秒数/等级、是否开"移动攒额外一次"都分档）
scoreboard players set #ss_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["smoke_step"],ol:"smoke_step"}] run scoreboard players set #ss_ol zx.meta 1

# ⑥ 回复魔力: 基础 10 点 / 超限 15 点
data modify storage manacore:in arg set value {uuid:"",value:10.0}
execute if score #ss_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",value:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ⑦ ★ 超限: 再恢复 1% 上限魔力（放子函数里 —— 它内部有 early return, 不能打断本层）
execute if score #ss_ol zx.meta matches 1 run function fallendream:equipment/armor/smoke_step/ol_pct

# ⑧ 迅捷: 基础 2 秒Ⅰ / 超限 3 秒Ⅱ
#   ★ 两档各写一条 effect, 不 clear 再给（clear 会连别处的迅捷一起抹掉）。
#   ★ 超限还顺手开启"移动累计"窗口 zx.ss_spd_end —— smoke_step/move_tick 只在
#     这个窗口里读坐标, 窗口一过就完全不消耗性能。
execute if score #ss_ol zx.meta matches 0 run effect give @s minecraft:speed 2 0 true
execute if score #ss_ol zx.meta matches 1 run effect give @s minecraft:speed 3 1 true
execute if score #ss_ol zx.meta matches 1 run scoreboard players operation @s zx.ss_spd_end = #now manacore.meta
execute if score #ss_ol zx.meta matches 1 run scoreboard players add @s zx.ss_spd_end 60
#   窗口重开时把"已累计"和采样基线一起重置, 否则上一轮的 4 格会直接算进这一轮
execute if score #ss_ol zx.meta matches 1 run scoreboard players set @s zx.ss_move 0
execute if score #ss_ol zx.meta matches 1 run scoreboard players set @s zx.ss_smp 0
execute if score #ss_ol zx.meta matches 1 run data modify storage zx:work ss.pos set from entity @s Pos
execute if score #ss_ol zx.meta matches 1 run execute store result score @s zx.ss_px run data get storage zx:work ss.pos[0] 100
execute if score #ss_ol zx.meta matches 1 run execute store result score @s zx.ss_py run data get storage zx:work ss.pos[1] 100
execute if score #ss_ol zx.meta matches 1 run execute store result score @s zx.ss_pz run data get storage zx:work ss.pos[2] 100

# ⑨ 表现
$execute at $(vx_uuid) run particle minecraft:smoke ~ ~0.6 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.5 1.6

# ⑩ 记账: "下次可触发刻" = 现在 + 60 刻（3 秒，两档同）
scoreboard players operation @s zx.ss_cd = #now manacore.meta
scoreboard players operation @s zx.ss_cd += #60 zx.meta
#   这一次是用"攒来的额外一次"放行的 -> 消费掉（正常节流走到这里时不消费, 留着）
execute if score @s zx.ss_use matches 1 run scoreboard players set @s zx.ss_extra 0
scoreboard players set @s zx.ss_use 0

# ⑪ 收尾
$tag $(vx_uuid) remove zx.victim
