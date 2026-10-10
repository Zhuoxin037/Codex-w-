# ============================================================
# sweetdream:equipment/axe/charge/end —— 超载状态收尾
# ------------------------------------------------------------
# 【要收的东西】
#   · 术阵: 框架那边按 10/15 秒到期的, 不用我们管;
#   · 迅捷(基础 II / 超限 III): 是"3 秒自灭"的写法, 不用手动清;
#   · ★ 第二形态的**属性加成**(攻击力翻倍 / 最大魔力 +50%): 它是 `stats/add` 加在玩家存档
#     上的, **不会自己掉** ⇒ 超载真的结束时必须显式收回(见 ③ -> mode_off)。
#       (2026-10-10 用户报"超负荷的增益焊在我身上了, 即使我没有开启超载")
# ============================================================

# ① 超限: 先走"第二形态"判定(可能进形态 + 立刻自动使用, 那会把 chg_on 重新点起来)
#    ★ end_ol 自己会在"已是第二形态 / 冷却没好"时原地返回, 不做任何事。
execute if score @s zx.chg_ol matches 1 run function sweetdream:equipment/axe/charge/end_ol

# ② 已经被"自动使用"重新点起来了 -> 不播"结束"的提示, 加成也继续留着
execute if score @s zx.chg_on matches 1.. run return 0

# ③ 走到这里 = 超载**真的**结束了(没被重新点起) -> 收回第二形态的加成
#    ★ 只有"已在第二形态"(chg_mode=1)的人加过; 第一形态的人从头到尾没加过。
execute if score @s zx.chg_mode matches 1 run function sweetdream:equipment/axe/charge/mode_off

scoreboard players set @s zx.chg_on 0
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.6 0.6 0.6 0.04 16 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.6 1.2
tellraw @s [{"text":"超载结束。","color":"gray","italic":true}]
