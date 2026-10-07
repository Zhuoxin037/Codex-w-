# ============================================================
# sweetdream:overlimit/def/load —— 超限定义表(由 core/load 调用)
# ------------------------------------------------------------
# 【存在哪】zx:config oldef."<武器id>" = {label:"..", name:{..}, note:"..", dmg:.., mana:.., cd:.., lore:[..]}
#   label = 中文全名(纯文本, 只给脚本/文档看)
#   name  = 【★ 物品**改名**成什么 ★】直接就是 item_name 组件, 整段拷到物品上
#           (见 overlimit/api/name_seed)。所以这里的写法必须是完整的文本组件,
#           想加粗/上色就在这写: {"text":"超限·流光","bold":true,"color":"light_purple"}
#           ⚠️ 它是**数据**, 不走宏, 所以双引号随便用。
#   note  = 一句话备注(目前不显示, 只当注释)
#   dmg   = 超限后整把武器伤害乘区加算(0.25 = +25%) —— 乘进该技能所用的那条
#           技能倍率通道(max_mana_mul / attack_mul / other_mul, 见 overlimit/api/mod)
#   mana  = 魔力消耗乘区加算(+0.30 = 耗蓝多 30%)   —— 乘进 check / consume 的 mana
#   cd    = 冷却乘区加算(+0.25 = 冷却长 25%)       —— 乘进 cooldown_seconds
#   lore  = 【★ 超限后的**整段描述**★】敲上之后物品的描述会被它**整段替换**,
#           不再是"原描述 + 追加一行"(玩家没法从追加行里看懂技能变成什么了)。
#           见 station/api/lore_refresh 的 ②。
#
# 【★ 超限 = 改名 + 整段换描述 ★】敲上之后物品会 ① 改名成 name 里的名字(超限·XX),
#   ② 描述整段换成 lore。原来那把武器的名字和描述都不再保留 ——
#   玩家拿在手里看到的就是"这是超限·流光, 它怎么用"。
#
# 【★ lore 必须和实装一致 ★】这三档数值由 overlimit/api/mod 在每个耗蓝/冷却/
#   技能倍率处真实乘进去(调用点见该函数注释)。所以 lore 里写的"魔力 325"
#   必须 = 原始 250 ×(1+0.30); 改了这个表, lore 里的数字要跟着改。
#
# 【每个武器一条】只有"和武器 id 对应的超限石"才敲得上(见 overlimit/api/fit)。
#   武器独有的那部分效果写在武器自己的超限钩子里(见文档)。
# 【字段写法限制】label / note / lore 里的字符串会被宏塞进 JSON 文本组件, 所以
#   不能出现英文双引号和反斜杠; 逗号、中文标点都可以。
# 【lore 排版】照抄 equipment/*/give:
#   ✦ 小标题(gold bold) / 拼色数值行 / 空行 {"text":" "} / 灰色正文(每行约 17.5~18.5 汉字宽硬切)。
#   ⚠️ **不要再写 "✦ 超限·XX" 这种总标题** —— 名字已经改成"超限·XX"了,
#      描述里再写一遍等于同一个名字印两行。
#   ⚠️ 也不要写"用法：……"这类收尾行 —— 右键怎么用是包内通用常识, 占地方。
# ============================================================

# 燎原: 伤害 +25% / 耗蓝 +30% / 冷却 +25%
#   -> 魔力 250 x1.30 = 325; 冷却 50 x1.25 = 62.5; 倍率 0.04 x1.25 = 0.05
data modify storage zx:config oldef."liaoyuan" set value {label:"超限·燎原",name:{"text":"超限·燎原","bold":true,"color":"light_purple"},note:"灼烧更强, 但更耗蓝、冷却更长",dmg:0.25,mana:0.30,cd:0.25,lore:[{"text":"","italic":false,"extra":[{"text":"伤害 ","color":"gray"},{"text":"+25%","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"耗蓝 ","color":"gray"},{"text":"+30%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"+25%","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"325","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"62.5 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后自身获得「超限·燎原」：18 秒内","color":"gray","italic":false},{"text":"每 2 秒对自身 5 格内的生物造成一次相","color":"gray","italic":false},{"text":"当于自身最大魔力值 ×0.05 的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 燎原","color":"gold","bold":true,"italic":false},{"text":"伤害每进行 3 次，其中第 3 次会额外使","color":"gray","italic":false},{"text":"受到伤害的生物附加「流火」。","color":"gray","italic":false}]}

# 风行: 伤害 +20% / 耗蓝 +20% / 冷却 +20%
#   -> 普攻 80 x1.20 = 96; 技能 550 x1.20 = 660; 冷却 120 x1.20 = 144
#      倍率 0.04 x1.20 = 0.048; 0.07 x1.20 = 0.084
data modify storage zx:config oldef."wind_ontheground" set value {label:"超限·风行于大地之上",name:{"text":"超限·风行于大地之上","bold":true,"color":"light_purple"},note:"风声相关效果增强",dmg:0.20,mana:0.20,cd:0.20,lore:[{"text":"","italic":false,"extra":[{"text":"伤害 ","color":"gray"},{"text":"+20%","color":"yellow"}]},{"text":"","italic":false,"extra":[{"text":"耗蓝 ","color":"gray"},{"text":"+20%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"+20%","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"96","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"当前魔力值 ×0.048","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻后自身获得 1 秒迅捷Ⅲ。若自身","color":"gray","italic":false},{"text":"术阵占用已满则本次攻击伤害 ×2.5。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"660","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"144 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 X 个术阵（X 为自身当前剩余","color":"gray","italic":false},{"text":"的可召唤术阵数量）。每召唤一个术阵则","color":"gray","italic":false},{"text":"自身对自身 12 格内随机一个生物的 5 格","color":"gray","italic":false},{"text":"内的全部生物造成 3 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.084 的伤害，每命中一个生物则","color":"gray","italic":false},{"text":"为自身积攒一点「风声」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 风声","color":"gold","bold":true,"italic":false},{"text":"召唤完术阵后自身若有超过 60 点","color":"gray","italic":false},{"text":"「风声」则每超出一点都会为下一次自身","color":"gray","italic":false},{"text":"使用最大魔力值相关的技能伤害提升 1%，","color":"gray","italic":false},{"text":"之后每有一点「风声」则自身最大魔力值","color":"gray","italic":false},{"text":"提升相当于「风声」×10 的数值并对自身","color":"gray","italic":false},{"text":"5 格内的生物造成 5 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.048 的伤害，持续 20 秒。结束","color":"gray","italic":false},{"text":"后清除「风声」。","color":"gray","italic":false}]}

# 流光: 数值上不动(三个乘区都 0), 超限给的是**一个新技能** ——
#   敲上之后右键放的就是「超限·流光」, 见 equipment/sword/liuguang/overlimit。
#   所以它的 lore 是整段新技能描述, 原本那条"锁定 1 个 / 8 格 / ×2 / 保底 6"
#   会被完全替换掉。
data modify storage zx:config oldef."liuguang" set value {label:"超限·流光",name:{"text":"超限·流光","bold":true,"color":"light_purple"},note:"超限后右键放的是全新技能",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"8 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"随机锁定自身 10 格内的 4 个生物，其中","color":"gray","italic":false},{"text":"一个必定为离自身最近，期间其获得缓慢","color":"gray","italic":false},{"text":"Ⅲ。3 秒后对其造成相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×4 的伤害（保底 15）。若其身上附有","color":"gray","italic":false},{"text":"「流火」或「夜火」则伤害翻倍。","color":"gray","italic":false}]}

# 脑髓蛭(盔甲) / 脊骨共生(盔甲): 三个乘区全 0 —— 超限给的是**改写被动数值 + 新机制**
#   (回魔 3->5 / 系数 0.03->0.05 / 「蛊虫」叠层), 实装见 equipment/armor/brain_leech
#   与 spine_symbiote 的 second/kill/attack。乘区留 0 是因为它们不在主手、不参与
#   overlimit/api/snap|mod 那条链路(那是武器的)。
#   ★ 名字与描述都会整段替换: 敲上之后拿在手里看到的就是"超限·脑髓蛭"。
data modify storage zx:config oldef."brain_leech" set value {label:"超限·脑髓蛭",name:{"text":"超限·脑髓蛭","bold":true,"color":"light_purple"},note:"蛊虫叠层: 攻击力随层数滚起来",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 -120，自身每秒额外恢复","color":"gray","italic":false},{"text":"5 点魔力值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 蛊虫","color":"gold","bold":true,"italic":false},{"text":"当魔力值满后，自身基础攻击力增加相当","color":"gray","italic":false},{"text":"于自身魔力值上限 ×0.05 的值，且每次攻","color":"gray","italic":false},{"text":"击后都会为自身增加 5 秒相当于自身魔力","color":"gray","italic":false},{"text":"值上限 ×0.02 的基础攻击力，并为自身附","color":"gray","italic":false},{"text":"加一层「蛊虫」。当「蛊虫」达到 10 层","color":"gray","italic":false},{"text":"后，自身不再增加基础攻击力及「蛊虫」，","color":"gray","italic":false},{"text":"改为每次攻击消耗一层「蛊虫」并为自身","color":"gray","italic":false},{"text":"增加 10 秒相当于自身魔力值上限 ×0.05","color":"gray","italic":false},{"text":"的基础攻击力（该效果在魔力值未满时也","color":"gray","italic":false},{"text":"生效）。「蛊虫」消耗至 0 层后重新开始","color":"gray","italic":false},{"text":"积累。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 脊骨共生","color":"gray","italic":false},{"text":"● 脑髓蛭","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值满后获得抗性提升Ⅱ及再生Ⅱ。","color":"gray","italic":false}]}

data modify storage zx:config oldef."spine_symbiote" set value {label:"超限·脊骨共生",name:{"text":"超限·脊骨共生","bold":true,"color":"light_purple"},note:"击杀滚护甲与生命, 与蛊虫联动",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 -180，每次击杀生物都会","color":"gray","italic":false},{"text":"恢复自身 80 点魔力值。当魔力值满后，","color":"gray","italic":false},{"text":"自身获得相当于自身魔力值上限 ×0.05 的","color":"gray","italic":false},{"text":"护甲值以及最大生命值。每次击杀生物后，","color":"gray","italic":false},{"text":"自身获得 20 秒相当于自身魔力值上限","color":"gray","italic":false},{"text":"×0.02 的护甲值以及最大生命值。若触发","color":"gray","italic":false},{"text":"该被动时自身也处于【脑髓蛭】的","color":"gray","italic":false},{"text":"「蛊虫」状态，则额外获得 5 秒抗性提升","color":"gray","italic":false},{"text":"Ⅴ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 脑髓蛭","color":"gray","italic":false},{"text":"● 脊骨共生","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值满后获得抗性提升Ⅱ及再生Ⅱ。","color":"gray","italic":false}]}

# ============================================================
# ---- 最后一批超限石(2026-10-08 实装): 万念 / 群星坠落之挽歌 / 黄昏黎明之交界 ----
# ------------------------------------------------------------
# 【★ 为什么多一条 oldef."qiansan" ★】万念超限后放技能会**换成千散**,
#   而换手是 item replace -> 换出来的是 give 那份原始组件串, 名字还叫「千散」、
#   描述还是原版。所以换手之后要**手动**把名字和 lore 换成超限版 ——
#   数据直接从 oldef."qiansan" 取(见 myriad/put_qian 与 qiansan/put_my 末尾)。
#   ⚠️ 它不是"能敲的石头": overlimit/api/fit 用 of 参数, 而没有任何石头会传
#      of:"qiansan"(只有 myriad 那块), 所以它不会被当作安装目标。
# 【★ 三块盔甲/剑的乘区都是 0 ★】它们要么不在主手(盔甲), 要么超限给的是
#   "整段换技能"而不是数值放大(万念/千散), overlimit/api/mod 对它们本就无调用点。
# ============================================================

data modify storage zx:config oldef."stellar_elegy" set value {label:"超限·群星坠落之挽歌",name:{"text":"超限·群星坠落之挽歌","bold":true,"color":"light_purple"},note:"上限 280->350, 抗性Ⅱ->Ⅲ, 回魔 10->2%, 5->6 格, ×0.02->×0.03, 附带随机效果",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +350。每次受到攻击后获","color":"gray","italic":false},{"text":"得抗性提升Ⅲ且自身每秒恢复 2% 魔力值，","color":"gray","italic":false},{"text":"持续 5 秒。之后使自身 6 格内全部有","color":"gray","italic":false},{"text":"「流火」、「夜火」、「渊海」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」中任意一个效果的","color":"gray","italic":false},{"text":"生物受到一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.03 的伤害并使其随机附加一个效果。","color":"gray","italic":false}]}

data modify storage zx:config oldef."dusk_dawn" set value {label:"超限·黄昏黎明之交界",name:{"text":"超限·黄昏黎明之交界","bold":true,"color":"light_purple"},note:"上限 180->250, 低魔线 50%->80%, 回 20->3%, 临时 8->12 秒, 带标签 +100->+100×X",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +250。若自身魔力值低于","color":"gray","italic":false},{"text":"魔力值上限 80% 则每秒获得 3% 魔力值。","color":"gray","italic":false},{"text":"自身杀死一个生物后自身临时获得 200 魔","color":"gray","italic":false},{"text":"力值上限，持续 12 秒。若杀死的生物有","color":"gray","italic":false},{"text":"「流火」、「夜火」、「渊海」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」中任意一个效果则","color":"gray","italic":false},{"text":"额外使自身获得 100×X 魔力值上限（X 为","color":"gray","italic":false},{"text":"该生物所有的效果数量）。","color":"gray","italic":false}]}

data modify storage zx:config oldef."myriad" set value {label:"超限·万念",name:{"text":"超限·万念","bold":true,"color":"light_purple"},note:"切千散 + 领域 + 特殊技能窗口 + 剑魂",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"180","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为【千散】并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.1 的伤害。若攻击到生物则召唤一个半","color":"gray","italic":false},{"text":"径为 5 格持续 6 秒的领域。之后若自身","color":"gray","italic":false},{"text":"处于领域中且攻击生物 5 次后则有 2 秒","color":"gray","italic":false},{"text":"时间可以释放一次特殊技能。本次技能的","color":"gray","italic":false},{"text":"效果为将【千散】切换回【万念】并对领","color":"gray","italic":false},{"text":"域内的生物使用一次【千散】的主动技能","color":"gray","italic":false},{"text":"效果。若原本就为【万念】则改为使用一","color":"gray","italic":false},{"text":"次【万念】的主动技能且本次伤害提高为","color":"gray","italic":false},{"text":"相当于自身最大魔力值 ×0.12。若自身没","color":"gray","italic":false},{"text":"有选择释放此次特殊技能则召唤一个相等","color":"gray","italic":false},{"text":"的领域，之后召唤一个“剑魂”。","color":"gray","italic":false}]}

data modify storage zx:config oldef."qiansan" set value {label:"超限·千散",name:{"text":"超限·千散","bold":true,"color":"light_purple"},note:"切万念 + 剑魂 + 居合(仅供换手时取名/换描述, 不是可敲的石头)",dmg:0.0,mana:0.0,cd:0.0,lore:[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"180","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后切换为【万念】并对自身 3 格内的","color":"gray","italic":false},{"text":"全部生物造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×3 的伤害。若攻击到生物则召唤一个“剑","color":"gray","italic":false},{"text":"魂”（最多为 5 个）。自身每有一个“剑","color":"gray","italic":false},{"text":"魂”则本武器的技能伤害则重复一次。自","color":"gray","italic":false},{"text":"身若主动使用了本武器技能则“剑魂”在","color":"gray","italic":false},{"text":"技能结束后清除（不包含本次技能积攒的","color":"gray","italic":false},{"text":"“剑魂”），手持切换为其它武器时一并","color":"gray","italic":false},{"text":"清除。若自身有 5 个“剑魂”且被动或主","color":"gray","italic":false},{"text":"动使用了该技能则进入 3 秒「居合」状态。","color":"gray","italic":false},{"text":"期间每使用技能切换【万念】或【千散】","color":"gray","italic":false},{"text":"都会使该效果延长一秒并使这两把武器下","color":"gray","italic":false},{"text":"一次技能伤害提升 20%（独立乘区）。","color":"gray","italic":false},{"text":"「居合」状态下每切换一次【万念】或","color":"gray","italic":false},{"text":"【千散】都会对造成了伤害的生物再次造","color":"gray","italic":false},{"text":"成一次相等的真实伤害。结束后清除“剑","color":"gray","italic":false},{"text":"魂”。","color":"gray","italic":false}]}
