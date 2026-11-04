# ============================================================
# sweetdream:equipment/staff/lucid_illusion/second —— 清醒与幻觉：每秒结算
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a at @s run ...
# 【做四件事】
#   ① 重算"还活着的额外法球数" zx.li_x（到期刻 ≤ now 的算作已消失）
#   ② 门：既不拿这把法杖、又没有额外法球、也没有待结算 → 跳过（@a 广播）
#   ③ 每个额外法球每秒自伤：最大生命 ×0.08 × X（X = 额外法球数）
#   ④ 主动技能 4 秒后的一次性结算
# 【★ ①② 顺序 ★】li_x 必须先算，门才有可能放行"已经换手、但身上还挂着额外法球"的人。
# ============================================================

scoreboard players set @s zx.li_x 0
execute if score @s zx.li_e1 > #now manacore.meta run scoreboard players add @s zx.li_x 1
execute if score @s zx.li_e2 > #now manacore.meta run scoreboard players add @s zx.li_x 1
execute if score @s zx.li_e3 > #now manacore.meta run scoreboard players add @s zx.li_x 1

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["lucid_illusion"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["lucid_illusion"]}] unless score @s zx.li_x matches 1.. unless score @s zx.li_on matches 1 run return 0

execute if score @s zx.li_x matches 1.. run function sweetdream:equipment/staff/lucid_illusion/drain

execute if score @s zx.li_on matches 1 if score @s zx.li_pend <= #now manacore.meta run function sweetdream:equipment/staff/lucid_illusion/settle
