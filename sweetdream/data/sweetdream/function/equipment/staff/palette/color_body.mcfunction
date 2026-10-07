# ============================================================
# sweetdream:equipment/staff/palette/color_body —— “色彩”的每刻逻辑(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work pc {id, rng}   【执行者】色彩 marker   【位置】色彩 marker 处
#   id  = 这个色彩的唯一编号(标记"已打过"的生物)
#   rng = 追踪 / 存活半径(= 12 + 8×黄数)
# 【文案】“色彩”会离自身 12 格远或对 5 个生物造成伤害后自毁。
#   “色彩”会自动追踪离自身最近的生物并对其造成伤害。“色彩”不会追踪已经攻击过的生物。
# 【★ “离自身”= 离释放者(以距离对称来量)★】距离是对称的: 从色彩处量
#   "释放者在 rng 内" 等价于 "色彩在释放者 rng 内" —— 所以不必把坐标搬去释放者,
#   直接用 @a[tag=zx.mc_by,distance=..rng] 判(见 color_tick 已反查好 zx.mc_by)。
# 【"已经攻击过的生物"= 它身上 zx.pal_hit 计分项 == 本色彩 id】
#   每打过一只就把那只的 zx.pal_hit 记成 id(见 color_hit), 于是同一色彩不会再追同一只。
# 【为什么用计分项而不是标签】标签没法按色彩区分(动态名字做不出来); 计分项的值可以动态写。
# ============================================================

# ① 安全寿命
scoreboard players remove @s zx.pal_life 1
execute if score @s zx.pal_life matches ..0 run return run function sweetdream:equipment/staff/palette/color_end

# ② 离释放者超出 rng -> 自毁
$execute unless entity @a[tag=zx.mc_by,distance=0..$(rng),limit=1] run return run function sweetdream:equipment/staff/palette/color_end

# ③ 挑目标: rng 内、没被本色彩打过、离自己最近的一只
tag @e[tag=zx.pal_c,distance=0..] remove zx.pal_c
tag @e[tag=zx.pal_t,distance=0..] remove zx.pal_t
$tag @e[type=!#sweetdream:no_damage,distance=..$(rng)] add zx.pal_c
$execute as @e[tag=zx.pal_c] if score @s zx.pal_hit = $(id) run tag @s remove zx.pal_c
tag @e[tag=zx.pal_c,distance=0..,sort=nearest,limit=1] add zx.pal_t
tag @e[tag=zx.pal_c,distance=0..] remove zx.pal_c

# ④ 朝目标飞(每刻 0.5 格); 进 1.5 格就结算
execute at @s if entity @e[tag=zx.pal_t,distance=0..,limit=1] facing entity @e[tag=zx.pal_t,distance=0..,limit=1] feet run tp @s ^ ^ ^0.5
execute at @s if entity @e[tag=zx.pal_t,distance=..1.5,limit=1] run function sweetdream:equipment/staff/palette/color_hit

# ⑤ 表现(按外观色码上色)
execute if data entity @s data.zx.pal{c:1} run particle minecraft:dust{color:[1.0,0.25,0.25],scale:1.1} ~ ~ ~ 0.15 0.15 0.15 0.0 3 normal
execute if data entity @s data.zx.pal{c:2} run particle minecraft:dust{color:[1.0,0.95,0.3],scale:1.1} ~ ~ ~ 0.15 0.15 0.15 0.0 3 normal
execute if data entity @s data.zx.pal{c:3} run particle minecraft:dust{color:[0.35,0.6,1.0],scale:1.1} ~ ~ ~ 0.15 0.15 0.15 0.0 3 normal
execute if data entity @s data.zx.pal{c:0} run particle minecraft:dust{color:[0.85,0.85,0.9],scale:1.1} ~ ~ ~ 0.15 0.15 0.15 0.0 3 normal

# ⑥ 收尾: 摘掉挑选标记
tag @e[tag=zx.pal_t,distance=0..] remove zx.pal_t
