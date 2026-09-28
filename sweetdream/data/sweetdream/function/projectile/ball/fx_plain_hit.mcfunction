# ============================================================
# sweetdream:projectile/ball/fx_plain_hit —— 没有指定 style 时的命中表现
# ------------------------------------------------------------
# 【为什么要有它】新写一把法杖、忘了写 style 的时候, 至少还有一个
#   "看起来打得中"的朴素表现, 而不是安安静静什么都不出。
# ============================================================

particle minecraft:poof ~ ~ ~ 0.3 0.3 0.3 0.02 8 normal
particle minecraft:crit ~ ~ ~ 0.3 0.3 0.3 0.05 6 normal
playsound minecraft:entity.player.attack.strong player @a ~ ~ ~ 0.6 1.4
