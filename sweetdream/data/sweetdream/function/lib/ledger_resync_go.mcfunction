# ============================================================
# sweetdream:lib/ledger_resync_go —— R02 自愈的执行层(这一秒死过的玩家才会进来)
# ------------------------------------------------------------
# 【谁调用它】lib/ledger_resync(每秒探针)。执行者 = 玩家, 处在 lib/second 的
#   in_bak/in_restore 窗口内 ⇒ 可以直接写 manacore:in arg 调 api/stats/add。
# 【清谁 / 怎么清】挂原版属性的账本分别处理:
#   ① 纯属性账本(apply 只碰属性): 直接清零。下一秒 diff = want - 0 = want,
#      走原有的"无条件先摘再加"把修饰符按账本挂回 —— 就算修饰符其实没丢
#      (死亡不清属性的世界)也不会翻倍。没穿装备时 want=0 ⇒ diff=0 ⇒ 什么都不发生。
#   ② 面板+属性耦合账本(apply 先 api/stats/add 进面板、再挂属性): 不能只清账本
#      —— 那会让下一秒把面板**重复加上**。正解 = 先把面板退回账本那笔(负值),
#      再清账本 ⇒ 下一秒面板补回(净零)、属性先摘再加(重挂)。两种世界都正确。
#   ③ 无光之海 / 蜃楼: 只摘/重挂原版属性, 保留已正确的账本和面板。
#      无光之海的 zx.ls_buf 还保存三秒宽限内的期望加成, 不能清零;
#      蜃楼的层数/到期环保留, 后续被动按到期或卸装的差值正常减回。
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
# 神经衰弱石(2026-10-12): 攻速也是"纯属性账本"(只挂 attack_speed modifier)。
# ★ 比上面三条多一句**摘属性**★ —— 账本清 0 后, 若玩家手里已没有带攻速升级的武器,
#   held_apply 的目标值也是 0、diff = 0 ⇒ 不会走 atks_add ⇒ 修饰符会**留下不动**,
#   变成"脱了武器攻速还快"的幽灵加成。先无条件摘一次就永远对得上
#   (修饰符没丢的世界也只是白摘一次, 下一秒按 want 重挂, 不翻倍)。
attribute @s minecraft:attack_speed modifier remove sweetdream:upg_atkspeed
scoreboard players set @s zx.up_atks 0

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

# ---- ③ 无光之海: 保留兼作宽限缓存的账本, 只重挂属性(S03) ----
#   不调用 apply_atk(它会改面板/账本); atk_add 仅挂修饰符。
#   无条件先摘以兼容死亡未清修饰符的世界, 账本为零时保持无加成。
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_ls_atk
execute if score @s zx.ls_buf matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.ls_buf matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.ls_buf
execute if score @s zx.ls_buf matches 1.. run function sweetdream:equipment/armor/lightless_sea/atk_add with storage zx:work x

# ---- ③ 蜃楼套装: 同样只重挂原版属性, 不重复加面板(S03) ----
#   保留 zx.mr_atk 与层数/到期环; 下一秒即使到期或卸装也会按旧账正确减回。
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk
execute if score @s zx.mr_atk matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.mr_atk matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.mr_atk
execute if score @s zx.mr_atk matches 1.. run function sweetdream:equipment/armor/mirage/set_atk_add with storage zx:work x
