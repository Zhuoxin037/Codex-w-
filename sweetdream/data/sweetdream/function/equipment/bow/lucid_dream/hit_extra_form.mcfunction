# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_form —— 漫彩续期时把术阵一起续
# ------------------------------------------------------------
# 【谁调它】hit_extra_dream ① 之前(执行者 = 被标记的那只生物)
# 【为什么要有它】big ⑦ 建的术阵时长 = X 秒(和标记同时结束)。而「白昼梦」会把
#   标记往后推 X 秒 —— 术阵不同步就会提前消失, "技能还在生效、术阵没了"。
#   术阵挂在**施法者**名下, 得用生物身上的 ld_u0..u3 反查回去才能刷新。
# 【失败不用管】术阵可能已经到期/被别的技能顶掉, 那时 refresh 找不到人都不做。
# ============================================================

# ① X = 该生物身上的 ld_x(触发漫彩时的梦回层数, 3..5)
scoreboard players set #ld_x zx.meta 0
execute store result score #ld_x zx.meta run scoreboard players get @s zx.ld_x
execute unless score #ld_x zx.meta matches 1.. run return 0

# ② 组一份 u0..u3, 反查施法者
data modify storage zx:work ldsu set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work ldsu.u0 int 1 run scoreboard players get @s zx.ld_u0
execute store result storage zx:work ldsu.u1 int 1 run scoreboard players get @s zx.ld_u1
execute store result storage zx:work ldsu.u2 int 1 run scoreboard players get @s zx.ld_u2
execute store result storage zx:work ldsu.u3 int 1 run scoreboard players get @s zx.ld_u3
function sweetdream:equipment/bow/lucid_dream/hit_extra_form_find with storage zx:work ldsu
