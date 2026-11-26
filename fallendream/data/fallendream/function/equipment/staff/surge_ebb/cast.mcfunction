# ============================================================
# fallendream:equipment/staff/surge_ebb/cast —— 右键分流（★ 法杖固定范式 ★）
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/staff/surge_ebb（consume_item）
# 【★ 2026-11-01 用户实机报错后重做 ★】
#   法杖没有左键攻击，普攻也是右键出法球。同一件法杖的右键必须分两种：
#   **普通右键 = 普攻（射法球，命中后给术阵）**、**潜行右键 = 主动（12 秒追奉者）**。
#   早先主动直接写进了 cast，玩家一右键就放掉 500 魔力并开始每秒掉血，
#   而且完全没有普攻 —— 用户说的"普攻就是主动技能"就是这个。
# 【判据】predicate fallendream:is_sneaking
# ============================================================

advancement revoke @s only fallendream:equipment/staff/surge_ebb

execute if predicate fallendream:is_sneaking run function fallendream:equipment/staff/surge_ebb/skill
execute unless predicate fallendream:is_sneaking run function fallendream:equipment/staff/surge_ebb/attack
