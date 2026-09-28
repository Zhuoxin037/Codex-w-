# ============================================================
# sweetdream:equipment/staff/wind_ontheground/give —— 给一把「风行于大地之上」
# ------------------------------------------------------------
# 【底材: 追溯指针(recovery_compass)】—— 按你的要求换的。
#   ⚠️ 提醒一句: 追溯指针**是可以合成的**(8 个回响碎片 + 1 个指南针),
#      所以它并不满足"不可合成"。真正不可合成的选项有:
#      下界之星 / 海洋之心 / 鹦鹉螺壳 / 潜影壳 / 回响碎片 / 知识之书 / 调试棒。
#      (后两个自带右键行为, 会和 consumable 打架, 不推荐。)
#      你要是后面想换, 改这一行的物品 id, 再同步改 deepsea/staff 的判定即可。
#   · 原版没有右键用途(它只是"指向死亡点"), 不会和 consumable 打架 ✅
#   · 样子无所谓 —— 你要用 Blockbench 做模型套上来
#   【模型】做好之后, 往这里加 `minecraft:item_model=` 指过去就行;
#   现在先不加 —— 模型文件还不存在的话物品会显示成"缺失模型", 反而更难看。
#   顺手也可以加 `minecraft:max_stack_size=1`。
#
# 【custom_data 三段 + skill】
#   "itemreplace"      -> 通用回手线认它(右键才触发、用完还手)
#   "wind_ontheground" -> 武器 id, 进度 equipment/staff/wind_ontheground 靠它认人
#   "staff"            -> 分类标记(剑/斧/弓/法杖/盔甲)
#   skill              -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
#
# 【还差什么】目前只有 give; 还缺 advancement + cast, 另外「风声」的层数机制也还没做。
#
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文。
#   正文**按你的原文一字不改**, 只按"文字宽度"等分硬切(每行约 16~20 个汉字宽);
#   唯一的例外: 切点如果正好落在数字/英文单词中间, 会往后挪一格,
#   免得出现 "×0." / "07" 这种被切碎的东西。
# ============================================================

give @s recovery_compass[item_name={text:"风行于大地之上",bold:true,color:"aqua"},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"当前魔力值 ×0.04","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻后自身获得1秒迅捷3。若自","color":"gray","italic":false},{"text":"身术阵占用已满则本次攻击伤害*2.5。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"550","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"120 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤X个术阵（X为自身当前剩余的可","color":"gray","italic":false},{"text":"召唤术阵数量）。每召唤一个术阵则自身对自","color":"gray","italic":false},{"text":"身12格内随机一个生物的5格内的全部生物造","color":"gray","italic":false},{"text":"成3次相当于自身最大魔力值*0.07的伤害，","color":"gray","italic":false},{"text":"每命中一个生物则为自身积攒一点「风声」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 风声","color":"gold","bold":true,"italic":false},{"text":"召唤完术阵后自身若有超过60点「风声」","color":"gray","italic":false},{"text":"则每超出一点都会为下一次自身使用最大","color":"gray","italic":false},{"text":"魔力值相关的技能伤害提升1%，之后每有","color":"gray","italic":false},{"text":"一点「风声」则自身最大魔力值提升相当","color":"gray","italic":false},{"text":"于「风声」*10的数值并对自身5格内的生","color":"gray","italic":false},{"text":"物造成5次相当于自身最大魔力值*0.04的","color":"gray","italic":false},{"text":"伤害，持续20秒。结束后清除「风声」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["wind_ontheground","staff","itemreplace"],skill:"sweetdream:wind_ontheground"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
