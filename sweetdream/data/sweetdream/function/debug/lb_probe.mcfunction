# ============================================================
# sweetdream:debug/lb_probe —— 归息「平A命中 → 消耗状态 → 回复」链 现场诊断(只读)
# ------------------------------------------------------------
# 【用法】
#   ① 穿上归息(胸甲)；② 先把「渊海」或「噬心」挂到一只生物身上(退汐 / 刺纹 / 其它
#   能上状态的件)；③ 对它用**满蓄力**平A打一下(别打死)；④ 立刻跑本函数：
#       /function sweetdream:debug/lb_probe
# 【为什么要它】这条链上有 6 个**静默**断点, 断在哪一级都是"什么都没发生"、
#   而且一个字都不报。last_breath/hit 里埋了分级计数锚 #lb_d1..d8：
#   **哪一级的计数明显小于上一级, 就断在那里**。
# 【怎么读】
#   · d1 = 0/空白        -> 进度压根没抛 = 没用**平A**(技能/法球不算) 或 这一下没打中生物
#   · d1 有、d2 小很多   -> 大多被「满蓄力闸」挡了(打太快)。慢一点、隔 0.7 秒再打
#   · d2 有、d3 小很多   -> 胸甲槽认不到归息(看 [胸甲] 那行; 显示别的 id/空 就是没穿对)
#   · d3 有、d4 小很多   -> 没定位到目标(打太远 / 目标不是生物 / 是这一下就死了)
#   · d4 有、d5 小很多   -> 大多是**满血**时打的(文案: 自身生命值为满时不触发)
#   · d5 有、d6 小很多   -> 撞 8 秒节流了(看 [冷却] 那行)
#   · d6 有、d7 小很多   -> 目标身上**没有**「渊海」/「噬心」(看 [附近 16 格] 那行)
#   · d7 有、d8 小很多   -> 挑到了状态但消耗/回复没走完 -> 查 lib/mark_consume 那条链
#   · d8 = d7            -> 正常兑现了
# 【只读】只写 zx.meta 上的 #lbp_* 假玩家, 不动任何游戏状态(不吃冷却、不改标签)。
#   注: 读面板 max_health 用的是 lib/uuid(它会刷新 zx:data self), 只影响那份调试现场。
# ============================================================
tellraw @s [{"text":"===== 归息 诊断 =====","color":"gold"}]

# ---- ① 分级锚(累积计数) ----
tellraw @s [{"text":" 链路计数  d1 进度 ","color":"yellow"},{"score":{"name":"#lb_d1","objective":"zx.meta"},"color":"aqua"},{"text":"  → d2 蓄力 ","color":"yellow"},{"score":{"name":"#lb_d2","objective":"zx.meta"},"color":"aqua"},{"text":"  → d3 穿着 ","color":"yellow"},{"score":{"name":"#lb_d3","objective":"zx.meta"},"color":"aqua"},{"text":"  → d4 定位 ","color":"yellow"},{"score":{"name":"#lb_d4","objective":"zx.meta"},"color":"aqua"}]
tellraw @s [{"text":"           d5 非满血 ","color":"yellow"},{"score":{"name":"#lb_d5","objective":"zx.meta"},"color":"aqua"},{"text":"  → d6 冷却就绪 ","color":"yellow"},{"score":{"name":"#lb_d6","objective":"zx.meta"},"color":"aqua"},{"text":"  → d7 有状态 ","color":"yellow"},{"score":{"name":"#lb_d7","objective":"zx.meta"},"color":"aqua"},{"text":"  → d8 兑现 ","color":"yellow"},{"score":{"name":"#lb_d8","objective":"zx.meta"},"color":"aqua"}]
tellraw @s [{"text":"  哪一级比上一级小很多, 就断在那里(读法见函数头)","color":"dark_gray","italic":true}]

# ---- ② 胸甲槽上是什么(认没认出归息) ----
data remove storage zx:work lbp
execute if data entity @s equipment.chest.components."minecraft:custom_data".zx[0] run data modify storage zx:work lbp.id set from entity @s equipment.chest.components."minecraft:custom_data".zx[0]
execute unless data storage zx:work lbp.id run tellraw @s [{"text":" [胸甲] 空 —— 归息必须穿在 **胸甲** 槽, 否则这一步就断了","color":"red"}]
execute if data storage zx:work lbp.id run tellraw @s [{"text":" [胸甲] zx[0] = ","color":"gray"},{"nbt":"lbp.id","storage":"zx:work","color":"light_purple"},{"text":"   (应为 last_breath)","color":"dark_gray"}]

# ---- ③ 满蓄力闸的结论(最近一次平A) ----
tellraw @s [{"text":" [蓄力] 最近一次平A的结论 zx.atk_ok = ","color":"gray"},{"score":{"name":"@s","objective":"zx.atk_ok"},"color":"aqua"},{"text":"   (1=满蓄力; 0/空白=没蓄满)","color":"dark_gray"}]

# ---- ④ 生命: 是否满血(满血整段不触发) ----
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function manacore:api/stats/get
scoreboard players set #lbp_mh zx.meta 0
scoreboard players set #lbp_hp zx.meta 0
execute if data storage zx:data self{ok:1b} run execute store result score #lbp_mh zx.meta run data get storage manacore:out r.value 1000
execute store result score #lbp_hp zx.meta run data get entity @s Health 1000
tellraw @s [{"text":" [生命] 当前 ","color":"gray"},{"score":{"name":"#lbp_hp","objective":"zx.meta"},"color":"aqua"},{"text":" / 上限 ","color":"gray"},{"score":{"name":"#lbp_mh","objective":"zx.meta"},"color":"aqua"},{"text":"   (×1000; 两者相等=满血 -> 不触发)","color":"dark_gray"}]

# ---- ⑤ 8 秒节流的账本 ----
scoreboard players set #lbp_due zx.meta 0
execute store result score #lbp_due zx.meta run scoreboard players get @s zx.lb_cd
tellraw @s [{"text":" [冷却] 下次可触发刻 = ","color":"gray"},{"score":{"name":"#lbp_due","objective":"zx.meta"},"color":"aqua"},{"text":"   当前刻 = ","color":"gray"},{"score":{"name":"#now","objective":"manacore.meta"},"color":"aqua"},{"text":"   (> 当前刻 = 还在冷却)","color":"dark_gray"}]

# ---- ⑥ 附近 16 格内有几只带「渊海」/「噬心」 ----
scoreboard players set #lbp_y zx.meta 0
scoreboard players set #lbp_s zx.meta 0
execute as @e[type=!#sweetdream:no_damage,distance=..16,tag=zx.status.yuanhai] run scoreboard players add #lbp_y zx.meta 1
execute as @e[type=!#sweetdream:no_damage,distance=..16,tag=zx.status.shixin] run scoreboard players add #lbp_s zx.meta 1
tellraw @s [{"text":" [附近 16 格] 带渊海 ","color":"gray"},{"score":{"name":"#lbp_y","objective":"zx.meta"},"color":"aqua"},{"text":" 只 / 带噬心 ","color":"gray"},{"score":{"name":"#lbp_s","objective":"zx.meta"},"color":"aqua"},{"text":" 只","color":"gray"}]
tellraw @s [{"text":"   最近一只: ","color":"dark_gray"},{"selector":"@e[type=!#sweetdream:no_damage,distance=..16,sort=nearest,limit=1]","color":"white"}]

# ---- ⑦ 收尾提示 ----
tellraw @s [{"text":" 清计数(想看新一轮): /scoreboard players reset #lb_d1 zx.meta  …… d1~d8 各来一次","color":"yellow"}]
tellraw @s [{"text":" 想看某只生物身上五个状态的实时剩余: 站到它旁边跑 /function sweetdream:debug/tag_state","color":"dark_gray"}]
