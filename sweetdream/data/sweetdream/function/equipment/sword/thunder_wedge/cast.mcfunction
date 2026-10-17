# ============================================================
# sweetdream:equipment/sword/thunder_wedge/cast —— 雷楔 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/thunder_wedge(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能  魔力 300 · 冷却 60 秒
#   "使用后召唤 1 个术阵，并在自身位置召唤一个持续 8 秒的“雷楔”。
#    同一使用者同时只能存在一个。"
#   ✦ 雷楔
#   "使用者攻击了“雷楔”8 格内的生物后，“雷楔”对命中位置释放一次闪电，
#    对其 1 格内的生物造成一次相当于使用者基础攻击力 ×2 的伤害，每秒最多触发一次。"
# 【★ 四要素逐个落实 ★】
#   ① 触发 = 右键(剑没有潜行分派, 与神裁 / 退汐等剑一致: cast 就是技能本体)。
#   ② 位置 = **自身位置**(不是准星) -> 就是 `execute at @s`。
#   ③ 次数 = 主动一次; "雷楔"召唤物 8 秒内可反复响应平A命中(每次 1 道雷, 每秒最多一次)。
#   ④ 时长 = 8 秒(marker 上 zx.twg_ft = 8, lib/second 每秒 -1, 归零 wedge_end)。
# 【"召唤 1 个术阵" = 登记 + 标记两手都要】
#   框架里的术阵(id/type/duration_seconds)让"术阵 n/上限"、术阵上限、看术阵行事的
#   装备认得出它; 但它**不存位置** —— "雷楔 8 格内"的判定必须有个圆心, 那就是下面
#   生成的 marker(也就是文案里那个"雷楔"本身): 它同时当召唤物和术阵的落点。
#   (和威霆术阵 / 重溟深池 / 长夜夜原 / 迟庭审庭同一套做法)
# 【为什么 duration_seconds 是 8.0 不是 0.0】0.0 = **永久术阵**(坑 46), 会白占槽位。
# 【为什么不预先查 can_create】文案只写了"召唤 1 个术阵", 没有"术阵位不足就不放"。
#   框架 create 失败(reason=formation_limit)时技能照常生效(判定只看 marker)。
# 【"同一使用者同时只能存在一个"怎么落实】先把**自己**那只旧的收掉(三维度各扫一遍,
#   因为玩家可能换维度了), 再召唤新的。判"是不是自己的"靠 marker 上的计分项
#   zx.twg_own = 施法者 UUID[0](写时由 wedge_one 从 #twg_me 抄过去)。
# ============================================================

# ⓪ 撤销自己的进度(奖励函数第一行必须是 revoke)
advancement revoke @s only sweetdream:equipment/sword/thunder_wedge

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批武器一致; 本件无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 60 秒 + 魔力 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunder_wedge",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #twg_need zx.meta 0
execute store result score #twg_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"雷楔冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#twg_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 300(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#twg_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 60 秒(超限后 72 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunder_wedge",cooldown_seconds:60.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ 算"基础攻击力 ×2"(施放这刻算好, 之后换装/死亡都不影响这一只雷楔)
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑥ 备好宏参数(★ 必须赶在后面那些调用**写掉 manacore:out 之前**抄走 r.damage ★)
#   formation/create 与 cooldown 那两套都会往 manacore:out 里写自己的 r.*, 抄晚了就是
#   "伤害凭空变成 0"(静默, 没日志)。所以 damage 一算完立刻落到 zx:work twg。
#   【宏参数只能取键、不能取下标】(坑 129) ⇒ UUID 的四个整数先摊成 u0..u3。
data modify storage zx:work twg set value {dmg:0.0,uu:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work twg.dmg set from storage manacore:out r.damage
data modify storage zx:work twg.uu set from storage zx:data self.uuid
execute store result storage zx:work twg.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work twg.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work twg.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work twg.u3 int 1 run data get entity @s UUID[3]

# ⑦ 记下"我是谁" -> #twg_me(UUID[0]), 用来收掉自己那只旧雷楔
scoreboard players set #twg_me zx.meta 0
execute store result score #twg_me zx.meta run data get entity @s UUID[0]

# ⑧ "同一使用者同时只能存在一个": 把自己那只旧的直接收掉(连带它的术阵)
#   ★ 三维度各扫一遍 ★ 玩家可能在上一个维度放完就走了 —— 只扫当前维度会漏。
#     `execute in <维度>` 只换"选择器在哪个世界里找", @s 仍然是玩家。
#   ★ `distance=0..` 不能省 ★ 它是"锁定当前维度"的那把锁: 不写就是跨维度全搜,
#     "三维度各写一遍"会让同一只雷楔被收 3 次(wedge_end 连跑 3 次, 术阵删 3 次)。
execute in minecraft:overworld as @e[type=marker,tag=zx.twg_wedge,distance=0..] if score @s zx.twg_own = #twg_me zx.meta run function sweetdream:equipment/sword/thunder_wedge/wedge_end
execute in minecraft:the_nether as @e[type=marker,tag=zx.twg_wedge,distance=0..] if score @s zx.twg_own = #twg_me zx.meta run function sweetdream:equipment/sword/thunder_wedge/wedge_end
execute in minecraft:the_end as @e[type=marker,tag=zx.twg_wedge,distance=0..] if score @s zx.twg_own = #twg_me zx.meta run function sweetdream:equipment/sword/thunder_wedge/wedge_end

# ⑨ 在框架里登记一个真术阵(占 1 个术阵位; 8 秒后由 wedge_end 删掉)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:thunder_wedge",type:"wedgeyard",duration_seconds:8.0,data:{radius:8.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑩ 在**自身位置**召唤"雷楔"(marker 实体)
#   【为什么用 marker】它同时是三样东西: 术阵的位置锚点、"8 格内"判定的圆心、
#     8 秒计时的载体(zx.twg_ft)。纯 marker 不做外观(与神裁/崩裂/深池的领域一致)。
execute at @s run function sweetdream:equipment/sword/thunder_wedge/wedge_one with storage zx:work twg

# ⑪ 表现 + 提示
execute at @s run particle minecraft:electric_spark ~ ~1 ~ 0.4 0.9 0.4 0.15 45 normal
execute at @s run playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.8 0.7
tellraw @s [{"text":"雷楔: 术阵已展开（8 秒）","color":"gold"}]
