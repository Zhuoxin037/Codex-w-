# ============================================================
# sweetdream:equipment/armor/step_observe —— 「技能施放后有没有真的位移」观察者
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start（前置包每次技能进入冷却时抛出；
#   本包所有主动技能都是"扣完蓝之后"才记冷却 ⇒ 此刻 @s 就是施法者本人）
# 【为什么需要它】批 14 的两件靴子共用同一个判据：
#   踏灰「主动技能完成实际位移后…」、雨迹「主动技能完成实际位移后，在位移过的
#   地方留下水迹」。文案里的「完成实际位移」= 施法之后**位置真的变了**（不是
#   "放了技能"那么简单 —— 原地放的范围技能不该触发）。
#   mcfunctions 没有"位移事件"，只能"记下施法刻坐标 → 之后几刻比坐标"。
# 【判据】lib/step 每刻读当前 Pos，与这里的起点比；任一轴超阈值即算位移。
# 【★ 只认这两件 ★】脚上没穿踏灰也没穿雨迹 → 直接返回，连坐标都不读
#   （本观察者挂在全局冷却事件上，全服每次放技能都会进来）。
# 【★ 为什么不调 lib/uuid ★】2026-10-17 修：旧版在这里取 UUID **文本**，拿不到就
#   `return 0`；实测存档 `zx.sm_x/y/z` 有值而 `zx.sm_t` 一条记录都没有 ⇒ 每次都在
#   那一步提前返回，标签与计时从没设上，lib/step 一次没跑，两件靴子全静默。
#   现在只用 `entity @s UUID[n]` 四个整数（拼键本来就只需要它），**不碰任何 api**，
#   于是也不需要 in_bak/in_restore 那一层栈。
# 【★ 记录放 storage、不放玩家计分项 ★】记录里要带**技能 id 字符串**（踏灰要用它
#   减"这一个技能"的冷却），计分项存不了字符串。键 = UUID 四个整数拼串
#   （sweep/casts 的现成范式）；玩家 NBT 只读（坑 162），不能往身上写。
# ============================================================

# ⓪ 不是玩家（理论到不了这）→ 收工
execute unless entity @s[type=minecraft:player] run return 0

# ① 穿着门控：脚上不是踏灰、也不是雨迹 → 不需要记
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["tread_ash"]}] unless items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] run return 0

# ② 起点坐标（×100 取整，0.01 精度足够分辨"挪了一步"）
execute store result score @s zx.sm_x run data get entity @s Pos[0] 100
execute store result score @s zx.sm_y run data get entity @s Pos[1] 100
execute store result score @s zx.sm_z run data get entity @s Pos[2] 100

# ③ 记录：技能 id + 起点坐标
#   ★ 2026-10-17 修：**不再存 uuid 文本**。旧版这里调 lib/uuid 拿文本，
#     拿不到就 `return 0` —— 实测存档里 `zx.sm_x/y/z` 有值、`zx.sm_t` 却一条记录
#     都没有，正是每次都在那一步提前返回 ⇒ 标签/计时从没设上，lib/step 一次没跑，
#     踏灰与雨迹全部静默。④ 拼键用的四整数已经足够唯一标识玩家，不需要文本。
data modify storage zx:step node set value {skill:"",uuid:"",x:0d,y:0d,z:0d}
execute if data storage manacore:ctx skill run data modify storage zx:step node.skill set from storage manacore:ctx skill
#   技能 id 与 uuid 文本都直接取 `manacore:ctx` —— 这两个正是 start_go 在抛事件前
#   刚刚写好的（`$data modify storage manacore:ctx skill/uuid set value "$(…)"`），
#   比绕一圈调 lib/uuid 又稳又便宜。
#   ★ uuid 取不到也**不 return**：雨迹根本不需要它；踏灰的"减 CD"在 uuid 为空时
#     自己空转（reduce 找不到玩家记录就不做），绝不连累位移判定。
execute if data storage manacore:ctx uuid run data modify storage zx:step node.uuid set from storage manacore:ctx uuid
data modify storage zx:step node.x set from entity @s Pos[0]
data modify storage zx:step node.y set from entity @s Pos[1]
data modify storage zx:step node.z set from entity @s Pos[2]

# ④ 拼键写入 + 开 20 刻检测窗口（1 秒；无息这类持续位移要 16 刻才走完）
data modify storage zx:step ctx set value {}
data modify storage zx:step ctx.u0 set from entity @s UUID[0]
data modify storage zx:step ctx.u1 set from entity @s UUID[1]
data modify storage zx:step ctx.u2 set from entity @s UUID[2]
data modify storage zx:step ctx.u3 set from entity @s UUID[3]
function sweetdream:equipment/armor/step_save with storage zx:step ctx

scoreboard players set @s zx.sm_t 24
#   ★ 24 刻（1.2 秒）只是**基础窗口** —— 2026-10-18 起 lib/step 会"还在动就续期"：
#     每检测到位置变化就把 sm_t 顶回 12，最长续到 56 刻（约 2.8 秒）。这样无息
#     （去程 16 刻 + 归位 4 刻）、沉锚、影刃这类长位移不会在中途窗口到期、标签被摘
#     （用户报的"无息大约到中间就断了""沉锚也是后面一段没了"就是窗口先关门了）。
#   ★ 顺手把"已确认位移"归零：上一次窗口若因退出游戏没走完 step_finish，
#     done 会残留 1，下一次施法就会直接当成"已经位移过"（误给水迹/回血）。
scoreboard players set @s zx.sm_done 0

#   ★ 续期用的两个量（2026-10-18 新增）：
#     zx.sm_px/py/pz = **上一刻**的坐标（初始 = 施法刻起点），lib/step 每刻拿它比
#     zx.sm_n        = 确认位移之后"还在动"的累计刻数（续期上限 56）
scoreboard players operation @s zx.sm_px = @s zx.sm_x
scoreboard players operation @s zx.sm_py = @s zx.sm_y
scoreboard players operation @s zx.sm_pz = @s zx.sm_z
scoreboard players set @s zx.sm_n 0

tag @s add zx.sm_chk

# ⑤ 雨迹：在**施法刻的位置**留一个锚点 marker
#   为什么非要它：step_moved 发现"真的位移了"的时候，玩家已经挪出 1.5 格了。
#   第一个水迹点如果按"玩家当前位置"撒，起手那 1.5 格永远是空的 —— 用户报的
#   "没铺满"有一部分就是这个。marker 记下的是施法那一刻的脚部坐标（= 起点）。
#   ★ 只给穿雨迹的玩家造（踏灰不撒水迹，白造实体没意义）。
#   ★ kill 用 `distance=..3`：只收自己脚边 3 格内的残留（窗口中途退出游戏会
#     留下一个），不碰别人正在用的锚点、也不会跨维度误删。
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] run kill @e[tag=zx.rt_anchor,distance=..3]
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.rt_anchor"]}
