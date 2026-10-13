# ============================================================
# sweetdream:internal/itembackup/resync —— 按【队列】重建镜像分数(宏 {uuid})
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid}   【执行者】玩家本人(@s)
# 【调用】function sweetdream:internal/itembackup/resync with storage zx:work a
#   调用方: resync_go(player_reset 末尾那条路)、migrate_legacy(迁移完立刻重建)。
# ------------------------------------------------------------
# 【★★ Q02(2026-10-11 四审): 重置把镜像清了, 队列还在 ★★】
#   A02 把"待归还"的**真相**放在了队列 `zx:ret p."<uuid>".q`(存储里, 不属计分板);
#   而 `zx.ret_pend / zx.ret_slot / zx.ret_wait` 只是**镜像**, 供三个普通函数
#   (recover / recover_go / return_go)在选择器和宏参数里用 —— 它们写不了动态存储路径。
#   但 `player_reset` 的逐项清单(N06)会把这三个 `zx.*` 一起 reset ⇒ 出现:
#       队列非空(1 件待还) + ret_pend 不存在 ⇒ recover 的选择器 `@a[scores={zx.ret_pend=1..}]`
#       一个人都选不到 ⇒ **没有任何东西再驱动这笔返还** ⇒ 物品卡死在队列里,
#       除非玩家碰巧再消耗一件武器(enqueue 才会顺手把镜像建回来)。
#   修法 = 把镜像当"可以随时重建的缓存": 清账**之后**按队列重算一遍。
#   语义选择(2026-10-11 定): **重置不打断返还事务** —— 重置只清"账本/计时",
#   不动"已经欠玩家的实物"; 队列不空就继续一秒一秒地试着还, 还成功才销账。
#   (另一条路"重置 = 结束返还事务、显式丢弃队列"会凭空吞掉玩家一件装备, 不取。)
# ------------------------------------------------------------
# 【为什么必须挂在 player_reset 的清单**之后**】
#   挂在清单之前 = 刚建好的镜像立刻被清单 reset 掉, 等于没做。
#   listener 侧见 event/player_reset 末尾(标记行以下的手写区)。
# 【双向重建(不只是"q 非空就置 1")】
#   反方向也要管: q 已经被还干净/被别处清掉, 而镜像还留着 1 ⇒ 玩家会被永久
#   挂上 `ret_pend=1`(每秒空转 recover、并吃到 20 秒那句"背包已满"提示)。
#   所以 q 空时把镜像复位成干净态(-2 / 0)。本函数**幂等**, 反复跑结果相同。
# 【★ 不动队列本身 ★】只读 q[0]; 出队永远是 effect_2 的职责(落地才算数)。
# ============================================================

# ① 队列非空 => 有待归还: 镜像 = 队首首选槽位, 布尔 = 1, 超时计时归零(从头算)
$execute if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot run data get storage zx:ret p."$(uuid)".q[0].slot
$execute if data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 1
$execute if data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_wait 0

# ② 队列空(或压根没有 q) => 无待归还: 镜像复位成"干净"态
#    (-2 = 无待办 且 槽位非法, 与 recover ④ / effect_2 ⑦ 的口径一致)
$execute unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_slot -2
$execute unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 0
$execute unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players reset @s zx.ret_wait
