# ------------------------------------------------------------
# internal/sweep/one —— 离线检测(每个已登记玩家都跑一次)
# 【宏参数】manacore:work.a {uuid,u0,u1,u2,u3,slot}
# 【判断】用 @a[nbt={UUID:[I;u0,u1,u2,u3]}] 反查: 世界上还存在这个实体吗?
#         存在 = 在线, 什么都不做;
#         不存在 = 已离线(正常退出 / 掉线 / 崩服), 交给 leave/player 清理。
# 【为什么每秒才跑一次】这个选择器比较贵(NBT 匹配), 每秒每个槽位一次
#         完全够用; 秒级延迟对"清残留"没有任何影响。
# 【这就是"玩家退出/异常情况不留残留"的实现点】
# ------------------------------------------------------------
# 心跳秒号 >= 当前秒号 -> 本秒仍然在线; 否则判定已离线
$execute if data storage manacore:index "$(slot)".beat store result score #beat manacore.math run data get storage manacore:index "$(slot)".beat
$execute unless data storage manacore:index "$(slot)".beat run scoreboard players set #beat manacore.math -1
execute if score #beat manacore.math < #sec manacore.meta run function manacore:internal/leave/player with storage manacore:work a
