# ============================================================
# sweetdream:station/api/apply —— "敲"(升级 / 超限)的统一入口(非宏外壳)
# ------------------------------------------------------------
# 【入参】zx:work st {kind:"upgrade"|"overlimit", id:"<升级id>", cat:"<类别词>", of:"<武器id>"}
# 【执行者】玩家: 材料在主手(右键把它用掉来触发), **要敲的武器装备在副手**。
# 【它做什么】①先把"工作台坐标"补进参数(默认 0,-59,2), ②再交给 apply_go 干活
#   —— 坐标要拼进命令文本, 所以只能走宏函数。
# 【出参】zx:out r {ok, reason}: ok=0b 时调用方应该把材料还给玩家(用 item replace 给回一份),
#   ok=1b 就让这次消耗成立。
# ============================================================

execute unless data storage zx:config bench.pos run data modify storage zx:config bench.pos set value {x:0,y:-59,z:2}
data modify storage zx:work st merge from storage zx:config bench.pos
function sweetdream:station/api/apply_go with storage zx:work st