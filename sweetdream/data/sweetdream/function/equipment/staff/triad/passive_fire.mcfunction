# ============================================================
# sweetdream:equipment/staff/triad/passive_fire —— 热刀被动: 下次额外 2 次(+ 强化破甲)
# ------------------------------------------------------------
# 【文案】「很热的刀」每次攻击后都有 40% 的概率使下一次攻击额外发射 2 次;
#   强化中: 概率 100%, 且**每次攻击**都会使目标 -1 护甲值, 命中 3 次后使其
#   -1 护甲韧性, 技能结束后恢复。
# 【★ 状态位要写在**玩家**身上 ★】"下一次攻击"指的是玩家的下一次普攻, 而本函数
#   执行者是法球 ⇒ 必须用球上的 u0..u3 反查玩家再写 zx.tri_next(宏选择器)。
# 【★ 破甲为什么不用宏 ★】韧性那个 modifier 恒为 -1, 字面量可直接写;
#   护甲那个是 "-命中次数", 要随累计变化, 才走宏(armor_break)。
# 【★ 同 id 重复 add 会失败 ★】每次都先 remove 再 add, 保证幂等。
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #tri_r zx.meta = #rnd zx.meta
scoreboard players operation #tri_r zx.meta %= #100 zx.meta

# ---- 普通 40% / 强化 100%: 埋"下次额外 2 次" ----
execute if data storage zx:work tri{strong:0b} if score #tri_r zx.meta matches ..39 run function sweetdream:equipment/staff/triad/set_next_one with entity @s data
execute if data storage zx:work tri{strong:1b} run function sweetdream:equipment/staff/triad/set_next_one with entity @s data

# ---- 强化: 每次 -1 护甲, 3 次后再 -1 韧性 ----
execute if data storage zx:work tri{strong:1b} as @e[tag=zx.ball_hit] at @s run function sweetdream:equipment/staff/triad/armor_break

# 命中表现: 火星
execute as @e[tag=zx.ball_hit] at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.5 0.3 0.02 8 normal
