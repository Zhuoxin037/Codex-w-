# ============================================================
# sweetdream:equipment/sword/hush/back —— 吸附回原点(瞬间, 归位的最后一下)
# ------------------------------------------------------------
# 【谁调用它】back_finish ①(2026-10-07 改版后, 逐刻闪回由 back_move 推,
#   本函数只负责"到了就吸附+收 marker"这最后一下)。
# 【宏参数】zx:work hs {uuid:"<施法者 uuid 文本>"}
# 【怎么找自己的 marker】marker 的 data.zx.hs.uuid 就是 cast 时写进去的 uuid 文本,
#   直接用 nbt 过滤器把 uuid 拼进选择器(这是唯一"按 uuid 找任意实体"的办法)。
# 【★ 为什么用 `at <marker> run tp @s ~ ~ ~` 而不是 tp @s <坐标>】
#   `at` 只换坐标基点、**不换执行者** —— 所以 tp 的还是玩家本人, 而 `~ ~ ~` 的
#   基准已经变成 marker 的位置 => 玩家被精确挪回原点, **朝向保持不变**。
#   (tp 到实体写法会把玩家朝向也拷成 marker 的 0/0, 不行。)
# 【distance=0.. 是干嘛的】它不过滤任何东西, 只给选择器一个位置基准, 从而把
#   搜索锁在当前维度 —— 裸 @e 会跨全部维度搜索(RULES 坑 53)。
# 【找不到 marker】execute 选 0 个 -> 这条不执行, 玩家留在撞击点, 不会报错。
# ============================================================

$execute at @e[tag=zx.hs_org,nbt={data:{zx:{hs:{uuid:"$(uuid)"}}}},distance=0..,limit=1] run tp @s ~ ~ ~
$kill @e[tag=zx.hs_org,nbt={data:{zx:{hs:{uuid:"$(uuid)"}}}},distance=0..,limit=1]
