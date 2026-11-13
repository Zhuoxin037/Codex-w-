
# 掷一次骰子(无论如何都掷, 保持序列连续)
function sweetdream:lib/rnd
scoreboard players operation #rm_r zx.meta = #rnd zx.meta
scoreboard players operation #rm_r zx.meta %= #5 zx.meta

# 命中 0 且目标确实带「流火」-> 把这一只钉进 zx.rm_c(之后操作与流火是否还在无关)
tag @e[tag=zx.rm_c] remove zx.rm_c
$execute if score #rm_r zx.meta matches 0 run execute if data entity $(vx_uuid) {Tags:["zx.status.liuhuo"]} run tag $(vx_uuid) add zx.rm_c

# 摘流火、附夜火(走通用标签接口, 图标跟着换)
# ★ 这里**故意**不走 lib/mark_consume(消耗统一入口) ★ —— 这是"替换"不是"消耗":
#   走入口的话, 穿「永恒」的玩家会把流火"补回来", 变成"流火+夜火"双状态
#   (2026-10-04 记过的刷魔力漏洞: 烈火残躯吸掉夜火后流火还在, 下次熄灭又能再变一次)。
#   所以保持直调 tag/unmark。
execute if entity @e[tag=zx.rm_c] run data modify storage zx:work ic set value {target:"@e[tag=zx.rm_c]",mark:"liuhuo"}
execute if entity @e[tag=zx.rm_c] run function sweetdream:tag/unmark with storage zx:work ic
execute if entity @e[tag=zx.rm_c] run data modify storage zx:work ic set value {target:"@e[tag=zx.rm_c]",mark:"yehuo"}
execute if entity @e[tag=zx.rm_c] run function sweetdream:tag/mark with storage zx:work ic
execute at @e[tag=zx.rm_c] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.5 0.6 0.5 0.03 16 normal
execute at @e[tag=zx.rm_c] run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.6 1.6
tag @e[tag=zx.rm_c] remove zx.rm_c

$tag $(vx_uuid) remove zx.victim
