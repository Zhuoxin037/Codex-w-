# ============================================================
# sweetdream:equipment/sword/everfrost/lock —— 冻住 8 个 + 记账(宏 {uuid})
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid}   【执行者】施法者
# 【记在哪】施法者名下独立记录 zx:data ef."<uuid>"; 目标只用原版标签 zx.ef_<uuid> 认。
# 【冻结】走 lib/freeze(宏 {target,ticks}): TicksFrozen + 移动速度 -100%, 3 秒 = 60 tick。
#   ★ 调用它前先设好 zx:work fz —— 宏参数缺字段会让整条宏调用失败(静默)。
# ============================================================

# 清掉上一轮残留
$tag @e[tag=zx.ef_$(uuid)] remove zx.ef_$(uuid)

# 冻: 5 格内就近取 8 个(③ 已保证至少 1 个)
$tag @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=8] add zx.ef_$(uuid)

# 冻结这批 3 秒(60 tick)
data modify storage zx:work fz set value {target:"",ticks:60}
$data modify storage zx:work fz.target set value "@e[type=!#sweetdream:no_damage,tag=zx.ef_$(uuid),distance=0..]"
function sweetdream:lib/freeze with storage zx:work fz

# 到点时刻 = 现在 + 60 tick
scoreboard players operation #ef_due zx.meta = #now manacore.meta
scoreboard players add #ef_due zx.meta 60

# 记账(施法者名下)
$data modify storage zx:data ef."$(uuid)" set value {u0:0,u1:0,u2:0,u3:0,due:0}
$data modify storage zx:data ef."$(uuid)".u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:data ef."$(uuid)".u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:data ef."$(uuid)".u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:data ef."$(uuid)".u3 set from storage manacore:players "$(uuid)".u3
$execute store result storage zx:data ef."$(uuid)".due int 1 run scoreboard players get #ef_due zx.meta

# 告诉 cast "冻上了"
data modify storage zx:work a.locked set value 1b

# 表现: 每只被冻生物身上一撮霜花 + 一声冰裂
$execute at @e[tag=zx.ef_$(uuid)] run particle minecraft:snowflake ~ ~1 ~ 0.4 0.6 0.4 0.02 24 normal
$execute at @e[tag=zx.ef_$(uuid)] run playsound minecraft:block.glass.break player @a ~ ~ ~ 0.6 1.6
