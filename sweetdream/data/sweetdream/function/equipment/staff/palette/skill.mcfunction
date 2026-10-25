# ============================================================
# sweetdream:equipment/staff/palette/skill —— 调色盘: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 主动技能
#   魔力 400   ·   冷却 60 秒
#   使用后将生成一个“色彩”。
#   ✦ 色彩
#   “色彩”会离自身 12 格远或对 5 个生物造成伤害后自毁。
#   “色彩”会自动追踪离自身最近的生物并对其造成相当于自身最大魔力值 ×0.1 的伤害。
#   若调色盘上有颜色则强化效果。“色彩”不会追踪已经攻击过的生物。
#   ● 红：每有一个红色都会将伤害提高 1 倍。
#   ● 黄：每有一个黄色都会将“色彩”的追踪范围扩大 8 格，并将可追踪生物的阀值提高 3 个。
#   ● 蓝：每有一个蓝色则在“色彩”对生物造成伤害后回复自身 150 点魔力值并使技能冷却时间 -5 秒。
# 【四要素(逐个落实)】
#   ① 触发 = 潜行右键;
#   ② 目标范围 = 生成的“色彩”自身会去追生物(见 color_body), 技能本身不打人;
#   ③ 次数 = 生成 1 个“色彩”;
#   ④ 时长 = 无固定时长, 由"离自身 12 格远 / 打满可攻击阀值"决定(见 color_body ② 与 color_hit ⑥);
#      ★ 2026-10-08 用户定: **没有时间限制** —— 不加任何"兜底寿命/倒计时"。
# 【不登记术阵】"色彩"是会飞出去打人的光球, 没有地面范围可言 ⇒ **不占术阵槽**
#   (2026-10-08 删除; 原委见第 ⑤ 步)。
# 【颜色 → 参数(实装口径)】
#   红(每 1 个): 伤害倍率 +1 倍 → 伤害 = 最大魔力 ×0.1 ×(1 + 红数)
#   黄(每 1 个): 追踪范围 +8 格, 可攻击阀值 +3 个
#   蓝(每 1 个): 每次造成伤害后 +150 魔力 且 技能冷却 -5 秒
#   ★ 颜色在**施法这一刻被消耗**(清空两个槽)。否则攒满 2 色之后永远封顶、
#     后续每次攒色都没意义 —— 与"每次普攻命中后都会随机积攒"的积累设计矛盾。
# 【“自身”= 释放者】三处都以释放者为准: 范围/阀值派生、伤害基数、150 魔力与冷却。
# 【延迟结算不看超限】伤害由 color_hit 每刻现算(不走超限乘区), 和偏振光的每秒结算同款。
# 【★ 位置/归属 ★】“色彩”是 item_display(可见小光球; 坐标 = 位置真相, 见 RULES §48);
#   color_body 全程按它的坐标算, 伤害用 data.zx.pal 里存的 u0..u3 反查释放者做归属
#   (见 color_hit)。2026-10-08 从 marker 换成 item_display(用户: 主动技能没召唤召唤物)。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/palette

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(消耗 / 冷却走它)
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 + 魔力 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:palette",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #pal_need zx.meta 0
execute store result score #pal_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"调色盘冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pal_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 400
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pal_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 60 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:palette",cooldown_seconds:60.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ (已删除) 原来这里给"色彩"登记一个 10 秒的术阵。
#   ★ 2026-10-08 用户: "用调色盘的技能后不知道为什么会占一个术阵位置"。
#   术阵是"**地面上的区域场**"的登记借口(有 id / type / 半径, 有自己的槽位上限);
#   而"色彩"是一个**会自己飞出去打人的光球**, 根本没有地面范围可言 ——
#   登记它除了白占一个术阵槽(默认上限 3, 和其他技能共用)之外没有任何用处。
#   ⇒ 整个删掉。技能与"色彩"的生命周期完全不依赖它。

# ⑥ 数颜色: 红/黄/蓝 各几个(zx.pal_c1 / zx.pal_c2 两个槽)
scoreboard players set #pal_red zx.meta 0
scoreboard players set #pal_yel zx.meta 0
scoreboard players set #pal_blu zx.meta 0
execute if score @s zx.pal_c1 matches 1 run scoreboard players add #pal_red zx.meta 1
execute if score @s zx.pal_c2 matches 1 run scoreboard players add #pal_red zx.meta 1
execute if score @s zx.pal_c1 matches 2 run scoreboard players add #pal_yel zx.meta 1
execute if score @s zx.pal_c2 matches 2 run scoreboard players add #pal_yel zx.meta 1
execute if score @s zx.pal_c1 matches 3 run scoreboard players add #pal_blu zx.meta 1
execute if score @s zx.pal_c2 matches 3 run scoreboard players add #pal_blu zx.meta 1

# ⑦ 派生参数
#   #pal_mul = 1 + 红数(伤害倍率; ×0.1 在 color_hit 里乘)
scoreboard players set #pal_mul zx.meta 1
scoreboard players operation #pal_mul zx.meta += #pal_red zx.meta
#   #pal_rng = 12 + 8 × 黄数(追踪 / 存活半径)
scoreboard players operation #pal_rng zx.meta = #pal_yel zx.meta
scoreboard players operation #pal_rng zx.meta *= #8 zx.meta
scoreboard players add #pal_rng zx.meta 12
#   #pal_thr = 5 + 3 × 黄数(可攻击生物上限)
scoreboard players operation #pal_thr zx.meta = #pal_yel zx.meta
scoreboard players operation #pal_thr zx.meta *= #3 zx.meta
scoreboard players add #pal_thr zx.meta 5

# ⑧ 生成“色彩” —— item_display 小光球(眼睛前方一点, 免得卡在脚底)
#   ★ 2026-10-08 用户: “主动技能没有召唤召唤物”。原来这里是**隐形 marker**,
#     玩家只看到几颗 dust ⇒ 观感上"什么都没召唤出来"。改成 item_display +
#     billboard:"center"(竖平面永远正对摄像机), 按色码挑贴图(pal_orb_{r,y,b,w})。
#   ★ 逻辑不变: 位置真相仍在实体坐标上; 归属/参数照样写进 data.zx.pal
#     (display 实体同样吃 `data` 标签, 见 RULES §48 —— 暗海/暗潮同款)。
#   ★ 模型 = components."minecraft:item_model"(RULES §48: 自定义模型只能这么挂)。
#   ★ 值写 **items/ 下的定义名**(sweetdream:pal_orb_w), 不是 item/ 下的几何名 ——
#     item_model 解析到 `assets/<ns>/items/<名>.json`(sea/tide/fr_beam/withered_wood 同款)。
execute anchored eyes run summon minecraft:item_display ^ ^ ^1.5 {Tags:["zx.pal_col","zx.pal_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:pal_orb_w"}},brightness:{sky:15,block:15},interpolation_duration:0,billboard:"fixed",view_range:2.0f,transformation:{translation:[0.0f,0.0f,0.0f],scale:[0.6f,0.6f,0.6f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal set value {uuid:"",u0:0,u1:0,u2:0,u3:0,c:0,c2:0}
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal.uuid set from storage zx:data self.uuid
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.pal_new] data.zx.pal.u3 set from entity @s UUID[3]
#   外观色码 c = c1(c1 为空时取 c2), 仅用于表现(贴图)
execute store result entity @n[limit=1,tag=zx.pal_new] data.zx.pal.c int 1 run scoreboard players get @s zx.pal_c1
execute if score @s zx.pal_c1 matches 0 run execute store result entity @n[limit=1,tag=zx.pal_new] data.zx.pal.c int 1 run scoreboard players get @s zx.pal_c2
#   ★ 次色 c2 —— **仅当两个色槽都有颜色**时才有值(其余情况保持 0),
#     专供"双色拖尾"(color_body ⑤ 的 fx_second)。这就是"有两种颜色就加两种"的另一半:
#     单色光球的 c2 = 0 ⇒ 只拖一条; 两色光球 c2 = 第二个色 ⇒ 主色 + 次色两条并排。
execute if score @s zx.pal_c1 matches 1.. run execute store result entity @n[limit=1,tag=zx.pal_new] data.zx.pal.c2 int 1 run scoreboard players get @s zx.pal_c2
# Paired 3D pigment crystal; both colours are visual facets of the same entity.
execute as @n[limit=1,tag=zx.pal_new] at @s run function sweetdream:equipment/staff/palette/visual/color_init
execute as @n[limit=1,tag=zx.pal_new] run function sweetdream:equipment/staff/palette/visual/color_prepare
#   参数落到实体的计分项
scoreboard players operation @n[limit=1,tag=zx.pal_new] zx.pal_mul = #pal_mul zx.meta
scoreboard players operation @n[limit=1,tag=zx.pal_new] zx.pal_rng = #pal_rng zx.meta
scoreboard players operation @n[limit=1,tag=zx.pal_new] zx.pal_thr = #pal_thr zx.meta
scoreboard players operation @n[limit=1,tag=zx.pal_new] zx.pal_blu = #pal_blu zx.meta
scoreboard players set @n[limit=1,tag=zx.pal_new] zx.pal_n 0
#   ★ 2026-10-08 删: 这里原来写一个"30 秒兜底寿命" zx.pal_end = #now + 600。
#     用户: "他还会随着时间消失, 但我不想让它随着时间消失, 而是严格按照我的描述来"。
#     文案只给了两个自毁条件(离自身 12 格 / 打满阀值), 没有时间限制 ⇒ 整个删掉。
#     于是"色彩"能活多久完全由 ②(出界) 与 color_hit ⑥(打满) 决定。
#   唯一 id(标记"已被这个色彩打过"的生物用)
scoreboard players add #pal_uid zx.meta 1
scoreboard players operation @n[limit=1,tag=zx.pal_new] zx.pal_id = #pal_uid zx.meta
tag @n[limit=1,tag=zx.pal_new] remove zx.pal_new

function sweetdream:equipment/staff/palette/visual/begin

# ⑨ 清空调色盘上的颜色(“色彩”把它们消耗掉了)
scoreboard players set @s zx.pal_c1 0
scoreboard players set @s zx.pal_c2 0

# ⑩ 表现
particle minecraft:end_rod ~ ~1.4 ~ 0.3 0.4 0.3 0.05 16 normal
playsound minecraft:entity.illusioner.cast_spell player @a ~ ~ ~ 0.8 1.4
