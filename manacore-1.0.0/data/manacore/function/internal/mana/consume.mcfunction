# ------------------------------------------------------------
# internal/mana/consume —— 魔力消耗判定(技能前置检查的核心)
# 【宏参数】manacore:work.a {uuid,value}
# 【出参】out.success = 1b(够, 且已扣除) / 0b(不够, 什么都没扣)
#         out.reason  = "ok" / "mana"
# 【逻辑】#cur >= #need ? consume_ok : consume_fail
# 【关键点】"不够就不扣"——所以只要看到 out.success=0b, 调用方就应该
#         直接中断技能, 不会出现"扣了魔力却没放出技能"的情况。
# 【技能流程里的位置】api/skill/cast 第 2 步。
# ------------------------------------------------------------
execute store result score #need manacore.math run data get storage manacore:work a.value 1000
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
execute if score #cur manacore.math >= #need manacore.math run function manacore:internal/mana/consume_ok with storage manacore:work a
execute if score #cur manacore.math < #need manacore.math run function manacore:internal/mana/consume_fail
