# ============================================================
# sweetdream:equipment/axe/anchor/cast —— 沉锚 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/anchor(consume_item) -> rewards
# 【主动原文(必须和这里对上)】
#   魔力 200 / 冷却 12 秒。
#   "向自身10格内的准星上的目标掷出沉锚并位移到目标位置，之后对其2格内的生物造成
#    相当于释放者基础攻击力*5的伤害并击飞2格。"
# 【四要素】① 触发 = 右键; ② 范围 = 10 格内**准星上的那个**目标 -> 落点在其 2 格内;
#   ③ 次数 = 1; ④ 时长 = —(瞬发)。
# 【怎么找"准星上的目标"】anchored eyes + 每 0.5 格一步的**递归射线**(照 cold_crow/step):
#   从眼睛出发沿视线一步 0.5 格, 第一个被判定箱(dx/dy/dz)碰到的生物就是它。10 格 = 20 步。
# 【★ 找不到目标就整个不放 ★】不扣蓝、不进冷却(同 tidemark 的"前方没有目标")。
# 【位移怎么落】★ 2026-10-12 用户拍板: 拉近**要有过程**, 不要瞬移 ——
#   cast 只把 zx.an_pull 设成 22(刻), 之后每刻由 core/tick -> pull_tick 把自己朝目标
#   拉 0.5 格(撞墙就不动), 直到贴上(1.8 格内)/目标消失/刻数用完 -> pull_end 就地结算 impact。
#   (旧版是 here 直接 tp 1.5 格 = 瞬移, 已删。)
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/anchor
execute if score @s zx.an_pull matches 1.. run return 0

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 沿准星探 10 格, 探到就打 zx.an_tgt
tag @e[tag=zx.an_tgt] remove zx.an_tgt
scoreboard players set #an_st zx.meta 0
execute anchored eyes run function sweetdream:equipment/axe/anchor/ray
execute unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run tellraw @s [{"text":"准星 10 格内没有目标","color":"red"}]
execute unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anchor",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"沉锚冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 12 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anchor",cooldown_seconds:12.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 掷锚表现(起点)
execute at @s run playsound minecraft:item.trident.throw player @a ~ ~ ~ 1.0 1.0
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.3 0.3 0.3 0.05 10 normal

# ⑦ 掷出锚: 目标已在 ② 打上 zx.an_tgt, 这里只**启动"牵引"状态** ——
#   之后每刻由 core/tick -> anchor/pull_tick 把自己朝目标拉 0.5 格。
#   ★ 用户 2026-10-12 拍板: "拉近要有过程, 而不是瞬移"。
#   ★ 为什么不在 cast 里连写几条 tp: 同一个函数里的命令都在**同一刻**执行, 连写 N 条仍是瞬移;
#     要"有过程"必须跨刻 —— 这就是 zx.an_pull 存在的理由。
#   ★ 22 刻 = 1.1 秒: 最远 10 格的目标(0.5 格/刻 = 20 刻)也能拉到位; 贴到 1.8 格内会提前停。
scoreboard players set @s zx.an_pull 22
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.6 1.4

# ⑧ 结算 + ⑨ 收尾: 都挪到"牵引停下那一刻"(anchor/pull_end) —— 停下才炸, 时序才对着。

# 成功施法后记录本人目标并生成真正离手飞锚。
function sweetdream:equipment/axe/anchor/visual/start
