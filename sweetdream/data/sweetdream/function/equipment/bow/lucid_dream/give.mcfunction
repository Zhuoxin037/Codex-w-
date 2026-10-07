# ============================================================
# sweetdream:equipment/bow/lucid_dream/give —— 给一件「清醒梦」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "lucid_dream" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["lucid_dream"]}(部分匹配 + 独有标记)
# 【X = 「梦回」层数】描述里那几个 X 不是笔误, 就是层数本身 —— 实现时
#   把层数读出来直接当代入值用, 别在描述里烘死成某个数字。
# 【和「幻昼」的「白昼梦」联动】判的是同一个效果名(zx.status.dream)。
# 【★ 漫彩期内的白昼梦处理 ★】文案是"消耗「白昼梦」且持续时间延长 X 秒"
#   —— 所以漫彩期间一旦发现该生物带白昼梦, 就**摘掉它**(tag/unmark dream)
#   并把 ld_end 往后推 X 秒(不是每格续命到白昼梦自然结束)。见 hit_extra。
# 【弩上的附魔】sweetdream:lucid_dream(见 enchantment/lucid_dream.json),
#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。
# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,
#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。
#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s crossbow[item_name={text:"清醒梦",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"180","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击若射击附加了「白昼梦」效果或","color":"gray","italic":false},{"text":"处于时停状态的生物，则累计一层","color":"gray","italic":false},{"text":"「梦回」（最多为 5 层）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 梦回","color":"gold","bold":true,"italic":false},{"text":"当「梦回」达到 3 层及以上后，再次射击","color":"gray","italic":false},{"text":"附有「白昼梦」的生物时对其造成相当于","color":"gray","italic":false},{"text":"自身当前魔力值 ×0.X 的伤害，之后清除","color":"gray","italic":false},{"text":"该生物的「白昼梦」并清除自身「梦回」，","color":"gray","italic":false},{"text":"之后召唤一个术阵。召唤术阵后该生物每","color":"gray","italic":false},{"text":"次受到攻击都会使自身 2 格内的全部生物","color":"gray","italic":false},{"text":"额外受到一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.0X 的真实伤害，持续 X 秒。若持续时","color":"gray","italic":false},{"text":"间内该生物被附加了「白昼梦」效果，则","color":"gray","italic":false},{"text":"消耗「白昼梦」效果且技能持续时间延长","color":"gray","italic":false},{"text":"X 秒（X 为「梦回」层数）。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:lucid_dream":1},custom_data={zx:["lucid_dream","bow"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
