# ============================================================
# manacore:internal/join/slot_check —— 决定"这个玩家用哪个槽"
# ------------------------------------------------------------
# 【宏参数】manacore:macro a {uuid,cur,slot}
# 【现在的做法(修槽位泄漏)】
#   ① 先把整张 index 扫一遍(#i 0..max_slots), 看有没有哪一格记着这个 uuid
#      - 找到 -> 直接把玩家计分项校正成那个槽, 然后 register(复用, 不再新分配)
#      - 没找到 -> 才走 reissue(分配新槽)
#   ② 扫完记得把 #i / #found 复位, 免得上一次的结果污染下一次
# 【为什么不能只看 cur】玩家的分数会因为换存档/重登/被别的系统覆盖而失准,
#   那就等于"每次都当新人", 槽位只增不减。
# 【★ F03 修(2026-10-10)】扫描区间统一成 1..#max_slots(原来从 0 起、上界写成 >=
#   少扫最后一格 —— 默认第 64 槽永远查不到), 见 index/find_uuid_loop。
# ============================================================
scoreboard players set #found manacore.meta 0
scoreboard players set #i manacore.meta 1
function manacore:internal/index/find_uuid_loop
scoreboard players set #i manacore.meta 1

execute if score #found manacore.meta matches 1 run scoreboard players operation @s manacore.slot = #found_slot manacore.meta
# ★ 把修正后的槽位**同步回宏参数**再登记 (2026-10-08 修)。
#   register 拿宏里的 $(slot) 当索引键, 而宏里的 slot 是玩家进函数那一刻的旧快照。
#   不同步的话: 键写旧槽、值写新槽 -> 两边不一致; 旧槽若正好是别人的在用槽位,
#   那条索引会被覆盖, 对方的 self_uuid 就会解析到另一个人的 UUID。
#   (reissue 那条路已经同步过了, 只有"命中已有槽位"这条路漏了。)
execute if score #found manacore.meta matches 1 run execute store result storage manacore:macro a.slot int 1 run scoreboard players get @s manacore.slot
execute if score #found manacore.meta matches 1 run function manacore:internal/join/register with storage manacore:macro a
execute unless score #found manacore.meta matches 1 run function manacore:internal/join/reissue with storage manacore:macro a
scoreboard players set #found manacore.meta 0
