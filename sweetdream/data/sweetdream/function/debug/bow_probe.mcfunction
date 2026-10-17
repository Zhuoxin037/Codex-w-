# ============================================================
# sweetdream:debug/bow_probe —— 弩「命中链」现场诊断(只读)
# ------------------------------------------------------------
# 【覆盖】龙舌 / 云迹 / 爆裂黎明 / 眠羽 / 烬弦 / 逆弦 / 黯日 —— 七把"有命中效果"的弩。
# 【用法】拿弩射几箭(最好**射中生物**), 然后 /function sweetdream:debug/bow_probe
# 【为什么需要它】弩没有 consumable / 右键, 命中结算**全靠** enchantment 的
#   post_attack 回调(坑 138: 回调只读攻击者主手物品上的附魔)。这条链上一共有
#   6 个可能断掉的地方, 而断在任何一个的表现都是"什么都没发生"、且**零日志**:
#     dbg0 箭回调(affected=damaging_entity)有没有被触发  <- 没触发 = 手上那把没附魔
#     dbg1 受害者回调(affected=victim)有没有被触发
#     dbg2 过了「是箭打的」(hook_arrow 打上了 zx.*_arr)
#     dbg3 过了「这一发付过账」(zx.*_paid == 1)
#     dbg4 过了「打中的是生物」(龙舌专有: 再过「带夜火」才是 dbg5)
#     dbg5 走到了结算入口(apply)
#   ⇒ 数字**从哪一级开始变成 0 / 空白**, 链就断在那一级。
# 【怎么读 dbg0】
#   dbg0 = 0 或空白, 但 dbg1 有数 -> 箭回调没跑(极少见, 通常是维度/实体类型问题)
#   dbg0 和 dbg1 **都是 0/空白** -> 附魔回调根本没触发 => 99% 是手上这把弩
#     没有机制附魔(**旧版本弩**): 物品 NBT 是快照, /reload 和重进世界都不会
#     让它自己长出来, 只能重新 give(看下面"主手物品"那一行确认)。
# 【只读】只写 zx.meta 上的 #*_dbg* 假玩家和临时标签, 不动任何游戏状态。
# ============================================================

tellraw @s [{"text":"===== 弩命中链诊断 =====","color":"gold"}]

# ---- ⓪ 手上这把弩: 是什么 / 有没有机制附魔 ----
tellraw @s [{"text":" 主手物品: ","color":"yellow"},{"nbt":"SelectedItem.id","entity":"@s"},{"text":"  附魔组件: ","color":"yellow"}]
execute if data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"   ✔ 有 enchantments 组件 —— 命中回调具备触发条件","color":"green"}]
execute unless data entity @s SelectedItem.components."minecraft:enchantments" run tellraw @s [{"text":"   ✘ 没有 enchantments 组件 —— 这是【旧版本弩】, 命中回调一次都不会触发, 请重新 give","color":"red"}]

# ---- ① 龙舌 ----
tellraw @s [{"text":" 【龙舌】箭回调 ","color":"aqua"},{"score":{"name":"#dt_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#dt_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#dt_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#dt_dbg3","objective":"zx.meta"}},{"text":" → 是生物 ","color":"aqua"},{"score":{"name":"#dt_dbg4","objective":"zx.meta"}},{"text":" → 带夜火(结算) ","color":"aqua"},{"score":{"name":"#dt_dbg5","objective":"zx.meta"}}]
execute if score @s zx.dt_paid matches 1 run tellraw @s [{"text":"   zx.dt_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.dt_paid matches 1 run tellraw @s [{"text":"   zx.dt_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]
# ---- ①b 龙舌结算内部(最近一次的值) ----
tellraw @s [{"text":"   X(6 格内带标记的生物数) = ","color":"aqua"},{"score":{"name":"#dt_x","objective":"zx.meta"}},{"text":"   箭数 X×3 = ","color":"aqua"},{"score":{"name":"#dt_n","objective":"zx.meta"}},{"text":"   每箭伤害 ×1000 = ","color":"aqua"},{"score":{"name":"#dt_dbg8","objective":"zx.meta"}}]
tellraw @s [{"text":"   箭雨: 点名 ","color":"aqua"},{"score":{"name":"#dt_dbg6","objective":"zx.meta"}},{"text":" 根 / 其中命中 ","color":"aqua"},{"score":{"name":"#dt_dbg7","objective":"zx.meta"}},{"text":" 根(差 = 落空, 正常)","color":"aqua"}]
execute if score #dt_x zx.meta matches ..0 run tellraw @s [{"text":"   ✘ X = 0: 被射中那只大概率在你 6 格之外 ⇒ 按文案没有箭雨(箭数 0、伤害 0)。走近一点再试。","color":"red"}]
execute if score #dt_x zx.meta matches 1.. if score #dt_dbg6 zx.meta matches ..0 run tellraw @s [{"text":"   ✘ X > 0 但循环一根都没转 —— 查 rain_one 的 #dt_i/#dt_n 比较","color":"red"}]
execute if score #dt_dbg7 zx.meta matches 1.. if score #dt_dbg8 zx.meta matches ..0 run tellraw @s [{"text":"   ✘ 打到目标了但每箭伤害是 0 —— 查当前魔力 / manacore:out r.damage","color":"red"}]

# ---- ② 云迹 ----
tellraw @s [{"text":" 【云迹】箭回调 ","color":"aqua"},{"score":{"name":"#ct_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#ct_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#ct_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#ct_dbg3","objective":"zx.meta"}},{"text":" → 是生物(结算) ","color":"aqua"},{"score":{"name":"#ct_dbg5","objective":"zx.meta"}}]
execute if score @s zx.ct_paid matches 1 run tellraw @s [{"text":"   zx.ct_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.ct_paid matches 1 run tellraw @s [{"text":"   zx.ct_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]

# ---- ③ 爆裂黎明 ----
tellraw @s [{"text":" 【爆裂黎明】箭回调 ","color":"aqua"},{"score":{"name":"#bd_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#bd_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#bd_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#bd_dbg3","objective":"zx.meta"}},{"text":" → 是生物(结算) ","color":"aqua"},{"score":{"name":"#bd_dbg5","objective":"zx.meta"}}]
execute if score @s zx.bd_paid matches 1 run tellraw @s [{"text":"   zx.bd_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.bd_paid matches 1 run tellraw @s [{"text":"   zx.bd_paid ≠ 1 ✘ (没射过 / 被「首发」的魔力不足分支清零 —— 见坑 143)","color":"red"}]

# ---- ④ 爆裂黎明: 首发 / 续轰分流 ----
tellraw @s [{"text":" 【爆裂黎明】分流判据 ","color":"aqua"},{"text":"#bd_hit(最近一发走了续轰?) = ","color":"aqua"},{"score":{"name":"#bd_hit","objective":"zx.meta"}},{"text":"  /  #bd_n(吃掉前几只) = ","color":"aqua"},{"score":{"name":"#bd_n","objective":"zx.meta"}},{"text":"  /  #bd_left(吃掉后剩几只) = ","color":"aqua"},{"score":{"name":"#bd_left","objective":"zx.meta"}}]
tellraw @s [{"text":" 当前 zx.bd_mode = ","color":"aqua"},{"score":{"name":"*","objective":"zx.bd_mode"}},{"text":" (1=主力 / 2=续轰)","color":"aqua"}]
scoreboard players set #bd_cnt zx.meta 0
execute at @s as @e[tag=zx.bd_shade,distance=..128] run scoreboard players add #bd_cnt zx.meta 1
tellraw @s [{"text":" 场上「魂灵之影」(128 格内, 含别人的): ","color":"aqua"},{"score":{"name":"#bd_cnt","objective":"zx.meta"}}]

# ---- ⑤ 批 15-1 四把弩(2026-10-15): 眠羽 / 烬弦 / 逆弦 / 黯日 ----
#   链的形状与上面三把完全一样(箭回调 -> 受害者回调 -> 过箭门控 -> 过付账门控 ->
#   过生物门控 -> 到结算), 所以"断在哪一级"读法也完全一样。
# ---- ⑤a 眠羽 ----
tellraw @s [{"text":" 【眠羽】箭回调 ","color":"aqua"},{"score":{"name":"#fs_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#fs_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#fs_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#fs_dbg3","objective":"zx.meta"}},{"text":" → 是生物 ","color":"aqua"},{"score":{"name":"#fs_dbg4","objective":"zx.meta"}},{"text":" → 到结算(还要带白昼梦) ","color":"aqua"},{"score":{"name":"#fs_dbg5","objective":"zx.meta"}}]
tellraw @s [{"text":"   最近一发: 6 格内其他生物数 = ","color":"aqua"},{"score":{"name":"#fs_c","objective":"zx.meta"}},{"text":" / 每枚羽箭伤害(×1000) = ","color":"aqua"},{"score":{"name":"#fs_dbg8","objective":"zx.meta"}},{"text":"  (0/1 只 -> 合 1 枚 ×0.18; >=2 -> 2 枚 ×0.08)","color":"gray"}]
execute if score @s zx.fs_paid matches 1 run tellraw @s [{"text":"   zx.fs_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.fs_paid matches 1 run tellraw @s [{"text":"   zx.fs_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]
# ---- ⑤b 烬弦 ----
tellraw @s [{"text":" 【烬弦】箭回调 ","color":"aqua"},{"score":{"name":"#es_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#es_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#es_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#es_dbg3","objective":"zx.meta"}},{"text":" → 是生物 ","color":"aqua"},{"score":{"name":"#es_dbg4","objective":"zx.meta"}},{"text":" → 到结算 ","color":"aqua"},{"score":{"name":"#es_dbg5","objective":"zx.meta"}}]
tellraw @s [{"text":"   最近一发走的分支 #es_dbg8 = ","color":"aqua"},{"score":{"name":"#es_dbg8","objective":"zx.meta"}},{"text":" (1=附加流火 / 2=流火转夜火 / 3=已有夜火补伤害; 0=没进结算或被 8 秒闸挡住)","color":"gray"}]
tellraw @s [{"text":"   节流: zx.es_gate = ","color":"aqua"},{"score":{"name":"@s","objective":"zx.es_gate"}},{"text":"  当前刻 #now = ","color":"aqua"},{"score":{"name":"#now","objective":"manacore.meta"}},{"text":"  (gate > now = 还在冷却)","color":"gray"}]
execute if score @s zx.es_paid matches 1 run tellraw @s [{"text":"   zx.es_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.es_paid matches 1 run tellraw @s [{"text":"   zx.es_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]
# ---- ⑤c 逆弦 ----
tellraw @s [{"text":" 【逆弦】箭回调 ","color":"aqua"},{"score":{"name":"#rs_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#rs_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#rs_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#rs_dbg3","objective":"zx.meta"}},{"text":" → 是生物 ","color":"aqua"},{"score":{"name":"#rs_dbg4","objective":"zx.meta"}},{"text":" → 到结算 ","color":"aqua"},{"score":{"name":"#rs_dbg5","objective":"zx.meta"}}]
tellraw @s [{"text":"   最近一发: #rs_ol(是否强化, 当前魔力<=25%) = ","color":"aqua"},{"score":{"name":"#rs_ol","objective":"zx.meta"}},{"text":" / 额外伤害(×1000) = ","color":"aqua"},{"score":{"name":"#rs_dbg8","objective":"zx.meta"}}]
execute if score @s zx.rs_paid matches 1 run tellraw @s [{"text":"   zx.rs_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.rs_paid matches 1 run tellraw @s [{"text":"   zx.rs_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]
# ---- ⑤d 黯日 ----
tellraw @s [{"text":" 【黯日】箭回调 ","color":"aqua"},{"score":{"name":"#ds_dbg0","objective":"zx.meta"}},{"text":" → 受害者回调 ","color":"aqua"},{"score":{"name":"#ds_dbg1","objective":"zx.meta"}},{"text":" → 是箭打的 ","color":"aqua"},{"score":{"name":"#ds_dbg2","objective":"zx.meta"}},{"text":" → 付过账 ","color":"aqua"},{"score":{"name":"#ds_dbg3","objective":"zx.meta"}},{"text":" → 是生物 ","color":"aqua"},{"score":{"name":"#ds_dbg4","objective":"zx.meta"}},{"text":" → 到结算 ","color":"aqua"},{"score":{"name":"#ds_dbg5","objective":"zx.meta"}}]
tellraw @s [{"text":"   最近一发: 命中前状态位 #ds_dbg9 = ","color":"aqua"},{"score":{"name":"#ds_dbg9","objective":"zx.meta"}},{"text":" (1=带流火 / 2=带夜火 / 3=两者都带; 带夜火才放影矢)","color":"gray"}]
tellraw @s [{"text":"   主目标伤害(×1000) = ","color":"aqua"},{"score":{"name":"#ds_dbg8","objective":"zx.meta"}},{"text":" / 影矢点到几只 = ","color":"aqua"},{"score":{"name":"#ds_dbg7","objective":"zx.meta"}}]
tellraw @s [{"text":"   节流: zx.ds_gate = ","color":"aqua"},{"score":{"name":"@s","objective":"zx.ds_gate"}},{"text":"  当前刻 #now = ","color":"aqua"},{"score":{"name":"#now","objective":"manacore.meta"}},{"text":"  (gate > now = 还在冷却)","color":"gray"}]
execute if score @s zx.ds_paid matches 1 run tellraw @s [{"text":"   zx.ds_paid = 1 ✔ 最近一发付过账","color":"green"}]
execute unless score @s zx.ds_paid matches 1 run tellraw @s [{"text":"   zx.ds_paid ≠ 1 ✘ (没射过 / 那一发魔力不足)","color":"red"}]

# ---- ⑥ 收尾提示 ----
tellraw @s [{"text":" 数字从哪一级开始是 0/空白, 链就断在那一级; 全为 0 且附魔组件 ✘ => 重新 give 一把。","color":"yellow"}]
