# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_bind_one —— 一只生物停留 2 秒后的结附结算
# ------------------------------------------------------------
# 【宏参数】u0..u3 —— 触发它的那片暗海的释放者 UUID 四个 int
#   (调用处: as @e[tag=zx.sea_bind] at @s run function ... with storage zx:work sea)
# 【执行者】那只生物(位置 = 它自己)
# 【文案】"…停留 2 秒后将结附「噬心」并在自身位置生成一个持续 10 秒、半径 2 格的
#   “暗海”, 之后将释放者生成的全部“暗海”持续时间 +2 秒(不超过各自的 10 秒上限)。"
# 【★ 延长在前、生成在后 ★】如果先生成再延长, 刚生成的次级片会被算进"全部暗海"里
#   被当场 +2 秒 —— 所以顺序必须是**先给已有暗海续命, 再生成次级片**。
#   续命带硬上限(sea_extend 截到 zx.sea_cap), 所以怎么续都不会超过 10 秒。
# 【每只生物各触发一次】多只同时停留够时, "全部暗海 +2 秒"会按只数各加一次
#   —— 这是文案的字面意思("停留 2 秒后… 之后将全部暗海 +2 秒"管的是每一只)。
# 【结附噬心后为什么重置计时】不重置的话, 下一秒它还满足"停留 ≥2 秒",
#   会被反复结附(每次还再 +2 秒 / 再拉一片次级片), 暗海会指数膨胀。
#   结附后它已经带噬心, 下一秒自动走 sea_veil 分支, 也不再吃伤害。
# ============================================================

# ① 结附「噬心」(走公共接口: 自带活体守卫 + 刷新 18 秒租约 + 头顶图标)
function sweetdream:tag/mark {target:"@s",mark:"shixin"}

# ② 该释放者名下**已有**的暗海全部续 2 秒(必须排在 ③ 生成次级片之前)
#    ★ 续命走 sea_extend: 它内部会截到 zx.sea_cap ⇒ 无论续几次都不超过 10 秒。
$execute as @e[tag=zx.sea] if data entity @s data.zx.sea{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)} run function sweetdream:equipment/armor/styx_walk/sea_extend

# ③ 在自身位置生成次级暗海(10 秒 / 半径 2 格; 归属由 zx:work sea 带过去)
execute at @s run function sweetdream:equipment/armor/styx_walk/sea_spawn_small

# ④ 重置停留计时(防重复结附; sw_st 与 sw_last 一起重置, 见 sea_enter)
scoreboard players operation @s zx.sw_st = #now manacore.meta
scoreboard players operation @s zx.sw_last = #now manacore.meta
