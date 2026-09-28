# ============================================================
# sweetdream:equipment/staff/wind_ontheground/summon —— 召唤第 n 个术阵
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid, n}   【执行者】施法者
# 【为什么 id 要带序号】术阵是按 id 存在玩家名下的字典, 用同一个 id 建第二次
#   会把第一个覆盖掉 —— 想同时存在 X 个就得 X 个不同的 id。
# 【时长 20 秒】和后面的"风声回响"对齐, 让两个看得见的东西同时消失。
# ============================================================

$data modify storage manacore:in arg set value {uuid:"$(uuid)",id:"sweetdream:wg_$(n)",type:"wind",duration_seconds:20.0}
function manacore:api/formation/create
