# ============================================================
# sweetdream:equipment/axe/thunderclap/join_clear —— 玩家重登时重建 zx.tc_on
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/player_join (以玩家身份; 见 data/manacore/tags/function/event/player_join.json)
# 【修什么(2026-10-08)】field_end 清 zx.tc_on 靠 lib/find_by 反查**在线**玩家 ——
#   施法者离线时 @a[tag=zx.mc_by] 为空, 计分项改不了, tc_on 就永远停在 1。
#   重登后 hit 永远走"已有术阵"分支, 而这件武器的被动/主动再也放不出来, 且不报错。
#   ⇒ 上线时按"我名下还有没有威霆术阵 marker"重建这把锁。
# 【为什么不是无条件清零】术阵可能还没到期 —— 无条件清零会让人能再开一个。
# ============================================================
scoreboard players set @s zx.tc_on 0
data modify storage zx:work jc.u0 set from entity @s UUID[0]
data modify storage zx:work jc.u1 set from entity @s UUID[1]
data modify storage zx:work jc.u2 set from entity @s UUID[2]
data modify storage zx:work jc.u3 set from entity @s UUID[3]
function sweetdream:equipment/axe/thunderclap/join_scan with storage zx:work jc
