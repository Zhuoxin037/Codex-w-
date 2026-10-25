# ============================================================
# sweetdream:equipment/staff/thunderrod/pend_go_sk —— 主动技能排队的那记雷到期了(宏)
# ------------------------------------------------------------
# 【谁调用它】core/tick: 三维度各一遍, 判 `zx.tr_due <= #now` 才进来(与普攻的
#   pend_go 同一形态, 只是 tag / 落雷函数不同)
# 【宏参数】marker 自己的 data.zx.tr {u0,u1,u2,u3,ol}
# 【执行者】marker, 位置 = 当时那个目标脚下(雷就劈在这儿)
# 【★ 为什么要 `at @s as 主人` ★】伤害/归属要按**主人**算(api/damage 会取 @s 的
#   UUID 当 by), 但雷必须落在 **marker 的位置**。`at @s` 先钉住位置/维度,
#   `as` 只换执行者; 顺序反了(`as` 在前)位置会跟到主人身上, 雷就劈错地方了。
# 【$ 宏行必须含 $(变量)】两行都满足(第一行 u0..u3、第二行 ol)。
# ============================================================

# ① 把"这一记是不是超限档"拍回主人身上(bolt_skill 要按它决定要不要加 ×0.1 附伤;
#    排队跨刻, 那时读 storage 不可靠, 读玩家自己的分数才稳)
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
$execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.tr_ol $(ol)

# ② 落雷(以主人为执行者, 位置留在 marker 处)
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute at @s as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/staff/thunderrod/bolt_skill

# ③ 撤掉自己(一次性 marker, 不摘的话会每刻重复触发)
kill @s
