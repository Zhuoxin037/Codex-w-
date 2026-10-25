# ============================================================
# sweetdream:equipment/armor/tide_fold/wall_end —— 水墙到寿 / 重载清场
# ------------------------------------------------------------
# 【执行者】墙 marker(@s)
# 【★ 分数为什么要 reset ★】这些分数打在实体身上, 实体被 kill **分数不会自己消失**
#   （scoreboard 会一直保留到被 reset）。墙是临时的、数量又少, 但 core/load 里
#    `kill @e[tag=zx.tf_wall]` 走的也是这里 ⇒ 重载后不留一地分数(铁律: 制造者收尸)。
# ============================================================

scoreboard players reset @s zx.tf_life
scoreboard players reset @s zx.tf_fx
scoreboard players reset @s zx.tf_id
scoreboard players reset @s zx.tf_u0
scoreboard players reset @s zx.tf_u1
scoreboard players reset @s zx.tf_u2
scoreboard players reset @s zx.tf_u3
kill @s
