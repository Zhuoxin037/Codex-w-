# ============================================================
# fallendream:equipment/armor/purge_fire/stack_gain —— 涤火(超限)：+1 层基础攻击力（12 秒）
# ------------------------------------------------------------
# 【执行者】穿超限涤火的玩家   【谁调它】purge_fire/stack_hit
# 【文案(逐字)】"…且自身每对其造成一次伤害则自身基础攻击力 +1，每次单独持续 12 秒。"
# 【★ "每次单独持续"怎么落 ★】8 个槽 zx.pf_k1..zx.pf_k8 各存一个到期刻,
#   新层写进**轮转槽**(zx.pf_ki 1→8 循环) —— 相当于"最多同时 8 层, 超了顶掉最老的一层"。
#   （12 秒 / 240 刻, 8 槽意味着 12 秒内打满 9 次以上才会开始顶掉。）
# 【★ 真正的加成不在这里加 ★】写槽后立刻调 stack_sync —— 它按"还活着的槽数"算差值,
#   统一走 manacore:api/stats/add 的 base_attack, 保证"加了几层"和账本 zx.pf_kv 一致。
# ============================================================

scoreboard players add @s zx.pf_ki 0
scoreboard players add @s zx.pf_ki 1
execute if score @s zx.pf_ki matches 9.. run scoreboard players set @s zx.pf_ki 1

scoreboard players operation @s zx.pf_k_end = #now manacore.meta
scoreboard players add @s zx.pf_k_end 240

execute if score @s zx.pf_ki matches 1 run scoreboard players operation @s zx.pf_k1 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 2 run scoreboard players operation @s zx.pf_k2 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 3 run scoreboard players operation @s zx.pf_k3 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 4 run scoreboard players operation @s zx.pf_k4 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 5 run scoreboard players operation @s zx.pf_k5 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 6 run scoreboard players operation @s zx.pf_k6 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 7 run scoreboard players operation @s zx.pf_k7 = @s zx.pf_k_end
execute if score @s zx.pf_ki matches 8 run scoreboard players operation @s zx.pf_k8 = @s zx.pf_k_end

function fallendream:equipment/armor/purge_fire/stack_sync
