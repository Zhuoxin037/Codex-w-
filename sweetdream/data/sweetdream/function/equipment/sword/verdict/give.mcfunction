# ============================================================
# sweetdream:equipment/sword/verdict/give —— 给一件「神裁」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "verdict" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["verdict"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【被动 + 主动两段】被动: 魔力≥50 时 25% 消耗 50 -> 被击者 2 格内 ×2 + 虚弱Ⅱ/缓慢Ⅱ/发光 8 秒。
#   主动: 380 / 10 秒 -> 自身 6 格内至多 2 个 ×0.1, 落点生成半径 2 的领域 3 秒, 每秒 ×3。
# 【★ 该被动是"每次攻击后"口径】平A一下算一次(命中几只都一样), 实装要按刻去重(check `atkonce`)。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_sword[item_model="sweetdream:verdict",item_name={text:"神裁",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次攻击后若自身有 50 及以上的魔力值，","color":"gray","italic":false},{"text":"则有 25% 的概率消耗 50 魔力值并对被攻","color":"gray","italic":false},{"text":"击的生物的 2 格内的全部生物造成相当于","color":"gray","italic":false},{"text":"自身基础攻击力 ×2 的伤害，并使受到伤","color":"gray","italic":false},{"text":"害的生物获得虚弱Ⅱ、缓慢Ⅱ及发光效果，","color":"gray","italic":false},{"text":"持续 8 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"380","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"10 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使自身 6 格内的至多 2 个生物受到相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.1 的伤害，之后在","color":"gray","italic":false},{"text":"受到伤害的生物处生成一个持续 3 秒的半","color":"gray","italic":false},{"text":"径 2 格的领域，在领域中的生物每秒受到","color":"gray","italic":false},{"text":"一次相当于施放者基础攻击力 ×3 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["verdict","sword","itemreplace"],skill:"sweetdream:verdict",tags:["max_mana","base_atk","debuff","field","slow"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
