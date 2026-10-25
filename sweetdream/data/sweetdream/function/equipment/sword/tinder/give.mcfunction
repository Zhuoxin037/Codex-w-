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
give @s netherite_sword[item_name={text:"火种",bold:true,color:red},lore=[{"text":"✦ 火种","color":"gold","bold":true,"italic":false},{"text":"手持时，若自身魔力值大于 400 且","color":"gray","italic":false},{"text":"「火种」处于熄灭状态则消耗 350 点魔力","color":"gray","italic":false},{"text":"值并使「火种」变为燃烧状态。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"「火种」处于燃烧状态时，攻击生物时将","color":"gray","italic":false},{"text":"会对其 2 格内的全部生物造成相当于自身","color":"gray","italic":false},{"text":"当前魔力值 ×0.1 的伤害，之后使未处于","color":"gray","italic":false},{"text":"燃烧状态的生物燃烧 5 秒并熄灭该武器。","color":"gray","italic":false},{"text":"处于熄灭状态时，攻击生物后会对自身造","color":"gray","italic":false},{"text":"成相当于自身最大生命值 ×0.3 的伤害并","color":"gray","italic":false},{"text":"使「火种」变为燃烧状态。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tinder","sword","itemreplace"],tags:["cur_mana","max_hp","debuff"]},tooltip_display={hidden_components:["unbreakable"]}]
