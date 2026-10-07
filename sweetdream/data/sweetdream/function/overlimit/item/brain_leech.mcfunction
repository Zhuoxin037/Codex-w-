# ============================================================
# sweetdream:overlimit/item/brain_leech —— 给一块「超限·脑髓蛭」
# ------------------------------------------------------------
# 【custom_data】标记 ol_brain_leech, 进度 advancement/overlimit/brain_leech 认它。
# 【和升级石一样】不带 itemreplace(那是回手线的标记), 敲失败才退材料。
#
# 【★ 底座为什么统一 recovery_compass(追溯指针)★】(换过两次, 别再改回去)
#   v1 = netherite_upgrade_smithing_template —— 原版会追加它自己的锻造介绍, 改不掉;
#        且它在锻造台是真能用的消耗品, 会被误用。
#   v2 = nether_star —— 玩家会拿它去造信标。
#   v3(现在) = recovery_compass —— 它不是任何配方的被消耗者。
#   底座一样了 -> 靠 custom_model_data={floats:[20]} 换图标(八芒星)。
#     编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
#     升级石占 1..6, 超限石从 7 起步(7=流光, 20=脑髓蛭, 21=脊骨共生)。
# 【图标已画】绯红八芒星(超限系列), 编号 20(八芒星, 无字母/无四角点 —— 与升级石一眼分开)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
#
# 【目标装备】armor/brain_leech(脑髓蛭)。本块是它的超限版本。
#   ★ 注意: 超限后上限是**减少** 120(不是增加) —— 用户明确写的是 -120。
# 【效果已实装】overlimit/apply/brain_leech + def/load 已登记; 「蛊虫」机制见 equipment/armor/brain_leech(2026-10-07)。
#
# 【lore 排版】照抄 equipment/*/give 的规范:
#   ✦ 小标题(gold bold) / 拼色数值行 / 空行 {"text":" "} / 灰色正文。
#   ⚠️ 不写"用法：拿在主手右键…"这类收尾行 —— 全套材料都一样, 纯占地方。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·脑髓蛭",bold:true,color:light_purple},custom_model_data={floats:[20.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"脑髓蛭","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后脑髓蛭更名为「超限·脑髓蛭」，其","color":"gray","italic":false},{"text":"基础属性变为：自身魔力值上限 -120，自","color":"gray","italic":false},{"text":"身每秒额外恢复 5 点魔力值。当魔力值满","color":"gray","italic":false},{"text":"后，自身基础攻击力增加相当于自身魔力","color":"gray","italic":false},{"text":"值上限 ×0.05 的值，且每次攻击后都会为","color":"gray","italic":false},{"text":"自身增加 5 秒相当于自身魔力值上限","color":"gray","italic":false},{"text":"×0.02 的基础攻击力，并为自身附加一层","color":"gray","italic":false},{"text":"「蛊虫」。当「蛊虫」到达 10 层后则之","color":"gray","italic":false},{"text":"后不再增加基础攻击力及「蛊虫」，改为","color":"gray","italic":false},{"text":"消耗一层「蛊虫」且为自身增加 10 秒相","color":"gray","italic":false},{"text":"当于自身魔力值上限 ×0.05 的基础攻击力","color":"gray","italic":false},{"text":"（该效果在魔力值未满时也生效）。","color":"gray","italic":false}],custom_data={zx:["ol_brain_leech"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
