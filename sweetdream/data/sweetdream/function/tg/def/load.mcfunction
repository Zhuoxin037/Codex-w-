# ============================================================
# sweetdream:tg/def/load —— 标签体系的运行时反查表(批 A)
# ------------------------------------------------------------
# 【这个文件是生成的】改词表/逐件标签请改 .workbuddy/_tags_data.py
#   再跑 `python .workbuddy/_gen_tags.py --write`。守门: _chk_tags.py
# 【三张表】
#   tgdef."<词>"      = {cat,label,desc}  词汇表(人读 / 校验)
#   tge."<装备id>"    = ["标签",…]        装备→标签(地图可直接 data get)
#   tgidx."<词>"      = ["装备id",…]      标签→装备(反查; tg/api/ids 用)
# 【匹配】物品上 custom_data.tags 是列表, 谓词列表匹配=「包含」语义:
#   custom_data~{zx:["staff"],tags:["dash"]}  类别+语义一条谓词同时查(AND)
#   any / at_least:N  跑 N 次单标签判定再并集 / 计数
# ============================================================

# ---- 词汇表(tgdef): 27 词 ----
data modify storage zx:config tgdef set value {}
data modify storage zx:config tgdef."liuhuo" set value {cat:"状态",label:"流火",desc:"lore 涉及「流火」状态"}
data modify storage zx:config tgdef."yehuo" set value {cat:"状态",label:"夜火",desc:"lore 涉及「夜火」状态"}
data modify storage zx:config tgdef."shixin" set value {cat:"状态",label:"噬心",desc:"lore 涉及「噬心」状态"}
data modify storage zx:config tgdef."yuanhai" set value {cat:"状态",label:"渊海",desc:"lore 涉及「渊海」状态"}
data modify storage zx:config tgdef."dream" set value {cat:"状态",label:"白昼梦",desc:"lore 涉及「白昼梦」状态"}
data modify storage zx:config tgdef."max_hp" set value {cat:"数值",label:"最大生命值",desc:"涉及「最大生命值 / 生命值上限」（含属性加成）"}
data modify storage zx:config tgdef."base_atk" set value {cat:"数值",label:"基础攻击力",desc:"涉及「基础攻击力 / 基础伤害」（含属性加成）"}
data modify storage zx:config tgdef."max_mana" set value {cat:"数值",label:"最大魔力值",desc:"涉及「最大魔力值 / 魔力值上限」（含属性加成）"}
data modify storage zx:config tgdef."cur_mana" set value {cat:"数值",label:"当前魔力值",desc:"涉及「当前魔力值 / 剩余魔力 / 消耗的魔力」"}
data modify storage zx:config tgdef."true_dmg" set value {cat:"数值",label:"真实伤害",desc:"伤害记为真实伤害"}
data modify storage zx:config tgdef."flat" set value {cat:"数值",label:"固定值",desc:"保底 / 固定值伤害"}
data modify storage zx:config tgdef."debuff" set value {cat:"机制",label:"削弱",desc:"给敌方挂负面状态（缓慢/虚弱/发光/反胃/燃烧/冰冻/时停/护甲减半/击退…）"}
data modify storage zx:config tgdef."heal" set value {cat:"机制",label:"治疗",desc:"治疗 / 回血（★ 目前无装备使用，保留备用）"}
data modify storage zx:config tgdef."consume" set value {cat:"机制",label:"消耗",desc:"消耗 / 清除某个状态（消耗流火 / 清除渊海 / 移除噬心…）"}
data modify storage zx:config tgdef."apply" set value {cat:"机制",label:"附加",desc:"给目标施加某个状态（附加流火 / 附加圣痕 / 附加电刺…）"}
data modify storage zx:config tgdef."buff" set value {cat:"机制",label:"增益",desc:"给自身挂正向状态效果（力量/迅捷/再生/抗性/抗火/水下呼吸…）"}
data modify storage zx:config tgdef."cd_down" set value {cat:"机制",label:"减冷却",desc:"冷却时间 -N 秒 / 立即结束 / 刷新"}
data modify storage zx:config tgdef."indep_mul" set value {cat:"机制",label:"独立乘区",desc:"明确写「独立乘区」或「技能伤害 +N%」（独立乘区）"}
data modify storage zx:config tgdef."summon" set value {cat:"机制",label:"召唤物",desc:"召唤独立实体（lore 用“”标出）"}
data modify storage zx:config tgdef."dash" set value {cat:"机制",label:"位移",desc:"突进 / 瞬移 / 闪回 / 跃升 / 俯冲 / 击退"}
data modify storage zx:config tgdef."attract" set value {cat:"机制",label:"吸引",desc:"把生物拉向中心"}
data modify storage zx:config tgdef."field" set value {cat:"机制",label:"领域",desc:"★ 仅 lore 明确写「领域」（威霆 / 神裁）"}
data modify storage zx:config tgdef."formation" set value {cat:"机制",label:"术阵",desc:"★ 凡 lore 出现「术阵」"}
data modify storage zx:config tgdef."timestop" set value {cat:"机制",label:"时停",desc:"时停 / 定身"}
data modify storage zx:config tgdef."freeze" set value {cat:"机制",label:"冰冻",desc:"冰冻"}
data modify storage zx:config tgdef."slow" set value {cat:"机制",label:"减速",desc:"lore 里的「缓慢」"}
data modify storage zx:config tgdef."overlimit" set value {cat:"超限",label:"超限",desc:"超限形态（= 基础标签 + 本词；敲超限时追加）"}

# ---- 装备→标签(tge): 83 件 ----
data modify storage zx:config tge set value {}
data modify storage zx:config tge."agony" set value ["max_hp","base_atk","formation"]
data modify storage zx:config tge."anchor" set value ["max_mana","base_atk","dash"]
data modify storage zx:config tge."angel_core" set value ["max_mana","base_atk","apply","consume"]
data modify storage zx:config tge."anion" set value ["cur_mana"]
data modify storage zx:config tge."apocalypse" set value ["max_mana","cur_mana","formation","debuff"]
data modify storage zx:config tge."arc" set value ["cur_mana","base_atk"]
data modify storage zx:config tge."aurora_dream" set value ["dream","timestop"]
data modify storage zx:config tge."azure_star" set value ["max_mana","cur_mana","indep_mul"]
data modify storage zx:config tge."ballad" set value ["base_atk","true_dmg","timestop"]
data modify storage zx:config tge."begonia" set value ["yuanhai","max_mana","cur_mana","formation","attract","consume"]
data modify storage zx:config tge."bitter_cold" set value ["yuanhai","slow","debuff","apply"]
data modify storage zx:config tge."blaze_armor" set value ["liuhuo","max_mana","buff","debuff","apply"]
data modify storage zx:config tge."blaze_plume" set value ["liuhuo","debuff"]
data modify storage zx:config tge."bone_erode" set value ["cur_mana"]
data modify storage zx:config tge."brain_leech" set value ["max_mana","base_atk","buff"]
data modify storage zx:config tge."burst_dawn" set value ["max_mana","base_atk","formation","summon","slow","debuff"]
data modify storage zx:config tge."charge" set value ["cur_mana","formation","buff","cd_down"]
data modify storage zx:config tge."chenyuan" set value ["yuanhai","max_mana","cur_mana","cd_down","slow","debuff","apply"]
data modify storage zx:config tge."chime" set value ["max_mana","formation","summon"]
data modify storage zx:config tge."cloudtrail" set value ["base_atk","field"]
data modify storage zx:config tge."cold_crow" set value ["max_mana","freeze","debuff"]
data modify storage zx:config tge."crescent" set value ["base_atk","max_mana","cd_down"]
data modify storage zx:config tge."deepsea_echo" set value ["yuanhai","cur_mana","apply","buff"]
data modify storage zx:config tge."delusion" set value ["max_mana","formation","timestop"]
data modify storage zx:config tge."dionysus_helmet" set value ["max_mana","buff"]
data modify storage zx:config tge."dragon_tongue" set value ["liuhuo","yehuo","cur_mana","consume"]
data modify storage zx:config tge."draught" set value ["max_hp","base_atk","buff"]
data modify storage zx:config tge."dream_reader" set value ["dream","cur_mana","true_dmg","summon","timestop","apply"]
data modify storage zx:config tge."dusk_dawn" set value ["liuhuo","yehuo","yuanhai","dream","shixin","max_mana"]
data modify storage zx:config tge."ember" set value ["liuhuo","yehuo","max_mana","apply","consume","buff"]
data modify storage zx:config tge."eternity" set value ["liuhuo","yehuo","yuanhai","dream","shixin","max_mana","consume","apply"]
data modify storage zx:config tge."everfrost" set value ["cur_mana","freeze","debuff"]
data modify storage zx:config tge."external_power" set value ["max_mana","max_hp","buff"]
data modify storage zx:config tge."fade" set value ["max_mana","cd_down"]
data modify storage zx:config tge."fallen_dream" set value ["dream","max_mana","cur_mana","true_dmg","formation","timestop","apply"]
data modify storage zx:config tge."final_revelation" set value ["max_mana","slow","debuff"]
data modify storage zx:config tge."fissure" set value ["base_atk"]
data modify storage zx:config tge."five_curses" set value ["cur_mana","true_dmg","slow","debuff"]
data modify storage zx:config tge."flame_brokenbody" set value ["yehuo","max_mana","cd_down"]
data modify storage zx:config tge."flesh_mill" set value ["max_mana","buff"]
data modify storage zx:config tge."furnace_core" set value ["max_mana","max_hp","base_atk"]
data modify storage zx:config tge."grayscale" set value ["liuhuo","cur_mana","debuff","apply"]
data modify storage zx:config tge."gu_poison" set value ["shixin","max_hp","cur_mana","apply","slow","debuff","consume","formation"]
data modify storage zx:config tge."hengdao" set value ["max_mana","dash"]
data modify storage zx:config tge."hex_belt" set value ["max_mana"]
data modify storage zx:config tge."hush" set value ["max_mana","dash"]
data modify storage zx:config tge."immolate" set value ["liuhuo","yehuo","max_mana","debuff"]
data modify storage zx:config tge."intravenous_pump" set value ["max_mana","max_hp","buff"]
data modify storage zx:config tge."iridescent" set value ["dream","max_mana","base_atk","true_dmg","slow","debuff","dash","timestop","apply"]
data modify storage zx:config tge."lethe_shore" set value ["shixin","max_mana","buff","apply","indep_mul"]
data modify storage zx:config tge."liaoyuan" set value ["liuhuo","max_mana","apply","buff"]
data modify storage zx:config tge."lightless_sea" set value ["yuanhai","max_mana","base_atk","summon","slow","debuff","apply"]
data modify storage zx:config tge."liuguang" set value ["base_atk","flat"]
data modify storage zx:config tge."look" set value []
data modify storage zx:config tge."lucid_dream" set value ["dream","max_mana","cur_mana","true_dmg","timestop","consume","formation"]
data modify storage zx:config tge."mana_helm" set value ["max_mana"]
data modify storage zx:config tge."mana_plate" set value ["max_mana"]
data modify storage zx:config tge."mana_pump" set value ["max_mana"]
data modify storage zx:config tge."meteor" set value ["base_atk","slow","debuff"]
data modify storage zx:config tge."mirage" set value ["dream","max_mana","base_atk","true_dmg","apply","timestop"]
data modify storage zx:config tge."myriad" set value ["cur_mana"]
data modify storage zx:config tge."nullify" set value ["max_mana","formation","indep_mul"]
data modify storage zx:config tge."palette" set value ["max_mana","summon","cd_down"]
data modify storage zx:config tge."polarized_light" set value ["cur_mana","formation","slow","debuff"]
data modify storage zx:config tge."pyre" set value ["cur_mana","debuff"]
data modify storage zx:config tge."qiansan" set value ["base_atk"]
data modify storage zx:config tge."rainbow" set value ["liuhuo","yehuo","yuanhai","dream","shixin","max_hp","consume"]
data modify storage zx:config tge."rebound" set value ["base_atk","consume"]
data modify storage zx:config tge."red_lotus" set value ["liuhuo","yehuo","base_atk","consume"]
data modify storage zx:config tge."remelt" set value ["liuhuo","yehuo","base_atk","debuff"]
data modify storage zx:config tge."resonance" set value ["max_mana","indep_mul"]
data modify storage zx:config tge."rogue_star" set value ["base_atk","flat"]
data modify storage zx:config tge."sacred_relic" set value ["liuhuo","yehuo","shixin","yuanhai","dream","max_mana","max_hp","true_dmg","timestop","formation","summon"]
data modify storage zx:config tge."sail" set value ["yuanhai","liuhuo","dream","shixin","attract","apply","summon"]
data modify storage zx:config tge."scorch_bone" set value ["liuhuo","yehuo","base_atk","max_mana","apply","consume"]
data modify storage zx:config tge."sculk_echo" set value ["base_atk"]
data modify storage zx:config tge."seraph_wing" set value ["base_atk","indep_mul"]
data modify storage zx:config tge."shadow_blade" set value ["base_atk","dash","cd_down"]
data modify storage zx:config tge."sickle_dreams" set value ["shixin","max_mana","apply","timestop","consume"]
data modify storage zx:config tge."skyvault" set value ["max_mana","base_atk","dash","cd_down","debuff"]
data modify storage zx:config tge."spine_symbiote" set value ["max_mana","max_hp","buff"]
data modify storage zx:config tge."spirit_sight" set value ["liuhuo","yehuo","yuanhai","dream","shixin","max_mana","debuff"]
data modify storage zx:config tge."stellar_elegy" set value ["liuhuo","yehuo","yuanhai","dream","shixin","max_mana","cur_mana","buff"]
data modify storage zx:config tge."styx_walk" set value ["shixin","max_mana","summon","apply","slow","debuff","indep_mul"]
data modify storage zx:config tge."thunder" set value ["max_mana"]
data modify storage zx:config tge."thunderclap" set value ["max_mana","cur_mana","max_hp","formation","field","debuff"]
data modify storage zx:config tge."tidemark" set value ["yuanhai","max_mana","apply"]
data modify storage zx:config tge."tinder" set value ["cur_mana","max_hp","debuff"]
data modify storage zx:config tge."triad" set value ["max_mana","base_atk","formation","freeze","debuff"]
data modify storage zx:config tge."twilight" set value ["shixin","max_mana","apply","debuff"]
data modify storage zx:config tge."verdict" set value ["max_mana","base_atk","debuff","field"]
data modify storage zx:config tge."wind_ontheground" set value ["max_mana","cur_mana","formation","buff"]
data modify storage zx:config tge."withered_garden" set value ["yuanhai","max_mana","summon","apply","slow","debuff","buff"]
data modify storage zx:config tge."wrath" set value ["max_mana","buff","indep_mul"]

# ---- 标签→装备(tgidx): 反查索引 ----
data modify storage zx:config tgidx set value {}
data modify storage zx:config tgidx."liuhuo" set value ["blaze_armor","blaze_plume","dragon_tongue","dusk_dawn","ember","eternity","grayscale","immolate","liaoyuan","rainbow","red_lotus","remelt","sacred_relic","sail","scorch_bone","spirit_sight","stellar_elegy"]
data modify storage zx:config tgidx."yehuo" set value ["dragon_tongue","dusk_dawn","ember","eternity","flame_brokenbody","immolate","rainbow","red_lotus","remelt","sacred_relic","scorch_bone","spirit_sight","stellar_elegy"]
data modify storage zx:config tgidx."shixin" set value ["dusk_dawn","eternity","gu_poison","lethe_shore","rainbow","sacred_relic","sail","sickle_dreams","spirit_sight","stellar_elegy","styx_walk","twilight"]
data modify storage zx:config tgidx."yuanhai" set value ["begonia","bitter_cold","chenyuan","deepsea_echo","dusk_dawn","eternity","lightless_sea","rainbow","sacred_relic","sail","spirit_sight","stellar_elegy","tidemark","withered_garden"]
data modify storage zx:config tgidx."dream" set value ["aurora_dream","dream_reader","dusk_dawn","eternity","fallen_dream","iridescent","lucid_dream","mirage","rainbow","sacred_relic","sail","spirit_sight","stellar_elegy"]
data modify storage zx:config tgidx."max_hp" set value ["agony","draught","external_power","furnace_core","gu_poison","intravenous_pump","rainbow","sacred_relic","spine_symbiote","thunderclap","tinder"]
data modify storage zx:config tgidx."base_atk" set value ["agony","anchor","angel_core","arc","ballad","brain_leech","burst_dawn","cloudtrail","crescent","draught","fissure","furnace_core","iridescent","lightless_sea","liuguang","meteor","mirage","qiansan","rebound","red_lotus","remelt","rogue_star","scorch_bone","sculk_echo","seraph_wing","shadow_blade","skyvault","triad","verdict"]
data modify storage zx:config tgidx."max_mana" set value ["anchor","angel_core","apocalypse","azure_star","begonia","blaze_armor","brain_leech","burst_dawn","chenyuan","chime","cold_crow","crescent","delusion","dionysus_helmet","dusk_dawn","ember","eternity","external_power","fade","fallen_dream","final_revelation","flame_brokenbody","flesh_mill","furnace_core","hengdao","hex_belt","hush","immolate","intravenous_pump","iridescent","lethe_shore","liaoyuan","lightless_sea","lucid_dream","mana_helm","mana_plate","mana_pump","mirage","nullify","palette","resonance","sacred_relic","scorch_bone","sickle_dreams","skyvault","spine_symbiote","spirit_sight","stellar_elegy","styx_walk","thunder","thunderclap","tidemark","triad","twilight","verdict","wind_ontheground","withered_garden","wrath"]
data modify storage zx:config tgidx."cur_mana" set value ["anion","apocalypse","arc","azure_star","begonia","bone_erode","charge","chenyuan","deepsea_echo","dragon_tongue","dream_reader","everfrost","fallen_dream","five_curses","grayscale","gu_poison","lucid_dream","myriad","polarized_light","pyre","stellar_elegy","thunderclap","tinder","wind_ontheground"]
data modify storage zx:config tgidx."true_dmg" set value ["ballad","dream_reader","fallen_dream","five_curses","iridescent","lucid_dream","mirage","sacred_relic"]
data modify storage zx:config tgidx."flat" set value ["liuguang","rogue_star"]
data modify storage zx:config tgidx."debuff" set value ["apocalypse","bitter_cold","blaze_armor","blaze_plume","burst_dawn","chenyuan","cold_crow","everfrost","final_revelation","five_curses","grayscale","gu_poison","immolate","iridescent","lightless_sea","meteor","polarized_light","pyre","remelt","skyvault","spirit_sight","styx_walk","thunderclap","tinder","triad","twilight","verdict","withered_garden"]
data modify storage zx:config tgidx."consume" set value ["angel_core","begonia","dragon_tongue","ember","eternity","gu_poison","lucid_dream","rainbow","rebound","red_lotus","scorch_bone","sickle_dreams"]
data modify storage zx:config tgidx."apply" set value ["angel_core","bitter_cold","blaze_armor","chenyuan","deepsea_echo","dream_reader","ember","eternity","fallen_dream","grayscale","gu_poison","iridescent","lethe_shore","liaoyuan","lightless_sea","mirage","sail","scorch_bone","sickle_dreams","styx_walk","tidemark","twilight","withered_garden"]
data modify storage zx:config tgidx."buff" set value ["blaze_armor","brain_leech","charge","deepsea_echo","dionysus_helmet","draught","ember","external_power","flesh_mill","intravenous_pump","lethe_shore","liaoyuan","spine_symbiote","stellar_elegy","wind_ontheground","withered_garden","wrath"]
data modify storage zx:config tgidx."cd_down" set value ["charge","chenyuan","crescent","fade","flame_brokenbody","palette","shadow_blade","skyvault"]
data modify storage zx:config tgidx."indep_mul" set value ["azure_star","lethe_shore","nullify","resonance","seraph_wing","styx_walk","wrath"]
data modify storage zx:config tgidx."summon" set value ["burst_dawn","chime","dream_reader","lightless_sea","palette","sacred_relic","sail","styx_walk","withered_garden"]
data modify storage zx:config tgidx."dash" set value ["anchor","hengdao","hush","iridescent","shadow_blade","skyvault"]
data modify storage zx:config tgidx."attract" set value ["begonia","sail"]
data modify storage zx:config tgidx."field" set value ["cloudtrail","thunderclap","verdict"]
data modify storage zx:config tgidx."formation" set value ["agony","apocalypse","begonia","burst_dawn","charge","chime","delusion","fallen_dream","gu_poison","lucid_dream","nullify","polarized_light","sacred_relic","thunderclap","triad","wind_ontheground"]
data modify storage zx:config tgidx."timestop" set value ["aurora_dream","ballad","delusion","dream_reader","fallen_dream","iridescent","lucid_dream","mirage","sacred_relic","sickle_dreams"]
data modify storage zx:config tgidx."freeze" set value ["cold_crow","everfrost","triad"]
data modify storage zx:config tgidx."slow" set value ["bitter_cold","burst_dawn","chenyuan","final_revelation","five_curses","gu_poison","iridescent","lightless_sea","meteor","polarized_light","styx_walk","withered_garden"]
