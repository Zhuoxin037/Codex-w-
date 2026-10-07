# ============================================================
# sweetdream:equipment/armor/flesh_mill/give —— 给一件「血肉磨坊」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "flesh_mill" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["flesh_mill"]}(部分匹配 + 独有标记)
# 【被动 + 二件套】受伤后每秒 +2 魔力 + 再生Ⅱ, 持续 5 秒。
#   二件套 =【魔化腰带 + 血肉磨坊】: 上限 +80, 每秒额外 +1 魔力。
#   ★ 与「聚魔」(头盔+胸甲)是两套独立的, 别再凑成四件套(见 hex_belt 的注)。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s iron_boots[item_name={text:"血肉磨坊",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"穿戴时，自身受到伤害后则每秒获得 2 魔","color":"gray","italic":false},{"text":"力值及再生Ⅱ效果，持续 5 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 魔化腰带","color":"gray","italic":false},{"text":"● 血肉磨坊","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +80。每秒额外获得 1 魔","color":"gray","italic":false},{"text":"力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["flesh_mill","boots","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
