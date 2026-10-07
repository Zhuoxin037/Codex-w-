# ============================================================
# sweetdream:equipment/sword/hush/back_move —— 归位一步(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work hs {uuid:"<施法者 uuid 文本>"}
# 【谁调用它】back_step ④
# 【每刻一次】离原点 <= 2 格 -> 交给 back_finish(吸附 + 收尾);
#   否则朝 marker 迈 2 格。
# 【★ 用 `facing entity <marker> feet` + `^ ^ ^2.0`】
#   facing 只改"这一步的朝向", **不改玩家保存的朝向**; tp 只动坐标 ——
#   所以闪回全过程里视角始终由玩家自己控制, 不会像 `tp @s <实体>` 那样把
#   朝向也一起拷走。
# 【distance=0..】只给选择器一个位置基准, 把搜索锁在当前维度(裸 @e 跨维度)。
# 【步长 2.0 与阈值 2 的配套】8 格 -> 8/2 = 4 刻 = 0.2 秒; 阈值取 2 是为了
#   让最后一步落在允许范围内就吸附, 不用追求精确到 0 格。
# ============================================================

# ① 到点: 收尾(back_finish 里会吸附 + 杀 marker + 结算回程伤害)
$execute if entity @e[tag=zx.hs_org,nbt={data:{zx:{hs:{uuid:"$(uuid)"}}}},distance=..2] run function sweetdream:equipment/sword/hush/back_finish with storage zx:work hs

# ② 还没到: 朝 marker 迈 2 格
$execute unless entity @e[tag=zx.hs_org,nbt={data:{zx:{hs:{uuid:"$(uuid)"}}}},distance=..2] facing entity @e[tag=zx.hs_org,nbt={data:{zx:{hs:{uuid:"$(uuid)"}}}},distance=0..,limit=1] feet run tp @s ^ ^ ^2.0
