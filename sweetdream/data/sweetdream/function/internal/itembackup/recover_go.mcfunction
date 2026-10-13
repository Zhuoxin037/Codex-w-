# ============================================================
# sweetdream:internal/itembackup/recover_go —— 每秒重试时以玩家身份执行的那一层
# ------------------------------------------------------------
# 【调用】execute as @a[scores={zx.ret_pend=1..}] run function ... (见 recover)
# 【为什么单独一个文件】和 return_go 一样的原因: 宏参数只能通过
#   "function xxx with storage ..." 传, 而调用方是 execute as, 没法顺带传;
#   所以在这里重新取一次 UUID, 再去调那个宏函数。
# 【此处 @s 就是玩家】由上一级的 execute as 保证。
# 【与 return_go 的唯一差别】没有。两条路径共用 effect_2 这一个"回手动作",
#   谁先跑到谁先成功; effect_2 里判"落地"的那段会出队 + 清 zx.ret_pend, 另一条白跑而已。
# 【★ A02(2026-10-11 三审): 不再需要 $(src) ★】
#   物品由 effect_2 从**队首** q[0].item 取, 不需要"按 src 去读哪一份快照"了;
#   只保留 $(slot)(队首的首选槽位, 供拼 `hotbar.$(slot)`)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work a.uuid set from storage zx:data self.uuid
# ★ effect_2 的第二个宏参数 $(slot) —— 漏掉 effect_2 会整函数作废, 见 effect_2 头部。
#   先把安全值 0 塞进去, 只有主手(镜像 zx.ret_slot = 0..8)才换成真槽位 ——
#   因为 $(slot) 是**文本替换**: 副手(-1)/非法值时若不钳, 会拼出非法的 `hotbar.-1`。
data modify storage zx:work a.slot set value 0
execute if score @s zx.ret_slot matches 0..8 store result storage zx:work a.slot int 1 run scoreboard players get @s zx.ret_slot

function sweetdream:internal/itembackup/effect_2 with storage zx:work a

tag @s remove zx.ret_off
