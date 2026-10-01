# 两个目标仅属于显示系统；状态本身保存在原生 Tags 中。
execute unless data storage zx:config tag_v2_initialized run scoreboard objectives add zx.icon_mask dummy
execute unless data storage zx:config tag_v2_initialized run scoreboard objectives add zx.icon_ttl dummy
data modify storage zx:config tag_v2_initialized set value 1b
scoreboard players set #tag_clock zx.meta 0
scoreboard players set #icon_t zx.meta 0
function sweetdream:tag/second
