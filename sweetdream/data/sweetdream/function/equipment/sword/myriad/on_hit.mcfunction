# ============================================================
# sweetdream:equipment/sword/myriad/on_hit —— 平A命中: 在领域里就给计数 +1
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/myriad_hit(player_hurt_entity)
# 【执行者】动手的玩家
# 【文案】之后若自身处于领域中且攻击生物 5 次后则有 2 秒时间可以释放一次特殊技能。
# 【★ "攻击生物 5 次"按**攻击次数**算 ★】玩家 2026-10-07 定的措辞口径:
#   「每次攻击(后)」= 一次平A一次。所以这里按游戏刻去重(照 upgrade/api/on_hit
#   那条既有写法, 用框架时钟 #now), 横扫一下打 3 只也只算一次。
# 【★ 只有超限版才计数 ★】没超限就没有领域, 计数毫无意义 —— 先判 is_ol 再干活。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/myriad_hit

# ① 同一刻只算一次(横扫打 3 只 => 这个进度同一刻触发 3 次)
execute if score @s zx.mq_hl = #now manacore.meta run return 0
scoreboard players operation @s zx.mq_hl = #now manacore.meta

# ② 超限版才有领域
function sweetdream:equipment/sword/myriad/is_ol
execute unless score #mq_ol zx.meta matches 1 run return 0

# ③ 我站在自己的领域里吗(复用同一份判据, 见 in_domain)
function sweetdream:equipment/sword/myriad/in_domain
execute unless score #mq_in zx.meta matches 1 run return 0

# ④ 计数 +1, 满 5 开一个 2 秒的窗口
#   【★ 提示只有一句"特殊技能就绪" ★】2026-10-08 用户定稿: 不要"2 秒内再按一次右键"、
#   不要"会切换到另一把刀"、不要"不放则转为…"那一堆尾巴 —— 就报状态本身。
#   (状态名比操作说明短, 老玩家一眼够用; 那堆尾巴反而把真正要看的信息淹掉。)
scoreboard players add @s zx.mq_h5 1
execute if score @s zx.mq_h5 matches 5.. run scoreboard players set @s zx.mq_win 2
execute if score @s zx.mq_h5 matches 5.. run tellraw @s [{"text":"特殊技能就绪","color":"gold"}]
execute if score @s zx.mq_h5 matches 5.. run execute at @s run playsound minecraft:block.beacon.activate player @s ~ ~ ~ 0.7 1.6

#   【★★ 清零必须是最后一步 ★★】(2026-10-08 修 —— 用户反馈"触发特殊技能时没有提示")
#   原来这行排在 tellraw / playsound **之前**, 而它自己就写着
#   `if ... matches 5..` —— 它把 zx.mq_h5 一改成 0, **后面那两条的判据当场变假**,
#   于是"特殊技能就绪"从来没显示过、音效也从没响过(计数本身是对的, 窗口照开)。
#   顺序读法: 同一条计分项上"判"与"改"交错时, 把**改**放到该分支所有**判**之后 ——
#   和 RULES 58(每秒清 + 同秒判) / scoreeq 是同一类错(改早了 = 判据被自己吃掉)。
execute if score @s zx.mq_h5 matches 5.. run scoreboard players set @s zx.mq_h5 0
