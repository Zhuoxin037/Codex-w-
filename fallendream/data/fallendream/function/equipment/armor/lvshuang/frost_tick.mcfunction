# ============================================================
# fallendream:equipment/armor/lvshuang/frost_tick —— 霜场每秒判定（执行者 = marker）
# ------------------------------------------------------------
# 【谁调】lib/second 每秒一次（三维度各一行）
# 【技能原文(lore 逐字)】
#   基础: "生物踩到霜时获得 2 秒缓慢Ⅱ；自身踩到霜时获得 2 秒迅捷Ⅰ，且不消耗该片霜。"
#   超限: "生物踩到霜时获得 5 秒缓慢Ⅱ并且会被冰冻 1 秒；自身踩到霜时获得 8 秒迅捷二，
#          且不消耗该片霜。…每增加一层则生物踩到霜后冷冻的时间 +1 秒。"
# 【★ 档位只加"冷冻时间"，不加缓慢时长 ★】原文只说"冷冻的时间 +1 秒"。
# 【★ 为什么冷冻要节流（见 ol_freeze）★】站在霜上会被每秒刷新一次冷冻，那就是
#   永久冻死（走不动 ⇒ 离不开霜 ⇒ 走不动…）。所以按"踩到"处理：同一只生物被冻过
#   之后要等"这次冻结时长 + 20 刻"才会再冻一次 —— 中间能走动、能离开。
# 【不消耗霜】踩上去只给效果，霜不消失（两档都一样）。
# ============================================================

# ① 敌人：缓慢（基础 2 秒 / 超限 5 秒）
execute unless score @s zx.lsh_ol matches 1 run effect give @e[type=!#fallendream:no_damage,distance=..1.2] minecraft:slowness 2 1 true
execute if score @s zx.lsh_ol matches 1 run effect give @e[type=!#fallendream:no_damage,distance=..1.2] minecraft:slowness 5 1 true

# ①.5 超限·冰冻（1 秒 + 每档 1 秒）
execute if score @s zx.lsh_ol matches 1 run function fallendream:equipment/armor/lvshuang/ol_freeze

# ② 自己：迅捷（基础 2 秒Ⅰ / 超限 8 秒Ⅱ）
execute unless score @s zx.lsh_ol matches 1 run effect give @a[gamemode=!spectator,distance=..1.2] minecraft:speed 2 0 true
execute if score @s zx.lsh_ol matches 1 run effect give @a[gamemode=!spectator,distance=..1.2] minecraft:speed 8 1 true

particle minecraft:snowflake ~ ~0.05 ~ 0.35 0.02 0.35 0.005 5 normal
particle minecraft:dust{color:[0.78,0.88,0.95],scale:0.8} ~ ~0.05 ~ 0.3 0.02 0.3 0.003 4 normal

# ③ 寿命（基础 5 秒 / 超限 16 秒，出生时写在 zx.lsh_ft 上，这里每秒 -1）
scoreboard players remove @s zx.lsh_ft 1
execute if score @s zx.lsh_ft matches ..0 run function fallendream:equipment/armor/lvshuang/frost_end
