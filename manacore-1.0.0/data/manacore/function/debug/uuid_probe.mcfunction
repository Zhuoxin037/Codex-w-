# ============================================================
# manacore:debug/uuid_probe —— 看"拼 UUID"到底卡在哪一步
# 依次打印: 收集到的 4 个整数 / hex(应该是 32 位) / h0..h4(切段) / 最终 uuid
# 用法: /function manacore:debug/uuid_probe
# ============================================================
function manacore:internal/uuid/collect
function manacore:internal/uuid/build
tellraw @s [{"text":"[探针] 4 个整数: ","color":"gold"},{"nbt":"a.u0","storage":"manacore:work","color":"white"},{"text":" / ","color":"gray"},{"nbt":"a.u1","storage":"manacore:work","color":"white"},{"text":" / ","color":"gray"},{"nbt":"a.u2","storage":"manacore:work","color":"white"},{"text":" / ","color":"gray"},{"nbt":"a.u3","storage":"manacore:work","color":"white"}]
tellraw @s [{"text":"[探针] hex(应为32位): ","color":"gold"},{"nbt":"a.hex","storage":"manacore:work","color":"aqua"}]
tellraw @s [{"text":"[探针] 切段: ","color":"gold"},{"nbt":"a.h0","storage":"manacore:work","color":"white"},{"text":" | ","color":"gray"},{"nbt":"a.h1","storage":"manacore:work","color":"white"},{"text":" | ","color":"gray"},{"nbt":"a.h2","storage":"manacore:work","color":"white"},{"text":" | ","color":"gray"},{"nbt":"a.h3","storage":"manacore:work","color":"white"},{"text":" | ","color":"gray"},{"nbt":"a.h4","storage":"manacore:work","color":"white"}]
tellraw @s [{"text":"[探针] 最终 uuid(应为 8-4-4-4-12): ","color":"gold"},{"nbt":"a.uuid","storage":"manacore:work","color":"green"}]