# ============================================================
# sweetdream:equipment/axe/thunderclap/domain_kill —— 收掉"属于某座术阵"的领域实体(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work td {u0,u1,u2,u3} = 术阵 marker **自身**的 UUID 四段
# 【谁调用它】field_end(执行者 = 术阵 marker, 寿命正常到点)
# 【做什么】kill 掉 data.zx.m 与这四段**完全一致**的那个 zx.tc_dom item_display
# 【★★ 为什么不按 distance 杀(2026-10-10 修 F17)★★】
#   旧写法 `kill @e[type=item_display,tag=zx.tc_dom,distance=..2]` —— 两座术阵中心
#   相距 <= 2 格时, 先结束的那一座会把**还活着**的那一座的领域显示一起删掉:
#   术阵逻辑 marker 还在、域模型却没了, 玩家看到"圈突然消失"。
#   改成按 marker UUID 精确匹配, 与两座之间的距离无关。
# 【为什么可以不锁维度】按 UUID 找的是唯一实体; 跨维度搜也不会误伤别座术阵
#   (每座 marker 的 UUID 各不相同, data.zx.m 也就不可能撞车)。
# ============================================================

$execute as @e[type=item_display,tag=zx.tc_dom,nbt={data:{zx:{m:[I;$(u0),$(u1),$(u2),$(u3)]}}}] run kill @s
