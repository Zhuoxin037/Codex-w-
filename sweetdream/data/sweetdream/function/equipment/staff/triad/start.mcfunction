# ============================================================
# sweetdream:equipment/staff/triad/start —— 首次施放: 术阵 + 开强化 15 秒
# ------------------------------------------------------------
# 【执行者】施法者(玩家 @s)
# 【文案】使用后召唤一个术阵; 武器被动强化, 持续 15 秒。
# 【★ id 必须唯一 ★】formation/create 的 id 同一玩家身上不能重复(删除/查询都靠它),
#   这里固定用 "sweetdream:triad"; 强化期间再次施放走的是 next_form(不会再建一个),
#   所以不会撞。
# 【★ 为什么强化计时用计分项不用术阵时长 ★】术阵是"视觉/登记"层的东西, 玩家可能
#   因为 formation_limit 上限建不出来(那样强化就没了); 强化是**机制**, 必须独立。
# ============================================================

# ① 术阵(15 秒, 与强化同长)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:triad",type:"triad",duration_seconds:15.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ② 开强化: 15 秒(由 second 每秒 -1, 归零时结束强化; 形态保留)
scoreboard players set @s zx.tri_strong 15

tellraw @s [{"text":"「很冰的斧」: 术阵展开，武器被动强化 15 秒","color":"aqua"}]
execute at @s run particle minecraft:enchant ~ ~1 ~ 0.8 0.8 0.8 0.05 30 normal
