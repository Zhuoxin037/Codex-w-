# ------------------------------------------------------------
# internal/join/existing —— 老玩家重新上线
# 【宏参数】manacore:work.a {uuid,u0,u1,u2,u3}
# 【干什么】
#   ① 兼容性补齐: 逐项检查缺失字段(stats/flags/cooldowns/regen_mods/
#      formations/debug/各单项属性), 缺什么补什么。这样升级框架版本后
#      老存档的数据不会因为少一个字段而报错。
#   ② 槽位校验: 把身份信息转交 join/slot_route, 它会检查
#      "计分板里的槽位是否仍属于我", 不属于就重新分配。
# 【为什么不用 merge 直接补齐】data modify merge 会用来源覆盖同名键,
#      那会把玩家已经成长过的属性重置回默认值。所以这里必须用
#      execute unless data 一项一项判断。
# ------------------------------------------------------------
$execute unless data storage manacore:players "$(uuid)".stats run data modify storage manacore:players "$(uuid)".stats set from storage manacore:config defaults.stats
$execute unless data storage manacore:players "$(uuid)".flags run data modify storage manacore:players "$(uuid)".flags set from storage manacore:config defaults.flags
$execute unless data storage manacore:players "$(uuid)".cooldowns run data modify storage manacore:players "$(uuid)".cooldowns set value {}
$execute unless data storage manacore:players "$(uuid)".regen_mods run data modify storage manacore:players "$(uuid)".regen_mods set value {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}}
$execute unless data storage manacore:players "$(uuid)".formations run data modify storage manacore:players "$(uuid)".formations set value {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}}
$execute unless data storage manacore:players "$(uuid)".debug run data modify storage manacore:players "$(uuid)".debug set value 0b
$execute unless data storage manacore:players "$(uuid)".stats.cooldown run data modify storage manacore:players "$(uuid)".stats.cooldown set value 0.0
$execute unless data storage manacore:players "$(uuid)".stats.cooldown_reduction run data modify storage manacore:players "$(uuid)".stats.cooldown_reduction set value 0.0
$execute unless data storage manacore:players "$(uuid)".stats.mana_regen run data modify storage manacore:players "$(uuid)".stats.mana_regen set value 1.0
$execute unless data storage manacore:players "$(uuid)".stats.mana_regen_multiplier run data modify storage manacore:players "$(uuid)".stats.mana_regen_multiplier set value 1.0
$execute unless data storage manacore:players "$(uuid)".stats.formation_limit run data modify storage manacore:players "$(uuid)".stats.formation_limit set value 3
$execute unless data storage manacore:players "$(uuid)".flags.no_regen run data modify storage manacore:players "$(uuid)".flags.no_regen set value 0b
$execute unless data storage manacore:players "$(uuid)".flags.regen_ban_end run data modify storage manacore:players "$(uuid)".flags.regen_ban_end set value 0
data modify storage manacore:macro a set value {uuid:"",u0:0,u1:0,u2:0,u3:0,cur:0,slot:0}
$data modify storage manacore:macro a.uuid set value "$(uuid)"
scoreboard players add @s manacore.slot 0
execute store result storage manacore:macro a.cur int 1 run scoreboard players get @s manacore.slot
execute store result storage manacore:macro a.slot int 1 run scoreboard players get @s manacore.slot
function manacore:internal/join/slot_check with storage manacore:macro a
