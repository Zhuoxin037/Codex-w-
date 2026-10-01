# ============================================================
# sweetdream:equipment/axe/charge/end —— 超载状态收尾
# ------------------------------------------------------------
# 【要收的只有状态】术阵是框架那边按 10 秒到期的, 不用我们管;
#   迅捷 II 也是"3 秒自灭"的写法, 不用手动清。
# ============================================================

scoreboard players set @s zx.chg_on 0
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.6 0.6 0.6 0.04 16 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.6 1.2
tellraw @s [{"text":"超载结束。","color":"gray","italic":true}]
