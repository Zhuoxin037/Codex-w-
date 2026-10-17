# ============================================================
# sweetdream:equipment/axe/death_bell/cast —— 丧铃 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/death_bell(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能   魔力 130 · 冷却 35 秒
#   "使用后向前方 4 格内重击，对范围内全部生物造成一次相当于自身最大魔力值 ×0.1 的
#    伤害。若命中了附有「白昼梦」的生物，则消耗其中最近一个生物的「白昼梦」，之后对其
#    4 格内最多 5 个其他生物释放两次钟声，每次都会造成相当于自身最大魔力值 ×0.08 的
#    伤害并使其获得 3 秒虚弱Ⅱ。若钟声影响了至少 5 个生物，则返还自身 80 魔力值并减少
#    10 秒冷却时间。"
# 【★ 四要素 ★】
#   ① 触发: 右键。
#   ② 范围: "前方 4 格内" -> area(采样球, 完全跟随朝向);
#      "其 4 格内最多 5 个其他生物" -> dom_one ⑤(以被清白昼梦的那只为中心, nearest 5)。
#   ③ 次数: 重击一段全体; 钟声**两次**(dom_one ⑦⑧ 调两次 bell_once)。
#   ④ 时长: 虚弱Ⅱ 3 秒 —— 原版 effect, 不留任何 marker/计分项。
# 【★ 通道 ★】重击 ×0.1 / 钟声 ×0.08, 全是 mm
#   ⇒ lib/skill_mul/def 里必须登记 wchan.death_bell = {mm:1b,...}。
# 【★ 2026-10-17 用户拍板 ★】"钟声影响了至少 5 个生物" = **两次钟声的命中次数合计 ≥5**
#   (同一只被两次钟声都打到算 2 次)。实现: bell_once 每命中一只就给 #dbl_n +1,
#   dom_one ⑨ 判 `#dbl_n >= 5` -> 返 80 魔力 + 冷却 -200 刻。
# 【数值改哪】130/35 = ②/⑤; 0.1 = ⑥; 4 格 = area 的两个球心; 0.08 = dom_one ⑥;
#   5 个 = dom_one ⑤ 的 limit; 80 魔力 = ⑨; 10 秒 = ⑨ 的 ticks:200; 3 秒虚弱Ⅱ = bell_once。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/death_bell

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 130
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:death_bell",mana:130.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"丧铃冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 130）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有没有目标? 一个都没有就整个不放
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run return fail

# ④ 扣魔力 -130
data modify storage manacore:in arg set value {uuid:"",value:130.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:death_bell",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 重击伤害 = 自身最大魔力值 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work dbl.dmg set from storage manacore:out r.damage

# ⑦ 框"前方 4 格" + 打重击(命中者钉成 zx.dbl_hit)
function sweetdream:equipment/axe/death_bell/area

# ⑧ 从命中者里挑**最近的一个**带「白昼梦」的
#   ★ 原文"消耗其中最近一个生物的「白昼梦」" —— 明写"最近一个", 只取 1 只。
tag @e[tag=zx.dbl_src,distance=0..] remove zx.dbl_src
execute as @e[type=!#sweetdream:no_damage,tag=zx.dbl_hit,distance=0..,tag=zx.status.dream,sort=nearest,limit=1] run tag @s add zx.dbl_src
execute if entity @e[tag=zx.dbl_src,distance=0..] run function sweetdream:equipment/axe/death_bell/dom_one

# ⑨ 清理本轮标记(必须在 dom_one 之后)
tag @e[tag=zx.dbl_hit,distance=0..] remove zx.dbl_hit
tag @e[tag=zx.dbl_src,distance=0..] remove zx.dbl_src

# ⑩ 表现: 斧刃砸地的一记闷响
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:cloud ~ ~0.2 ~ 1.4 0.2 1.4 0.04 20 normal
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:soul ~ ~0.4 ~ 1.0 0.4 1.0 0.02 12 normal
playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.8 1.4
playsound minecraft:block.bell.use player @a ~ ~ ~ 0.6 1.0
