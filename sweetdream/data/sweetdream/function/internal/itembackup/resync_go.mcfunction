# ============================================================
# sweetdream:internal/itembackup/resync_go —— 调 resync 的普通包装(以玩家身份执行)
# ------------------------------------------------------------
# 【为什么单独一个文件】和 return_go / recover_go 一样的原因: resync 是**宏函数**,
#   `$(uuid)` 只能由调用方通过 `with storage` 传; 而调用它的是 player_reset
#   (普通函数, 手里没有 uuid) ⇒ 在这里重新取一次自己的 UUID。
# 【此处 @s 就是玩家】由 player_reset 保证(@s 只可能是在线那位)。
# 【用途】player_reset 清账清单跑完**之后**调一次, 把 ret_pend/ret_slot/ret_wait
#   按队列 zx:ret p."<uuid>".q 重建(详见 resync 头部)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/resync with storage zx:work a
