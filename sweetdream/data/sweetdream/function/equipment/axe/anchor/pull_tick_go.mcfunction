# 原0.5格/刻、22刻上限和1.8格停止距离保持。
# 【★ 2026-10-23 卡顿修复 + 不钻地 ★】
#   ① 目标由 "UUID NBT 反查" 改成 **标签 zx.an_lock + scores={zx.an_own=$(u0)}**:
#      `@e[nbt={UUID:[I;...]}]` 是逐个实体的整份 NBT 序列化, 一发沉锚每刻要跑 3 次
#      (外加飞锚 visual/flight 的 6 次) ⇒ 人卡住、几秒后伤害才哗一下全出来。
#      标签是集合过滤, **零 NBT**(同思路见 lib/u_by / internal/damage/who)。
#   ② "死了" 的判据从 `nbt={Health:0.0f}` 改成原版 health 计分项 zx.hp_c:
#      玩家 NBT 序列化同样 ≈10 ms 一次, 而这是**每刻**都判的一条。
#   ③ 位移那步补了"头顶那格也要能站人"的判据 —— 跳起来掷锚时只判脚下一格,
#      会把人拉进地形里(玩家反馈"卡到地底下面去")。
execute if score @s zx.hp_c matches ..0 run return run function sweetdream:equipment/axe/anchor/cancel
function sweetdream:equipment/axe/anchor/visual/dimension
$scoreboard players set #av_expected zx.meta $(dim)
execute unless score #av_dim zx.meta = #av_expected zx.meta run return run function sweetdream:equipment/axe/anchor/cancel
$execute unless entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] run scoreboard players set @s zx.an_pull 0
$execute if entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=..1.8,limit=1] run scoreboard players set @s zx.an_pull 0
execute if score @s zx.an_pull matches ..0 run function sweetdream:equipment/axe/anchor/pull_end
execute if score @s zx.an_pull matches ..0 run return 0
# ④ 朝目标脚底走 0.5 格: ★ 脚与头两格都要是可替换方块, 否则这一步不走(宁可停下, 也不钻地)
$execute at @s facing entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1.6 ~ #minecraft:replaceable run tp @s ~ ~ ~
particle minecraft:cloud ~ ~0.1 ~ 0.15 0.1 0.15 0.02 3 normal
scoreboard players remove @s zx.an_pull 1
execute if score @s zx.an_pull matches ..0 run function sweetdream:equipment/axe/anchor/pull_end
