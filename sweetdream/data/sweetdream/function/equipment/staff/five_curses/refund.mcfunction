# ============================================================
# sweetdream:equipment/staff/five_curses/refund —— 击杀返还魔力
# ------------------------------------------------------------
# 【执行者】施法者(玩家 @s)
# 【入参】#fcv_kill zx.meta = 要返还的**魔力值**(已在 skill 里 ×50 并钳到 ≤300)
# 【为什么走 api/mana/add】这条是"主动回复"路径, 不受"禁止魔力恢复"的限制,
#   且内部已做了"不超过 max_mana"的钳位 —— 不用自己再判上限。
# 【为什么 uuid 用 zx:data self】skill 开头已调过 lib/uuid, self.uuid 还在。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #fcv_kill zx.meta
function manacore:api/mana/add

tellraw @s [{"text":"「五世恶咒」终世结算击杀，返还 ","color":"aqua"},{"score":{"name":"#fcv_kill","objective":"zx.meta"},"color":"aqua"},{"text":" 魔力","color":"aqua"}]
