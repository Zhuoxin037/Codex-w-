# ============================================================
# sweetdream:.../anchor/visual/flight —— 飞锚: 每刻朝锁定目标飞(宏 {u0..u3})
# ------------------------------------------------------------
# 【★ 2026-10-23 卡顿修复 ★】
#   原来这里每刻要跑 **6 次** `@e[nbt={UUID:[I;$(t0),...]}]`, 外加 3 次
#   `data ... set from entity <同一只> Pos[n]` —— 全都是"整份实体 NBT 序列化"。
#   飞锚活 70 刻 ⇒ 一发沉锚光表现层就是几百次序列化, 服务端被拖到个位数 tps,
#   玩家看到的就是"人卡住、过几秒伤害才哗一下全结算"。
#   现在: ① 目标一律走标签 zx.an_lock(+ scores={zx.an_own=$(u0)} 认人), 零 NBT;
#          ② 朝向交给 `facing entity ... eyes`, 不再读 Pos。
# ============================================================

# ① 目标不在了 -> 收掉自己
$execute unless entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] run return run kill @s

# ② 最后2格贴到目标上方, 避免越过目标反复穿梭; 方向始终指向锁定目标
$execute if entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=..2,limit=1] at @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] rotated as @s rotated ~ 0 run return run tp @s ~ ~0.9247258234534629 ~ ~ 0

# ③ 朝目标飞(每刻 1.8 格) —— 用 facing entity(引擎自己算方向), 不读 Pos(零 NBT)
#   ★ 瞄 **feet** 而不是 eyes: 同目录的 return_flight 有一条 `distance=..0.8` 的
#     "到手了"判据(那是量到**脚底**的距离), 若这里瞄眼睛就会踩坑 157 ——
#     "瞄眼睛的线 + 小 distance 判到达" 恒假。锚本来也是砸在地上的, 瞄脚底更自然。
$execute at @s facing entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] feet run tp @s ^ ^ ^1.8 ~ ~
particle minecraft:cloud ~ ~ ~ 0.06 0.06 0.06 0.01 1 normal
