# ============================================================
# sweetdream:station/api/apply —— "敲"(升级 / 超限)的统一入口(非宏外壳)
# ------------------------------------------------------------
# 【入参】zx:work st {kind:"upgrade"|"uncolor"|"overlimit", id:"<升级id>", cat:"<类别词>", of:"<武器id>"}
# 【执行者】玩家: 材料在主手(右键把它用掉来触发), **要敲的武器装备在副手**。
# 【它做什么】①把 cat3/cat4 的空串补上, ②交给 apply_go 干活。
# 【出参】zx:out r {ok, reason}: ok=0b 时调用方应该把材料还给玩家(用 item replace 给回一份),
#   ok=1b 就让这次消耗成立。
#
# 【★ 为什么在这里补 cat3/cat4 的空串 ★】
#   upgrade/api/fit 里 `$(cat3)` / `$(cat4)` 是宏参数 —— **没绑定 = 整个 fit 作废**
#   (一行解析不了, 整个函数不可用, 而且不报错)。而 apply/<id> 是按需填的:
#   老的 6 颗石头只有 cat/cat2。所以在唯一的入口这里统一补默认值。
#   ⚠️ 必须用 unless(缺了才填) —— 直接 set value "" 会把 apply/<id> 读出来的真值冲掉。
#
# 【★★ 这里曾经做过的事, 2026-10-08 已经不做了 ★★】
#   以前这一行还会往参数里塞一个方块坐标(zx:config bench.pos, 默认 0,-59,2),
#   apply_go 会在那儿 setblock 一个箱子当"改物品 NBT 的跳板"。
#   那个箱子是上古版本"用箱子做强化台"的残留 —— 后来改成"副手放装备 + 主手放石头"
#   的操作方式, 箱子却一直留着, 世界里会凭空多出一个箱子。
#   现在整套改成**临时盔甲架**中转(见 apply_go 头注释): 不碰世界、不留方块、
#   也不依赖 forceload / 主世界。所以这里不再补坐标, 也不再需要坐标。
# ============================================================

execute unless data storage zx:work st.cat3 run data modify storage zx:work st.cat3 set value ""
execute unless data storage zx:work st.cat4 run data modify storage zx:work st.cat4 set value ""
function sweetdream:station/api/apply_go with storage zx:work st
