# ============================================================
# sweetdream:equipment/staff/five_curses/skill —— 五世恶咒: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 600 魔力 / 冷却 120 秒。
#   对自身 12 格内所有**至少拥有一层**「世咒」的生物立即**推进至下一世**;
#   已处于第五世的目标不会推进, 而是**立即结算终世**, 且比例由 30% 提高到 **80%**。
#   若因此击杀一个生物, 则返还 50 魔力, **每次技能最多返还 300 魔力**(即 6 个)。
# 【超限·五世恶咒(2026-10-23 批 K9)】魔力 600→**650**、冷却 120→**100 秒**;
#   推进时**强化下一世的效果**(二世 Ⅳ→Ⅴ、三世 +20%→+40%、四世 -80%→**清零**、
#   五世记录窗口 12→**15 秒**); 已在第五世者立即结算, 比例 80%→**100%**;
#   击杀返还 50→**60**(仍是"最多 6 个" ⇒ 上限 300→**360**)。
#   分档表见 ol_tier(那里有"未超限 / 超限普攻 / 超限主动"三档的完整对照)。
# 【★ 顺序: 先结算第五世, 再推进其余 ★】
#   第五世被 final 结算后 fcv_st 会归 0(clear 里清的) —— 于是紧接着那条
#   "1..4 世推进"的选择器就**不会再选中它**。反过来先推进就会把第五世又推一遍
#   (钳位到 5, 白跑), 而且它已经被结算、清掉了, 会被重新上咒。
# 【★ 为什么用标签 zx.fcv_tar 先圈人 ★】"12 格内有世咒"这个集合要在**改状态之前**
#   定下来(坑 123 同族: 按当前状态选人的选择器, 不能在改了同一状态之后再求值)。
#   推进之后 fcv_st 变了, 再选就选不到原来那批了。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/five_curses

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ⓪.5 超限判定(批 K9): 主/副手任一件是超限·五世恶咒就走强化档
#   ★ 只认 `ol:"five_curses"` 这个**值**(不能只判 ol 键在不在)。
scoreboard players set #fcv_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"],ol:"five_curses"}] run scoreboard players set #fcv_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"],ol:"five_curses"}] run scoreboard players set #fcv_ol zx.meta 1
#   「这一刀是主动推进的」—— 给 curse_step / ol_tier 用(主动档比普攻档更狠)
scoreboard players set #fcv_skl zx.meta 1

# ② 只读检查: 冷却 + 魔力(原版 600 / 超限 650)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:five_curses",mana:600.0}
execute if score #fcv_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 650.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"五世恶咒冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score #fcv_ol zx.meta matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 600）","color":"red"}]
execute if score #fcv_ol zx.meta matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 650）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力(600 / 650)
data modify storage manacore:in arg set value {uuid:"",value:600.0}
execute if score #fcv_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 650.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if score #fcv_ol zx.meta matches 0 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 600）","color":"red"}]
execute if score #fcv_ol zx.meta matches 1 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 650）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却(原版 120 秒 / 超限 100 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:five_curses",cooldown_seconds:120.0,reduce:1b}
execute if score #fcv_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 100.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 圈人: 12 格内**至少一层**世咒的生物(★ 必须在改状态之前圈)
tag @e[tag=zx.fcv_tar] remove zx.fcv_tar
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..12,scores={zx.fcv_st=1..}] add zx.fcv_tar

# ⑤.5 先记下"这批里现在有几只"(击杀数 = 结算前 − 结算后, 理由见 ⑨)
scoreboard players set #fcv_alive0 zx.meta 0
execute as @e[tag=zx.fcv_tar] run scoreboard players add #fcv_alive0 zx.meta 1

# ⑥ 表现: 一圈诅咒扩散
execute at @s run particle minecraft:soul ~ ~1 ~ 1.2 0.8 1.2 0.02 40 normal

# ⑦ 先把第五世的按 **80%**(超限 100%)结算终世
#   ★ 比例现在写进**目标身上**的 zx.fcv_pct(final 读它), 不再用全局假名 #fcv_pct ——
#     见 final 头注释: 全局假名会被"同一刻别的调用"串味, 而且自然到期那条路读不到。
scoreboard players set #fcv_pct zx.meta 80
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_pct zx.meta 100
execute as @e[tag=zx.fcv_tar,scores={zx.fcv_st=5}] run scoreboard players operation @s zx.fcv_pct = #fcv_pct zx.meta
execute as @e[tag=zx.fcv_tar,scores={zx.fcv_st=5}] at @s run function sweetdream:equipment/staff/five_curses/final

# ⑧ 其余 1..4 世: 推进一世(施法者 uuid 先搬进 storage, curse_step 要抄到目标身上)
execute store result storage zx:work fcv.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work fcv.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work fcv.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work fcv.u3 int 1 run data get entity @s UUID[3]
execute as @e[tag=zx.fcv_tar,scores={zx.fcv_st=1..4}] at @s run function sweetdream:equipment/staff/five_curses/curse_step

# ⑨ 击杀返还: 数死了几只 → ×50(超限 ×60)魔力, 上限 300(超限 360 = 仍是"最多 6 个")
#   ★★ 不能"逐只判死没死" ★★ 被终世打死的实体在这一刻**已经从世界里移除**了,
#     `@e[tag=zx.fcv_tar]` **选不到它**(坑 134/135: @e 正向判死恒空, MC-108307)
#     ⇒ 老写法(逐只读 Health 判死)永远数到 0, "击杀返还 50 魔力"一次都不会触发。
#     改成"结算前后各数一次存活数, 取差值": 活着的还带着标签、选得到, 差值就是死的那几只。
scoreboard players set #fcv_alive1 zx.meta 0
execute as @e[tag=zx.fcv_tar] run scoreboard players add #fcv_alive1 zx.meta 1
scoreboard players operation #fcv_kill zx.meta = #fcv_alive0 zx.meta
scoreboard players operation #fcv_kill zx.meta -= #fcv_alive1 zx.meta
#   ×50: 先 ×100 再 ÷2(计分项没有 ×0.5, 也没有小数常数); 超限档是 ×60 ⇒ ×120 ÷2
scoreboard players set #fcv_km zx.meta 100
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_km zx.meta 120
scoreboard players operation #fcv_kill zx.meta *= #fcv_km zx.meta
scoreboard players operation #fcv_kill zx.meta /= #2 zx.meta
execute if score #fcv_kill zx.meta matches 300.. if score #fcv_ol zx.meta matches 0 run scoreboard players set #fcv_kill zx.meta 300
execute if score #fcv_kill zx.meta matches 360.. run scoreboard players set #fcv_kill zx.meta 360
execute if score #fcv_kill zx.meta matches 1.. run function sweetdream:equipment/staff/five_curses/refund

# ⑩ 收尾
tag @e[tag=zx.fcv_tar] remove zx.fcv_tar

# 用户授权的猴头模型动效；不改变上述原技能的数值与执行顺序。
function sweetdream:equipment/staff/five_curses/visual/begin_skill
