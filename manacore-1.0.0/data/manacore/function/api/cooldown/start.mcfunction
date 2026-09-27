# ============================================================
# api/cooldown/start —— 让某个技能进入冷却
# ------------------------------------------------------------
# 【调用模板】
#   tick 级: data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball", cooldown:40}
#   秒  级: data modify storage manacore:in arg set value {uuid:"<UUID>", skill:"fireball", cooldown_seconds:2.0}
#   不吃缩减: 再加 reduce:0b
#   function manacore:api/cooldown/start
# 【字段】
#   skill           : 技能唯一 id(冷却就是按这个键存的)
#   cooldown        : tick 冷却, 优先使用
#   cooldown_seconds: 秒冷却, cooldown<=0 时生效
#   reduce          : 是否吃玩家的"冷却缩减"属性, 默认 1b
# 【注意】直接调用它是"强制进入冷却"; 正常的技能释放请用 api/skill/cast,
#   它会自动在释放成功后开始冷却。
# 【重复调用】会覆盖旧记录, 也就是"刷新冷却时间"。
# ============================================================
data modify storage manacore:work a set value {uuid:"",cooldown:0,cooldown_seconds:0.0,reduce:1b}
data modify storage manacore:work a merge from storage manacore:in arg
function manacore:api/player/ensure
execute if data storage manacore:work a.skill run function manacore:internal/cooldown/start with storage manacore:work a
