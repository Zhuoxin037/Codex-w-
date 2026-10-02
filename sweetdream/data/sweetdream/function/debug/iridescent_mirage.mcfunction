# ============================================================
# sweetdream:debug/iridescent_mirage —— 异彩 / 幻昼自检
# ------------------------------------------------------------
# 【怎么用】游戏里 /function sweetdream:debug/iridescent_mirage
# 【看什么】
#   ① 两件穿没穿(认错了后面全白测)
#   ② 两个魔力上限账本 —— 穿上应该是 220 / 240
#   ③ 套装两层各有多少层(+1 不设上限 / +2 最多 10 层), 以及实际挂了多少攻击力
#   ④ 12 格内带「白昼梦」的生物有几只、有没有在时停
#   ⑤ 最近一次 /damage 的数字 / 类型 / 目标 / 成败 —— 真实伤害打不出来的第一现场
# 【最常见的四个"没效果"】
#   · 魔力上限没变      -> 看 ②, 账本为 0 说明 passive 没跑(查 event/second 接线)
#   · 时停结束不打伤害  -> 看 ① ⑤; 且注意必须是**穿幻昼的人 8 格内**
#   · 白昼梦不出现      -> 20% 概率, 砍十刀看看; 另外确认不是打在玩家身上
#   · 伤害数字是 0      -> 面板 base_attack 没读到(已加原版属性兜底, 见 ts_dmg)
# ============================================================

scoreboard players add @s zx.ir_mana 0
scoreboard players add @s zx.mr_mana 0
scoreboard players add @s zx.mr_atk 0
scoreboard players add @s zx.mr_atk1 0
scoreboard players add @s zx.mr_atk2 0
scoreboard players add #dbg_n zx.meta 0
scoreboard players add #dbg_dmg zx.meta 0

tellraw @s [{"text":"===== 异彩 / 幻昼 自检 =====","color":"gold","bold":true}]

# ① 穿没穿
execute if items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run tellraw @s [{"text":"异彩(头盔): ","color":"gray"},{"text":"已穿戴","color":"green"}]
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run tellraw @s [{"text":"异彩(头盔): ","color":"gray"},{"text":"未穿戴","color":"red"}]
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run tellraw @s [{"text":"幻昼(腿甲): ","color":"gray"},{"text":"已穿戴","color":"green"}]
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run tellraw @s [{"text":"幻昼(腿甲): ","color":"gray"},{"text":"未穿戴","color":"red"}]

# ② 魔力上限账本
tellraw @s [{"text":"异彩 上限账本: ","color":"gray"},{"score":{"name":"@s","objective":"zx.ir_mana"},"color":"aqua"},{"text":"  (穿上应为 220)","color":"dark_gray"}]
tellraw @s [{"text":"幻昼 上限账本: ","color":"gray"},{"score":{"name":"@s","objective":"zx.mr_mana"},"color":"aqua"},{"text":"  (穿上应为 240)","color":"dark_gray"}]

# ③ 套装层数(每次触发各加一层, 每层自己到期)
tellraw @s [{"text":"套装 +1 层数(受伤): ","color":"gray"},{"score":{"name":"@s","objective":"zx.mr_atk1"},"color":"white"},{"text":" 层   +2 层数(打白昼梦): ","color":"gray"},{"score":{"name":"@s","objective":"zx.mr_atk2"},"color":"white"},{"text":" 层 (上限 10)","color":"dark_gray"}]
tellraw @s [{"text":"已挂攻击力: ","color":"gray"},{"score":{"name":"@s","objective":"zx.mr_atk"},"color":"white"},{"text":"  = +1层数 + +2层数×2","color":"dark_gray"}]

# ④ 周围的白昼梦 / 时停
execute at @s positioned ~-12 ~-12 ~-12 store result score #dbg_n zx.meta if entity @e[tag=zx.status.dream,dx=24.0,dy=24.0,dz=24.0]
tellraw @s [{"text":"24 格内带「白昼梦」的生物: ","color":"gray"},{"score":{"name":"#dbg_n","objective":"zx.meta"},"color":"light_purple"}]
execute at @s positioned ~-12 ~-12 ~-12 store result score #dbg_n zx.meta if entity @e[tag=zx.stop,dx=24.0,dy=24.0,dz=24.0]
tellraw @s [{"text":"24 格内正在时停的生物: ","color":"gray"},{"score":{"name":"#dbg_n","objective":"zx.meta"},"color":"light_purple"}]

# ⑤ 最近一次 /damage
execute if data storage zx:data last.num run tellraw @s [{"text":"最近一次伤害: 数字 ","color":"gray"},{"nbt":"last.num","storage":"zx:data","color":"white"},{"text":"  类型 ","color":"dark_gray"},{"nbt":"last.type","storage":"zx:data","color":"white"},{"text":"  打向 ","color":"dark_gray"},{"nbt":"last.target","storage":"zx:data","color":"white"}]
execute unless data storage zx:data last.num run tellraw @s [{"text":"还没有任何 /damage 被调用过 —— 链路压根没走到","color":"red"}]
tellraw @s [{"text":"那次是否成功 ","color":"gray"},{"score":{"name":"#dbg_dmg","objective":"zx.meta"},"color":"white"},{"text":"   (1=成功 0=失败; 失败会自动回退用 sweetdream:skill 再打一次)","color":"dark_gray"}]
tellraw @s [{"text":"真实伤害用 sweetdream:true_damage —— damage_type 是注册表内容, 新增后必须退出世界重进, /reload 不补。","color":"dark_gray"}]
tellraw @s [{"text":"提示: 砍生物 10 刀看白昼梦(20%, 约中 2 次); 时停结束那一下的伤害只在穿幻昼者 8 格内结算。","color":"dark_gray"}]
