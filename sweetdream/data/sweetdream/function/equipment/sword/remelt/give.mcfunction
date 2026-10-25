# ============================================================
# sweetdream:equipment/sword/remelt/give —— 给一把「热熔」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】见 shadow_blade/give 的说明。
# 【lore 版式】统一走 .workbuddy/lore_fmt.py。
# ============================================================

give @s netherite_sword[item_model="sweetdream:remelt",item_name={text:"热熔",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":" ","italic":false},{"text":"每次攻击到附有「流火」效果的生物时都","color":"gray","italic":false},{"text":"有 20% 的几率将其转化为「夜火」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后每攻击一次都会同步使自身 8 格内","color":"gray","italic":false},{"text":"带有「夜火」的生物受到一次相当于自身","color":"gray","italic":false},{"text":"基础攻击力 ×2 的伤害，之后使其护甲值","color":"gray","italic":false},{"text":"归 0，持续 10 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["remelt","sword","itemreplace"],skill:"sweetdream:remelt",tags:["liuhuo","yehuo","base_atk","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
