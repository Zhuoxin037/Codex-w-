# ------------------------------------------------------------
# internal/join/register —— 落库登记 + 抛上线事件
# 【宏参数】manacore:macro.a 或 manacore:work.a {uuid,u0,u1,u2,u3,slot}
# 【写入】① players."uuid".slot / .session=1b
#         ② index."slot" = {uuid,u0,u1,u2,u3,slot}  <- 供离线检测与遍历使用
#         ③ ctx 事件上下文(uuid/slot/reason="join")
# 【最后】调用 #manacore:event/player_join, 你自己的包只要往那个函数标签里
#         加一条函数, 就能在玩家真正注册完成的那一刻初始化自己的数据。
# 【为什么 ctx 要单独存】事件函数拿不到宏参数, 只能读全局上下文存储,
#         所以框架统一用 manacore:ctx 传递事件信息。
# ------------------------------------------------------------
$execute store result storage manacore:players "$(uuid)".slot int 1 run scoreboard players get @s manacore.slot
$data modify storage manacore:players "$(uuid)".session set value 1b
$data modify storage manacore:index "$(slot)" set value {uuid:"",slot:0,beat:0}
$data modify storage manacore:index "$(slot)".uuid set value "$(uuid)"
$execute store result storage manacore:index "$(slot)".slot int 1 run scoreboard players get @s manacore.slot
$execute store result storage manacore:index "$(slot)".beat int 1 run scoreboard players get #sec manacore.meta
$data modify storage manacore:ctx uuid set value "$(uuid)"
execute store result storage manacore:ctx slot int 1 run scoreboard players get @s manacore.slot
data modify storage manacore:ctx reason set value "join"
function #manacore:event/player_join
