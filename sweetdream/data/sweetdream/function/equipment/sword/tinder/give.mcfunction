# ============================================================
# sweetdream:equipment/sword/tinder/give —— 给一件「火种」（剑）
# ------------------------------------------------------------
# 【custom_data】
#   "tinder" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["tinder"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【没有主动技能】整把武器就一个「火种」状态机, 不开右键 -> 不加 consumable/skill。
# 【★ 「火种」是这把武器独有的状态】燃烧/熄灭两态; 燃烧态攻击后熄灭, 熄灭态攻击反噬自己。
#   魔力>400 且熄灭态时手持自动点燃(消耗 350 魔力) —— 这就是它的"充能"方式。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_sword[item_name={text:"火种",bold:true,color:red},lore=[{"text":"✦ 火种","color":"gold","bold":true,"italic":false},{"text":"手持时，若自身魔力值大于 400 且","color":"gray","italic":false},{"text":"「火种」为熄灭状态则消耗 350 点魔力值","color":"gray","italic":false},{"text":"并使「火种」变为燃烧状态。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"「火种」为燃烧状态时，攻击生物时将会","color":"gray","italic":false},{"text":"对其 2 格内的全部生物造成相当于自身当","color":"gray","italic":false},{"text":"前魔力值 ×0.1 的伤害，之后使未处于燃","color":"gray","italic":false},{"text":"烧状态的生物燃烧 5 秒并熄灭该武器。为","color":"gray","italic":false},{"text":"熄灭状态时，攻击生物后会对自身造成相","color":"gray","italic":false},{"text":"当于自身最大生命值 ×0.3 的伤害并使","color":"gray","italic":false},{"text":"「火种」变为燃烧状态。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tinder","sword","itemreplace"],tags:["cur_mana","max_hp","debuff"]},tooltip_display={hidden_components:["unbreakable"]}]
