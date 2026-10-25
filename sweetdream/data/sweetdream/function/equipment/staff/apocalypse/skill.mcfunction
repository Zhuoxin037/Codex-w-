# ============================================================
# sweetdream:equipment/staff/apocalypse/skill —— 启示录: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 450 魔力 / 冷却 90 秒。使用后召唤一个术阵, 并每隔 4 秒就依次
#   消耗一层「启示」。每消耗一页, 每隔 3 秒发生一次「灾示」: 对自身 8 格内
#   全部生物造成相当于该页记录魔力值 ×0.5 的伤害。若该页记录的技能消耗魔力
#   超过 500, 则本次「灾示」额外使目标获得 5 秒发光与虚弱Ⅱ。
#   若三页启示全部被消耗, 则最后一次「灾示」伤害提高 50%。
# 【节奏(两个独立计时器, 不可合并)】
#   t4 = 每 4 秒消耗一页(施法那一刻先消耗第一页, 之后 s4/s8 换页)
#   t3 = 每 3 秒一次灾示(s3/s6/s9), 用的都是"当前页"的魔力值
#        ★ "当前页"在每次灾示后清 0(reveal_go ⑧) ⇒ 灾示次数恒等于手里页数
#          (1 页 1 次 / 2 页 2 次 / 3 页 3 次; 2026-10-06 修, 以前固定 3 次)
#   状态总长 11 秒: s9 的灾示打完到 s12 本来也没有新页可换,
#   所以收在 11 秒, 恰好 3 次灾示、不多不少。
# 【"最后一次灾示 ×1.5"的判定】按节奏推演, 最后一次灾示必然落在
#   "离状态结束不到 3 秒"的窗口里(ap_on <= 3) —— 用这个判, 和玩家手里
#   有几页无关(1 页 / 2 页 / 3 页的最后一次都在 s9)。
# 【无页也允许施放】描述没有禁止 —— 没页时只是没有灾示, 给一句提示。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/apocalypse

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 450
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:apocalypse",mana:450.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"启示录冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 450）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 450
data modify storage manacore:in arg set value {uuid:"",value:450.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 450）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 90 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:apocalypse",cooldown_seconds:90.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤术阵(11 秒 = 与灾示状态对齐)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:apocalypse",type:"light",duration_seconds:11.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 无页提示(不拦施法)
execute if score @s zx.ap_n matches ..0 run tellraw @s [{"text":"没有可消耗的「启示」—— 灾示不会发生","color":"gray"}]

# ⑥.5 超限（批 K8）：施法时手里至少 3 页 ⇒ 本次**所有**灾示 +50%（结束时还有缓慢Ⅴ）
#   ★ 必须排在 ⑦ consume_page **之前**：那一句会把 ap_n 减 1，之后就判不出"施法时几页"。
scoreboard players set @s zx.ap_big 0
execute if score @s zx.ap_ol matches 1 if score @s zx.ap_n matches 3.. run scoreboard players set @s zx.ap_big 1

# ⑦ 点火: 施法那一刻先消耗第一页(没有页就跳过), 当前页 = 它的魔力值
# 初始化视觉，必须先于 consume_page 统计本次已消耗页数。
function sweetdream:equipment/staff/apocalypse/visual/begin
scoreboard players set @s zx.ap_cur 0
execute if score @s zx.ap_n matches 1.. run function sweetdream:equipment/staff/apocalypse/consume_page

# ⑧ 两个计时器 + 状态开关(每秒由 second 驱动 tick_s)
scoreboard players set @s zx.ap_t3 3
scoreboard players set @s zx.ap_t4 4
scoreboard players set @s zx.ap_on 11

# ⑨ 表现
execute at @s run particle minecraft:wax_on ~ ~1 ~ 1.0 0.8 1.0 0.03 30 normal
execute at @s run playsound minecraft:block.enchantment_table.use player @a ~ ~ ~ 1.0 0.6
