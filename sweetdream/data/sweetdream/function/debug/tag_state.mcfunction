# ============================================================
# sweetdream:debug/tag_state —— 通用标签「现场诊断」(只读)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/tag_state   (先站到那只生物旁边)
# 【诊断什么】"标签 / 头顶图标很快就没了"这类问题, 光看画面分不清是
#   ① 状态标签 zx.status.* 真被摘了, 还是 ② 只有图标那一侧出问题(标签其实还在)。
#   本函数把两边一次性打出来 —— 现象一出现就立刻跑一次, 就是一份现场快照。
# 【选谁】① 16 格内最近的 zx.tagged 生物(正常应先命中它);
#         ② 没命中就退成 16 格内最近的非显示实体(标签刚掉的那一刻用它)。
# 【怎么读】
#   · "不在 zx.tagged 里 ✘"  -> 图标不再跟随; 而且 ttl_tick / icon_refresh
#     只遍历 zx.tagged, 所以这时倒计时也停了(标签会赖着不走, 不是变短)。
#   · "标签✔ 但剩余 0"        -> 那条 zx.tt.* 分数没了(旧存档兜底没跑到),
#     下一轮 ttl_tick 会补上; 补不上就是 core/load 没建那条计分项。
#   · "最近图标 mask=N"       -> 位 0..4 在不在 / 位 5..9 剩余<=3 秒(32/64/…/512);
#     icon_ttl 由 follow_dimension 每 2 tick 续到 40, 看到 0 就是续租断了。
# 【只读】只临时打标签 zx.ts_t 和写 zx.meta 上的 #ts_* 假玩家, 不动任何游戏状态。
# ============================================================
tellraw @s [{"text":"===== 通用标签诊断 =====","color":"gold"}]

# ---- ① 钉死目标: 下面每一步都用同一个 zx.ts_t, 免得 sort=nearest 每句换人 ----
tag @e[tag=zx.ts_t] remove zx.ts_t
execute if entity @e[type=!#sweetdream:no_damage,tag=zx.tagged,distance=..16] run tag @e[type=!#sweetdream:no_damage,tag=zx.tagged,distance=..16,sort=nearest,limit=1] add zx.ts_t
execute unless entity @e[tag=zx.ts_t] run tag @e[type=!#sweetdream:no_damage,distance=..16,sort=nearest,limit=1] add zx.ts_t
execute unless entity @e[tag=zx.ts_t] run tellraw @s [{"text":"  16 格内没有可看的非显示实体 —— 走近那只生物再试","color":"red"}]
execute unless entity @e[tag=zx.ts_t] run return 0

# ---- ② 它还在不在 zx.tagged(这一步决定"图标跟不跟、倒计时还跑不跑") ----
execute if entity @e[tag=zx.ts_t,tag=zx.tagged] run tellraw @s [{"text":"  在 zx.tagged 里 ✔  (图标在跟随, 每秒倒计时正常)","color":"green"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.tagged] run tellraw @s [{"text":"  不在 zx.tagged 里 ✘  (图标不再跟随; 倒计时也停了)","color":"red"}]

# ---- ③ 五个状态标签 + 剩余秒数(没分数时会显示 0, 配合上一行看) ----
scoreboard players set #ts_y zx.meta 0
scoreboard players set #ts_l zx.meta 0
scoreboard players set #ts_h zx.meta 0
scoreboard players set #ts_s zx.meta 0
scoreboard players set #ts_d zx.meta 0
execute if score @e[tag=zx.ts_t,limit=1] zx.tt.yuanhai matches -2147483648.. run scoreboard players operation #ts_y zx.meta = @e[tag=zx.ts_t,limit=1] zx.tt.yuanhai
execute if score @e[tag=zx.ts_t,limit=1] zx.tt.liuhuo matches -2147483648.. run scoreboard players operation #ts_l zx.meta = @e[tag=zx.ts_t,limit=1] zx.tt.liuhuo
execute if score @e[tag=zx.ts_t,limit=1] zx.tt.yehuo matches -2147483648.. run scoreboard players operation #ts_h zx.meta = @e[tag=zx.ts_t,limit=1] zx.tt.yehuo
execute if score @e[tag=zx.ts_t,limit=1] zx.tt.shixin matches -2147483648.. run scoreboard players operation #ts_s zx.meta = @e[tag=zx.ts_t,limit=1] zx.tt.shixin
execute if score @e[tag=zx.ts_t,limit=1] zx.tt.dream matches -2147483648.. run scoreboard players operation #ts_d zx.meta = @e[tag=zx.ts_t,limit=1] zx.tt.dream
execute if entity @e[tag=zx.ts_t,tag=zx.status.yuanhai] run tellraw @s [{"text":"  渊海    标签✔  剩余 ","color":"green"},{"score":{"name":"#ts_y","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"aqua"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.status.yuanhai] run tellraw @s [{"text":"  渊海    标签✘  剩余 ","color":"dark_gray"},{"score":{"name":"#ts_y","objective":"zx.meta"},"color":"dark_gray"},{"text":" 秒","color":"dark_gray"}]
execute if entity @e[tag=zx.ts_t,tag=zx.status.liuhuo] run tellraw @s [{"text":"  流火    标签✔  剩余 ","color":"green"},{"score":{"name":"#ts_l","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"aqua"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.status.liuhuo] run tellraw @s [{"text":"  流火    标签✘  剩余 ","color":"dark_gray"},{"score":{"name":"#ts_l","objective":"zx.meta"},"color":"dark_gray"},{"text":" 秒","color":"dark_gray"}]
execute if entity @e[tag=zx.ts_t,tag=zx.status.yehuo] run tellraw @s [{"text":"  夜火    标签✔  剩余 ","color":"green"},{"score":{"name":"#ts_h","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"aqua"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.status.yehuo] run tellraw @s [{"text":"  夜火    标签✘  剩余 ","color":"dark_gray"},{"score":{"name":"#ts_h","objective":"zx.meta"},"color":"dark_gray"},{"text":" 秒","color":"dark_gray"}]
execute if entity @e[tag=zx.ts_t,tag=zx.status.shixin] run tellraw @s [{"text":"  噬心    标签✔  剩余 ","color":"green"},{"score":{"name":"#ts_s","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"aqua"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.status.shixin] run tellraw @s [{"text":"  噬心    标签✘  剩余 ","color":"dark_gray"},{"score":{"name":"#ts_s","objective":"zx.meta"},"color":"dark_gray"},{"text":" 秒","color":"dark_gray"}]
execute if entity @e[tag=zx.ts_t,tag=zx.status.dream] run tellraw @s [{"text":"  白昼梦  标签✔  剩余 ","color":"green"},{"score":{"name":"#ts_d","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"aqua"}]
execute unless entity @e[tag=zx.ts_t,tag=zx.status.dream] run tellraw @s [{"text":"  白昼梦  标签✘  剩余 ","color":"dark_gray"},{"score":{"name":"#ts_d","objective":"zx.meta"},"color":"dark_gray"},{"text":" 秒","color":"dark_gray"}]

# ---- ④ 图标侧: 它附近有几个图标 / 最近那个的掩码与租约 ----
scoreboard players set #ts_n zx.meta 0
scoreboard players set #ts_m zx.meta -1
scoreboard players set #ts_t zx.meta -1
execute store result score #ts_n zx.meta run execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4]
execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4] store result score #ts_m zx.meta run scoreboard players get @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] zx.icon_mask
execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4] store result score #ts_t zx.meta run scoreboard players get @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] zx.icon_ttl
tellraw @s [{"text":"  附近图标数 ","color":"gray"},{"score":{"name":"#ts_n","objective":"zx.meta"},"color":"yellow"},{"text":"   最近图标 mask=","color":"gray"},{"score":{"name":"#ts_m","objective":"zx.meta"},"color":"light_purple"},{"text":"(=-1 表示没有)  icon_ttl=","color":"gray"},{"score":{"name":"#ts_t","objective":"zx.meta"},"color":"light_purple"}]
execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_fading,distance=..4] run tellraw @s [{"text":"  ⚠ 附近有正在淡出的图标 —— 说明刚刚被摘过标签(不是没显示过)","color":"yellow"}]

# ---- ④.5 图标本体: 文字里用的是"普通字形"还是"淡色字形", 不透明度是不是卡住了 ----
#   · 文字里的 translate 键名一眼可读:
#       sweetdream.icon.liuhuo      = 普通字形(该用的就是这个)
#       sweetdream.icon.dim.liuhuo  = 淡色字形(只在剩余<=3秒时才该出现)
#     ★ 如果一开始就一直是 .dim.*, 说明"变淡"判据错了 -> 图标会淡得看不见。
#   · text_opacity 是**有符号 byte**: 0..3=完全不透明 / 4..26=**整段丢弃(看不见!)** / 27..255=正常。
#     缺省 = -1b(读成 255, 正常)。落到 4..26 之间就是被写坏了 -> 图标"没有报错地看不见"。
#   · view_range 是渲染距离: 0.5 = 太远就整个不画(默认 1.0)。站远了看不到不是 bug。
execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4] run data get entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] text
execute at @e[tag=zx.ts_t,limit=1] if data entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] text_opacity run data get entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] text_opacity
execute at @e[tag=zx.ts_t,limit=1] unless data entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] text_opacity run tellraw @s [{"text":"  text_opacity 缺省 = 完全不透明 ✔","color":"dark_gray"}]
execute at @e[tag=zx.ts_t,limit=1] if entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4] run data get entity @e[type=minecraft:text_display,tag=zx.icon_v2,distance=..4,sort=nearest,limit=1] view_range

# ---- ⑤ 收尾: 摘掉临时目标标签 ----
tag @e[tag=zx.ts_t] remove zx.ts_t
