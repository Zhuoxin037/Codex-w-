# ============================================================
# sweetdream:equipment/bow/bone_erode/ol_consume —— 超限·蚀骨: 清除被波及生物的「噬心」
# ------------------------------------------------------------
# 【谁调用它】fire ⑤(超限版), 在 ④ 的追击**打完之后**
# 【执行者】被打中的那只生物(fire 的 @s; 本函数只用它的位置, 不依赖它自己带不带噬心)
# 【文案】"…之后清除「噬心」"
# 【清除范围 = 2 格内**全部**带噬心的生物】与 ④ 的追击范围一致(同一批 zx.be_aoe)。
# 【★ 消耗者是谁(2026-10-06 定下的通用口径)★】噬心是在**目标生物**身上被吞的, 但
#   "消耗"这个动作是**射手**做的 —— 所以先 `lib/find_by` 用这一发快照里的 u0..u3
#   反查射手(打 zx.mc_by), 再当 `by` 传进统一入口。射手穿「永恒」时会扣他 50 魔力
#   把噬心刷回来(= 永恒吞不掉); 反查不到人(离线) -> by 选 0 人 -> 永恒跳过, 噬心照常清。
# 【为什么反查只做一次】清除是一次**范围操作**, 不用逐只查射手; 反查一次就够。
#   而 ④ 的追击要按"每只自己的血量"结算, 所以那边必须逐只 as。
# 【为什么走 lib/mark_consume 而不是直接 tag remove】统入口才会通知「永恒」这类
#   "消耗触发"的装备; 直接摘会静默漏掉它们。
# ============================================================

# ① 反查射手 -> zx.mc_by(用这一发快照里的 uuid 四位 int)
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from storage zx:work be.snap.u0
data modify storage zx:work fb.u1 set from storage zx:work be.snap.u1
data modify storage zx:work fb.u2 set from storage zx:work be.snap.u2
data modify storage zx:work fb.u3 set from storage zx:work be.snap.u3
function sweetdream:lib/find_by with storage zx:work fb

# ② 清除「噬心」(统一入口; by = 射手)
data modify storage zx:work a set value {target:"@e[tag=zx.be_aoe,tag=zx.status.shixin]",mark:"shixin",by:"@a[tag=zx.mc_by,limit=1]"}
function sweetdream:lib/mark_consume

# ③ 表现(噬心被抽走的青黑残影)
particle minecraft:sculk_soul ~ ~1 ~ 1.0 0.5 1.0 0.02 12 normal
playsound minecraft:block.sculk_vein.break player @a ~ ~ ~ 0.6 1.2

# ④ 收尾: 清反查标签(别给别人留脏标签)
tag @a remove zx.mc_by
