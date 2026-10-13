# ============================================================
# sweetdream:equipment/bow/arc/shot —— 每次射击(电弧)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/arc(触发器 shot_crossbow)。
# 【★ 这个文件是补的(2026-10-12)★】电弧原先**只有**附魔回调(hook_arrow /
#   hook_attacker / hook_victim), 完全没有"射击"这一环 —— 于是 lore 上写的
#   「魔力 30」**从来没被扣过**(用户实测: 发射不消耗魔力)。
#   其余 5 把弩(寒鸦/蚀骨/幽匿残响/清醒梦/彩虹)都是"射击进度 -> shot -> 扣蓝",
#   电弧漏了这一套, 属实现遗漏, 不是数值问题。
# 【文案(lore 逐字)】"✦ 主动技能 · 魔力 30 —— 每次射击都会对被攻击的生物附加
#   「电刺」效果。..."
#   ⇒ 扣蓝发生在**离弦那一刻**(射击触发), 与其余弩同一口径:
#     没射中也要付钱; 没蓝 -> 这一发不附加「电刺」(提示一句)。
# 【为什么要给**箭**打标记】电弧的效果由附魔回调在"箭命中"时才跑, 那时手里拿的
#   未必还是这把弩 —— 所以"这一发到底付没付钱"必须写在**箭自己**身上。
#   shot 给刚射出的箭打 zx.arc_ok, hook_arrow 只认带这个标记的箭。
# 【★ 怎么认出"刚射出的那支箭"★】core/tick 每刻开头给场上**已有**的箭都打
#   zx.cc_seen(见 core/tick 那一节)。本函数在这一刻跑, 所以"没有 zx.cc_seen
#   且在射手 4 格内"的 cc_arrow 就是刚离弦的那些(多重射击的 3 支一起抓)。
#   这套写法与寒鸦/蚀骨/幽匿残响完全一致, 别自己另发明。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/arc
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪ 快照"手里这把是不是超限版"(1/0) —— 命中回调落在**受害者那一侧**, 那里拿不到
#    射手的主手, 所以离弦时拍一次, hook_victim 按它分流(同 sd_ol / hd_ol / sb_ol)。
function sweetdream:equipment/bow/arc/is_ol
execute if score #arc_ol zx.meta matches 1.. run scoreboard players set @s zx.arc_ol 1
execute unless score #arc_ol zx.meta matches 1.. run scoreboard players set @s zx.arc_ol 0

# ① 扣魔力(固定 30 —— 与 lore 的「魔力 30」逐字对应)
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume

# ② 魔力不足 -> 这一发不附加「电刺」: 箭不打 zx.arc_ok, hook_arrow 自然就不会
#    给 zx.arc_arr 打标 -> hook_victim 开头那句门控直接收工。
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭无法附加「电刺」","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 给刚射出的箭打"已付钱"标记(zx.arc_ok 只用于本次命中判定)
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run tag @s add zx.arc_ok

# ④ 「启示录」记页(幽匿残响等同款; 电弧同样固定扣 30)
function sweetdream:equipment/staff/apocalypse/spend
