# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_own —— 决堤超限：水流地带的每秒结算（施法者侧）
# ------------------------------------------------------------
# 【谁调用】core/tick 每秒一次：`as @a[scores={zx.bb_wt=1..}] at @s`
# 【为什么挂在施法者身上、而不是每个 marker 自己跑】
#   判定要三样东西：伤害值、施法者 UUID、还剩多久 —— 全都在施法者身上。
#   让 marker 侧去猜（反查 UUID / 写 NBT）要么很贵，要么把 chunk 写脏。
#   这里先在自己身上拍一份宏源 bbw，再把同一份参数喂给宏函数 wet_run。
# 【★ 为什么拆成两层 ★】本函数是**普通函数**：`$(uuid)` 只有在
#   `function ... with storage` 调进来的宏函数里才会被替换。在普通函数里写 `$` 行，
#   参数没绑定 ⇒ 那一条命令会被整行跳过（静默，check 规则专门盯这个）。
#   所以"拍参数"留在这里，"用参数"全部挪进 wet_run。
# ============================================================

# ① 拍宏源（uuid 供 tag 拼接；dmg/u0..u3 供伤害投递）
data modify storage zx:work bbw set value {uuid:"",dmg:0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work bbw.uuid set from storage zx:data self.uuid
execute store result storage zx:work bbw.dmg int 1 run scoreboard players get @s zx.bb_wd
data modify storage zx:work bbw.u0 set from entity @s UUID[0]
data modify storage zx:work bbw.u1 set from entity @s UUID[1]
data modify storage zx:work bbw.u2 set from entity @s UUID[2]
data modify storage zx:work bbw.u3 set from entity @s UUID[3]

# ② 12 秒到点收工
execute if score @s zx.bb_wt <= #now manacore.meta run function sweetdream:equipment/staff/burst_bank/wet_end with storage zx:work bbw
execute if score @s zx.bb_wt <= #now manacore.meta run return 0

# ③ 站在水面上给迅捷 + 逐点结算（宏函数）
function sweetdream:equipment/staff/burst_bank/wet_run with storage zx:work bbw
