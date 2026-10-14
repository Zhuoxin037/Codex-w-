# ------------------------------------------------------------
# internal/slot/scan_one —— 叶子: 若 index."$(i)" 存在, 则把 #next_slot 抬到 i
# 【★ 2026-10-11 P1 修(N01/N02)★】
# 【宏参数】manacore:work.s.i(由驱动器 scan_go 每轮写入后调用本函数)
# 【为什么单独一个文件 + 只读不写】宏时序陷阱: 宏函数里 $(i) 在进入本轮时就冻结;
#   把"写宏源 s.i"和"用 $(i)"放在同一层会 off-by-one, 漏掉第 #max_slots 槽
#   (2026-10-11 事故: #next_slot 恒 0)。所以: 写 = 驱动器 scan_go, 用 $(i) = 本叶子。
#   详见 internal/slot/scan_go 头部。
# ------------------------------------------------------------
$execute if data storage manacore:index "$(i)" run scoreboard players operation #next_slot manacore.meta = #i manacore.meta
