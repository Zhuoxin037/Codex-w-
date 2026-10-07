# ============================================================
# sweetdream:equipment/armor/lightless_sea/tide_tick —— 暗潮的每秒
# ------------------------------------------------------------
# 【谁调用它】lightless_sea/second(执行者 = 暗潮 marker 本体)
# 【文案】"暗潮"范围内的生物获得常态的缓慢Ⅱ; 8 秒后自毁。
# 【套装】若"暗潮"内有"朽木"存在, 则每秒使"暗潮"内的全部生物受到相当于
#   释放者最大魔力值 ×0.1 的伤害, 且附加「渊海」。
#   —— "暗潮内有没有朽木"只能在 marker 位置判; "释放者穿没穿套装"
#   要反查玩家 → tide_set(宏 u0..u3) → tide_go(玩家身份判穿着 + 结算)。
# ============================================================

# ① 到期 → **启动退场动画**(不是直接 kill): 摘判定标签, 换 shrink 轨道(缓入收拢 = 退潮),
#   dir 改 "out", 由 lib/anim_step 走完最后一帧收掉。气泡/水花在这里一次撒够。
execute if score @s zx.ls_end <= #now manacore.meta run tag @s remove zx.ls_tide
execute if score @s zx.ls_end <= #now manacore.meta run scoreboard players set @s zx.ls_anim 14
execute if score @s zx.ls_end <= #now manacore.meta run data modify entity @s data.zx.anim set value {field:"scale",track:"shrink",key:"zx.ls_anim",dir:"out"}
execute if score @s zx.ls_end <= #now manacore.meta run tag @s add zx.anim
execute if score @s zx.ls_end <= #now manacore.meta run particle minecraft:bubble_pop ~ ~0.2 ~ 3.4 0.15 3.4 0.03 30 normal
execute if score @s zx.ls_end <= #now manacore.meta run particle minecraft:current_down ~ ~0.6 ~ 3.0 0.3 3.0 0.02 20 normal
execute if score @s zx.ls_end <= #now manacore.meta run playsound minecraft:block.conduit.deactivate player @a ~ ~ ~ 0.7 1.4
execute if score @s zx.ls_end <= #now manacore.meta run return 0

# ② 常态缓慢Ⅱ: 4 格内全部生物(每秒续 2 秒 = 常态)
execute at @s run effect give @e[type=!#sweetdream:no_damage,distance=..4] minecraft:slowness 2 1 true

# ③ 表现(平图已负责大面积海面; 这里只留气泡上浮 + 暗流下沉两撮, 每秒各 6 个)
particle minecraft:bubble_pop ~ ~0.2 ~ 3.2 0.08 3.2 0.01 6 normal
particle minecraft:current_down ~ ~0.6 ~ 3.2 0.3 3.2 0.008 6 normal

# ④ 套装: 暗潮内(4 格)有朽木 → 圈好目标 + 反查释放者
tag @e[tag=zx.ls_area] remove zx.ls_area
execute if entity @e[tag=zx.gw_wood,distance=..4] run tag @e[type=!#sweetdream:no_damage,type=!minecraft:marker,type=!minecraft:block_display,type=!minecraft:item_display,type=!minecraft:text_display,distance=..4] add zx.ls_area
execute if entity @e[tag=zx.ls_area] run function sweetdream:equipment/armor/lightless_sea/tide_set with entity @s data.zx.ls
