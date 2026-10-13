# ============================================================
# sweetdream:internal/itembackup/migrate_legacy —— 旧版待归还快照 -> 新队列(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid, slot}   【执行者】玩家本人(@s)
#   uuid = zx uuid 文本(定位存储键)
#   slot = **主手那笔**的首选槽位(0..8); 副手路线不用它(固定 -1)
# 【调用】function sweetdream:internal/itembackup/migrate_legacy with storage zx:work a
#   唯一调用方 = sweetdream:event/player_join(玩家上线/重注册时跑一次, 幂等)。
# ------------------------------------------------------------
# 【★★ Q01(2026-10-11 四审): 升级缺口 ★★】
#   A02(三审)把返还结构从"两份固定快照 + 单标量待办"改成了"暂存区 stage.* + 队列 q":
#     旧: zx:ret p."<uuid>".mainhand / .offhand   (快照)
#         + zx.ret_pend(倒计时) / zx.ret_slot(镜像)
#     新: zx:ret p."<uuid>".stage.mainhand / .stage.offhand   (暂存, 随时被覆盖)
#         + zx:ret p."<uuid>".q = [{slot,item}]              (队列 = 真实待办)
#   全包**再也不读旧键** ⇒ 旧版遗留的"已消耗、还没还回来"那一笔, 升级后:
#     effect_2 找不到 q[0] ⇒ 走"队首没东西可还"分支 ⇒ ret_slot=-2 / ret_pend=0
#     ⇒ **快照还在存储里、驱动它的待办被清掉了** ⇒ 那把武器再也回不来。
#   这里在上线时把旧的一笔**搬进队列**(搬移: 成功后删旧键), 之后一切走新结构。
# ------------------------------------------------------------
# 【★★ 判据为什么必须是 zx.ret_pend >= 1 ★★】
#   旧版的 `.mainhand/.offhand` 快照**每秒被 backup_go 刷新** ⇒ "有快照" **完全不能**
#   代表"欠一把"(否则会把玩家非待还状态下的普通备份当成欠款, 凭空发武器)。
#   旧版的"欠一把"只由 zx.ret_pend 表达(老实现: 倒计时, 归零=放弃; N8 续修后 >=1 = 待还)。
#   ⇒ 只迁移 **ret_pend >= 1** 的那一笔; 没有这个标记的旧备份**一律不动**。
# 【至多一笔】旧版是**玩家级单标量**待办(A02 要修的就是"连消耗两件会互相顶掉")
#   ⇒ 同一时刻最多只有一笔, 且它属于第一次消耗的那把。所以本函数只建**一个**条目。
# 【哪一份快照 = 那一笔】旧镜像 zx.ret_slot: -1 = 副手 -> 用 .offhand;
#   0..8 = 某快捷栏格 -> 用 .mainhand。(与旧 effect_2 的落脚点口径一致。)
# 【幂等】① `unless q[0]` —— 队列已有东西就整段不动(迁移过 / 本来就是新结构);
#   ② 迁移成功后**删掉**被搬走的那份旧键 ⇒ 下次上线连"有旧快照"都不成立。
#   两道加起来, 重复上线不会重复发放, 也不会重复 append。
# 【★ 顺序要紧 ★】先用标志算出"这次要迁哪一份", **再**按标志构造队列。
#   不能边判边建: 建完 q[0] 之后, 后面几行的 `unless q[0]` 会立刻变成假 ⇒ 搬移那步被跳过
#   ⇒ 建出一个只有 slot、没有 item 的空条目(反而堵死队首)。(同族: 坑 99 的先算后判)
# ============================================================

# ① 算标志: 这一次要迁"副手那笔"还是"主手那笔"(都不是 => 两个都是 0, 整段空转)
scoreboard players set #lg_off zx.meta 0
scoreboard players set #lg_main zx.meta 0
$execute if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches -1 unless data storage zx:ret p."$(uuid)".q[0] if data storage zx:ret p."$(uuid)".offhand.id run scoreboard players set #lg_off zx.meta 1
$execute if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches 0..8 unless data storage zx:ret p."$(uuid)".q[0] if data storage zx:ret p."$(uuid)".mainhand.id run scoreboard players set #lg_main zx.meta 1

# ② 副手那笔 -> 队首(slot = -1)  【append 要求目标是已存在的 list, 先建空壳】
$execute if score #lg_off zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q set value []
$execute if score #lg_off zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q append value {slot:-1}
$execute if score #lg_off zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q[0].item set from storage zx:ret p."$(uuid)".offhand
# ③ 主手那笔 -> 队首(slot = 旧镜像; 由调用方钳成 0..8 再传进来)
$execute if score #lg_main zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q set value []
$execute if score #lg_main zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q append value {slot:$(slot)}
$execute if score #lg_main zx.meta matches 1 run data modify storage zx:ret p."$(uuid)".q[0].item set from storage zx:ret p."$(uuid)".mainhand

# ④ 搬移: 删掉"被搬走的那一份"旧键(没搬的一律不动 —— 见头部"幂等")
$execute if score #lg_off zx.meta matches 1 run data remove storage zx:ret p."$(uuid)".offhand
$execute if score #lg_main zx.meta matches 1 run data remove storage zx:ret p."$(uuid)".mainhand

# ⑤ 重建镜像(队列非空 => pend=1 / slot=队首 / 计时归零)。
#    ★ 一并交给 resync: 迁移后镜像必须立刻与新队列一致, 否则下一秒 recover 的选择器
#      还是选不到人。语义与 A02 的不变式"ret_pend=1 ⟺ 队列非空"逐字一致。
function sweetdream:internal/itembackup/resync_go
