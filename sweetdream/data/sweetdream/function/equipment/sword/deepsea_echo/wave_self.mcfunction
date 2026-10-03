# ============================================================
# sweetdream:equipment/sword/deepsea_echo/wave_self —— 以玩家身份取 UUID, 推一波
# ------------------------------------------------------------
# 【谁调用它】core/tick 里"倒计时到点"的那一句(以前是 wave + schedule)
# 【执行者】施法者本人(带 zx.de_run)
# 【为什么要拆两层】每个源的标记名里带施法者 UUID, 拼路径只能用宏变量,
#   而宏变量只能通过 with storage 传进宏函数。这一层先把 UUID 取到手,
#   再把 zx:work de(里面就是 uuid)整个当宏参数交给下一层。
# 【★ 取不到 UUID 时必须收链 ★】
#   老版本走 schedule, 取不到就直接 return, 链自然就断了;
#   现在改成每刻轮询, 光 return 的话 zx.de_t 会一直卡在 <=0, 于是**每刻重试一次**。
#   所以这里要显式把链掐掉。
#   (lib/uuid 只有在 manacore 还没给这个玩家建档时才会失败, 属于异常态。)
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tag @s remove zx.de_run
execute unless data storage zx:data self{ok:1b} run scoreboard players set @s zx.de_t 0
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage zx:work de.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/deepsea_echo/wave_go with storage zx:work de
