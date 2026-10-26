# ============================================================
# sweetdream:equipment/armor/ebb_tide/second —— 「返汐」每秒入口
# ------------------------------------------------------------
# 【谁调用它】lib/second(每秒一次)
# 【★ 文案(逐字)】"自身在海浪上移速将每秒增加 1%，最多增加 20%，生物在海浪上移速
#   将每秒减少 1%，最多减少 30%。离开海浪后增益或减益将极速衰减。"
# 【★ 为什么全部放在**每秒**这一个函数里 ★】
#   "在不在浪上"的戳(zx.et_on)和"加减档"必须在**同一个时间切片**里完成。
#   拆成"每刻打戳 + 每秒读戳"会出现时序问题: #now 每刻 +1, 若读戳的那一秒
#   打戳还没跑(取决于函数标签的执行先后), 戳就是上一刻的值 ⇒ 整片浪被判成
#   "不在浪上" ⇒ 一边加一边衰减, 档位永远上不去(静默)。
# 【★ 衰减量化 ★】"极速衰减" = 每秒回落 **10 个百分点**(设计稿 §七 边界),
#   不是立刻清零 —— 立刻清零会让"拉扯进出"完全没有手感。
# ============================================================

# ---------- ① 本体: 靴子自带移速 +10%（穿脱差值账本, 照 resonance/passive） ----------
execute as @a run function sweetdream:equipment/armor/ebb_tide/base_sync

# ---------- ② 生物侧: 在浪上 +1 档(封顶 30) ----------
execute in minecraft:overworld as @e[tag=zx.et_wave,distance=0..] at @s as @e[type=!#sweetdream:no_damage,distance=..1] at @s run function sweetdream:equipment/armor/ebb_tide/wave_on
execute in minecraft:the_nether as @e[tag=zx.et_wave,distance=0..] at @s as @e[type=!#sweetdream:no_damage,distance=..1] at @s run function sweetdream:equipment/armor/ebb_tide/wave_on
execute in minecraft:the_end as @e[tag=zx.et_wave,distance=0..] at @s as @e[type=!#sweetdream:no_damage,distance=..1] at @s run function sweetdream:equipment/armor/ebb_tide/wave_on

# ---------- ③ 生物侧: 有档位但这一秒不在浪上 ⇒ -10 档(封底 0) ----------
execute in minecraft:overworld as @e[distance=0..,scores={zx.et_e=1..}] unless score @s zx.et_on = #now manacore.meta run function sweetdream:equipment/armor/ebb_tide/decay_dn
execute in minecraft:the_nether as @e[distance=0..,scores={zx.et_e=1..}] unless score @s zx.et_on = #now manacore.meta run function sweetdream:equipment/armor/ebb_tide/decay_dn
execute in minecraft:the_end as @e[distance=0..,scores={zx.et_e=1..}] unless score @s zx.et_on = #now manacore.meta run function sweetdream:equipment/armor/ebb_tide/decay_dn

# ---------- ④ 玩家侧: 在浪上 +1 档(封顶 20), 不在 ⇒ -10 档 ----------
execute as @a at @s run function sweetdream:equipment/armor/ebb_tide/self_step
