# ============================================================
# fallendream:equipment/sword/chengxing/next_amp —— 扫"当前最高的下一次技能增幅"
# ------------------------------------------------------------
# 【执行者】玩家本人   【出参】@s zx.cx_amp = 倍率千分（1000 = ×1.0，1300 = ×1.3）
# 【文案】"每攻击 4 次则下一次攻击可以被任意技能伤害倍率增幅（取最高），且不会消耗增幅。"
# ------------------------------------------------------------
# 【★ 为什么是"实时扫描"而不是"赋予时登记"★】
#   包里这些加成有的是计分项（zx.cy_mmn / zx.pf_mul / zx.gs3p）、有的是 tag
#   （zx.mv_ny）、有的是每刻算出来的状态（浮光 gl_mode）、有的是按坐标找的实体
#   （海棠强化漩涡）。它们的**消失**并不都经过同一个入口 —— 若在"赋予时登记"，
#   一旦某个来源被别的技能吃掉，登记值就成了幽灵，秤星会一直白吃一份不存在的加成。
#   扫描只在"第 5 次普攻真正打出去"这一刻跑（每 4 次攻击一次），不在热路径上。
# 【★ 为什么不动任何来源 ★】
#   "不会消耗增幅" ⇒ 这里只读、不摘 tag、不清计分项、不写加算池。所有来源原样保留，
#   真正的技能该吃的时候照吃。秤星自己只是"借"了最大值。
# 【来源清单（与 lib/skill_mul/pending 的只读扫描同一批）】
#   ① 残影     zx.cy_mmn ≥ 1              → +10%（mm 通道）
#   ② 桂冠     zx.dio_emp ≥ 1             → +30%（三通道）
#   ③ 杂纹     zx.mv_ny + 穿护腿           → +20%（三通道）
#   ④ 剖面     zx.pf_mul / zx.pf_mn ≥ 1    → +pf_mul%（oth 通道）
#   ⑤ 缑丝     zx.gs3p / zx.gs3n ≥ 1       → 独立 ×(1 + gs3p/100)
#   ⑥ 浮光     红 +20%（三通道）/ 白 ×1.3（独立乘区）
#   ⑦ 海棠     6 格内有自己强化过的漩涡     → +20%（mm 通道）
#   ⑧ 通用加成 zx.mm_add ≥ 1               → +mm_add%（mm 通道）
# 【★ 加算来源按"百分点"折成千分倍率：(1000 + pct×10)。独立来源本身就是千分。★】
# 【★ 取最高，不是相加 ★】文案写"取最高"。两条同时挂着时只借大的那一条。
# ============================================================

scoreboard players set @s zx.cx_amp 1000
scoreboard players set #10 zx.meta 10

# ① 残影：+10%
scoreboard players set #cx_c zx.meta 1000
execute if score @s zx.cy_mmn matches 1.. run scoreboard players set #cx_c zx.meta 1100
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ② 桂冠：+30%
scoreboard players set #cx_c zx.meta 1000
execute if score @s zx.dio_emp matches 1.. run scoreboard players set #cx_c zx.meta 1300
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ③ 杂纹：+20%（要穿着护腿 —— tag 可能因脱下而残留）
scoreboard players set #cx_c zx.meta 1000
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] if entity @s[tag=zx.mv_ny] run scoreboard players set #cx_c zx.meta 1200
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ④ 剖面：+pf_mul%
scoreboard players set #cx_c zx.meta 1000
scoreboard players set #cx_t zx.meta 0
execute if score @s zx.pf_mul matches 1.. if score @s zx.pf_mn matches 1.. run scoreboard players operation #cx_t zx.meta = @s zx.pf_mul
scoreboard players operation #cx_t zx.meta *= #10 zx.meta
scoreboard players operation #cx_c zx.meta += #cx_t zx.meta
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ⑤ 缑丝：独立 ×(1 + gs3p/100)
scoreboard players set #cx_c zx.meta 1000
scoreboard players set #cx_t zx.meta 0
execute if score @s zx.gs3p matches 1.. if score @s zx.gs3n matches 1.. run scoreboard players operation #cx_t zx.meta = @s zx.gs3p
scoreboard players operation #cx_t zx.meta *= #10 zx.meta
scoreboard players operation #cx_c zx.meta += #cx_t zx.meta
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ⑥ 浮光：红 +20% / 白 ×1.3（gl_mode 由 glimmer/state 只读算出）
function fallendream:equipment/armor/glimmer/state
scoreboard players set #cx_c zx.meta 1000
execute if score #gl_mode zx.meta matches 1 run scoreboard players set #cx_c zx.meta 1200
execute if score #gl_mode zx.meta matches 2 run scoreboard players set #cx_c zx.meta 1300
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

# ⑦ 海棠：6 格内有自己强化过的漩涡 → +20%（需要 UUID，走宏叶子）
scoreboard players set #cx_bg zx.meta 0
data modify storage zx:work cxn set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work cxn.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work cxn.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work cxn.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work cxn.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:equipment/sword/chengxing/next_amp_bg with storage zx:work cxn
execute if score #cx_bg zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_bg zx.meta

# ⑧ 通用「最大魔力值技能倍率」加成（风声 / 忘川彼岸 / 无效都在这里）
scoreboard players set #cx_c zx.meta 1000
scoreboard players set #cx_t zx.meta 0
execute if score @s zx.mm_add matches 1.. run scoreboard players operation #cx_t zx.meta = @s zx.mm_add
scoreboard players operation #cx_t zx.meta *= #10 zx.meta
scoreboard players operation #cx_c zx.meta += #cx_t zx.meta
execute if score #cx_c zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_c zx.meta

data modify storage zx:work cx_panel_frames append value {pl:{},add:{}}
data modify storage zx:work cx_panel_frames[-1].pl set from storage zx:work pl
data modify storage zx:work cx_panel_frames[-1].add set from storage zx:work add
data modify storage zx:work pl.independent_multiplier set value 1.0
function fallendream:lib/skill_mul/scan
scoreboard players set #cx_read zx.meta 1000
execute store result score #cx_read zx.meta run data get storage zx:work pl.smul_mm 1000
execute if score #cx_read zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_read zx.meta
execute store result score #cx_read zx.meta run data get storage zx:work pl.smul_atk 1000
execute if score #cx_read zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_read zx.meta
execute store result score #cx_read zx.meta run data get storage zx:work pl.smul_oth 1000
execute if score #cx_read zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_read zx.meta
execute store result score #cx_read zx.meta run data get storage zx:work pl.independent_multiplier 1000
execute if score #cx_read zx.meta > @s zx.cx_amp run scoreboard players operation @s zx.cx_amp = #cx_read zx.meta
data modify storage zx:work pl set from storage zx:work cx_panel_frames[-1].pl
data modify storage zx:work add set from storage zx:work cx_panel_frames[-1].add
data remove storage zx:work cx_panel_frames[-1]
