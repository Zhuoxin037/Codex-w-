# ============================================================
# sweetdream:overlimit/item/spine_symbiote —— 给一块「超限·脊骨共生」
# ------------------------------------------------------------
# 【custom_data】标记 ol_spine_symbiote, 进度 advancement/overlimit/spine_symbiote 认它。
# 【和升级石一样】不带 itemreplace(那是回手线的标记), 敲失败才退材料。
# 【底座】recovery_compass(理由见 brain_leech / liuguang 的注释)
#   + custom_model_data 编号 21(★ floats:[21.0f] 不能写成 [21])。
# 【图标已画】骨青八芒星(超限系列), 编号 21(八芒星, 无字母/无四角点 —— 与升级石一眼分开)。
#   画法/重跑: python .workbuddy/_gen_stone_icons.py (纯标准库点阵)
#
# 【目标装备】armor/spine_symbiote(脊骨共生)。本块是它的超限版本。
#   ★ 注意: 超限后上限是**减少** 180(不是增加) —— 用户明确写的是 -180。
# 【效果已实装】overlimit/apply/spine_symbiote + def/load 已登记; 击杀加成/蛊虫联动见 equipment/armor/spine_symbiote(2026-10-07)。
#
# 【lore 排版】照抄 equipment/*/give 的规范。⚠️ 不写"用法：右键…"收尾行。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·脊骨共生",bold:true,color:light_purple},custom_model_data={floats:[21.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"脊骨共生","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后脊骨共生更名为「超限·脊骨共生」，","color":"gray","italic":false},{"text":"其基础属性变为：自身魔力值上限 -180，","color":"gray","italic":false},{"text":"每次击杀生物都会恢复自身 80 点魔力值。","color":"gray","italic":false},{"text":"当魔力值满后，自身获得相当于自身魔力","color":"gray","italic":false},{"text":"值上限 ×0.05 的护甲值以及最大生命值，","color":"gray","italic":false},{"text":"且每次击杀生物后都会为自身增加 20 秒","color":"gray","italic":false},{"text":"相当于自身魔力值上限 ×0.02 的护甲值以","color":"gray","italic":false},{"text":"及最大生命值。若自身触发该被动时自身","color":"gray","italic":false},{"text":"也处于【脑髓蛭】的「蛊虫」被动状态时，","color":"gray","italic":false},{"text":"该被动效果强化为 ×0.05 且自身获得 5","color":"gray","italic":false},{"text":"秒抗性提升Ⅴ。","color":"gray","italic":false}],custom_data={zx:["ol_spine_symbiote"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
