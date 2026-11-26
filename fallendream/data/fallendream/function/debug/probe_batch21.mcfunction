# ============================================================
# fallendream:debug/probe_batch21 —— 第三批职业装备的现场读数（自助排查）
# ------------------------------------------------------------
# 【怎么用】站在问题发生的状态里（手里拿着那件、刚右键完 / 刚打完一下），
#   在聊天栏输入：
#       /function fallendream:debug/probe_batch21
#   它把你身上的关键分数直接打出来 —— 不用翻日志、不用截图存档。
# 【为什么要有它】2026-11-01 那轮三个 bug（牺牲 cast 加载失败、脱离缺 num_str、
#   法杖没有普攻）都是"零日志静默失效"，靠猜改代码会白跑好几轮。
#   有探头就能一眼看出"是压根没跑到，还是跑到了算错"。
# 【读法】
#   · dt_arm = 1  ⇒ 脱离已经蓄好了，下一次命中就该追加伤害（打中后会清 0）
#   · dt_hp       ⇒ 那一发要打的最大生命值（毫点，÷1000 = 点）。是 0 就白打
#   · sc_on = 1   ⇒ 牺牲正在流血；sc_dps 是每秒掉多少（毫点）
#   · li_on = 1   ⇒ 清醒的 4 秒结算还挂着；li_x 是当前超过上限的额外法球数
#   · j_orb / jcap⇒ 法球数与上限（清醒的普攻要靠它判"到没到上限"）
#   · se_on = 1   ⇒ 潮涌的 12 秒还在跑
#   · as_win = 1  ⇒ 余响的 12 秒收回窗口开着；as_n 是本轮收回个数（×5%）
#   · atk_ok      ⇒ 这一下算不算"满蓄力"（1 = 满）。脱离/牺牲不看它，仅供对照
# ============================================================

tellraw @s [{"text":"===== 第三批职业装备 · 现场读数 =====","color":"gold","bold":true}]

# ① 职业与手持
tellraw @s [{"text":"职业 zx.job = ","color":"gray"},{"score":{"name":"@s","objective":"zx.job"},"color":"aqua"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["detach"]}] run tellraw @s [{"text":"主手：脱离（iron_axe）","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sacrifice"]}] run tellraw @s [{"text":"主手：牺牲","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["lucid_illusion"]}] run tellraw @s [{"text":"主手：清醒与幻觉","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["intone"]}] run tellraw @s [{"text":"主手：引声","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["surge_ebb"]}] run tellraw @s [{"text":"主手：潮涌，潮枯","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["throe"]}] run tellraw @s [{"text":"主手：痛楚","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aftersound"]}] run tellraw @s [{"text":"主手：余响","color":"green"}]
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["bulwark"]}] run tellraw @s [{"text":"胸甲：肉盾","color":"green"}]
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"主手：不是本包武器","color":"dark_gray"}]

# ② 脱离
tellraw @s [{"text":"[脱离] dt_arm=","color":"gray"},{"score":{"name":"@s","objective":"zx.dt_arm"},"color":"yellow"},{"text":"  dt_hp=","color":"gray"},{"score":{"name":"@s","objective":"zx.dt_hp"},"color":"yellow"}]
# ③ 牺牲
tellraw @s [{"text":"[牺牲] sc_on=","color":"gray"},{"score":{"name":"@s","objective":"zx.sc_on"},"color":"yellow"},{"text":"  sc_dps=","color":"gray"},{"score":{"name":"@s","objective":"zx.sc_dps"},"color":"yellow"},{"text":"  sc_floor=","color":"gray"},{"score":{"name":"@s","objective":"zx.sc_floor"},"color":"yellow"}]
# ④ 肉盾
tellraw @s [{"text":"[肉盾] bw_st=","color":"gray"},{"score":{"name":"@s","objective":"zx.bw_st"},"color":"yellow"},{"text":"  bw_atk=","color":"gray"},{"score":{"name":"@s","objective":"zx.bw_atk"},"color":"yellow"}]
# ⑤ 清醒与幻觉
tellraw @s [{"text":"[清醒] j_orb=","color":"gray"},{"score":{"name":"@s","objective":"zx.j_orb"},"color":"yellow"},{"text":"  li_on=","color":"gray"},{"score":{"name":"@s","objective":"zx.li_on"},"color":"yellow"},{"text":"  li_x=","color":"gray"},{"score":{"name":"@s","objective":"zx.li_x"},"color":"yellow"}]
tellraw @s [{"text":"        额外槽到期刻 e1/e2/e3 = ","color":"gray"},{"score":{"name":"@s","objective":"zx.li_e1"},"color":"yellow"},{"text":" / ","color":"gray"},{"score":{"name":"@s","objective":"zx.li_e2"},"color":"yellow"},{"text":" / ","color":"gray"},{"score":{"name":"@s","objective":"zx.li_e3"},"color":"yellow"}]
# ⑥ 痛楚
tellraw @s [{"text":"[痛楚] pn_until=","color":"gray"},{"score":{"name":"@s","objective":"zx.pn_until"},"color":"yellow"}]
# ⑦ 余响
tellraw @s [{"text":"[余响] as_on=","color":"gray"},{"score":{"name":"@s","objective":"zx.as_on"},"color":"yellow"},{"text":"  as_win=","color":"gray"},{"score":{"name":"@s","objective":"zx.as_win"},"color":"yellow"},{"text":"  as_n=","color":"gray"},{"score":{"name":"@s","objective":"zx.as_n"},"color":"yellow"}]
# ⑧ 潮涌
tellraw @s [{"text":"[潮涌] se_on=","color":"gray"},{"score":{"name":"@s","objective":"zx.se_on"},"color":"yellow"},{"text":"  se_end=","color":"gray"},{"score":{"name":"@s","objective":"zx.se_end"},"color":"yellow"},{"text":"  se_b_until=","color":"gray"},{"score":{"name":"@s","objective":"zx.se_b_until"},"color":"yellow"}]
# ⑨ 通用：蓄力与术阵
tellraw @s [{"text":"[通用] atk_ok=","color":"gray"},{"score":{"name":"@s","objective":"zx.atk_ok"},"color":"yellow"},{"text":"  hp_c=","color":"gray"},{"score":{"name":"@s","objective":"zx.hp_c"},"color":"yellow"}]
data modify storage manacore:in arg set value {uuid:""}
function fallendream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
tellraw @s [{"text":"       术阵：","color":"gray"},{"nbt":"r.count","storage":"manacore:out","color":"aqua"},{"text":" / 上限 ","color":"gray"},{"nbt":"r.limit","storage":"manacore:out","color":"aqua"}]
