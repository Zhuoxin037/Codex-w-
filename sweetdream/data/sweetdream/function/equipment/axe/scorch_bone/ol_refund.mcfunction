# ============================================================
# sweetdream:equipment/axe/scorch_bone/ol_refund —— 超限·焦骨: 夜火档返还 80% 魔力
# ------------------------------------------------------------
# 【谁调用它】scorch_bone/cast ⑥(只在"超限版 且 主目标原本已有「夜火」"时调)
# 【执行者】施法者(玩家)
# 【为什么单独写】原版夜火档**不返还**魔力(只把溅射提到 ×0.1);
#   超限版才追加"返还本次技能所消耗魔力的 80%"。共用 convert 会把普通版也改成返蓝。
# 【208 怎么来的】超限消耗 260 × 0.8 = 208。
# ------------------------------------------------------------
# 【★ 这条不摘不贴标签 ★】夜火档本来就不用转换 —— 它已经是更强的那个状态。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:208.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

execute at @e[tag=zx.sc_t,distance=0..,limit=1] run particle minecraft:soul_fire_flame ~ ~0.6 ~ 0.5 0.5 0.5 0.02 20 normal
tellraw @s [{"text":"焦骨: 「夜火」共鸣 · 范围伤害提升至 最大魔力 ×0.12 · 返还 208 魔力","color":"dark_red"}]
