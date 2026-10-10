# ============================================================
# sweetdream:equipment/armor/lethe_shore/hit —— 沉溺忘川彼岸: 攻击计数
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/lethe_shore_hit(player_hurt_entity)
# 【执行者】玩家(动手的那个人)
# 【文案】"自身攻击了 8 次生物后, 自身进入「残念」状态, 持续 3 秒。"
# 【★ 先 revoke 再判 ★】进度是一次性开关, 不撤销就只有第一次能计数(见 lib/rearm)。
# 【计数口径】打中**任何活体**都算一次 —— 文案只说"攻击了…生物", 没有限定目标
#   身上的状态, 所以不像漫步冥河那样需要先定位"打的是谁"。原版 post_attack/hurt
#   已经保证"只有真的打中活体"才会触发本进度。
# 【残念期间不计数】已经在残念里再打也不累加(否则一秒连打会立刻续上第二发)。
# 【阈值只在"进入残念"时才清】被打断/降阈值都不影响当前计数, 攒够就放。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/lethe_shore_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿沉溺忘川就没这事
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lethe_shore"]}] run return 0

# ② 已在残念 -> 不再计数
execute if entity @s[tag=zx.lethe] run return 0

# ③ 计数 +1
scoreboard players add @s zx.lt_n 1

# ④ 达到阈值(默认 8, 可被削到 3) -> 进入残念
scoreboard players set #need zx.meta 8
execute if score @s zx.lt_need matches 1.. run scoreboard players operation #need zx.meta = @s zx.lt_need
execute if score @s zx.lt_n >= #need zx.meta run function sweetdream:equipment/armor/lethe_shore/begin
