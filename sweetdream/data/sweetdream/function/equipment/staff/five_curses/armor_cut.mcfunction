# ============================================================
# sweetdream:equipment/staff/five_curses/armor_cut —— 第四世: 护甲 / 韧性 降低 N%
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【入参】#fcv_apct zx.meta = 降低的**百分比**(50 = 原版; 超限 80; 超限·主动 100 = 清零)
#   —— 由 ol_tier 按档灌好, curse_step 在调本函数之前已跑过 ol_tier。
# 【为什么拆成"算"和"加"两个文件】`attribute ... modifier add <值>` 的那个**数值
#   必须写在命令行里**, 算出来的分数塞不进去 —— 只能先算好写进 storage, 再用
#   **宏函数**把 $(arm) / $(tou) 展开成字面量(全包同款做法, 见 armor/brain_leech)。
# 【为什么读 base 不读当前值】"降低 50%" 指的是**基础值**的五成; 读当前值会把
#   别的装备加成也算进去, 叠两次就越减越多。
# 【为什么要先 remove】modifier 的 id 是固定的, 同 id 二次 add 会失败(静默)。
#   第四世被刷新时(第五世不会, 但保险起见)先摘再加, 幂等。
# 【定点】attribute 的值是小数, 而计分板是 int ⇒ 全程按"百分之一点"算:
#   `base get 100` 拉成整数 → ×百分比 ÷100 → 0 - 它 取负 → double 0.01 写回。
#   ★ 原版是"÷2"(固定五成); 2026-10-23 批 K9 改成 ×#fcv_apct ÷100, 原版值 50 时结果
#     与 ÷2 逐字相同(50/100 = 1/2), 所以没超限时行为完全不变。
# ============================================================

# ⓪ 百分比没设(不该发生)就按原版 50
scoreboard players add #fcv_apct zx.meta 0
execute if score #fcv_apct zx.meta matches ..0 run scoreboard players set #fcv_apct zx.meta 50

# ---- 护甲 ----
attribute @s minecraft:armor modifier remove sweetdream:fcv4_arm
execute store result score #fcv_a zx.meta run attribute @s minecraft:armor base get 100
scoreboard players operation #fcv_a zx.meta *= #fcv_apct zx.meta
scoreboard players operation #fcv_a zx.meta /= #100 zx.meta
scoreboard players set #fcv_na zx.meta 0
scoreboard players operation #fcv_na zx.meta -= #fcv_a zx.meta
execute store result storage zx:work fcv.arm double 0.01 run scoreboard players get #fcv_na zx.meta

# ---- 护甲韧性 ----
attribute @s minecraft:armor_toughness modifier remove sweetdream:fcv4_tou
execute store result score #fcv_tou zx.meta run attribute @s minecraft:armor_toughness base get 100
scoreboard players operation #fcv_tou zx.meta *= #fcv_apct zx.meta
scoreboard players operation #fcv_tou zx.meta /= #100 zx.meta
scoreboard players set #fcv_nt zx.meta 0
scoreboard players operation #fcv_nt zx.meta -= #fcv_tou zx.meta
execute store result storage zx:work fcv.tou double 0.01 run scoreboard players get #fcv_nt zx.meta

# ---- 真正下 modifier(宏展开) ----
function sweetdream:equipment/staff/five_curses/armor_apply with storage zx:work fcv

# ---- 起"第四世自己的"倒计时(时长按档: 原版 5 / 超限 8 秒) ----
#   ★ 2026-10-13 用户拍板: 文案写"护甲及护甲韧性降低 50%, **持续 5 秒**",
#     而各层共用的 zx.fcv_t 会被"每次命中"刷回 5 ⇒ 玩家续攻时破甲会一直挂着。
#     ⇒ 破甲挂独立的 zx.fcv_t4(单位秒), tick_one 每秒 -1, 归零由 armor_uncut 摘掉。
#   ★ zx.fcv_4 这个标签同时是"当前正挂着破甲"的门控 —— 没挂的目标不进倒计时。
tag @s add zx.fcv_4
scoreboard players operation @s zx.fcv_t4 = #fcv_t4 zx.meta
