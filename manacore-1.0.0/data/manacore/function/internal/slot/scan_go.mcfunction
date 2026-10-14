# ------------------------------------------------------------
# internal/slot/scan_go —— 扫出"最高已登记(占用)槽" -> #next_slot(递归驱动器)
# 【★ 2026-10-11 P1 修(N01/N02)★】
# 【为什么拆成"驱动器 + 叶子(scan_one)"两个文件】
#   与同目录 rebuild_go/rebuild_one、index/foreach+loop 完全同构。理由是一个**宏时序**坑:
#   带 `with` 的宏函数里, `$(i)` 在**进入本轮时**就已冻结成"调用方写进宏源的值";
#   若在**同一层**里"先写宏源 s.i、再用 $(i)", 本轮读到的永远是**上一轮**的值 ⇒
#   整体 off-by-one: 只扫到 0..#max_slots-1, **永远漏掉第 #max_slots 槽**。
#   2026-10-11 实测事故: index."64" 明明存在, #next_slot 却恒 0; 再叠加 rebuild_one 的
#   `<= #next_slot` 守卫 ⇒ 回收池被清成空。玩家看到的症状 = "/reload 后 #next_slot 仍 0"。
#   正解: 驱动器(本文件, **不含宏行**)**先写宏源、再带 with 调用叶子**; 叶子只读 $(i)。
# 【宏参数】manacore:work.s.i(本驱动器每轮写入; 仅供叶子 scan_one 渲染使用)
# 【语义】#next_slot = 所有"存在 index 条目"的槽号中的最大值(没有则保持 0)。
#   ⇒ 遍历上界 1..#next_slot 恒覆盖所有占用槽 —— 见 internal/slot/rebuild 的不变量。
#   本函数取代 core/boot 原来的"满槽归零"hack: 那是 N02 的根(归零后 slot/new 不判
#   index 是否存在 ⇒ 满槽 reload 后第 65 人写到已占用的 slot 1 上)。
# 【终止】调用方先把 #next_slot 置 0、#i 置 1、并把 s.i 写成 1; 扫到并含 #max_slots 就停。
# 【调用方】只从 internal/slot/rebuild 调用(在重建回收池之前), 见那里。
# ------------------------------------------------------------
execute if score #i manacore.meta > #max_slots manacore.meta run return 0
execute store result storage manacore:work s.i int 1 run scoreboard players get #i manacore.meta
function manacore:internal/slot/scan_one with storage manacore:work s
scoreboard players add #i manacore.meta 1
function manacore:internal/slot/scan_go
