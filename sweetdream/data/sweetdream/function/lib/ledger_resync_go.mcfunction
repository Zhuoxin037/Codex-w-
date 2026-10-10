# ============================================================
# sweetdream:lib/ledger_resync_go —— R02 自愈的执行层(这一秒死过的玩家才会进来)
# ------------------------------------------------------------
# 【谁调用它】lib/ledger_resync(每秒探针)。执行者 = 玩家, 处在 lib/second 的
#   in_bak/in_restore 窗口内 ⇒ 可以直接写 manacore:in arg 调 api/stats/add。
# 【清谁 / 怎么清】挂原版属性的账本分两类:
#   ① 纯属性账本(apply 只碰属性): 直接清零。下一秒 diff = want - 0 = want,
#      走原有的"无条件先摘再加"把修饰符按账本挂回 —— 就算修饰符其实没丢
#      (死亡不清属性的世界)也不会翻倍。没穿装备时 want=0 ⇒ diff=0 ⇒ 什么都不发生。
#   ② 面板+属性耦合账本(apply 先 api/stats/add 进面板、再挂属性): 不能只清账本
#      —— 那会让下一秒把面板**重复加上**。正解 = 先把面板退回账本那笔(负值),
#      再清账本 ⇒ 下一秒面板补回(净零)、属性先摘再加(重挂)。两种世界都正确。
# 【不走这条的账本】zx.am_mana / zx.up_mana(纯面板, 见 ledger_resync 头部);
#   remelt/meteor/tag_liuhuo/tag_dream_atk/lethe/twilight/freeze 等**限时战斗增益**
#   —— 死亡丢 buff 本身就是合理行为, 且它们到点自然收尾, 不需要自愈。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ---- ① 纯属性账本: 直接清 ----
scoreboard players set @s zx.up_armor 0
scoreboard players set @s zx.up_at 0
scoreboard players set @s zx.ss_armor 0

# ---- ② 耦合账本·max_health 面板组(升级生命 / 炉心 / 外援 / 套装 / 脊骨共生) ----
#   面板上这几家都加在同一个键上, 可以合成一笔退。
scoreboard players set #lr_sum zx.meta 0
scoreboard players operation #lr_sum zx.meta += @s zx.up_hp
scoreboard players operation #lr_sum zx.meta += @s zx.fc_hp
scoreboard players operation #lr_sum zx.meta += @s zx.power_hp
scoreboard players operation #lr_sum zx.meta += @s zx.set_hp
scoreboard players operation #lr_sum zx.meta += @s zx.ss_hp
scoreboard players set #lr_neg zx.meta 0
scoreboard players operation #lr_neg zx.meta = #lr_sum zx.meta
scoreboard players set #-1 zx.meta -1
scoreboard players operation #lr_neg zx.meta *= #-1 zx.meta
execute if score #lr_sum zx.meta matches 1.. run data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
execute if score #lr_sum zx.meta matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #lr_sum zx.meta matches 1.. store result storage manacore:in arg.value double 1 run scoreboard players get #lr_neg zx.meta
execute if score #lr_sum zx.meta matches 1.. run function manacore:api/stats/add
scoreboard players set @s zx.up_hp 0
scoreboard players set @s zx.fc_hp 0
scoreboard players set @s zx.power_hp 0
scoreboard players set @s zx.set_hp 0
scoreboard players set @s zx.ss_hp 0

# ---- ② 耦合账本·base_attack 面板组(脑髓蛭) ----
scoreboard players set #lr_sum zx.meta 0
scoreboard players operation #lr_sum zx.meta += @s zx.bl_atk
scoreboard players set #lr_neg zx.meta 0
scoreboard players operation #lr_neg zx.meta = #lr_sum zx.meta
scoreboard players operation #lr_neg zx.meta *= #-1 zx.meta
execute if score #lr_sum zx.meta matches 1.. run data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
execute if score #lr_sum zx.meta matches 1.. run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #lr_sum zx.meta matches 1.. store result storage manacore:in arg.value double 1 run scoreboard players get #lr_neg zx.meta
execute if score #lr_sum zx.meta matches 1.. run function manacore:api/stats/add
scoreboard players set @s zx.bl_atk 0
