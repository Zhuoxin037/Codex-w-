# ============================================================
# sweetdream:equipment/sword/liaoyuan/cast —— 主动技能(右键)
# ------------------------------------------------------------
# 【文案】消耗 250 魔力 / 冷却 50 秒。
#   使用后自身获得「燎原」: 18 秒内每 2 秒对自身 5 格内的生物造成
#   "自身最大魔力值 ×0.04"的伤害; **每 2 次之后的下一 次**(也就是第 3、6、9 次)
#   额外给受到伤害的生物附加「流火」。
# 【实现】这一份只负责"检查 + 扣魔力 + 起冷却 + 开光环", 之后每秒由
#   #manacore:event/second -> second 推一次, 每 2 秒脉冲一次(见 pulse)。
# 【光环为什么用计分项】
#   zx.ly_aura   = 光环还剩几秒(0 = 收工)
#   zx.ly_timer  = 离下一次灼烧还有几秒(设成 2 -> 严格"施法后每 2 秒一次")
#   zx.ly_times  = 这次光环里已经灼烧了几次(用"次数"才能实现"第 3/6/9 次附加流火")
# 【★ 不用"全局秒号取余"了 ★】那样第一次灼烧可能在施法后 1 秒就到(取决于施法落在哪一秒),
#   节奏不规整、也不好数。改成每人自己一个 2 秒小计时器, 节奏就是死板的 2/4/6/8… 秒。
# ============================================================

# ⓪ 撤销自己的进度(不撤销的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/sword/liaoyuan

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 ★ 拍下超限乘区 ★ 光环是施法之后才结算的(每秒推), 那时候主手可能已经
#      换掉了 —— 所以在这里把"敲没敲超限"拍成玩家身上的快照, 后面全程用它。
function sweetdream:overlimit/api/snap

# ①.5 把要用到的计分项先建出来(没分数的目标在 matches 里判不出来)
scoreboard players add @s zx.ly_aura 0
scoreboard players add @s zx.ly_timer 0
scoreboard players add @s zx.ly_times 0

# ② 只读检查: 冷却 + 魔力 250
#    ★ 检查之前先过一道超限: 敲过超限的燎原要 325 蓝、冷却 62.5 秒 ——
#      不在这里乘的话, 提示会说"需要 250", 实际却扣 325(见 overlimit/api/mod)。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liaoyuan",mana:250.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ly_need zx.meta 0
execute store result score #ly_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"燎原 冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ly_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力(超限后的值: zx:work olv.mana 由上面的 mod 抄好)
#    先 set 成基准 250 再 from 覆盖 —— 万一 olv 读不到, 最坏也只是扣回原来的数, 不会扣 0。
data modify storage manacore:in arg set value {uuid:"",value:250.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ly_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 50 秒(超限后 62.5 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liaoyuan",cooldown_seconds:50.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ 开光环: 18 秒; 2 秒后第一次灼烧; 灼烧次数清零
scoreboard players set @s zx.ly_aura 18
scoreboard players set @s zx.ly_timer 2
scoreboard players set @s zx.ly_times 0

# ⑥ 表现(不出聊天提示)
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.8
execute at @s run particle minecraft:flame ~ ~1 ~ 2.4 0.6 2.4 0.02 30 normal
execute at @s run particle minecraft:lava ~ ~0.3 ~ 2.2 0.2 2.2 0.01 12 normal
