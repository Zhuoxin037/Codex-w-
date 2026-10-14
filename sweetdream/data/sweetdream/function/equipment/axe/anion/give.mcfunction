# ============================================================
# sweetdream:equipment/axe/anion/give —— 给一把「负离子」（斧 · 稀有）
# ------------------------------------------------------------
# 【custom_data】"anion" -> 装备 id
#   ★ 判定一律写成 custom_data~{zx:["anion"]}(部分匹配 + 独有标记)
# 【数值要和实现对上】主动 魔力 40 / 冷却 30 秒; 6 格内随机 3 个生物;
#   伤害 = 自身**当前**魔力值 ×0.1(注意是当前不是最大, 别写成最大魔力)。
# 【★ 效果已实装(2026-10-06 晚)】进度 advancement/equipment/axe/anion.json
#   (consume_item -> equipment/axe/anion/cast) + cast.mcfunction。
#   custom_data 已补 skill:"sweetdream:anion"(推进度用不到它, 但保持全包一致写法)。
#   ★ 6 格内没有可打的目标时不放(不扣蓝/不进冷却) —— 同沉渊 cast ③。
# 【"稀有"怎么处理 —— 待用户确认】用户原文标了「负离子 - 稀有」。包里现在**没有**
#   稀有度系统(没搜到"稀有"两个字), 所以这里只把 item_name 用了 blue 色,
#   lore 里没写"稀有"字样(写了也没有任何系统认)。若以后要做稀有度, 再补标记。
# 【模型 / 底物】不写 item_model —— 斧走原版外观。
#   ★ 2026-10-06 用户要求: 底物由 netherite_axe 改为 **iron_axe**(外观变铁斧),
#     item_name 颜色 gold -> **blue**。
#     ⚠️ 换底物不影响数值: 本包"基础攻击力"取自 manacore 面板 stats.base_attack
#       (give 里既没有 attribute_modifiers、也没有任何地方按原版物品取伤害);
#       而技能触发走 custom_data~{zx:["anion"]}, 不认物品类型(全包唯一按类型判的是
#       angel_core/skyvault 的 hit, 与本件无关)。所以这纯粹是外观改动。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s iron_axe[item_model="sweetdream:anion",item_name={text:"负离子",bold:true,color:blue},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"40","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身 6 格内的随机 3 个生物释","color":"gray","italic":false},{"text":"放闪电，并对其造成相当于自身当前魔力","color":"gray","italic":false},{"text":"值 ×0.1 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["anion","axe","itemreplace"],skill:"sweetdream:anion",tags:["lightning","cur_mana"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
