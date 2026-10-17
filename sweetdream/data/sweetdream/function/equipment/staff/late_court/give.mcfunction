# ============================================================
# sweetdream:equipment/staff/late_court/give —— 给一件「迟庭」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "late_court" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["late_court"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"迟庭",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.025","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后，使其获得 2 秒缓慢Ⅱ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"400","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 1 个术阵，在准星处生成半径","color":"gray","italic":false},{"text":"4 格、持续 6 秒的领域。领域每秒对其中","color":"gray","italic":false},{"text":"处于缓慢状态的生物造成一次相当于自身","color":"gray","italic":false},{"text":"最大魔力值 ×0.04 的伤害。生物的缓慢效","color":"gray","italic":false},{"text":"果在领域内结束时，额外对其造成一次相","color":"gray","italic":false},{"text":"当于自身基础攻击力 ×4 的伤害，并将其","color":"gray","italic":false},{"text":"向领域外击退最多 1 格；每个生物整次领","color":"gray","italic":false},{"text":"域最多触发一次该结束效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["late_court","staff","itemreplace"],skill:"sweetdream:late_court",tags:["max_mana","base_atk","debuff","slow","dash","field","formation"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
