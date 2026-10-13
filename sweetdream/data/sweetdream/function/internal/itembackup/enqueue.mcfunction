# ============================================================
# sweetdream:internal/itembackup/enqueue —— 把"欠玩家的那件武器"压进队列(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid, src, slot}   【执行者】玩家本人(@s)
#   uuid = zx uuid 文本(定位存储键)
#   src  = 取哪份暂存快照(mainhand | offhand)
#   slot = 消耗时那一格(0..8; 副手给 -1) = 首选还回哪
# 【调用】function sweetdream:internal/itembackup/enqueue with storage zx:work a
#   (effect_1 唯一调用方; 调用前它已把 src/slot 备好)
# 【★ 队列 ★】zx:ret p."<uuid>".q = **列表**, 每个条目 {slot:<int>, item:<物品快照>}
#   · 条目里既带"要还什么"(.item), 也带"首选还回哪"(.slot);
#   · 回手只动**队首** q[0](见 effect_2), 落地(或队首没东西可还)才出队
#     ⇒ 连消耗两件不会互相顶掉(这正是 A02 要修的 ②)。
# 【★ 为什么要"先备份到暂存区, 再从这里搬进队列" ★】
#   物品快照只能靠"临时盔甲架中转"拍下来(snap_main/snap_off, 坑 95 —— 玩家主/副手
#   物品没有静态 NBT 路径); 那套中转把落点写死成暂存区 stage.*。所以先拍进 stage.*,
#   再用一条**存储->存储**的 `data modify set from` 搬进 q[-1].item —— 纯存储操作,
#   不必再召一次架子。
# 【★ 没快照就不入队 ★】stage 缺失说明"这一下没拍成", 没有东西可还;
#   硬塞一个空条目会**永久堵住队首** => 后面所有武器一起卡住。宁可这一件拍不到
#   (与旧版失败模式相同), 也不能让队列卡死。
# 【★ 镜像 ★】
#   zx.ret_slot = **队首**的首选槽位(供 return_go / recover_go 拼宏参数 $(slot) 用)。
#     从 q[0].slot 重算: 队列本来是空时它就是这一件的槽位; 本来非空则队首没变,
#     重算结果与原来一致(天然幂等, 不会把队首的镜像改错)。
#   zx.ret_pend = 1(有待归还; 队列空才由 effect_2 归 0)。
#   zx.ret_wait = 0(超时计时归零, 从头开始算)。
# 【★ 为什么 q 要先建出来 ★】`data modify … append` 要求目标是**已存在的 list**;
#   `set value []` 会连带把中间复合键 p."<uuid>" 建出来(存储根也能这样长出来)。
# ============================================================

# ① 队列不存在就先建出来(append 要求目标已是一个 list)
$execute unless data storage zx:ret p."$(uuid)".q run data modify storage zx:ret p."$(uuid)".q set value []

# ② 入队(仅当那份暂存快照真的拍到了东西 —— 见头部"没快照就不入队")
$execute if data storage zx:ret p."$(uuid)".stage.$(src).id run data modify storage zx:ret p."$(uuid)".q append value {slot:$(slot)}
$execute if data storage zx:ret p."$(uuid)".stage.$(src).id run data modify storage zx:ret p."$(uuid)".q[-1].item set from storage zx:ret p."$(uuid)".stage.$(src)

# ③ 镜像队首槽位 + 置"有待归还" + 清零超时计时
$execute if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot run data get storage zx:ret p."$(uuid)".q[0].slot
$execute if data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 1
$execute if data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_wait 0
