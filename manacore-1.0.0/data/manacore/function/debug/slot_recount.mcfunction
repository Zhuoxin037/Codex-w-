# ============================================================
# manacore:debug/slot_recount —— 对外入口(和 debug/on、debug/version 一个风格)
# 实际逻辑在 internal/debug/slot_recount。
# 用途: 槽位泄漏(#next_slot 涨得离谱)时跑一次, 把指针拉回"最大已用槽+1"。
# ============================================================
function manacore:internal/debug/slot_recount