# ============================================================
# fallendream:equipment/staff/lucid_illusion/orb —— 清醒与幻觉：生成一个法球（或超限法球）
# ------------------------------------------------------------
# 【执行者】玩家（已过职业/蓄力/手持判定）
# 【分流】没到上限 -> 正常 zx.j_orb +1（和魔导士通用被动同一条路）；
#         已到上限 -> 额外法球（zx.li_e1..3，10 秒，最多 3 个）。
# 【★ 额外法球不占 j_orb ★】j_orb 是"上限内"的球，观感与其它魔导士武器一致；
#   额外球单独记在三个到期刻槽里，所以"到上限"这个判据永远不会被自己突破。
# ============================================================

function fallendream:profession/mage/tally

function fallendream:equipment/armor/eagle_hat/orb_before
execute if score #jorbs zx.meta < #jcap zx.meta run scoreboard players add @s zx.j_orb 1
function fallendream:equipment/armor/eagle_hat/orb_after
execute unless score #jorbs zx.meta < #jcap zx.meta run scoreboard players set #li_dur zx.meta 200
execute unless score #jorbs zx.meta < #jcap zx.meta run function fallendream:equipment/staff/lucid_illusion/extra
