execute if entity @s[tag=zx.s2_shield] if score @s zx.s2_abs_next <= #now manacore.meta run function fallendream:batch21/shield/tick
execute if score @s zx.job matches 1 if items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run function fallendream:equipment/armor/still_sky/tick
execute unless score @s zx.job matches 1 run scoreboard players set @s zx.s2_sky_full 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_full 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_end 0
#   超限三层制: 摘头盔把三个独立到期刻一起清(否则下次戴上就白捡一层)
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky1 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky2 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky3 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_ct 0
execute unless items entity @s armor.head *[custom_data~{zx:["still_sky"]}] run scoreboard players set @s zx.s2_sky_cw 0
execute if score @s zx.s2_stage matches 1.. unless score @s zx.s2_stage_end > #now manacore.meta run scoreboard players set @s zx.s2_stage 0
execute if score @s zx.s2_rail matches 1.. unless score @s zx.s2_rail_end > #now manacore.meta run scoreboard players set @s zx.s2_rail 0
execute if entity @s[tag=zx.s2_cw] run function fallendream:equipment/armor/cease_war/tick
execute unless score @s zx.j_reborn matches 1.. run scoreboard players set @s zx.s2_veil_rec 0
execute unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"]}] run scoreboard players set @s zx.s2_veil_rec 0
scoreboard players set @s zx.s2_sky_view 0
execute if score @s zx.s2_sky_end > #now manacore.meta run scoreboard players set @s zx.s2_sky_view 1
#   超限三层制: 观测镜读的是"还剩几层", 逐格累加
execute if score @s zx.s2_sky1 > #now manacore.meta run scoreboard players add @s zx.s2_sky_view 1
execute if score @s zx.s2_sky2 > #now manacore.meta run scoreboard players add @s zx.s2_sky_view 1
execute if score @s zx.s2_sky3 > #now manacore.meta run scoreboard players add @s zx.s2_sky_view 1
scoreboard players set @s zx.s2_cw_view 0
execute if entity @s[tag=zx.s2_cw] run scoreboard players set @s zx.s2_cw_view 1
# ---- 超限·复纱(2026-11-22): 12 秒内提前召唤的爆发 ----
# ★ 三个条件都带 matches 1.. 前置: 计分项"没分数"就是 0, 直接拿去比 #now 恒真。
# 4 秒回血窗口: 到点清账, 窗口内每 20 刻回一口
execute if score @s zx.rbv_rg_end matches 1.. unless score @s zx.rbv_rg_end > #now manacore.meta run scoreboard players set @s zx.rbv_rg_end 0
execute if score @s zx.rbv_rg_end matches 1.. if score @s zx.rbv_rg_next matches 1.. if score @s zx.rbv_rg_next <= #now manacore.meta run function fallendream:equipment/armor/rebirth_veil/regen_one
# +20% 最大魔力: 到点退还
execute if score @s zx.rbv_mm_end matches 1.. unless score @s zx.rbv_mm_end > #now manacore.meta run function fallendream:equipment/armor/rebirth_veil/mm_end
# 死亡刻只在同生职业身上有意义: 不是同生就清掉, 免得上限复纱拿到过期值
execute unless score @s zx.job matches 4 run scoreboard players set @s zx.rbv_die 0
# ---- 超限·归息(2026-11-22): 移速 +20% 的 8 秒到期 ----
# ★ matches 1.. 前置: "没分数"= 0 直接拿去比 #now 会恒真, 会每刻白跑一次 remove。
# ★ remove 失败会截断整个函数 ⇒ 只在账本说"挂着"时才撤, 撤完立刻清账。
execute if score @s zx.lb_spd_end matches 1.. unless score @s zx.lb_spd_end > #now manacore.meta run attribute @s minecraft:movement_speed modifier remove fallendream:lb_spd
execute if score @s zx.lb_spd_end matches 1.. unless score @s zx.lb_spd_end > #now manacore.meta run scoreboard players set @s zx.lb_spd_end 0

# ---- 超限·杂纹(2026-11-23): 凑够 3 种的兑现, 统一在本刻结算 ----
#   consume 只落 zx.mv_pend=1(理由见 mottle_vein/consume 文件头: 让"一次性消耗
#   5 种"这种情形能真的把种类数推到 5)。这里每刻扫一次, 延迟 ≤ 1 刻。
execute if score @s zx.mv_pend matches 1 run function fallendream:equipment/armor/mottle_vein/reward

# ---- 超限·烟履(2026-11-23): 迅捷窗口内累计移动 4 格 -> 攒一次额外触发 ----
#   只对"本件刚给过迅捷"的人扫(ss_spd_end 有值), 窗口外一概不进函数。
execute if score @s zx.ss_spd_end matches 1.. run function fallendream:equipment/armor/smoke_step/move_tick
