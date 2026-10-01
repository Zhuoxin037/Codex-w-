# ============================================================
# sweetdream:equipment/armor/immolate/second —— 焚舟·每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【★ 必须逐玩家 at @s ★】事件标签是服务器身份, 没有 @s / 没有玩家位置。
#   旧版直接 `scoreboard players add @s` 在服务器身份下会找不到实体,
#   函数会当场中断, 导致整个焚舟的烈空/上限/套装都不执行。
# 【备份公共输入口】second_one 会通过 api/stats/add 改魔力上限,
#   会写 manacore:in arg; 用 lib/in_bak 包起来, 不冲掉聊天栏手填的参数。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/immolate/second_one

function sweetdream:lib/in_restore
