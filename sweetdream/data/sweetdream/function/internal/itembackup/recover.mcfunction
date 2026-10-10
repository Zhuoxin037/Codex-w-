# ============================================================
# sweetdream:internal/itembackup/recover —— 每秒的"待归还"重试(由 lib/second 调用)
# ------------------------------------------------------------
# 【修 R06】原来只有一条路: effect_1 schedule 出来的 internal/itembackup/return,
#   它 1 tick 后跑**一次**, 执行对象是 `@a[tag=test_pending_return]`。
#   于是下面这些情况都会漏:
#     ① 消耗后立刻退出 / 掉线   -> 那一刻已经不是 @a 了, 没人给他还刀;
#        tag 也不持久, 重连后连"我欠一把刀"这件事都忘了 => 武器永久消失。
#     ② 那一 tick 恰好死亡       -> 同理; 重生后物品栏变了, 更不可能碰巧对上。
#     ③ 目标格当时被占(见 R01 的新保护)-> 那一 tick 没写进去就再也没人管。
#   现在这条每秒扫一遍"倒计时还没归零"的玩家, 重试 -> 成功就清零
#   (由 effect_2 的第 ④ 段判定), 失败就 -1, 归零即放弃。
# 【为什么不挂在 join / 重生事件上】本包没有可靠的重生钩子(重生用的是
#   minecraft 原版流程), 而且那样写要覆盖"离线期间到期"这类场景还得再补一条。
#   每秒轮询一处就能同时覆盖 掉线重连 / 死亡重生 / 临时占位挪开。
# 【开销】只对 zx.ret_pend >= 1 的玩家展开, 通常一个都没有 => 一条选择器命令, 空转。
# ============================================================

# ① 还有待归还的人: 重试一次(effect_2 内部判"到位"后会把倒计时清零)
execute as @a[scores={zx.ret_pend=1..}] run function sweetdream:internal/itembackup/recover_go

# ② 这一秒还没还成的: 倒计时 -1(上面刚被清零的人不满足 1.., 不会再被扣)
scoreboard players remove @a[scores={zx.ret_pend=1..}] zx.ret_pend 1

# ③ 倒计时归零 -> 放弃, 并把 zx.ret_slot 复位成 -2,
#    免得下一次消耗时残留一个旧目标格被 effect_2 的第 ③ 条兜底误当成合法值。
#    (只对**真的被设成 0** 的人生效: 从来没有这个分数的人不匹配 scores={...=0})
scoreboard players set @a[scores={zx.ret_pend=0}] zx.ret_slot -2
