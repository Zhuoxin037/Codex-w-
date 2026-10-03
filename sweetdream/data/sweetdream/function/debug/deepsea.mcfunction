# ============================================================
# sweetdream:debug/deepsea —— 「深海的回响」释放动画自检(只读)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/deepsea     (以玩家身份执行)
# 【为什么要它】释放动画横跨三层, 任何一层断了都表现为"剑不动",
#   光看画面分不出是哪一层:
#     ① 数据包状态机(tag zx.de_cast)有没有被点着
#     ② anim/tick 的"物品识别谓词"认不认得出手上这把剑
#     ③ item_modifier 里的常量(#deidle/#dezero)还在不在
#   这里把三层一次全打出来。
# 【它是只读的】只写三个 zx.meta 上的探测用假玩家(#de_pmain/#de_poff/#de_mcd)。
#   想验证"写入"那一步(第 ④ 层), 用 debug/deepsea_go。
# ============================================================

tellraw @s [{"text":"===== 深海的回响 · 释放动画自检 =====","color":"aqua","bold":true}]

# ---- ① 状态机有没有被点着 ----
execute if entity @s[tag=zx.de_cast] run tellraw @s [{"text":"tag zx.de_cast  有   -> core/tick 正在给这个人推帧","color":"green"}]
execute unless entity @s[tag=zx.de_cast] run tellraw @s [{"text":"tag zx.de_cast  无   -> anim/start 没跑到(技能没成立, 或 cast ⑤ 之前就 return 了)","color":"red"}]
tellraw @s [{"text":"当前帧号 zx.de_cast  ","color":"gray"},{"score":{"name":"@s","objective":"zx.de_cast"},"color":"white"},{"text":"   (0..31 播放中, 33 收尾, 空=已复位)","color":"dark_gray"}]

# ---- ② 物品识别谓词(anim/tick 里那两个 if items) ----
scoreboard players set #de_pmain zx.meta 0
scoreboard players set #de_poff zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run scoreboard players set #de_pmain zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run scoreboard players set #de_poff zx.meta 1
tellraw @s [{"text":"主手认剑 ","color":"gray"},{"score":{"name":"#de_pmain","objective":"zx.meta"},"color":"yellow"},{"text":"   副手认剑 ","color":"gray"},{"score":{"name":"#de_poff","objective":"zx.meta"},"color":"yellow"},{"text":"   (1=认到, 0=谓词没匹配上)","color":"dark_gray"}]

# ---- ③ item_modifier 的两个常量 ----
tellraw @s [{"text":"#deidle ","color":"gray"},{"score":{"name":"#deidle","objective":"zx.meta"},"color":"white"},{"text":" (必须 32 = 待机位)     #dezero ","color":"dark_gray"},{"score":{"name":"#dezero","objective":"zx.meta"},"color":"white"},{"text":" (必须 0)","color":"dark_gray"}]

# ---- ④ 手上这把剑的 custom_model_data 现在是多少 ----
#      item_modifier 用 replace_section 写的是 floats = [0, N]。
#      没被推过帧 = 根本没有这个组件(那 range_dispatch 会退到 threshold 0 = cast_00)。
#      【★ 为什么不写成物品谓词 ★】本来写的是
#        *[custom_data~{...},custom_model_data~{floats:[0.0f,32.0f]}]
#      结果**整个函数加载失败**(Whilst parsing command on line 35:
#      应为字面量= at position 116 ...model_data)—— 多组件的物品谓词里
#      custom_model_data 这个分量不吃 `~` 部分匹配。
#      改成 data get 把数**读出来打印**, 反而更有用(能直接看到是几)。
scoreboard players set #de_mcd zx.meta -1
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] store result score #de_mcd zx.meta run data get entity @s SelectedItem.components."minecraft:custom_model_data".floats[1]

tellraw @s [{"text":"主手剑 custom_model_data.floats[1] = ","color":"gray"},{"score":{"name":"#de_mcd","objective":"zx.meta"},"color":"white"},{"text":"   (-1 = 组件不存在 / 主手没拿深海剑)","color":"dark_gray"}]
execute if score #de_mcd zx.meta matches 32 run tellraw @s [{"text":"  = 32 -> 正处在待机模型 ✓","color":"green"}]
execute unless score #de_mcd zx.meta matches 32 run execute unless score #de_mcd zx.meta matches ..0 run tellraw @s [{"text":"  ≠ 32 -> 卡在某个 cast 帧上(每秒的 reset_hands 本该把它拉回 32)","color":"red"}]

tellraw @s [{"text":"提示: 想确认'写入'那一步, 先 /scoreboard players set @s zx.de_cast 11","color":"gold","italic":true},{"text":"  再 /function sweetdream:debug/deepsea_go","color":"gold","italic":true}]
