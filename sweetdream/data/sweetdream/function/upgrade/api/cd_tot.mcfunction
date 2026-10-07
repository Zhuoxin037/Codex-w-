# ============================================================
# sweetdream:upgrade/api/cd_tot —— 读某技能**本次冷却的总时长**(宏 {uuid, skill})
# ------------------------------------------------------------
# 【入参】zx:work cq {uuid, skill}
# 【出参】#cd_tot = 该技能本次冷却的总 tick(cooldowns.<skill>.total);
#         没在冷却 / 没这条记录 = 0。
# 【为什么不用 api/cooldown/get】那个只给"剩余"(remaining) —— 而冷却剂·Ω 的
#   判据是"这个技能的冷却时间大于 30 秒", 说的是**时长本身**, 不是还剩多少。
#   剩余会随时间变小, 拿它判会导致冷却后半段突然失效。
# 【为什么是宏】路径里有 uuid 与 skill 两个变量, 只能拼文本。
# ============================================================

scoreboard players set #cd_tot zx.meta 0
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)".total store result score #cd_tot zx.meta run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".total
