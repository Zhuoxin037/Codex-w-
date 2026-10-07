# ============================================================
# sweetdream:equipment/sword/remelt/convert —— 20% 把「流火」转成「夜火」
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【★ 这里刻意不写 return ★】中途 return 会把 zx.victim 留下来, 下一次事件就会
#   把上一只当成本次的目标。用"条件都写在 execute 上"的写法, 最后统一清标签。
# 【20% 怎么来】随机源 lib/rnd 取模 5, 命中 0 就是 1/5 = 20%(和幻昼铺白昼梦同一套)。
# 【★ 2026-10-04 修的 bug ★】旧写法每一步都带 `if entity @e[...,tag=zx.status.liuhuo]`,
#   而第一步就把流火摘了 -> 后面"附夜火"那几行条件不再成立 -> **流火直接变没、夜火没上**
#   (玩家反馈)。改成: 先把这一只钉进 zx.rm_c, 之后摘/加都只看这个标签。
# ============================================================

function sweetdream:lib/victim

# 掷一次骰子(无论如何都掷, 保持序列连续)
function sweetdream:lib/rnd
scoreboard players operation #rm_r zx.meta = #rnd zx.meta
scoreboard players operation #rm_r zx.meta %= #5 zx.meta

# 命中 0 且目标确实带「流火」-> 把这一只钉进 zx.rm_c(之后操作与流火是否还在无关)
tag @e[tag=zx.rm_c] remove zx.rm_c
execute if score #rm_r zx.meta matches 0 run tag @e[tag=zx.victim,tag=zx.status.liuhuo,limit=1] add zx.rm_c

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

tag @e[tag=zx.victim] remove zx.victim
