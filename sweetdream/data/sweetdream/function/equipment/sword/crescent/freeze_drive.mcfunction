# ============================================================
# sweetdream:equipment/sword/crescent/freeze_drive —— 每刻把玩家的 uuid 喂给宏叶子
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a[scores={zx.cr_t=1..}] at @s run function ...
# 【★ 为什么要有这一层(坑 96 的同族) ★】
#   freeze_tick 需要按 uuid 拼存储路径(`p."<uuid>"`), 所以它是**宏函数**。
#   宏参数只能由调用方写好后 `with` 传进去 —— 这里就是"驱动器": 写好宏源, 再调叶子。
#   叶子只读 $(uuid), 不自己写它 ⇒ 不会出现"同层写宏源又用 $(i)"那种 off-by-one。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work crd set value {uuid:""}
data modify storage zx:work crd.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/crescent/freeze_tick with storage zx:work crd
