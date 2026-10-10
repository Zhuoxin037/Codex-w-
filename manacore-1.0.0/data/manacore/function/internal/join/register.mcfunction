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
# 【为什么会重写同一条索引】正常只写一次; 但"槽位被回收后又被别人占用"时,
#   新主人会覆盖旧索引 —— 这正是要的(旧主人下次上线会因 u0..u3 不匹配而重注册)。
# 【★ 2026-10-10 事故(整包静默失效)★】这一行**必须带 execute**。
#   上一批改 F01 时手滑写成 `$store result ...`(少一个 execute)⇒ `store` 不是命令
#   ⇒ 宏函数在这一行炸掉 ⇒ 后面全部不执行 ⇒ **索引写不进去、manacore.gen 不写**
#   ⇒ tick_self 每秒判定"未注册" ⇒ 每秒重走 join(每秒弹走一格槽位: 实测 64→55)
#   ⇒ self_uuid 恒空 ⇒ sweetdream 整包静默失效, 且日志**零报错**。
#   ★ 宏函数(带 $ 的行)在**加载时不解析**, 所以这种语法错不会变成
#     "Failed to load function", 只在运行时炸 —— 守门规则 `noexecute` 已拦这一类。
$execute store result storage manacore:players "$(uuid)".slot int 1 run scoreboard players get @s manacore.slot
$data modify storage manacore:players "$(uuid)".session set value 1b
# 【★ 索引条目带 u0..u3(F01 修 2026-10-10)】tick_self 靠"索引里的 u0..u3 是否等于
#   自己的 UUID 四 int"来判"这个槽位还记不记得我" —— 只用槽位号会被"槽位被回收后
#   分给别人"骗到。这里一次写全, 免得将来漏字段。
$data modify storage manacore:index "$(slot)" set value {uuid:"",slot:0,beat:0,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$data modify storage manacore:index "$(slot)".uuid set value "$(uuid)"
$execute store result storage manacore:index "$(slot)".slot int 1 run scoreboard players get @s manacore.slot
$execute store result storage manacore:index "$(slot)".beat int 1 run scoreboard players get #sec manacore.meta
# 【★ 记下"本次注册所在代"(F01 修)】tick_self 判"@s manacore.gen >= #gen"就知道
#   这一代已经注册过了, 不必每秒重走 join。
scoreboard players operation @s manacore.gen = #gen manacore.meta
# 【F16 的"终身清单"不在这里登记】见 internal/player/create 的说明:
#   本函数每次上线/重注册都会跑, 而清单元素是裸字符串、判不了重 ⇒ 在这里登记会
#   每上线一次长一条。清单改在"建记录处"登记(天然唯一)。
$data modify storage manacore:ctx uuid set value "$(uuid)"
execute store result storage manacore:ctx slot int 1 run scoreboard players get @s manacore.slot
data modify storage manacore:ctx reason set value "join"
function #manacore:event/player_join
