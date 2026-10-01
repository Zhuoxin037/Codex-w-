# ============================================================
# sweetdream:lib/mark_consume —— 统一的“消耗通用标签”入口
# ------------------------------------------------------------
# 【入参】zx:work a = {target:"选择器", mark:"yuanhai|liuhuo|yehuo|shixin|dream"}
# 【做什么】① 摘掉目标身上的通用标签（图标一起收）
#          ② 如果执行者穿着「余烬」: 流火回 50 魔力+力量2; 夜火回 100+力量5
# 【为什么要有这一层】以前“摘标签”直接调 tag/unmark, 装备被动就不知道
#   谁被消耗了。以后所有会消耗通用标签的技能都改成调这里:
#     data modify storage zx:work a set value {target:"...",mark:"yehuo"}
#     function sweetdream:lib/mark_consume
#   这样余烬/未来“消耗流火/夜火”的装备只需要读同一个入口, 不用改每把武器。
# 【★ 旧版有个真实 bug ★】旧版调用 manacore:api/mana/add 时写的是
#   `with storage zx:work em.mana50`, 但 api/mana/add 不是宏函数 ——
#   它只读 manacore:in arg! 所以魔力回复从来没生效。现在改成标准写法:
#   先写 manacore:in arg, 再正常调用 api。
# ============================================================

# ① 冻结参数, 摘标签（不管有没有余烬都要把标签消耗掉）
data modify storage zx:work ic.target set from storage zx:work a.target
data modify storage zx:work ic.mark set from storage zx:work a.mark
function sweetdream:tag/unmark with storage zx:work ic

# ② 拿执行者自己的 uuid（写魔力面板要用）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ③ 余烬被动: 流火=回50+力量2
execute if data storage zx:work a{mark:"liuhuo"} run data modify storage manacore:in arg set value {uuid:"",value:50.0}
execute if data storage zx:work a{mark:"liuhuo"} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:work a{mark:"liuhuo"} run function manacore:api/mana/add
execute if data storage zx:work a{mark:"liuhuo"} run effect give @s minecraft:strength 5 1 true

# ④ 余烬被动: 夜火=回100+力量5
execute if data storage zx:work a{mark:"yehuo"} run data modify storage manacore:in arg set value {uuid:"",value:100.0}
execute if data storage zx:work a{mark:"yehuo"} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:work a{mark:"yehuo"} run function manacore:api/mana/add
execute if data storage zx:work a{mark:"yehuo"} run effect give @s minecraft:strength 5 4 true
