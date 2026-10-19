# ============================================================
# sweetdream:equipment/tool/coffin_silk/on_true_hit —— 殓丝: 真伤命中带「噬心」的目标
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（打完伤害之后那条派发；宏 {u0..u3} = 这一批的攻击者）
# 【执行者】@s = 被打中的那一只生物
# 【文案(lore 逐字)】持于副手时，自身真实伤害命中了附有「噬心」且仍存活的生物后，
#   若自身未持有「殓结」且魔力足够，则额外消耗 80 魔力与该生物的「噬心」，为自身
#   获得持续 8 秒的「殓结」。该效果 12 秒内最多触发一次。
# 【且仍存活】伤害结算后显式检查 Health；死亡动画期间 @s 仍能保留标签。
# 【★ 为什么读 ob 而不是 a ★】deal 里可能有嵌套调用改过 zx:work a；ob 是这一批
#   伤害的**不可变快照**（见 lib/dmg / with_from 的说明）。
# ============================================================

# ① 它必须还带着「噬心」（调用点已判一次，这里再判一次：本文件要能独立测）
execute unless entity @s[tag=zx.status.shixin] run return 0
execute if entity @s[nbt={Health:0.0f}] run return 0

# ② 标出"被打中的这一只" —— 下面要换成玩家身份，之后就找不到它了
tag @e[tag=zx.cfs_v,distance=0..] remove zx.cfs_v
tag @s add zx.cfs_v

# ③ 反查"造成这一下真伤的玩家"，且他副手确实持着殓丝
scoreboard players set #cfs_held zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/tool/coffin_silk/held
execute unless score #cfs_held zx.meta matches 1 run tag @s remove zx.cfs_v
execute unless score #cfs_held zx.meta matches 1 run return 0

# ④ 交给玩家侧（未持「殓结」+ 魔力足够 + 12 秒节流 -> 扣 80 魔力、消耗目标「噬心」、给自己「殓结」）
data modify storage zx:work cfs.target set value "@e[tag=zx.cfs_v,limit=1]"
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] at @s run function sweetdream:equipment/tool/coffin_silk/gain

# ⑤ 收尾
tag @e[tag=zx.cfs_v,distance=0..] remove zx.cfs_v
