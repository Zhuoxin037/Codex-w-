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

# ⓪.5 超限·沉锚(2026-10-23 批 K6): "4 秒内可以再次使用技能并回到原处"
#   ★ 用假玩家 #anc_bk 拍快照再判 —— ol_back 会把 zx.anc_back 清 0,
#     直接 `if score @s zx.anc_back matches 1.. run ...` 之后那行会永远不成立。
scoreboard players set #anc_bk zx.meta 0
execute if score @s zx.anc_back matches 1.. run scoreboard players set #anc_bk zx.meta 1
execute if score #anc_bk zx.meta matches 1 run function sweetdream:equipment/axe/anchor/ol_back
execute if score #anc_bk zx.meta matches 1 run return 0

# ⓪.6 这一次是不是超限版(亲手/副手那把带 ol:"anchor")
scoreboard players set #anc_ol zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{ol:"anchor"}] run scoreboard players set #anc_ol zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{ol:"anchor"}] run scoreboard players set #anc_ol zx.meta 1
scoreboard players operation @s zx.anc_ol = #anc_ol zx.meta

# ⓪.7 射程: 普通 10 格(20 步 × 0.5) / 超限 12 格(24 步)
scoreboard players set #an_max zx.meta 20
execute if score #anc_ol zx.meta matches 1 run scoreboard players set #an_max zx.meta 24

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 沿准星探 10 格, 探到就打 zx.an_tgt
tag @e[tag=zx.an_tgt] remove zx.an_tgt
scoreboard players set #an_st zx.meta 0
execute anchored eyes run function sweetdream:equipment/axe/anchor/ray
execute if score #anc_ol zx.meta matches 0 unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run tellraw @s [{"text":"准星 10 格内没有目标","color":"red"}]
execute if score #anc_ol zx.meta matches 1 unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run tellraw @s [{"text":"准星 12 格内没有目标","color":"red"}]
execute unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run return fail

# ②.5 【★ 给这一发的目标钉"锁定"标签 zx.an_lock ★】(2026-10-23 卡顿修复)
#   【为什么】牵引(pull_tick)与飞锚(visual/flight)每刻都要再找一次"这一发的那只"。
#     原来写的是 `@e[nbt={UUID:[I;$(t0),...]}]` —— 那是**逐个实体整份 NBT 序列化**,
#     每刻 6~9 次; 一次沉锚 ≈ 90 次 × 数毫秒 = 肉眼可见的"人卡住、几秒后哗一下结算"。
#     换成标签之后只剩一次集合过滤, **零 NBT**(同思路见 lib/u_by / internal/damage/who)。
#   【认人】zx.an_own = 施法者 UUID 的第 0 个 int(从 manacore.u0 直接搬, 不读 NBT);
#     下游一律写 `@e[tag=zx.an_lock,scores={zx.an_own=$(u0)}]` —— 两个人同时掷锚
#     锁定不同的怪也不会互相抢。
#   【先清自己的旧锁】上一发还没走完(连按 / 被取消)时, 旧目标身上还挂着我的锁。
scoreboard players set #anc_u zx.meta 0
scoreboard players operation #anc_u zx.meta = @s manacore.u0
execute as @e[tag=zx.an_lock] if score @s zx.an_own = #anc_u zx.meta run tag @s remove zx.an_lock
execute as @e[tag=zx.an_tgt,distance=0..,limit=1] run scoreboard players operation @s zx.an_own = #anc_u zx.meta
tag @e[tag=zx.an_tgt,distance=0..,limit=1] add zx.an_lock

# ③ 只读检查: 冷却 + 魔力 200 / 超限 320
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:anchor",mana:200.0}
execute if score #anc_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 320.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"沉锚冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score #anc_ol zx.meta matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute if score #anc_ol zx.meta matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 320）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 200 / 超限 320
data modify storage manacore:in arg set value {uuid:"",value:200.0}
execute if score #anc_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 320.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
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
#   ★ 超限射程 12 格 = 24 步, 给 26 刻。
scoreboard players set @s zx.an_pull 22
execute if score #anc_ol zx.meta matches 1 run scoreboard players set @s zx.an_pull 26
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.6 1.4

# ⑦.5 超限·沉锚: 在**原处**钉一个锚点 marker, 4 秒后自动消失 —— 供"回到原处"用。
#   ★ 为什么不把坐标存 NBT 再 `tp @s $(x) $(y) $(z)`: 宏替换出来的 double 会带 `d` 后缀
#     (如 `12.0d`), 而 tp 的坐标参数不认那个后缀 ⇒ 整条命令解析失败、静默不传送。
#     钉一个 marker 就没有格式化问题(`execute at <marker> run tp @s ~ ~ ~`)。
#   ★ 计时用计分项 zx.anc_bt(marker 身上), lib/second 每秒 -1, 归零 kill。
#   ★ 先清掉自己上一轮还没消失的锚点(否则两个, "回到原处"会跳回更早那次)。
execute if score #anc_ol zx.meta matches 1 run scoreboard players operation #anc_u zx.meta = @s manacore.u0
execute if score #anc_ol zx.meta matches 1 as @e[type=marker,tag=zx.anc_org,distance=0..] if score @s zx.anc_own = #anc_u zx.meta run kill @s
execute if score #anc_ol zx.meta matches 1 at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.anc_org"]}
execute if score #anc_ol zx.meta matches 1 at @s as @e[type=marker,tag=zx.anc_org,distance=..1,limit=1] run scoreboard players operation @s zx.anc_own = #anc_u zx.meta
execute if score #anc_ol zx.meta matches 1 at @s as @e[type=marker,tag=zx.anc_org,distance=..1,limit=1] run scoreboard players set @s zx.anc_bt 4
execute if score #anc_ol zx.meta matches 1 run scoreboard players set @s zx.anc_back 4

# ⑧ 结算 + ⑨ 收尾: 都挪到"牵引停下那一刻"(anchor/pull_end) —— 停下才炸, 时序才对着。

# 成功施法后记录本人目标并生成真正离手飞锚。
function sweetdream:equipment/axe/anchor/visual/start
