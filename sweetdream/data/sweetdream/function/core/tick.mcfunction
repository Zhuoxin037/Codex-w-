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

# 法球(法杖类普攻的载体): 场上没有法球时这个选择器是空的, 开销为零
#   为什么不用 @a 而是 @e: 法球是 minecraft:marker, 要靠它自己带的数据飞,
#   和"谁在拿着法杖"无关 —— 发射出去之后你切武器、走开都不影响它。
execute as @e[tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data

# 通用标签的图标: 每 tick 摆一次位置(必须每 tick, 不然跑得快的怪会把图标甩在后面)
#   只在"带 zx.tagged 的生物"上跑, 没标记时开销为零。
execute as @e[tag=zx.tagged] at @s run function sweetdream:tag/follow_one

function sweetdream:lib/in_restore
