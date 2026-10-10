# ------------------------------------------------------------
# internal/slot/rebuild_one —— 单格判定: 没有索引条目 = 空闲 => 丢进回收池
# 【宏参数】{i}(槽位号)
# 【为什么不判 slot 是否 <= #next_slot】#next_slot 只是"曾经发到过几号",
#   它**不代表占用**; 占用与否只由 index 说了算(见 rebuild 的不变量说明)。
# ------------------------------------------------------------
# ★ 用 `append from` 而不是 `append value $(i)`:
#   `from + 存储里的 int` 是本包**已验证**的写法(见 internal/leave/body 第 20 行
#   `data modify storage manacore:free_slots list append from storage manacore:work a.slot`);
#   第一版写 `append value $(i)` 实测一格都没 append 进去(2026-10-10 第二次 reload 后
#   free_slots 仍是 0 长度), 而命令不报错、日志也看不到 —— 换成熟写法。
#   work s.n 由 rebuild_go 每轮写入(= 当前 #i)。
$execute unless data storage manacore:index "$(i)" run data modify storage manacore:free_slots list append from storage manacore:work s.n
