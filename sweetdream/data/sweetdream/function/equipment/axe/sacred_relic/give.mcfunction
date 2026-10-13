# ============================================================
# sweetdream:equipment/axe/sacred_relic/give —— 给一件「圣骸」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "sacred_relic" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["sacred_relic"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【被动 + 主动】被动: 玩家击杀的生物在死亡位置留 12 秒“遗骸”, 记住死者的最大生命与身上的标签。
#   主动: 400 / 40 秒 -> 术阵; 每秒让 12 格内全部“遗骸”打它 3 格内随机一只 最大魔力 ×0.1;
#   “遗骸”带「流火」伤害 +30% 且锁定范围 +1 格 / 「夜火」+80% / 「噬心」追加死者最大生命 5% 真伤 /
#   「白昼梦」追加 0.3 秒时停 / 「渊海」锁定目标 +2; 共 12 秒。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 圣骸外观已接入 sweetdream:sacred_relic；旧物品持有时自动补绑。
#   实际模型及统一 display 在 assets/sacredrelic/models/item/axe.json。
# ============================================================
give @s netherite_axe[item_model="sweetdream:sacred_relic",custom_model_data={floats:[0.0f]},item_name={text:"圣骸",bold:true,color:white},lore=[{"text":"✦ 遗骸","color":"gold","bold":true,"italic":false},{"text":"持有圣骸时，由玩家击杀的生物会在其死","color":"gray","italic":false},{"text":"亡位置留下持续 12 秒的“遗骸”。其会","color":"gray","italic":false},{"text":"保留死者死亡瞬间的两个信息：最大生命","color":"gray","italic":false},{"text":"和身上的标签。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"400","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。每秒使自身 12 格","color":"gray","italic":false},{"text":"内的全部“遗骸”对其 3 格内的随机一个","color":"gray","italic":false},{"text":"生物造成一次相当于释放者最大魔力值","color":"gray","italic":false},{"text":"×0.1 的伤害。若“遗骸”上有「流火」则","color":"gray","italic":false},{"text":"伤害 +30% 且锁定范围 +1 格；若有","color":"gray","italic":false},{"text":"「夜火」则伤害 +80%；若有「噬心」则额","color":"gray","italic":false},{"text":"外附加相当于死亡者最大生命值 5% 的真","color":"gray","italic":false},{"text":"实伤害；若有「白昼梦」则额外附加 0.3","color":"gray","italic":false},{"text":"秒的时停；若有「渊海」则锁定目标 +2。","color":"gray","italic":false},{"text":"共持续 12 秒。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:sacred_relic":1},enchantment_glint_override=false,custom_data={zx:["sacred_relic","axe","itemreplace"],skill:"sweetdream:sacred_relic",tags:["liuhuo","yehuo","shixin","yuanhai","dream","max_mana","max_hp","true_dmg","timestop","formation","summon"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
