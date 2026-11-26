# ============================================================
# fallendream:equipment/staff/intone/cast —— 引声：右键分流（★ 法杖固定范式 ★）
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/intone（consume_item）
# 【★ 为什么要有这一层（2026-11-01 用户实机报错后重做）★】
#   法杖左键不能攻击，所以"普攻"也是右键出的法球。同一件法杖的右键于是要分两种：
#   **普通右键 = 普攻（射法球）**、**潜行右键 = 主动技能**。
#   早先我把主动技能直接写进了 cast，结果玩家一右键就直接放大招、而且根本没有普攻
#   —— 用户实测所说"普攻就是主动技能"就是这个。现在照 begonia / wake_bell /
#   long_night 的既有范式补上分流。
# 【判据】predicate fallendream:is_sneaking（全包统一，别自己写分数判）
# ============================================================

advancement revoke @s only fallendream:equipment/staff/intone

execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/intone/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/intone/attack
