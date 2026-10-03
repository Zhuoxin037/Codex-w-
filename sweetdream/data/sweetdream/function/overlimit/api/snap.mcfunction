# ============================================================
# sweetdream:overlimit/api/snap —— 施法那一刻把超限乘区"拍"到玩家身上
# ------------------------------------------------------------
# 【谁调用它】武器的施法 / 普攻入口(拿完 uuid 之后立刻一次):
#   liaoyuan/cast  ·  wind_ontheground/attack  ·  wind_ontheground/skill
#
# 【★ 为什么要快照, 而不是每次现读主手 ★】
#   燎原的光环、风行的 3 轮爆发 / 20 秒回响都是**施法之后**才结算的
#   (由 event/second 驱动), 那时候玩家很可能已经换手 / 换武器了 ——
#   现读主手会读到"现在的武器"(甚至根本没武器), 乘区凭空消失。
#   所以: 施法瞬间拍一张快照, 整段技能都用它。
#
# 【出参】@s 的三个计分项(整数百分比):
#   zx.ol_d = 伤害 +N%   zx.ol_m = 耗蓝 +N%   zx.ol_c = 冷却 +N%
#   没超限 = 三个都是 0(和"读不到"同一个结果, 不用额外记 has)。
#   计分项在 core/load 里注册。
# ============================================================

scoreboard players set @s zx.ol_d 0
scoreboard players set @s zx.ol_m 0
scoreboard players set @s zx.ol_c 0

function sweetdream:overlimit/api/bonus_held
execute unless data storage zx:out r{has:1b} run return 0

execute store result score @s zx.ol_d run data get storage zx:out r.dmg 100
execute store result score @s zx.ol_m run data get storage zx:out r.mana 100
execute store result score @s zx.ol_c run data get storage zx:out r.cd 100
