# ------------------------------------------------------------
# internal/slot/rebuild_one —— 单格判定: 没有索引条目 = 空闲 => 丢进回收池
# 【宏参数】{i}(槽位号)
# 【★ 2026-10-11 P1 修(N01/N02)★ 现在**要**判 #i <= #next_slot】
#   旧注释曾写"不判 #next_slot, 因为占用只由 index 说了算" —— 那句本身没错, 但漏了
#   关键一条: **回收池的元素必须 ≤ 遍历上界**(1..#next_slot), 否则 from_free 把高位
#   槽发出去、foreach 却遍历不到它(N01 的"高位槽漏遍历")。
#   所以这里加**上限守卫**: 只把 1..#next_slot 范围内的空槽收进池。
#   #next_slot 已由 rebuild 在调用本函数**之前**用 scan_go 重算好(= 最高占用槽)。
#   占用与否仍由 index 说了算(`unless data … index "$(i)"`)—— 两句并列, 都要有。
# ------------------------------------------------------------
# ★ 用 `append from` 而不是 `append value $(i)`:
#   `from + 存储里的 int` 是本包**已验证**的写法(见 internal/leave/body 第 20 行
#   `data modify storage manacore:free_slots list append from storage manacore:work a.slot`);
#   第一版写 `append value $(i)` 实测一格都没 append 进去(2026-10-10 第二次 reload 后
#   free_slots 仍是 0 长度), 而命令不报错、日志也看不到 —— 换成熟写法。
#   work s.n 由 rebuild_go 每轮写入(= 当前 #i)。
$execute if score #i manacore.meta <= #next_slot manacore.meta unless data storage manacore:index "$(i)" run data modify storage manacore:free_slots list append from storage manacore:work s.n
