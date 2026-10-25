# ============================================================
# sweetdream:internal/damage/stg_per —— 「升痕」每层加成百分之几（5 = 原版 / 10 = 超限）
# ------------------------------------------------------------
# 【谁调用它】internal/damage/stg_mul 的 ④(以**攻击者**身份执行: `execute as <UUID 反查> run …`)
# 【执行者】攻击者(玩家)
# 【出参】#stg_per zx.meta = 5 或 10
# 【为什么要单独一个函数】stg_mul 里是"用 UUID 的四个整数反查玩家"的宏行, 而
#   `if items entity` 的教训是**别拿非 @s 的选择器去喂它**(包里没有先例, 见坑 151)。
#   所以照全包统一写法: 先用 `execute as <选择器>` 把人切出来, 剩下的判据一律对 @s 写。
# 【★ 判据必须是"攻击者手里那把" ★】「升痕」的加伤是这把武器的被动: 别人拿普通天穹
#   或别的武器来打, 仍然是每层 5%。
# ============================================================

scoreboard players set #stg_per zx.meta 5
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["skyvault"],ol:"skyvault"}] run scoreboard players set #stg_per zx.meta 10
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["skyvault"],ol:"skyvault"}] run scoreboard players set #stg_per zx.meta 10
