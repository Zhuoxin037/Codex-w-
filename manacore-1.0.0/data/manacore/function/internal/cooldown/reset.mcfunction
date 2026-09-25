# ------------------------------------------------------------
# internal/cooldown/reset —— 重置单个技能冷却
# 【宏参数】manacore:work.a {uuid,skill}
# 【做法】直接删掉该技能在 cooldowns 里的键 —— 也就是"立刻可用"。
# 【用途】技能冷却重置道具 / 大招刷新。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns."$(skill)" run data remove storage manacore:players "$(uuid)".cooldowns."$(skill)"
