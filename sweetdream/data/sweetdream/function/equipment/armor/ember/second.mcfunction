# ============================================================
# sweetdream:equipment/armor/ember/second —— 余烬·每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【为什么改成逐玩家】事件标签是服务器身份执行的, 层里没有 @s;
#   旧版直接写 `execute unless items entity @s ...` 在服务器身份下
#   找不到玩家, 后面的 @e[distance=..9] 也会以世界出生点为中心算。
#   所以这里先 `as @a at @s`, 后面的"自身 9 格内"才是玩家身边。
# 【★ 2026-10-12 起: 本函数只剩"认装备 + 魔力上限账本" ★】
#   燃烧边沿检测(zx.em_burn)已挪到 core/tick **每 5 刻**调一次 scan_one ——
#   每秒一次的检测让"火灭了要等将近 1 秒才上流火/夜火"(用户反馈), 提速到
#   5 刻后延迟 0~0.25 秒。zx.em_on 标签仍是命脉: 它是那条高频扫描的门控。
# ============================================================

# 【为什么对全部玩家跑】魔力上限 +240 是"穿上加, 脱下减"的差值账本:
#   如果只筛穿余烬的人, 脱下那一秒就没人执行 second_one, 240 永远减不回去。
#   所以先让所有人进来, 由 second_one 自己判断"这件装备在不在身上"。
# 【备份公共输入口】second_one 会通过 api/stats/add 改魔力上限, 会写
#   manacore:in arg; 用 lib/in_bak 包住整段, 不冲掉聊天栏手填的参数。
function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/ember/second_one

function sweetdream:lib/in_restore
