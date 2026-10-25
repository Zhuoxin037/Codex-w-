# ============================================================
# sweetdream:equipment/sword/gousi/ol_pull —— 超限·钩丝 拉一拍(宏)
# ------------------------------------------------------------
# 【执行者】玩家；位置已在玩家脚下
# 【宏参数】zx:work gs3 {own}
# 【一拍做四件事】
#   ① 目标全没了 -> 收尾(ol_done)
#   ② 给施法者挂一个不带 uuid 的临时标签 zx.gs3_src
#      —— 下层 ol_step 已经 `as` 到生物身上, 手上只有 own(UUID[0]) 一个整数,
#         拼不出玩家选择器; 靠这个标签才能在生物视角"面向玩家"拉过来。
#   ③ 距离 ≤2 的直接按"到位"结算; 其余的各自 ol_step 拉一步
#   ④ 步数 -1; 用完 -> 还挂着的全部按"没拉到"结算
# 【★ 顺序: 先结算到位的、再拉剩下的 ★】
#   反过来的话, 这一步刚被拉进 2 格内的那只会被下一拍才结算 —— 观感上多等 0.25 秒,
#   而且"拉到位置后立即结算"是文案明写的。
# ============================================================

# ⓪ 一只目标都没有 -> 直接收尾
$execute unless entity @e[tag=zx.gs3_$(own),limit=1] run function sweetdream:equipment/sword/gousi/ol_done
$execute unless entity @e[tag=zx.gs3_$(own),limit=1] run return 0

# ① 施法者临时标签
tag @s add zx.gs3_src

# ② 已经到身前 2 格 -> 到位结算
$execute as @e[tag=zx.gs3_$(own),distance=..2] at @s run function sweetdream:equipment/sword/gousi/ol_land with storage zx:work gs3

# ③ 2 格外的各拉一步(撞墙与到点都在 ol_step 里就地结算)
$execute as @e[tag=zx.gs3_$(own),distance=2.01..,limit=3] at @s run function sweetdream:equipment/sword/gousi/ol_step with storage zx:work gs3

# ④ 步数 -1(12 × 0.8 = 9.6 格, 盖住 8 格锁敌半径)
scoreboard players remove @s zx.gs_st 1
execute if score @s zx.gs_st matches ..0 run function sweetdream:equipment/sword/gousi/ol_timeout with storage zx:work gs3

tag @s remove zx.gs3_src

# ⑤ 这一拍把最后一只也结算掉了 -> 收尾
$execute unless entity @e[tag=zx.gs3_$(own),limit=1] run function sweetdream:equipment/sword/gousi/ol_done
