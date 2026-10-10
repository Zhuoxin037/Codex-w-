# ============================================================
# sweetdream:equipment/axe/meteor/give —— 给一把「陨星」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】见 shadow_blade/give 的说明。
# 【lore 版式】统一走 .workbuddy/lore_fmt.py。
# ============================================================

give @s diamond_axe[item_model="sweetdream:meteor",item_name={text:"陨星",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次攻击都有 10% 的概率对自身 2 格内","color":"gray","italic":false},{"text":"的随机一个生物及自身攻击的生物降下一","color":"gray","italic":false},{"text":"个陨石，且对其造成相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×4 的伤害，之后使其获得 2 秒缓慢Ⅱ","color":"gray","italic":false},{"text":"效果。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后攻击间隔大幅度缩小，且被动概率","color":"gray","italic":false},{"text":"提升为 50%，持续 10 秒。期间若切换主","color":"gray","italic":false},{"text":"手武器则该效果失效。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["meteor","axe","itemreplace"],skill:"sweetdream:meteor",tags:["base_atk","slow","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
