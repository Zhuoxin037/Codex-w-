# ============================================================
# sweetdream:equipment/armor/ebb_tide/wave_tick —— 海浪每刻（由 core/tick 驱动）
# ------------------------------------------------------------
# 【执行者】那片浪(@s)   【位置】at @s
# 【★ 只做两件事 ★】① 寿命; ② 给 2.5 格内的**生物**打"本秒在浪上"的戳。
#   ★ 档位的加减与衰减统一放在 ebb_tide/second(每秒一次), 这里**不碰档位** ——
#     否则同一秒里 6 片浪各自加一次, 一只站在两片浪上的生物会一秒涨 2 档。
# 【★ 打戳用计分项而不是 tag ★】照共鸣 pass_set 的 2026-10-20 卡顿修复:
#   每刻给同一只生物 add/remove tag ⇒ chunk 每刻标脏 ⇒ 存盘整份重写。
# ============================================================

# ① 寿命
scoreboard players remove @s zx.et_life 1
execute if score @s zx.et_life matches ..0 run return run function sweetdream:equipment/armor/ebb_tide/wave_end

# ② 表现(每 10 刻一次)
scoreboard players remove @s zx.et_fx 1
execute if score @s zx.et_fx matches ..0 run particle minecraft:splash ~ ~0.1 ~ 1.2 0.05 1.2 0.06 10
execute if score @s zx.et_fx matches ..0 run scoreboard players set @s zx.et_fx 10

# ③ 给 2.5 格内的生物打"这一秒在浪上"的戳
#    ★ 用**分数存 #now**而不是 tag: 下面 second 里的衰减只看"戳是不是这一秒的"。
execute as @e[type=!#sweetdream:no_damage,distance=..2.5] run scoreboard players operation @s zx.et_on = #now manacore.meta
