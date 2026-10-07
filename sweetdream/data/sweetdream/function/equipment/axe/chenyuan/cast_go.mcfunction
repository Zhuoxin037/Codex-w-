# ============================================================
# sweetdream:equipment/axe/chenyuan/cast_go —— 沉渊主动的落点
# ------------------------------------------------------------
# 【执行者】施法者本人   【无宏参数】
# 【目标】zx.cy_a(随机一只) / zx.cy_b(渊海那一只) / zx.cy_x(有增益时的额外 3 只)
# 【★ 2026-10-07 起不再是宏函数 ★】原来"有没有最大魔力值技能增益"要按 uuid 拼
#   zx:data wg_bonus 的路径, 所以这份必须写成宏、由 cast 传 uuid。现在那份加成
#   改存在玩家自己的计分项 zx.mm_add 上(风声 / 忘川彼岸 / 无效 共用), 直接判 @s
#   就行 —— 本文件一条 `$` 都没有了。
# ============================================================

# ① 判"自身有没有给自身最大魔力值相关技能的增益"(= 风声 / 忘川彼岸 / 无效)
scoreboard players set #cy_mode zx.meta 0
execute if score @s zx.mm_add matches 1.. run scoreboard players set #cy_mode zx.meta 1

# ② 有增益 -> 额外锁定 3 个
execute if score #cy_mode zx.meta matches 1 run function sweetdream:equipment/axe/chenyuan/extra

# ③ 把所有目标并成 zx.cy_hit(一个标签走到底, 免得后面求值选到别人)
tag @e[tag=zx.cy_hit] remove zx.cy_hit
tag @e[tag=zx.cy_a] add zx.cy_hit
tag @e[tag=zx.cy_b] add zx.cy_hit
tag @e[tag=zx.cy_x] add zx.cy_hit

# ④ 3 秒缓慢Ⅳ(amplifier 3)
execute if entity @e[tag=zx.cy_hit] run effect give @e[tag=zx.cy_hit] minecraft:slowness 3 3 true

# ⑤ 伤害: 没增益走"当前魔力"通道, 有增益走"最大魔力"通道
execute if score #cy_mode zx.meta matches 0 run function sweetdream:equipment/axe/chenyuan/dmg_normal
execute if score #cy_mode zx.meta matches 1 run function sweetdream:equipment/axe/chenyuan/dmg_buff

# ⑥ 表现 + 收尾
execute at @e[tag=zx.cy_hit] run particle minecraft:splash ~ ~1 ~ 0.5 0.5 0.5 0.05 18 normal
execute at @e[tag=zx.cy_hit] run particle minecraft:bubble ~ ~1 ~ 0.4 0.4 0.4 0.03 12 normal
execute at @s run playsound minecraft:entity.player.hurt_drown player @a ~ ~ ~ 0.6 0.7
execute at @s run playsound minecraft:block.conduit.attack.target player @a ~ ~ ~ 0.7 1.1

tag @e[tag=zx.cy_hit] remove zx.cy_hit
tag @e[tag=zx.cy_a] remove zx.cy_a
tag @e[tag=zx.cy_b] remove zx.cy_b
tag @e[tag=zx.cy_x] remove zx.cy_x
