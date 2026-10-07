# ============================================================
# sweetdream:equipment/axe/ballad/cast —— 歌谣 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/ballad(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 240 / 冷却 30 秒。
#   "使用后自身下一次攻击额外对自身 X 格内的 X 个生物造成一次相当于自身基础攻击力
#    ×（9-X）的真实伤害并时停 X 秒。之后清除全部「曲调」。（X 为「曲调」层数）"
# 【★ 四要素 ★】
#   ① 触发: 右键(只挂状态, 不立刻打伤害)。
#   ② 目标范围: 下一次攻击时 —— 自身 X 格内最近的 X 个生物。
#   ③ 次数: 1 次(打完清空「曲调」)。
#   ④ 时长: "下一次攻击"= 一直挂着直到打出下一次攻击(玩家 2026-10-07 定: 不设时限);
#      时停 X 秒(见 hit, X×20 tick)。
# 【★ 解读(请核对) ★】文案写"X 格内的 X 个生物" —— 按"取最近的至多 X 个"实现
#   (选择器 limit=X、range=X 格)。层数为 0 时整个技能没有意义, 所以**要求 ≥1 层**才放
#   (不扣蓝、不进冷却) —— 这是我的判断, 避免白烧 240 点。
# 【数值改哪】个数/范围 = pick 的选择器; 倍率 (9-X) = hit; 时停秒数 = hit 的 X×20。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/ballad

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 240
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:ballad",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"歌谣冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 至少 1 层「曲调」, 否则整个不放
execute if score @s zx.bd_tune matches 1.. run scoreboard players add #bd_t zx.meta 0
execute unless score @s zx.bd_tune matches 1.. run tellraw @s [{"text":"「曲调」为 0, 先击杀生物积攒","color":"red"}]
execute unless score @s zx.bd_tune matches 1.. run return fail

# ④ 扣魔力 240
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:ballad",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 挂上"下一次攻击已就绪"
scoreboard players set @s zx.bd_song 1

# ⑦ 表现
execute at @s run particle minecraft:note ~ ~1 ~ 0.6 0.6 0.6 0.05 20 normal
execute at @s run playsound minecraft:block.note_block.chime player @a ~ ~ ~ 1.0 1.2
tellraw @s [{"text":"歌谣: 下一次攻击将以 ","color":"yellow"},{"score":{"name":"@s","objective":"zx.bd_tune"},"color":"gold"},{"text":" 层「曲调」奏响","color":"yellow"}]
