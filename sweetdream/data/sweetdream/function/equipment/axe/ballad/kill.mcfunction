# ============================================================
# sweetdream:equipment/axe/ballad/kill —— 歌谣「曲调」: 击杀攒层
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/ballad_kill(player_killed_entity)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "自身使用「歌谣」时每击杀一个生物则积攒一点「曲调」。（最高 8 层）"
# 【★ 四要素 ★】① 触发: 击杀; ② 范围: 手持歌谣时; ③ 次数: 每杀一只 +1; ④ 上限: 8 层。
# 【★ 首行必须 revoke 自己 ★】否则这个进度一辈子只触发一次(见 lib/rearm)。
# 【不需要按刻去重】一次击杀就是一个独立事件, 杀几只就 +几点 —— 这正是文案要的。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/ballad_kill

# 武器门控: 主手或副手是歌谣才记
execute unless items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["ballad"]}] unless items entity @s weapon.offhand diamond_axe[custom_data~{zx:["ballad"]}] run return 0

# 超限: 同一刻的"攻击"已经攒过一点了 -> 这一杀不再加
#   (一击必杀会同时触发 player_hurt_entity 与 player_killed_entity 两个进度;
#    文案写的是"攻击**或**击杀", 不是两次)
execute if score @s zx.blt_lt = #now manacore.meta run return 0

# 上限 8 层
execute if score @s zx.bd_tune matches 8.. run return 0
scoreboard players add @s zx.bd_tune 1
