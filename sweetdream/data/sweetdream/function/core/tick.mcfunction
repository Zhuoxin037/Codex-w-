# ============================================================
# sweetdream:core/tick —— 每游戏刻执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/tick.json
# 【现在做三件事】都靠"先筛人/筛实体再干活", 没参与的对象开销为零:
#   · 给开着数值面板的玩家刷新动作栏(标签 @a[tag=test_look_on])
#   · 推横刀的突进(分数 zx.dash >= 1 的玩家)
#   · 推法球(场上所有 zx.ball)
# 【以后加东西】每刻的逻辑写这里; 每秒的逻辑建议挂到 #manacore:event/second。
# ============================================================

# 【备份公共输入口】下面三套每刻逻辑都会写 manacore:in arg(观测镜要查术阵数量),
#   不还回去的话你在聊天栏手填的参数每刻都被冲掉 —— 见 lib/in_bak。
function sweetdream:lib/in_bak

execute as @a[tag=test_look_on] run function sweetdream:equipment/tool/look/render

# 横刀突进: 只有分数 >= 1 的玩家参与, 平时完全不参与(开销为零)
execute as @a[scores={zx.dash=1..}] at @s run function sweetdream:equipment/sword/hengdao/dash_tick

# 冷冻: TicksFrozen 每 tick 会自己 -2(离开粉雪就衰减), 这里帮被冻住的生物续回 140,
#   这样"冻 N tick"就是真的 N tick(见 lib/freeze_hold)。
#   只对带 zx.freeze 的生物跑, 没冻住东西时开销为零。
execute in minecraft:overworld as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_nether as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_end as @e[tag=zx.freeze] run function sweetdream:lib/freeze_hold

# 法球(法杖类普攻的载体): 场上没有法球时这个选择器是空的, 开销为零
#   为什么不用 @a 而是 @e: 法球是 minecraft:marker, 要靠它自己带的数据飞,
#   和"谁在拿着法杖"无关 —— 发射出去之后你切武器、走开都不影响它。
execute in minecraft:overworld as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_nether as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_end as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data

# 标签位置每 2 tick 更新；完整状态校验固定每 20 tick，跨原版三维度。
scoreboard players add #icon_t zx.meta 1
execute if score #icon_t zx.meta matches 2.. run function sweetdream:tag/follow_all
execute if score #icon_t zx.meta matches 2.. run scoreboard players set #icon_t zx.meta 0
scoreboard players add #tag_clock zx.meta 1
execute if score #tag_clock zx.meta matches 20.. run function sweetdream:tag/second
execute if score #tag_clock zx.meta matches 20.. run scoreboard players set #tag_clock zx.meta 0

# 寒鸦这里**每刻什么都不用做**: "箭打中了谁"由弩上自带的附魔「霜矢」回调
#   (hook_victim) 交给原版判定, 不再需要我们逐 tick 去认箭。

# 焚舟: 每刻推 烈空(只对穿着焚舟的人跑)
#   攻击命中时 hurt 里的 buff_on 也会写 manacore:in arg, 所以放在
#   in_restore 之前, 让这一整段都在公共输入口的备份保护里。
execute as @a[tag=zx.im_on] at @s run function sweetdream:equipment/armor/immolate/tick

function sweetdream:lib/in_restore
