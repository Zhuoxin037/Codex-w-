# ============================================================
# sweetdream:equipment/axe/sacred_relic/timestop —— 「白昼梦」: 追加 0.3 秒时停
# ------------------------------------------------------------
# 【谁调用它】sacred_relic/strike ⑤(遗骸 NBT 上带 data.zx.dm 时)
# 【执行者】遗骸(marker); 位置 = 遗骸处
# 【时长】0.3 秒 = 6 刻(20 刻/秒)。
# 【★ 为什么用 `as 释放者` 调 lib/timestop ★】lib/timestop 内部走 lib/ctrl_mul/pct,
#   那一步读的是"@s(施法者)的控制时长加成" —— 遗骸身份读不到那个加成, 所以必须
#   切回释放者再调(宏参数 target/ticks 照常经 zx:work fz 传)。
# ============================================================

data modify storage zx:work fz set value {target:"@e[tag=zx.sr_t,distance=0..]",ticks:6}
execute as @a[tag=zx.sr_caster,limit=1] run function sweetdream:lib/timestop with storage zx:work fz

# 表现: 一圈粉白的"梦"光(与本包「白昼梦」同色)
execute at @e[tag=zx.sr_t,distance=0..,limit=1] run particle minecraft:dust{color:[1.0,0.65,0.85],scale:1.2} ~ ~0.6 ~ 0.5 0.5 0.5 0 18 normal
