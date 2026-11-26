# ============================================================
# fallendream:equipment/armor/still_sky/tick —— 「星帷」充能(每刻)
# ------------------------------------------------------------
# 【执行者】玩家(batch21/player_tick, 已判 job 1 + 戴着静穹)
# 【基础】普通法球满额 6 秒(120 刻) → 一层, 至多 1 层, 保留 12 秒
# 【超限】满额 4 秒(80 刻) → 一层, 至多 3 层, 每层独立保留 16 秒
# 【★ 层数是"三个独立到期刻"而不是一个计数 ★】文案写"每层独立保留 16 秒",
#   用一个计数器就必然出现"第二层刷新了第一层的时长"。
# ============================================================
scoreboard players set #s2_full zx.meta 3
execute if score @s zx.j_aw matches 1 run scoreboard players set #s2_full zx.meta 5
execute unless score @s zx.j_orb = #s2_full zx.meta run scoreboard players set @s zx.s2_sky_full 0
execute unless score @s zx.j_orb = #s2_full zx.meta run return 0
scoreboard players add @s zx.s2_sky_full 1

# 门限: 基础 120 刻 / 超限 80 刻
scoreboard players set #s2_gate zx.meta 120
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["still_sky"],ol:"still_sky"}] run scoreboard players set #s2_gate zx.meta 80
execute if score @s zx.s2_sky_full >= #s2_gate zx.meta run function fallendream:equipment/armor/still_sky/ready
