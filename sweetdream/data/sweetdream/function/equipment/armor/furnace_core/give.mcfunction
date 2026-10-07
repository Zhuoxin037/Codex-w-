# ============================================================
# sweetdream:equipment/armor/furnace_core/give —— 给一件「炉心」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "furnace_core" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["furnace_core"]}(部分匹配 + 独有标记)
# 【注意别和「天使核心」(angel_core)搞混】两件是不同的东西。
# 【属性加成要双写】原版 attribute modifier + 面板 base_attack/max_health,
#   同 id modifier 必须"无条件 remove 再 add"(见 RULES 通用约定)。
# 【X/Y 会随层数变】按差值加减, 别直接 set; "最低为 3 / 5"是保底。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_chestplate[item_name={text:"炉心",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +100，最大生命值 +10，","color":"gray","italic":false},{"text":"基础攻击力 +5。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 燃灰","color":"gold","bold":true,"italic":false},{"text":"自身每攻击一次处于燃烧状态的生物则积","color":"gray","italic":false},{"text":"攒一层「燃灰」（最大为 10 层）。每有","color":"gray","italic":false},{"text":"一层「燃灰」则自身魔力值上限 +30，基","color":"gray","italic":false},{"text":"础攻击力 +X(X 为自身当前基础攻击力","color":"gray","italic":false},{"text":"×0.1，最低为 3)，最大生命值 +Y(Y 为自","color":"gray","italic":false},{"text":"身当前最大生命值 ×0.1，最低为 5)，且","color":"gray","italic":false},{"text":"每秒恢复 1 点魔力值。「燃灰」每 3 秒","color":"gray","italic":false},{"text":"-1 层。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["furnace_core","chestplate","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
