# 圣骸诊断: 不再尝试用 @e 搜尸体。
scoreboard players set #sr_probe_ready zx.meta 0
function sweetdream:equipment/axe/sacred_relic/probe
execute if score #sr_probe_ready zx.meta matches 0 run tellraw @s {text:"圣骸诊断未加载：新增的遗骸附魔需要保存退出世界后重新进入（服务器需重启），仅 /reload 无效；若重进后仍出现此提示，请查看日志中的加载错误。",color:"red"}
