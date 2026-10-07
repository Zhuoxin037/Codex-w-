# ============================================================
# sweetdream:equipment/axe/angel_core/give —— 给一把「天使核心」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】见 shadow_blade/give 的说明。
# 【「圣痕」存在哪】原生标签 zx.status.shenghen(只需要"在不在", 不需要层数)。
#   ⚠️ 它**没有**接进头顶图标系统(那套只认 渊海/流火/夜火/噬心/白昼梦 五种) ——
#      加图标要动资源包的字体贴图, 属于后续可做项, 不影响机制。
# 【lore 版式】统一走 .workbuddy/lore_fmt.py。
# ============================================================

give @s netherite_axe[item_name={text:"天使核心",bold:true,color:yellow},lore=[{"text":"✦ 圣痕","color":"gold","bold":true,"italic":false},{"text":"每次攻击后若自身有 80 及以上的魔力值，","color":"gray","italic":false},{"text":"则消耗 80 魔力值并使离自身 8 格内最近","color":"gray","italic":false},{"text":"的 3 个生物附加「圣痕」。「圣痕」15","color":"gray","italic":false},{"text":"秒后消失。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"50 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身 8 格内附加了「圣痕」的生","color":"gray","italic":false},{"text":"物造成相当于自身基础攻击力 ×8 的伤害，","color":"gray","italic":false},{"text":"重复 2 次。之后对自身 6 格内附加了","color":"gray","italic":false},{"text":"「圣痕」的生物 2 格内的全部生物造成相","color":"gray","italic":false},{"text":"当于自身最大魔力值 ×0.08 的伤害，重复","color":"gray","italic":false},{"text":"2 次。之后清除触发了第二段效果的","color":"gray","italic":false},{"text":"「圣痕」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["angel_core","axe","itemreplace"],skill:"sweetdream:angel_core"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
