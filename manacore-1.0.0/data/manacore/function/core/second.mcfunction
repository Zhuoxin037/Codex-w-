# ============================================================
# core/second —— 每秒逻辑(默认 20 tick 一次)
# ------------------------------------------------------------
# 【步骤】
#   ① session/refresh  : 逐个在线玩家检查"是否已注册/是否需要重新上线",
#                        新玩家会走完整的 UUID 注册流程, 老玩家重新上线
#                        会补全缺失字段并重新占槽。
#   ② player/second    : 逐个在线玩家做"每秒结算"——
#                        魔力恢复、术阵到期移除。这一步不需要全局遍历,
#                        因为每个玩家的数据都在自己 UUID 名下。
#   ③ debug/hud        : 只给带了 manacore.debug 标签的玩家刷 ActionBar,
#                        不打扰普通玩家。
#   ④ sweep            : 遍历槽位索引, 找出"索引里有、但人已经不在线"的
#                        玩家, 做离线清理(释放槽位、清术阵、抛 leave 事件)。
#                        这一步是"退出/崩溃不留残留"的关键。
#   ⑤ #manacore:event/second : 抛给外部数据包做自己的每秒逻辑。
# 【顺序为什么重要】先 refresh 再 sweep: 刚上线的玩家会被登记, 而确实
#         掉线的人才会被判定为离线, 不会误清。
# ============================================================

scoreboard players set #tick manacore.timer 0

# 秒号递增: 用于心跳(判断在线)与注册续期
scoreboard players add #sec manacore.meta 1

execute as @a run function manacore:internal/session/tick_self
execute as @a run function manacore:internal/player/second

execute as @a[tag=manacore.debug] run function manacore:debug/hud

# 状态栏扩展点: 插件包可以在这里覆盖/追加自己的显示(例如武器冷却)。
# 默认挂的是空操作函数, 没人扩展时什么都不会发生。
execute as @a[tag=manacore.debug] run function #manacore:event/hud_extra

scoreboard players set #mode manacore.meta 1
function manacore:internal/index/foreach

function #manacore:event/second
