# ============================================================
# sweetdream:equipment/armor/mana_helm/give —— 给一件「聚魔头盔」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "mana_helm" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["mana_helm"]}(部分匹配 + 独有标记)
# 【纯被动 + 二件套】魔力值上限 +10; 与「聚魔胸甲」同穿再 +20。
#   ★ 套装成员只有【聚魔头盔 + 聚魔胸甲】两件 —— 2026-10-08 事故: 我曾凭
#   "腰带/靴也是盔甲" 把魔化腰带、血肉磨坊也划进来, 还编了个四件套
#   (+80 上限 / 每秒 +1)。用户从未这么说过, 已撤。名字里带"聚魔"才是一套。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_helmet[item_name={text:"聚魔头盔",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +10。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 聚魔头盔","color":"gray","italic":false},{"text":"● 聚魔胸甲","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +20。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["mana_helm","helmet","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
