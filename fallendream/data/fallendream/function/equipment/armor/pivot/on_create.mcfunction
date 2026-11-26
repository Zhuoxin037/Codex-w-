# ============================================================
# fallendream:equipment/armor/pivot/on_create —— 超限枢: 召唤术阵时回 1% 生命
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/formation_create(写盘成功后抛, ctx = {id,uuid,reason})
# 【★ 为什么先抄 uuid 再进宏】tag 文件只能列函数名, 绑不了宏参数;
#   且 ctx.uuid 是**裸 UUID 文本** —— 可以直接当 `execute as <uuid>` 的选择器用
#   (裸 UUID 可以当持有者/选择器, 不要拼成 `$(u)[tag=…]` 那种形式)。
# ============================================================

execute unless data storage manacore:ctx uuid run return 0
data modify storage zx:work pv_c.uu set from storage manacore:ctx uuid
function fallendream:equipment/armor/pivot/on_create_go with storage zx:work pv_c
