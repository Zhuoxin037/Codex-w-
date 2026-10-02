# ============================================================
# sweetdream:internal/itembackup/return_go —— 真正的回手动作(必须以玩家身份执行)
# ------------------------------------------------------------
# 【为什么单独一个文件】宏参数只能通过 "function xxx with storage ..." 传入,
#   而调用它的地方是 execute as ..., 没法顺便传宏参数。
#   所以在这里重新取一次自己的 UUID, 再去调那个宏函数。
# 【此时 @s 就是玩家】因为上一级用的是 execute as @a[tag=test_pending_return]。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:internal/itembackup/effect_2 with storage zx:work a

# 回手做完了, 槽位标记就用不着了 —— 留着会污染下一次判定。
#   (下一次 effect_1 开头也会先 remove 一次, 这里是双保险)
tag @s remove zx.ret_off
