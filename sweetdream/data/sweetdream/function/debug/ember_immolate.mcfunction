# ============================================================
# sweetdream:debug/ember_immolate —— 查余烬 / 焚舟的实时状态
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/ember_immolate
# 【看什么】
#   余烬: 在不在身上 / zx.em_mana(已经加进面板的 +240 账本)
#   焚舟: 在不在身上 / 套装在不在 / zx.lk(烈空) / zx.lk_mode(0攒1衰减)
#         zx.im_mk(烈空已经加进面板的上限) / zx.im_buff(套装buff剩余秒)
#         zx.im_buff_mk(套装buff已经加进面板的上限)
#   最后读一次真实 max_mana, 用来核对“面板有没有跟账本对上”。
# 【为什么要 lib/in_bak】读 max_mana 会写 manacore:in arg;
#   不还回去会冲掉聊天栏手填的公共参数。
# ============================================================

scoreboard players add @s zx.em_mana 0
scoreboard players add @s zx.lk 0
scoreboard players add @s zx.lk_mode 0
scoreboard players add @s zx.im_mk 0
scoreboard players add @s zx.im_buff 0
scoreboard players add @s zx.im_buff_mk 0

tellraw @s [{"text":"===== 余烬 / 焚舟 =====","color":"gold","bold":true}]
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run tellraw @s [{"text":"余烬: ","color":"gray"},{"text":"已装备","color":"green"},{"text":"  上限账本 ","color":"gray"},{"score":{"name":"@s","objective":"zx.em_mana"},"color":"aqua"}]
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run tellraw @s [{"text":"余烬: ","color":"gray"},{"text":"未装备","color":"red"},{"text":"  上限账本 ","color":"gray"},{"score":{"name":"@s","objective":"zx.em_mana"},"color":"aqua"}]
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run tellraw @s [{"text":"焚舟: ","color":"gray"},{"text":"已装备","color":"green"}]
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run tellraw @s [{"text":"焚舟: ","color":"gray"},{"text":"未装备","color":"red"}]
execute if entity @s[tag=zx.im_set] run tellraw @s [{"text":"两件套: ","color":"gray"},{"text":"是","color":"green"}]
execute unless entity @s[tag=zx.im_set] run tellraw @s [{"text":"两件套: ","color":"gray"},{"text":"否","color":"red"}]
tellraw @s [{"text":"烈空: ","color":"gray"},{"score":{"name":"@s","objective":"zx.lk"},"color":"yellow"},{"text":"   模式(0攒/1衰减): ","color":"gray"},{"score":{"name":"@s","objective":"zx.lk_mode"},"color":"white"}]
tellraw @s [{"text":"烈空上限账本: ","color":"gray"},{"score":{"name":"@s","objective":"zx.im_mk"},"color":"aqua"},{"text":"   套装buff剩余: ","color":"gray"},{"score":{"name":"@s","objective":"zx.im_buff"},"color":"white"},{"text":"   套装buff账本: ","color":"gray"},{"score":{"name":"@s","objective":"zx.im_buff_mk"},"color":"aqua"}]
tellraw @s [{"text":"换算常量 #20/#30: ","color":"gray"},{"score":{"name":"#20","objective":"zx.meta"},"color":"white"},{"text":" / ","color":"gray"},{"score":{"name":"#30","objective":"zx.meta"},"color":"white"}]
tellraw @s [{"text":"套装+20 触发次数: ","color":"gray"},{"score":{"name":"@s","objective":"zx.im_set20"},"color":"white"},{"text":"  (烈空已 200 时会被夹住, 但这里仍会 +1)","color":"dark_gray"}]
tellraw @s [{"text":"余烬燃烧结束转换次数: ","color":"gray"},{"score":{"name":"@s","objective":"zx.em_conv"},"color":"white"}]
tellraw @s [{"text":"余烬看到燃烧生物的 tick 次数: ","color":"gray"},{"score":{"name":"@s","objective":"zx.em_seen"},"color":"white"}]

function sweetdream:lib/in_bak
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run function sweetdream:lib/in_restore
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
tellraw @s [{"text":"真实 max_mana: ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"light_purple"}]
function sweetdream:lib/in_restore
