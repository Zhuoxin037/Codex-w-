# ============================================================
# internal/skill/cast —— 统一技能流程(状态机)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,skill,...}(完整技能参数, 见 api/skill/cast)
# 【顺序】
#   ① cooldown/check  : 冷却中?  -> fail_cooldown(直接中断)
#   ② stage_mana      : 扣魔力 -> 不够就 fail_mana(直接中断)
#   ③ go              : 开始冷却 -> 计算伤害 -> 施加伤害 -> 抛技能事件
# 【为什么用 out.success / out.ready 当状态】命令没有 if/else 结构,
#   最稳妥的做法是把判断结果写进存储, 再用 execute if data ... run 分派。
#   这样每个阶段只关心一个布尔结果, 逻辑极清晰且不会"穿过"错误分支。
# 【需求覆盖】
#   "冷却期间禁止技能再次释放" -> 第 ① 步
#   "技能释放成功后开始冷却"   -> 第 ③ 步的第一步(失败时根本不会进 go)
# ============================================================
function manacore:internal/cooldown/check with storage manacore:work a
execute if data storage manacore:out r{ready:0b} run function manacore:internal/skill/fail_cooldown with storage manacore:work a
execute if data storage manacore:out r{ready:1b} run function manacore:internal/skill/stage_mana with storage manacore:work a
