# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark —— 击杀带通用标签的怪: 补 100×X
# ------------------------------------------------------------
# 【谁调用它】5 个 wrapper(equipment/armor/dusk_dawn/kill_mark_<tag>), 它们各自由
#   一条**同名进度**触发(advancement/equipment/armor/dusk_dawn_kill_mark_<tag>.json)。
#   **死者的 Tags 里有几个通用标签, 就有几条进度同刻触发 ⇒ 本函数同刻被调用几次
#   ⇒ 天然实现"100×X"(X = 死者身上的效果数量)。**
# 【★★ 2026-10-12 重写(坑 138, 用户实测: 打一只「流火+夜火」的怪只加了 300)★★】
#   旧版走的是一条**从根上就不工作**的路: 新增 `enchantment/dusk_dawn.json`
#   (post_attack, affected:victim), 想让回调函数"就地数死者的标签"。
#   但**原版 post_attack 只读「攻击者的主手物品」上的附魔** —— 附魔却挂在
#   **靴子**(slots:feet)上 ⇒ 永不触发 ⇒ 回调零调用 ⇒ X 恒用兜底值 1
#   ⇒ 超限版"额外 100×X"永远只给 100(本该 400)。见圣骸的同款注释
#   (equipment/axe/sacred_relic/watch: "原版 post_attack 读取攻击者的主手物品")。
#   正解 = **不用附魔**: "数死者标签"这件事交给**进度的条件** —— 进度的
#   `conditions.entity`(角色 this = 被杀死的实体)本来就在**死者**上求值, 读 Tags
#   不受 MC-108307 的 isAlive 限制(现行进度一直这么写、也一直能触发)。
#   再用"一个标签一条进度"把"计数"变成"函数被调用几次" ⇒ 不需要任何附魔/回调。
# 【★ revoke 在各自的 wrapper 里 ★】自撤销型奖励函数的"首行 revoke 自己那条"
#   由 kill_mark_<tag> 负责(见 lib/rearm、check.py 的 selfrev 规则):
#   共享函数不知道自己是被哪条进度调的, 所以 revoke 必须落在各自的入口上。
# 【★ 与"基础 +200"那条进度顺序无关 ★】dusk_dawn_kill(→ kill) 与本函数同刻触发,
#   谁先谁后都行: 同刻账本只清一次(kill_init 的 dd_know 去重), 本函数再按
#   `@s zx.dd_n`(本刻进来的第几次)决定加多少。
# ============================================================

execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return fail
function sweetdream:equipment/armor/dusk_dawn/is_ol

# 同一次击杀的账本(t1/t2/dd_n)只清一次 —— 第一次进来时清, 后面几次直接跳过
function sweetdream:equipment/armor/dusk_dawn/kill_init
# 本刻第几次进来 = 死者身上第几个通用标签
scoreboard players add @s zx.dd_n 1

# 基础版: "额外 100"(不管死者有几个标签) -> 同一次击杀只加一次
execute unless score #dd_ol zx.meta matches 1 if score @s zx.dd_n matches 1 run scoreboard players set @s zx.dd_t2 100
# 超限版: 100×X -> 死者有几个标签本函数就被调几次, 每次 +100
execute if score #dd_ol zx.meta matches 1 run scoreboard players add @s zx.dd_t2 100

function sweetdream:equipment/armor/dusk_dawn/temp_apply
