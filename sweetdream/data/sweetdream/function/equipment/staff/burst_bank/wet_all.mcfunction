# ============================================================
# sweetdream:equipment/staff/burst_bank/wet_all —— 决堤超限：把这一秒喂给自己撒的每一个点
# ------------------------------------------------------------
# 【宏参数】zx:work bbw（uuid / dmg / u0..u3）
# 【★ 为什么单独拆一层 ★】wet_own 自己也要用 $(uuid) 做"我还站在水面上吗"的判定，
#   而 execute as 之后 @s 变成 marker、@s 不再是施法者 —— 拆开就不会互相污染。
# ============================================================
$execute as @e[type=marker,tag=zx.bb_wet_$(uuid),distance=0..] at @s run function sweetdream:equipment/staff/burst_bank/wet_hit with storage zx:work bbw
