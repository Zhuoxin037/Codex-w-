# ============================================================
# sweetdream:overlimit/item/liuguang —— 给一块「超限·流光」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_liuguang :
#   进度 advancement/overlimit/liuguang 靠它认"右键用掉了哪块超限石"。
# 【和升级石一样】不带 itemreplace(那是回手线的标记), 敲失败才退材料。
#
# 【★ 底座为什么统一 recovery_compass(追溯指针)★】(换过两次, 别再改回去)
#   v1 = netherite_upgrade_smithing_template —— 两个硬伤:
#     ① 原版会给锻造模板**追加它自己的锻造介绍**, 客户端按物品本身拼的, 改不掉。
#     ② 它在锻造台是真能用的消耗品, 会被误用。
#   v2 = nether_star —— 星形是超限家族的统一外观, 但玩家会拿它去**造信标**。
#   v3(现在) = recovery_compass —— 第一原则是"它不是任何配方的被消耗者":
#     追溯指针只有"被造出来"这一个方向(指南针 + 回响碎片), 没有任何配方吃它。
#   底座一样了 -> 靠 custom_model_data={floats:[7]} 换图标(八芒星)。
#     编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
#     升级石占 1..6, 超限石从 7 起步。
#
# 【lore 排版】照抄 equipment/*/give 的规范:
#   ✦ 小标题(gold bold) / 拼色数值行(魔力 aqua · 冷却 yellow) /
#   空行 {"text":" "} / 灰色正文(每行约 18 汉字宽硬切)。
#   ⚠️ 不写"用法：拿在主手右键…"这类收尾行 —— 全套材料都一样, 纯占地方。
#   数字和文字挤同一行就用 extra 拼, 别拆成两行。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·流光",bold:true,color:light_purple},custom_model_data={floats:[7.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"8 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"流光","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后流光更名为「超限·流光」，右键释","color":"gray","italic":false},{"text":"放全新技能：随机锁定自身 10 格内的 4","color":"gray","italic":false},{"text":"个生物，其中一个必定为离自身最近的一","color":"gray","italic":false},{"text":"个，期间其获得缓慢Ⅲ。3 秒后对其造成","color":"gray","italic":false},{"text":"相当于自身基础攻击力 ×4 的伤害","color":"gray","italic":false},{"text":"（保底 15）。若其身上附有「流火」或","color":"gray","italic":false},{"text":"「夜火」则伤害翻倍。","color":"gray","italic":false}],custom_data={zx:["ol_liuguang"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
