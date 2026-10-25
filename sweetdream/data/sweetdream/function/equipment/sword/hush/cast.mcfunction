# ============================================================
# sweetdream:equipment/sword/hush/cast —— 无息 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/hush(consume_item) -> rewards
# 【文案(必须和这里对上)】魔力 200 / 冷却 30 秒 / 向前突击最多 8 格 /
#   途中无视生物、穿身而过, 只有抵达终点或撞上障碍物才停;
#   途中**每碰到一个生物**, 立即对身边 3 格内的全部生物造成一次 最大魔力值 ×0.1
#   (同一只每次施法至多一次);
#   停下后约 0.2 秒内极速闪回原点, 再次对路径上的生物造成 最大魔力值 ×0.2。
# 【怎么分段做】
#   · cast 只干四件事: 校验 -> 记原点 -> 起突进 -> 扣蓝/记冷却。伤害一律不在
#     cast 里结算(此刻人还在起点, 打伤害等于打起点周围)。
#   · 逐刻推进在 dash_tick(挂 core/tick); 碰到生物**当刻**由 touch_dmg 打 ×0.1。
#   · 停下 -> dash_end(只起归位); 归位是**一段过程**(0.2 秒), 由 back_step 每刻推,
#     回到原点那一刻由 back_finish 结算回程伤害 ×0.2。★ 2026-10-07 改版。
# 【原点怎么记】在自己脚下 summon 一个 marker, 把**自己的 uuid 文本**写进它的
#   data.zx.hs.uuid。归位时按 uuid 找到这个 marker, 用 `at <marker> run tp @s ~ ~ ~`
#   —— `at` 只换坐标基点、**不换执行者**, 所以 tp 的还是玩家本人, 且**朝向保持
#   不变**; 而"朝 marker 迈步"的闪回过程用的也是这个 marker(见 back_move)。
#   ★ 为什么不存坐标计分项: `data get Pos` 只能取整(会差半格左右), 而 marker 是
#     精确位置; 且 marker 天然"每人一个", 不用拼宏坐标字符串。
#   ★ marker 只在"没跑完的极端情况"(玩家中途退游戏)才会残留 -> cast 开头先把
#     自己名下的旧 marker 清一遍(按 uuid), 保证每人最多一个。
#   ★ 突击标记(zx.hs_hit_<uuid> / zx.hs_path_<uuid> / zx.hs_new_<uuid>)同理:
#     它们**带施法者 uuid**, 所以"多人同时施放"天然隔离(报告 F10); 清理也只清
#     自己名下那一种, 不再像老实现那样全局清(会误删别人正在进行的突击)。
# 【数值改哪】距离 = 这里的 16 与 dash_tick 的 0.5(16 × 0.5 = 8 格);
#   倍率 = touch_dmg 的 0.1 / back_finish 的 0.2; 归位速度 = back_move 的 2.0;
#   去程范围 = dash_mark ②③ 与 touch_dmg 的 3 格; 回程走廊 = dash_mark ② 的 1.5 格。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/hush

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力够不够
#   【skill 不能漏】api/skill/check 内部是"先看 skill 在不在, 在才去查冷却"。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:hush",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"无息冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 200)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 清掉自己名下的旧残留(marker + 突击标记), 再在起点留一个
#   ★ 这里要调宏函数(把 uuid 写进选择器), 所以先把 uuid 抄进 zx:work hs
data modify storage zx:work hs.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/hush/org_clear with storage zx:work hs
#   突击标记(zx.hs_hit_<uuid> / zx.hs_path_<uuid> / zx.hs_new_<uuid>)也按**自己的
#   uuid** 清一遍 —— 正常一局由 back_finish 收尾; 只有"突击没跑完"(中途退游戏/
#   被传送)才会残留。★ 只动自己的, 不碰别人正在进行的突击(见 tag_clear 的说明)。
function sweetdream:equipment/sword/hush/tag_clear with storage zx:work hs

#   ★ marker 的临时标签叫 zx.hs_mk(只在下面 4 行内存在), **不要**和去程用的
#     "生物临时标记 zx.hs_new_<uuid>" 混为一谈 —— 两者名字相近但语义无关。
summon minecraft:marker ~ ~ ~ {Tags:["zx.hs_org","zx.hs_mk"]}
data modify entity @n[limit=1,tag=zx.hs_mk] data.zx.hs set value {uuid:""}
data modify entity @n[limit=1,tag=zx.hs_mk] data.zx.hs.uuid set from storage zx:data self.uuid
tag @n[limit=1,tag=zx.hs_mk] remove zx.hs_mk

# ④ 起突进: 还剩 16 步(0.5 格/步 = 8 格)
#   顺手清掉上一轮可能残留的归位状态(tag / 倒计时)
#   (去程要用的两种标记已在 ③ 按 uuid 清过, 这里不再清 —— 老实现是全局清,
#    会把别人正在进行的突击标记一起删掉, 见 tag_clear 的说明。)
scoreboard players set @s zx.hush 16
tag @s remove zx.hs_back
scoreboard players reset @s zx.hush_bk

# ⑤ 起手表现: 出鞘的"唰"
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 1.0 1.3

# ⑥ 扣魔力 -200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:hush",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
