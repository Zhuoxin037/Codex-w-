# 减少此玩家所有已声明技能的现存冷却记录。
#   未超限: 每个噬心 -2 秒 / 超限·剖心: 每个噬心 **-3 秒**(2026-10-23 批 K2)
#   ★ "所有技能"仍沿用既有口径: 只减剖心释放的这个技能(manacore 的冷却记录是 compound,
#     命令列不出键 —— 见 upgrade/api/cd_tick 头注释, 2026-10-07 定稿)。
#   ★ 超限那条"前面武器 -10 秒"是另一件事, 在 ol_prev_cd 里按快捷栏槽位算。
scoreboard players set #pf_per zx.meta 2
execute if score #pf_ol zx.meta matches 1 run scoreboard players set #pf_per zx.meta 3
scoreboard players operation #pf_sec zx.meta = #pf_clear zx.meta
scoreboard players operation #pf_sec zx.meta *= #pf_per zx.meta

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:profane",seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.seconds double 1.0 run scoreboard players get #pf_sec zx.meta
function sweetdream:equipment/staff/stop_needle/cd_all

execute at @s run particle minecraft:dust{color:[0.2,0.75,0.85],scale:0.9} ~ ~1 ~ 0.5 0.6 0.5 0.01 10 normal
