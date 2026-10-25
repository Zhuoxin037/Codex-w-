# ============================================================
# sweetdream:equipment/armor/zhuzu/tick —— 驻足的每刻状态机
# ------------------------------------------------------------
# 【执行者】玩家（core/tick 每刻 `as @a` 调一次）
# 【第一行就判装备】不穿驻足的铁靴 ⇒ 两条命令就退出，日常不产生额外负载。
# 【三段】
#   ① 等待中（zx.zz_w=1）→ 倒数 zx.zz_t，到 0 交给 judge
#   ② 领域在场上（zx.zz_on=1）且刚动过（zx.st_n=0）→ close
#   ③ 其余什么都不做
# 【zx.st_n 由 lib/still 每 2 刻维护】30 = 1.5 秒静止
# ============================================================
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["zhuzu"]}] run return 0

# ① 等待
execute if score @s zx.zz_w matches 1 run scoreboard players remove @s zx.zz_t 1
execute if score @s zx.zz_w matches 1 if score @s zx.zz_t matches ..0 run function sweetdream:equipment/armor/zhuzu/judge

# ② 移动即收
execute if score @s zx.zz_on matches 1 if score @s zx.st_n matches 0 run function sweetdream:equipment/armor/zhuzu/close
