# ------------------------------------------------------------
# internal/debug/reset_notify —— 重置后, 逐个在线玩家抛"应用层收尾"事件
# 【谁调用它】debug/reset_all(以及任何想复用这条收尾链的地方)
# 【执行者】由调用方 `execute as @a run function ...` 送进来 = 玩家本人
# 【做什么】把上下文写清楚, 再抛 #manacore:event/player_reset
#   —— 应用层(sweetdream)在那里清自己的"已加成账本"(见该事件的 handler)。
# 【为什么必须逐个玩家抛, 而不是抛一次让 handler 自己找】
#   handler 要用 `@s` 定位那个玩家(账本挂在玩家实体上); 而 /function 不改变执行者,
#   所以只有在"as <玩家>"里抛, @s 才是那个人。
# 【离线玩家】@a 选不到, 他们的账本这一次清不掉 —— 见 sweetdream 那个 handler 的注释。
# ------------------------------------------------------------
data modify storage manacore:ctx uuid set value ""
data modify storage manacore:ctx reason set value "player_reset"
function #manacore:event/player_reset
