# ============================================================
# sweetdream:debug/cd_clear_go —— 清冷却的宏层
# ------------------------------------------------------------
# 【宏参数】zx:work cd {uuid, skill}
# 【出参】没有出参, 直接把结果 tellraw 给玩家。
# 【为什么用公开接口】api/cooldown/get 与 api/cooldown/reset 是前置包对外的
#   正规入口 —— 直接去改 players."<uuid>".cooldowns 的内部结构属于"绕过 API",
#   前置包一改内部布局这里就烂了。
# ============================================================

# ---- ① 先读一下还剩多少(顺便说明这条冷却到底存不存在) ----
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"$(skill)"}
function manacore:api/cooldown/get
$tellraw @s [{"text":"[调试] ","color":"dark_gray"},{"text":"$(skill)","color":"white"},{"text":"  原来还剩 ","color":"gray"},{"nbt":"r.remaining","storage":"manacore:out","color":"yellow"},{"text":" tick","color":"gray"}]

# ---- ② 清掉 ----
# 【为什么要重新填一次 arg】上面 api/cooldown/get 内部会把 work.a 当宏参数用,
#   但 manacore:in arg 本身没被改过 —— 这里再写一遍只是让它自解释、不依赖上一句。
$data modify storage manacore:in arg set value {uuid:"$(uuid)",skill:"$(skill)"}
function manacore:api/cooldown/reset
$tellraw @s [{"text":"[调试] 已结束冷却 ✓  ","color":"green"},{"text":"$(skill)","color":"white"},{"text":" 现在可以立刻再放一次","color":"gray"}]
