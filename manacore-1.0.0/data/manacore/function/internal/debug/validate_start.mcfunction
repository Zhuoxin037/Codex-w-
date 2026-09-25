# ------------------------------------------------------------
# internal/debug/validate_start —— 启动遍历式校验
# 【前置】调用方已把 ctrl.mode 设为 "validate"(debug/validate 里做的)
# 【作用】走一遍所有已登记槽位, 每个玩家跑一次 validate_one。
# ------------------------------------------------------------
function manacore:internal/index/foreach
