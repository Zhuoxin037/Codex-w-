# ============================================================
# sweetdream:station/api/apply —— "敲"(升级 / 超限)的统一入口(非宏外壳)
# ------------------------------------------------------------
# 【入参】zx:work st {kind:"upgrade"|"uncolor"|"overlimit", id:"<升级id>", cat:"<类别词>", of:"<武器id>"}
# 【执行者】玩家: 材料在主手(右键把它用掉来触发), **要敲的武器装备在副手**。
# 【它做什么】①先把"工作台坐标"补进参数(默认 0,-59,2), ②再交给 apply_go 干活
#   —— 坐标要拼进命令文本, 所以只能走宏函数。
# 【出参】zx:out r {ok, reason}: ok=0b 时调用方应该把材料还给玩家(用 item replace 给回一份),
#   ok=1b 就让这次消耗成立。
#
# 【★ 为什么在这里补 cat3/cat4 的空串 ★】
#   upgrade/api/fit 里 `$(cat3)` / `$(cat4)` 是宏参数 —— **没绑定 = 整个 fit 作废**
#   (一行解析不了, 整个函数不可用, 而且不报错)。而 apply/<id> 是按需填的:
#   老的 6 颗石头只有 cat/cat2。所以在唯一的入口这里统一补默认值。
#   ⚠️ 必须用 unless(缺了才填) —— 直接 set value "" 会把 apply/<id> 读出来的真值冲掉。
# ============================================================

execute unless data storage zx:config bench.pos run data modify storage zx:config bench.pos set value {x:0,y:-59,z:2}
execute unless data storage zx:work st.cat3 run data modify storage zx:work st.cat3 set value ""
execute unless data storage zx:work st.cat4 run data modify storage zx:work st.cat4 set value ""
data modify storage zx:work st merge from storage zx:config bench.pos
function sweetdream:station/api/apply_go with storage zx:work st