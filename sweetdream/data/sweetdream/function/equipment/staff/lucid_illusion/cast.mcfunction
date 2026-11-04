# ============================================================
# sweetdream:equipment/staff/lucid_illusion/cast —— 右键分流（★ 法杖固定范式 ★）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/lucid_illusion（consume_item）
# 【★ 2026-11-01 用户实机报错后重做 ★】
#   法杖没有左键攻击，普攻也是右键出法球；所以同一件法杖的右键必须分两种：
#   **普通右键 = 普攻（射固定 1 点伤害的法球）**、**潜行右键 = 主动技能**。
#   早先我把主动直接写进了 cast，玩家一右键就放掉 500 魔力 + 扣自己一半血，
#   而且完全没有普攻 —— 用户说的"普攻就是主动技能"就是这个。
# 【判据】predicate sweetdream:is_sneaking
# ============================================================

advancement revoke @s only sweetdream:equipment/staff/lucid_illusion

execute if predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/lucid_illusion/skill
execute unless predicate sweetdream:is_sneaking run function sweetdream:equipment/staff/lucid_illusion/attack
