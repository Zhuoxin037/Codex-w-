# ============================================================
# sweetdream:equipment/staff/apocalypse/spend —— 「启示」记页(唯一的记页入口)
# ------------------------------------------------------------
# 【谁调用它】两条链都汇到这里:
#   ① apocalypse/observe —— #manacore:event/cooldown_start 上(所有"带冷却的
#      主动技能": 扣完蓝起冷却时经过);
#   ② 五把弩的 shot —— 弩没有冷却, **根本不抛 cooldown_start**。
#      (2026-10-05 修: 清醒梦 180 / 漫彩 580 / 幽匿残响 100 / 寒鸦 / 蚀骨
#       射一发耗的蓝, 一页都记不到 —— 玩家报"快捷栏里用别的耗蓝的也拿不到书页")
# 【文案】该武器位于快捷栏时, 自身每次释放主动技能时若该技能消耗了至少 100
#   魔力, 则记录该技能消耗的魔力值并获得一页「启示」, 最多 3 页; 每个技能
#   单次最多产生一页。
# 【消耗怎么量】zx.ap_pre(core/tick 每刻快照) - 当前魔力, ×100 定点。
#   快照是本刻开头的值, 消耗发生在同刻稍后 → 差值就是这一次的消耗。
# 【★ 每刻只记一页(zx.ap_done)★】两条链可能在同一刻都命中(将来哪把弩要是
#   加了冷却就会撞上), 用这个"本刻已记过"开关兜住 —— 它在 snap 里每刻清零。
# 【★ 公共现场必须备份 ★】本函数会嵌在别的函数中间被调用:
#   · 写 manacore:in arg -> 冲掉调用方的参数 -> 走 lib/in_bak + in_restore;
#   · ★不★走 lib/uuid —— 它写 zx:data self, 而调用方(各把弩的 shot)此刻
#     正拿着 zx:data self.uuid 用。改用自己的节点 zx:work ap。
# 【★ zx.ap_n 必须先"建成分数" ★】`if score @s zx.ap_n matches ..2` 在玩家
#   **还没在这条计分项上有分数**时会直接失败(不是当成 0) —— 那样永远记不进
#   第一页, 而且观测镜上会冒出"启示 0/3 页"的幽灵段(守卫 `matches 0` 同样
#   判不住)。`add ... 0` 显式建成 0, 已存在则加 0 不动。snap 里也建了一次,
#   这里是双保险(万一 snap 被跳过)。
# ============================================================

# ⓪ 守卫: 不是玩家 / 本刻已经记过 / 快捷栏里没有启示录 → 收工
execute unless entity @s[type=minecraft:player] run return 0
execute if score @s zx.ap_done matches 1.. run return 0
execute unless entity @s[tag=zx.ap_has] run return 0
scoreboard players add @s zx.ap_n 0

# ① 备份公共输入口
function sweetdream:lib/in_bak

# ② 取自己的 uuid(写进 zx:work ap, 不动 zx:data self)
data modify storage zx:work ap set value {uuid:"",ok:0b}
function manacore:api/player/self_uuid
execute if data storage manacore:out r.uuid unless data storage manacore:out r{uuid:""} run data modify storage zx:work ap.uuid set from storage manacore:out r.uuid
execute if data storage zx:work ap.uuid unless data storage zx:work ap{uuid:""} run data modify storage zx:work ap.ok set value 1b

# ③ 当前魔力(消耗已经发生)
execute if data storage zx:work ap{ok:1b} run data modify storage manacore:in arg set value {uuid:""}
execute if data storage zx:work ap{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:work ap.uuid
execute if data storage zx:work ap{ok:1b} run function manacore:api/mana/get
scoreboard players set #now_m zx.meta 0
execute if data storage zx:work ap{ok:1b} run execute store result score #now_m zx.meta run data get storage manacore:out r.value 100

# ④ 消耗 = 本刻开头快照 - 现在(×100 定点; 没拿到 uuid 时保持 0, 别拿快照当消耗)
scoreboard players set #used zx.meta 0
execute if data storage zx:work ap{ok:1b} run scoreboard players operation #used zx.meta = @s zx.ap_pre
execute if data storage zx:work ap{ok:1b} run scoreboard players operation #used zx.meta -= #now_m zx.meta

# ⑤ 消耗 ≥100(即 #used ≥ 10000)且还有空页 → 记一页(写进第 n 页, n+1)
scoreboard players set #rec zx.meta 0
execute if score #used zx.meta matches 10000.. if score @s zx.ap_n matches ..2 run scoreboard players set #rec zx.meta 1
execute if score #rec zx.meta matches 1 if score @s zx.ap_n matches 0 run scoreboard players operation @s zx.ap_p1 = #used zx.meta
execute if score #rec zx.meta matches 1 if score @s zx.ap_n matches 1 run scoreboard players operation @s zx.ap_p2 = #used zx.meta
execute if score #rec zx.meta matches 1 if score @s zx.ap_n matches 2 run scoreboard players operation @s zx.ap_p3 = #used zx.meta
execute if score #rec zx.meta matches 1 run scoreboard players add @s zx.ap_n 1
execute if score #rec zx.meta matches 1 run scoreboard players set @s zx.ap_done 1
execute if score #rec zx.meta matches 1 run tellraw @s [{"text":"启示录记录了一页「启示」（现有 ","color":"gold"},{"score":{"name":"*","objective":"zx.ap_n"},"color":"yellow"},{"text":" 页）","color":"gold"}]

# ⑥ 还原公共输入口
function sweetdream:lib/in_restore
