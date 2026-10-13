# ============================================================
# sweetdream:equipment/staff/five_curses/armor_cut —— 第四世: 护甲 / 韧性 -50%
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【为什么拆成"算"和"加"两个文件】`attribute ... modifier add <值>` 的那个**数值
#   必须写在命令行里**, 算出来的分数塞不进去 —— 只能先算好写进 storage, 再用
#   **宏函数**把 $(arm) / $(tou) 展开成字面量(全包同款做法, 见 armor/brain_leech)。
# 【为什么读 base 不读当前值】"降低 50%" 指的是**基础值**的五成; 读当前值会把
#   别的装备加成也算进去, 叠两次就越减越多。
# 【为什么要先 remove】modifier 的 id 是固定的, 同 id 二次 add 会失败(静默)。
#   第四世被刷新时(第五世不会, 但保险起见)先摘再加, 幂等。
# 【定点】attribute 的值是小数, 而计分板是 int ⇒ 全程按"百分之一点"算:
#   `base get 100` 拉成整数 → ÷2 得五成 → 0 - 它 取负 → double 0.01 写回。
# ============================================================

# ---- 护甲 ----
attribute @s minecraft:armor modifier remove sweetdream:fcv4_arm
execute store result score #fcv_a zx.meta run attribute @s minecraft:armor base get 100
scoreboard players operation #fcv_a zx.meta /= #2 zx.meta
scoreboard players set #fcv_na zx.meta 0
scoreboard players operation #fcv_na zx.meta -= #fcv_a zx.meta
execute store result storage zx:work fcv.arm double 0.01 run scoreboard players get #fcv_na zx.meta

# ---- 护甲韧性 ----
attribute @s minecraft:armor_toughness modifier remove sweetdream:fcv4_tou
execute store result score #fcv_tou zx.meta run attribute @s minecraft:armor_toughness base get 100
scoreboard players operation #fcv_tou zx.meta /= #2 zx.meta
scoreboard players set #fcv_nt zx.meta 0
scoreboard players operation #fcv_nt zx.meta -= #fcv_tou zx.meta
execute store result storage zx:work fcv.tou double 0.01 run scoreboard players get #fcv_nt zx.meta

# ---- 真正下 modifier(宏展开) ----
function sweetdream:equipment/staff/five_curses/armor_apply with storage zx:work fcv
