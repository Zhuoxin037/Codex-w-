# ============================================================
# sweetdream:equipment/staff/triad/give —— 给一件「很冰的斧」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "triad" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["triad"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【法杖三形态】★ 名字先按初始形态「很冰的斧」；切形态改名属"效果", 本批不做。
#   普攻 50: 冰斧 = 最大魔力 ×0.02 / 热刀 = 基础攻击力 ×3 / 重枪 = 基础攻击力 ×6。
#   形态被动: 冰斧 20% 冰冻 1 秒 / 热刀 40% 下次攻击额外 2 次 / 重枪 下次攻击为空。
#   主动 500 / 80 秒: 再按一次提前切下一把; 术阵 + 15 秒强化(冰斧 60% 且伤害取 最大魔力 ×0.05 /
#   热刀 100% 且每次 -1 护甲、3 次 -1 护甲韧性 / 重枪 不再为空 + 抗性提升失效 2 秒), 结束切回冰斧。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 本批只做 give（2026-10-11 用户定）: 技能 / 进度 / 外观 等后续批次再接。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:triad" + items/*.json + models/ + 贴图。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"很冰的斧",bold:true,color:gold},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"50","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"武器初始默认为「很冰的斧」。","color":"gray","italic":false},{"text":"「很冰的斧」的伤害为自身最大魔力值","color":"gray","italic":false},{"text":"×0.02，「很热的刀」为自身基础攻击力","color":"gray","italic":false},{"text":"×3，「很重的枪」为自身基础攻击力 ×6。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"「很冰的斧」每次攻击生物后都有 20% 的","color":"gray","italic":false},{"text":"概率使其冰冻 1 秒；「很热的刀」每次攻","color":"gray","italic":false},{"text":"击后都有 40% 的概率使下一次攻击额外发","color":"gray","italic":false},{"text":"射 2 次；「很重的枪」每次攻击后下一次","color":"gray","italic":false},{"text":"攻击为空。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后若再次使用该技能则切换武器至下","color":"gray","italic":false},{"text":"一把。使用后召唤一个术阵。武器被动强","color":"gray","italic":false},{"text":"化：「很冰的斧」概率提升至 60% 且伤害","color":"gray","italic":false},{"text":"提升至自身最大魔力值 ×0.05；","color":"gray","italic":false},{"text":"「很热的刀」概率提升为 100% 且每次攻","color":"gray","italic":false},{"text":"击都会使目标 -1 护甲值，命中 3 次后使","color":"gray","italic":false},{"text":"其 -1 护甲韧性，技能结束后恢复；","color":"gray","italic":false},{"text":"「很重的枪」下一次攻击不再会为空且每","color":"gray","italic":false},{"text":"次攻击都会使其抗性提升失效 2 秒。本效","color":"gray","italic":false},{"text":"果持续 15 秒，结束后切回「很冰的斧」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["triad","staff","itemreplace"],skill:"sweetdream:triad",tags:["max_mana","base_atk","formation","freeze","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
