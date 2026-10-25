# ============================================================
# sweetdream:equipment/tool/look/cache_go —— 缓存落库(宏: {uuid})
# ------------------------------------------------------------
# 【谁调用它】equipment/tool/look/cache(取好 uuid 之后) —— 执行者 = 玩家本人
# 【写哪】zx:look cache."<uuid>" = { eq:{<装备id>:1b,…}, skill:"sweetdream:<id>" }
#   两个键**都"先整格删、再按需写"**: 没有就整个键真的不存在
#   (读侧一律用 `if data` 判空 —— 残留上一秒的旧值会让人以为"还穿着/还拿着")。
# 【为什么整格删一次就够】eq 与 skill 是同一次采样的两个字段, 一起失效一起重建。
# 【★ N07: 这一格必须是"每人一份" ★】见 cache 头注释 —— 全局共用会被后跑的人覆盖。
# 【★ 为什么有的行有 `$` 有的没有 ★】含 $(uuid) 的行必须带 `$`;
#   不带宏变量的行**不能**带(`$` + 无宏变量 = 整个函数作废, 守门规则 dollar)。
# ============================================================

# ① 装备在身名单: 复用 equip_scan(它把 <id> 写进 zx:work eq.<id>), 完了整体搬进缓存
# One player serialization per synchronous scan; slot extraction uses this same snapshot.
data remove storage zx:look_scan player
data modify storage zx:look_scan player set from entity @s
data remove storage zx:work eq
function sweetdream:equipment/tool/look/equip_snapshot {p:"SelectedItem"}
function sweetdream:equipment/tool/look/equip_snapshot {p:"equipment.offhand"}
function sweetdream:equipment/tool/look/equip_snapshot {p:"equipment.head"}
function sweetdream:equipment/tool/look/equip_snapshot {p:"equipment.chest"}
function sweetdream:equipment/tool/look/equip_snapshot {p:"equipment.legs"}
function sweetdream:equipment/tool/look/equip_snapshot {p:"equipment.feet"}

# ② 先把自己那一格清空, 再把"这一秒真实存在的键"写回去
$data remove storage zx:look cache."$(uuid)"
$execute if data storage zx:work eq run data modify storage zx:look cache."$(uuid)".eq set from storage zx:work eq

# ③ 手持武器的 skill 字段 —— ★ 2026-10-18 起**不再缓存**
#   用户反馈"换武器后 CD 显示要等 0.5 秒左右才换"。原因就是这里每秒才采样一次
#   主手 skill, 平均滞后半秒。现在 render_go 每刻直接读 SelectedItem
#   (只对面版玩家、1 次序列化, 在 O02 清掉的 14 次里只占一小份) —— 这里不再写。
#   ★ 第 ② 步已经整格删过 cache."<uuid>", 所以旧 skill 键不会残留。

# ④ 面板"当前生命"(原来 render_go 每刻 data get entity @s Health —— 又是一次全量
#    序列化)。每秒读一次缓存进 zx.hp_show, render_go 每刻只读计分板。
#    ★ zx.hp_c(criterion)只给"活着/死了"门用(账本自愈), 显示值不用它 ——
#      criterion 的刻度(×2 与否)没有先例背书, 别拿来做显示。
#    ★ 计分板天然是"每人一份", 这一项不需要 uuid 分片。
scoreboard players set @s zx.hp_show 0
execute store result score @s zx.hp_show run data get storage zx:look_scan player.Health

# Never retain a full player snapshot after this synchronous scan.
data remove storage zx:look_scan player
