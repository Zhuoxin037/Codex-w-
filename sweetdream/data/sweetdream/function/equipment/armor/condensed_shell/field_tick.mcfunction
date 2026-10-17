# ============================================================
# sweetdream:equipment/armor/condensed_shell/field_tick —— 领域每秒一跳(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[type=marker,tag=zx.cs_field,distance=0..] at @s run ...
# 【每秒干什么】
#   ① 挑出"首次进入本次领域"的生物 -> 冰冻 1 秒(每名生物整次领域最多一次)
#   ② 对领域内(半径 3 格)的全部生物打一次"施放者基础攻击力 ×4"
#   ③ 计时 -1, 归零走 field_end。
# 【★ ①的"整次领域最多一次"怎么判 ★】用**领域实例号**:
#   实例号 = 本 marker 的 UUID[0](随机 32 位整数, 两个领域撞号概率可忽略),
#   冻过谁就把这个号写进**生物自己**的 zx.cs_fid; 下秒一比相等就不再冻。
#   · 为什么不用标签: 标签不能带动态后缀(宏拼标签要另铺一层驱动器, 见坑 96)。
#   · 为什么不用 NBT: 目标是"生物", 将来若把玩家也放进来也**写不了玩家 NBT**(坑 162);
#     计分项对谁都安全, 且天然逐目标。
#   · 计分项不存在时 `unless score @s zx.cs_fid = #cs_iid` 判不成立 ⇒ unless 放行
#     ⇒ 首次必然冻。这正是要的行为(freeze_new 里再把这个号记上)。
# 【什么是"领域内"】distance=..3 = 从 marker 到生物**脚底**(坑 157)。地面领域这样量没问题
#   (先例 = 神裁 distance=..2 / 崩裂 distance=..3 / 重溟 distance=..3)。
# 【★ distance=0.. 的显式锁维度 ★】本函数在"每维度各跑一次"的链上, 所有 @e 选择器都带
#   distance 起点; 领域自身的两个 @e 用 ..3 作起点, 同样是锁维度的(裸 @e 会跨维度重复扣)。
# ============================================================

# ① 本次领域的实例号 = 本 marker 的 UUID[0](store result 每刻都会重写, 不会读陈旧值)
scoreboard players add #cs_iid zx.meta 0
execute store result score #cs_iid zx.meta run data get entity @s UUID[0]

# ② "首次进入本次领域"的生物 -> 冻 1 秒 + 把这个领域号记到它身上
execute as @e[type=!#sweetdream:no_damage,distance=..3] unless score @s zx.cs_fid = #cs_iid zx.meta run function sweetdream:equipment/armor/condensed_shell/freeze_new

# ③ 每秒伤害: 基础攻击力 ×4(施放那刻已算好, 存在 marker NBT 的 data.zx.dmg)
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain

# 目标: 领域(3 格)内的全部生物。distance=..3 既给选择器位置基准(锁维度)也是范围。
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..3]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# 归属: 施放者 UUID 四个整数
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现: 一层贴着地面打转的霜壳
particle minecraft:snowflake ~ ~0.15 ~ 1.6 0.1 1.6 0.02 14 normal
particle minecraft:white_ash ~ ~0.3 ~ 1.4 0.2 1.4 0.02 10 normal

# ⑤ 计时 -1, 归零收摊
scoreboard players remove @s zx.cs_ft 1
execute if score @s zx.cs_ft matches ..0 run function sweetdream:equipment/armor/condensed_shell/field_end
