# ============================================================
# sweetdream:equipment/armor/immolate/second_one —— 单个玩家的焚舟结算
# ------------------------------------------------------------
# 【执行者】玩家   【执行位置】玩家脚下
# 【每秒做四件事】
#   ① 认装备:    boots = zx.im_on, 两件套 = zx.im_set
#   ② 脱装回收:  没穿 boots 就把"烈空给的上限"和"套装 buff 上限"减回去
#   ③ 烈空账本:  #im_p = floor(烈空/20)*30, 和 zx.im_mk 求差, 只加差值
#   ④ buff 倒计时: zx.im_buff 每秒 -1, 到 0 收回 +100 上限
# 【为什么先 lib/uuid】写面板要用 zx:data self.uuid, 而 zx:data self 是
#   全局节点, 不重新取一次可能还是上一个人的 uuid。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 先把本件用到的计分项建出来(没分数的目标在 matches 里判不出来)
scoreboard players add @s zx.lk 0
scoreboard players add @s zx.lk_mode 0
scoreboard players add @s zx.im_mk 0
scoreboard players add @s zx.im_buff 0
scoreboard players add @s zx.im_buff_mk 0

# ① 认装备
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run tag @s add zx.im_on
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["immolate"]}] run tag @s remove zx.im_on

# ② 没穿焚舟 -> 回收本件给过的所有上限, 然后本秒收工
execute unless entity @s[tag=zx.im_on] run function sweetdream:equipment/armor/immolate/reclaim
execute unless entity @s[tag=zx.im_on] run return 0

# ③ 两件套(焚舟 + 余烬)
tag @s remove zx.im_set
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run tag @s add zx.im_set

# ④ 烈空 -> 魔力上限: floor(烈空/20)*30
scoreboard players operation #im_p zx.meta = @s zx.lk
scoreboard players operation #im_p zx.meta /= #20 zx.meta
scoreboard players operation #im_p zx.meta *= #30 zx.meta
scoreboard players operation #im_d zx.meta = #im_p zx.meta
scoreboard players operation #im_d zx.meta -= @s zx.im_mk
execute unless score #im_d zx.meta matches 0 run function sweetdream:equipment/armor/immolate/mana_apply

# ⑤ 套装 buff(+100 上限, 持续 20 秒)倒计时
execute if score @s zx.im_buff matches 1.. run scoreboard players remove @s zx.im_buff 1
execute if score @s zx.im_buff matches ..0 if score @s zx.im_buff_mk matches 1.. run function sweetdream:equipment/armor/immolate/buff_off
