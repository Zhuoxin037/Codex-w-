# ============================================================
# test:itemreplace_return_go —— 真正的回手动作(必须以玩家身份执行)
# ------------------------------------------------------------
# 【为什么单独一个文件】宏参数只能通过 "function xxx with storage ..." 传入,
#   而调用它的地方是 execute as ..., 没法顺便传宏参数。
#   所以在这里重新取一次自己的 UUID, 再去调那个宏函数。
# 【此时 @s 就是玩家】因为上一级用的是 execute as @a[tag=test_pending_return]。
# ============================================================

function test:uuid
execute unless data storage test:data self{ok:1b} run return fail

data modify storage test:work a.uuid set from storage test:data self.uuid
function test:itemreplace_effect_2 with storage test:work a
