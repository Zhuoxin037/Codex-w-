# ============================================================
# sweetdream:equipment/armor/dusk_dawn/second —— 每秒入口
# ------------------------------------------------------------
# 【★ 必须 at @s ★】只写 execute as 位置还是服务器的, 里面所有相对判定都会错。
# 【备份公共输入口】下面到处在写 manacore:in arg, 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 被动 + 套装(上限 +180 / +200)
execute as @a run function sweetdream:equipment/armor/dusk_dawn/passive

# ② 魔力低于一半 -> 每秒回 20
execute as @a at @s run function sweetdream:equipment/armor/dusk_dawn/low_mana

# ③ 击杀后的临时上限倒计时(8 秒)
execute as @a[scores={zx.dd_temp=1..}] at @s run function sweetdream:equipment/armor/dusk_dawn/temp_tick

# ④ 套装: 每 3 秒恢复 1% 魔力(用全局秒号 % 3 判定, 所有人同拍, 省一套计分项)
scoreboard players operation #m3 zx.meta = #sec manacore.meta
scoreboard players operation #m3 zx.meta %= #3 zx.meta
execute if score #m3 zx.meta matches 0 as @a[tag=zx.dd_set_on] at @s run function sweetdream:equipment/armor/dusk_dawn/set_regen

function sweetdream:lib/in_restore
