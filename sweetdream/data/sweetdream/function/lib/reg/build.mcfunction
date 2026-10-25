# ============================================================
# sweetdream:lib/reg/build —— 「通用数值注册表」的构建(在 core/load 里跑一次)
# ------------------------------------------------------------
# 【这是干嘛的】
#   以前 debug/stats 里把"要显示哪些装备加成"**写死在代码里**
#   (只写死了静脉泵/桂冠/体外那几件), 所以新做的装备加了属性也看不见,
#   风行还单独占一个板块 —— 又乱又不通用。
#   现在改成: 显示什么由**这张表**决定, 代码只负责按表渲染。
#
# 【★ 2026-10-03 加了 e 字段: "穿着什么报什么" ★】
#   e = 这行加成**属于哪件装备**(就是 custom_data.zx[0] 那一段英文 id)。
#   debug/stats 每次都先扫一遍身上 6 个槽位, 只有"这件装备确实在身上"
#   的那些行才会被打印 —— 不再把所有装备一股脑全叠上来。
#     e:"intravenous_pump"    = 只有静脉泵穿在身上才显示
#     e:"all"                 = 全局行, 永远显示(合计账本/不属于单件的东西)
#   ⚠️ **漏写 e 的那一行永远不显示, 而且不报错** —— check.py 会抓。
#
# 【l 只写"分类", 别写装备名】
#   屏幕上长这样: "魔力上限 · 静脉泵    120"
#                  ^l    ^从 names 表查的全名
#   装备名统一从 names 表取 —— 想改名只改 names 一处, 这张表不用动。
#   全局行(e:"all")的 l 就是完整文字(因为没有装备名可拼)。
#
# 【★ 以后加了新装备/新武器有加成, 只要在下面加一行 ★】
#     data modify storage zx:reg b append value {l:"魔力上限",o:"zx.计分项",c:"aqua",n:"",e:"<装备id>"}
#   不用改任何别的文件。前提: ① 那个计分项得先在 core/load 里建出来
#   ② 装备 id 得在下面的 names 表里登记过。
#
# 【两张数值表】
#   b = 数值为 0 就不显示(账本类 —— 没穿的装备不该占地方)
#   a = 永远显示(状态类 —— 0 也是有效信息, 比如"风声 0")
#   ⚠️ 一行的字段(l/o/c/n/e)必须**都写全**: 宏参数少一个, 那条命令直接不跑
#      (不会报错, 更难查)。
#   ⚠️ l / n 会被塞进 tellraw 的 JSON 字符串里, **不要写英文双引号和反斜杠**。
#
# 【表位上限】b 最多 48 行, a 最多 8 行, menu 最多 12 行。
#   加超了就把 debug/reg_unroll 里的槽数补上, 同时改这里的 cap 和
#   .workbuddy/gen_reg_unroll.py 顶上的常量, 再跑一次那个脚本。
#   (check.py 会帮你数, 超了会报警。)
#
# 【另外两张表】
#   tg.*  = 每个 /trigger 调试入口(name 显示名 / fn 实际干的函数 / obj 计分项)
#   menu  = 菜单里按顺序列出来的入口(指向 tg 的键)
# ============================================================

# ---------- 建空表 ----------
#   【为什么要先 set []】debug/worn 之类会读 names, 而 load 可能被 reload 重跑;
#   不重置的话表会一直 append, 越滚越长(而且全是重复行)。
data modify storage zx:reg b set value []
data modify storage zx:reg a set value []
data modify storage zx:reg menu set value []
data modify storage zx:reg names set value {}

# ---------- 全局行哨兵表 ----------
#   e:"all" 的行是"合计"性质的(套装合计 / 回魔账本 / 升级合计…), **不属于任何单件装备**,
#   所以它不该显示装备名, 也不该被当成"忘了登记中文名"。
#   stat_row / stat_row_a 拿这张表当凭据(三分支):
#     e 在 names 里 -> 打全名("魔力上限 · 静脉泵")
#     e 在 gsent 里 -> 不打名字("回魔 · 装备额外  12 /秒")
#     两个都不在   -> 打红字 "(没登记中文名!)"(说明 e 真的写错了)
#   ⚠️ 漏建这张表的话, **所有 e:"all" 的行都会红着写 "all(没登记中文名!)"**
#      —— 2026-10-04 真实事故: 静脉泵的"回魔 · 装备额外"那一行。
#   ⚠️ check.py 的 regsent 项会同时盯"表在不在"和"渲染器认不认哨兵"。
data modify storage zx:reg gsent set value {all:1b}

# ============================================================
# b: 数值为 0 就不显示 —— **按装备分组排序**, 同一件的行挨在一起
# ============================================================

# ---- 静脉泵 (intravenous_pump) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.pump_mana",c:"aqua",n:"",e:"intravenous_pump"}

# ---- 静脉泵 + 体外供能装置 的两件套装 ----
#   【为什么是 e:"all"】套装要求两件都在, 账本非 0 本身就说明都穿着了,
#   绑到哪一件都会在"只穿另一件"时把账藏掉, 所以放全局。
data modify storage zx:reg b append value {l:"套装魔力上限",o:"zx.set_mana",c:"aqua",n:"",e:"all"}
data modify storage zx:reg b append value {l:"套装生命上限",o:"zx.set_hp",c:"red",n:"",e:"all"}

# ---- 回魔账本(合计; 来源有静脉泵/桂冠/挽歌/黄昏套装, 不属于单件) ----
data modify storage zx:reg b append value {l:"回魔 · 装备额外",o:"zx.regen_last",c:"green",n:"/秒",e:"all"}

# ---- 体外供能装置 (external_power) ----
data modify storage zx:reg b append value {l:"生命上限",o:"zx.power_hp",c:"red",n:"",e:"external_power"}

# ---- 狄俄尼索斯之桂冠 (dionysus_helmet) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.dio_mana",c:"aqua",n:"",e:"dionysus_helmet"}
data modify storage zx:reg b append value {l:"回魔 · 剩余",o:"zx.dio_regen",c:"green",n:"秒",e:"dionysus_helmet"}

# ---- 脑髓蛭 (brain_leech) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.bl_mana",c:"aqua",n:"",e:"brain_leech"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.bl_atk",c:"gold",n:"",e:"brain_leech"}
data modify storage zx:reg b append value {l:"回魔修正",o:"zx.bl_regen",c:"green",n:"",e:"brain_leech"}

# ---- 脊骨共生 (spine_symbiote) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.ss_mana",c:"aqua",n:"",e:"spine_symbiote"}
data modify storage zx:reg b append value {l:"生命上限",o:"zx.ss_hp",c:"red",n:"",e:"spine_symbiote"}
data modify storage zx:reg b append value {l:"护甲",o:"zx.ss_armor",c:"white",n:"",e:"spine_symbiote"}

# ---- 群星坠落之挽歌 (stellar_elegy) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.se_mana",c:"aqua",n:"",e:"stellar_elegy"}
data modify storage zx:reg b append value {l:"回魔 · 剩余",o:"zx.se_regen",c:"green",n:"秒",e:"stellar_elegy"}

# ---- 黄昏黎明之交界 (dusk_dawn) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.dd_mana",c:"aqua",n:"",e:"dusk_dawn"}
data modify storage zx:reg b append value {l:"套装魔力上限",o:"zx.dd_set",c:"aqua",n:"",e:"dusk_dawn"}
data modify storage zx:reg b append value {l:"击杀后临时魔力上限",o:"zx.dd_temp",c:"aqua",n:"",e:"dusk_dawn"}

# ---- 余烬 (ember) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.em_mana",c:"aqua",n:"",e:"ember"}

# ---- 焚舟 (immolate) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.im_mk",c:"aqua",n:"",e:"immolate"}
data modify storage zx:reg b append value {l:"套装 buff 剩余",o:"zx.im_buff",c:"gold",n:"秒",e:"immolate"}

# ---- 异彩 (iridescent) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.ir_mana",c:"aqua",n:"",e:"iridescent"}

# ---- 共振 (resonance) ----
#   术阵数量本身在面板的"术阵"那一行看; 这里只记魔力上限那本账。
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.rs_mana",c:"aqua",n:"",e:"resonance"}

# ---- 炉心 (furnace_core) ----
#   三本账都是"穿上加 / 脱下减"的差值, 燃灰层数单独一行(0 层时不显示)。
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.fc_mana",c:"aqua",n:"",e:"furnace_core"}
data modify storage zx:reg b append value {l:"生命上限",o:"zx.fc_hp",c:"red",n:"",e:"furnace_core"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.fc_atk",c:"gold",n:"",e:"furnace_core"}
data modify storage zx:reg b append value {l:"燃灰",o:"zx.fc_ash",c:"yellow",n:"层",e:"furnace_core"}

# ---- 枯枝园 (withered_garden) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.gd_mana",c:"aqua",n:"",e:"withered_garden"}

# ---- 无光海 (lightless_sea) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.ls_mana",c:"aqua",n:"",e:"lightless_sea"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.ls_buf",c:"gold",n:"",e:"lightless_sea"}

# ---- 启示录 (apocalypse) ----
#   只登页数; 当前页魔力是 ×100 定点值, 直接上面板会差 100 倍, 不登。
data modify storage zx:reg b append value {l:"启示页数",o:"zx.ap_n",c:"yellow",n:"页",e:"apocalypse"}

# ---- 幻昼 (mirage) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.mr_mana",c:"aqua",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力",o:"zx.mr_atk",c:"gold",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力 · A层",o:"zx.mr_atk1",c:"gold",n:"",e:"mirage"}
data modify storage zx:reg b append value {l:"基础攻击力 · B层",o:"zx.mr_atk2",c:"gold",n:"",e:"mirage"}

# ---- 风行于大地之上 (wind_ontheground) ----
data modify storage zx:reg b append value {l:"回响期间魔力上限",o:"zx.wg_mana",c:"aqua",n:"",e:"wind_ontheground"}
data modify storage zx:reg b append value {l:"回响剩余",o:"zx.wg_aura",c:"light_purple",n:"秒",e:"wind_ontheground"}
data modify storage zx:reg b append value {l:"爆发剩余",o:"zx.wg_burst",c:"light_purple",n:"轮",e:"wind_ontheground"}

# ---- 寒鸦 (cold_crow) ----
data modify storage zx:reg b append value {l:"冰凌层数",o:"zx.cc_ice",c:"blue",n:"",e:"cold_crow"}

# ---- 幽匿残响 (sculk_echo) ----
data modify storage zx:reg b append value {l:"悲鸣",o:"zx.se_cry",c:"dark_aqua",n:"点",e:"sculk_echo"}

# ---- 清醒梦 (lucid_dream) ----
data modify storage zx:reg b append value {l:"梦回",o:"zx.ld_dream",c:"aqua",n:"层",e:"lucid_dream"}

# ---- 燎原 (liaoyuan) ----
data modify storage zx:reg b append value {l:"光环剩余",o:"zx.ly_aura",c:"gold",n:"秒",e:"liaoyuan"}
data modify storage zx:reg b append value {l:"离下次灼烧",o:"zx.ly_timer",c:"gold",n:"秒",e:"liaoyuan"}
data modify storage zx:reg b append value {l:"本光环灼烧次数",o:"zx.ly_times",c:"gold",n:"次",e:"liaoyuan"}

# ---- 引梦镰 (sickle_dreams) ----
data modify storage zx:reg b append value {l:"强化锁定",o:"zx.sd_lock",c:"light_purple",n:"秒",e:"sickle_dreams"}

# ---- 烈火, 残躯 (flame_brokenbody) ----
data modify storage zx:reg b append value {l:"熔浆",o:"zx.fb_lava",c:"red",n:"层",e:"flame_brokenbody"}

# ---- 超·负·荷 (charge) ----
data modify storage zx:reg b append value {l:"超载剩余",o:"zx.chg_on",c:"yellow",n:"秒",e:"charge"}

# ---- 陨星 (meteor) ----
data modify storage zx:reg b append value {l:"熔星剩余",o:"zx.mt_on",c:"gold",n:"秒",e:"meteor"}

# ---- 热熔 (remelt) ----
data modify storage zx:reg b append value {l:"熔解剩余",o:"zx.rm_on",c:"red",n:"秒",e:"remelt"}

# ---- 天穹 (skyvault) ----
data modify storage zx:reg b append value {l:"俯冲就绪",o:"zx.sv_launch",c:"aqua",n:"tick",e:"skyvault"}

# ---- 深海的回响 (deepsea_echo) ----
data modify storage zx:reg b append value {l:"下一波倒计时",o:"zx.de_t",c:"aqua",n:"tick",e:"deepsea_echo"}

# ---- 永恒 (eternity) ----
#   ★ 2026-10-21 补(玩家第三次提"哪些地方没接入观测镜"): 它的 apply_mana 一直在维护
#     zx.et_mana 这本账, 但 b 表没登记 —— 面板上"魔力上限"里少了 +280 的来源。
#   ★ 同批补的还有 沉溺忘川彼岸 / 漫步冥河之上 / 体外魔力泵 三件, 都是同一形态:
#     有 apply_mana + 自己的 zx.<id>_mana 账本, 只是没往这张表登记。
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.et_mana",c:"aqua",n:"",e:"eternity"}

# ---- 沉溺忘川彼岸 (lethe_shore) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.lt_mana",c:"aqua",n:"",e:"lethe_shore"}

# ---- 漫步冥河之上 (styx_walk) ----
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.sw_mana",c:"aqua",n:"",e:"styx_walk"}

# ---- 体外魔力泵 (mana_pump) ----
#   副手才生效 —— 没放副手时这本账是 0, b 表"值为 0 不显示"的特性正好。
data modify storage zx:reg b append value {l:"魔力上限",o:"zx.mp_mana",c:"aqua",n:"",e:"mana_pump"}

# ---- 全局兜底类(平时是 0, 出现就说明有情况) ----
data modify storage zx:reg b append value {l:"魔力下限保护垫付",o:"zx.floor_mana",c:"dark_aqua",n:"",e:"all"}

# ---- 升级系统(盔甲升级给的魔力上限, 账本就记在 zx.up_mana 上) ----
data modify storage zx:reg b append value {l:"升级·魔力上限",o:"zx.up_mana",c:"aqua",n:"",e:"all"}

# ============================================================
# a: 永远显示(0 也有意义的) —— 同样要写 e, 只显示在身装备的
# ============================================================
data modify storage zx:reg a append value {l:"风声",o:"zx.wg_sound",c:"light_purple",n:"",e:"wind_ontheground"}

# ============================================================
# layer: 「层数机制」一览 —— **观测镜第二行**的数据源(2026-10-05 新增)
# ------------------------------------------------------------
# 【这是干嘛的】
#   观测镜(equipment/tool/look)以前只有一行: 攻击/生命/魔力/术阵/冷却。
#   现在手里拿着武器、或身上穿着装备时, 若那件东西**有"层数"机制**,
#   就在**下面一行**把当前层数显示出来 —— 一层一层刷多少、还剩几层, 一眼看到。
#
# 【为什么单开一张表, 不复用 b 表】
#   b 表是"给 stats 面板看的账本", 里面混着魔力上限/生命上限这种**数值**行,
#   还有"回魔剩余(秒)""冷却剩余"这种**计时器**行。观测镜第二行只要**层数**,
#   混进去会把"层数"和"还剩几秒"搅在一起, 反而看不清。
#   所以单开一张"只放层数类"的表, 谁要显示谁登记, stats 面板不受影响。
#
# 【字段】
#   o = 计分项(一定要先在 core/load 建出来)
#   l = 短标签(观测镜第二行直接显示这个, **要短** —— 一行挤得下才算好标签)
#   c = 数值颜色
#   e = 这层数属于哪件装备(custom_data.zx[0]) —— 只在**那件装备在身 / 在手上**时显示
#   n = 尾巴备注(如「层」; 留空 "" 也行)
#   max = 【可选】上限, 用来显示成 "3/5" 这种"当前/上限"格式; 不写就只显示当前值。
#         ⚠️ 上限是**写死的常数**(不是计分项) —— 文案里"最多 N 层"的 N 就填这。
#         没有上限概念的(悲鸣这种"点数")可不写。
#   ⚠️ l / n 会被塞进 tellraw 的 JSON 字符串: 不要写英文双引号和反斜杠。
#   ⚠️ 一行的字段(o/l/c/e)必须写全; 宏参数少一个那条命令直接不跑(不报错, 难查)。
#
# 【表位上限】layer 最多 23 行(2026-10-17 由 20 提到 23); 加超了先把下面的 cap 行改掉,
#   再改 .workbuddy/gen_reg_unroll.py 顶上的 CAP_LAYER 常量(两边必须一致), 然后跑一次
#   那个脚本重生成 lib/look/layer_unroll —— check.py 的 regcap 会帮你数。
# ============================================================
data modify storage zx:reg layer set value []

# ---- 炉心「燃灰」★ 不在这张表里 ★ ----
#   它的上限**随超限变**(基础 10 / 超限 12), 而本表的 max 是**写死的常数**(一行只能给
#   一个上限) —— 写 10 则超限显示错, 写 12 则基础版显示错。所以搬到
#   equipment/armor/furnace_core/look_seg(观测镜里"装备专属段"的口径), 由
#   "身上这件是不是超限版"现选 10 / 12。★ 别再加回这张表(会显示成两份"燃灰")。
# ---- 寒鸦「冰凌」(最多 4 层) ----
data modify storage zx:reg layer append value {o:"zx.cc_ice",l:"冰凌",c:"blue",e:"cold_crow",n:"",max:4}
# ---- 烈火残躯「熔浆」(无硬上限, 由技能消耗) ----
data modify storage zx:reg layer append value {o:"zx.fb_lava",l:"熔浆",c:"red",e:"flame_brokenbody",n:"",max:0}
# ---- 焚舟「烈空」(0..200 点; 每 20 点 +30 魔力上限, 满 200 后攻击非燃烧目标逐点泄) ----
data modify storage zx:reg layer append value {o:"zx.lk",l:"烈空",c:"gold",e:"immolate",n:"点",max:200}
# ---- 清醒梦「梦回」(最多 5 层) ----
data modify storage zx:reg layer append value {o:"zx.ld_dream",l:"梦回",c:"aqua",e:"lucid_dream",n:"",max:5}
# ---- 幽匿残响「悲鸣」(0..50 点, 无"层"概念 -> 不加 max) ----
data modify storage zx:reg layer append value {o:"zx.se_cry",l:"悲鸣",c:"dark_aqua",e:"sculk_echo",n:"点",max:0}
# ---- 燎原「本光环灼烧次数」(第 3/6/9 次附加流火) ----
data modify storage zx:reg layer append value {o:"zx.ly_times",l:"灼烧",c:"gold",e:"liaoyuan",n:"次",max:0}
# ---- 启示录「启示」页数(最多 3 页; 页是玩家身上的持久资产, 跨施法保留) ----
data modify storage zx:reg layer append value {o:"zx.ap_n",l:"启示",c:"gold",e:"apocalypse",n:"页",max:3}
# ---- 终末天启「圣光」(最多 10 层; 满 10 层自动释放一次主动技能并清空) ----
data modify storage zx:reg layer append value {o:"zx.fr_light",l:"圣光",c:"gold",e:"final_revelation",n:"层",max:10}
# ---- 脑髓蛭「蛊虫」(最多 10 层; 满 10 层进入消耗模式, 每次攻击 -1 层, 消耗完重新积累) ----
data modify storage zx:reg layer append value {o:"zx.bl_gu",l:"蛊虫",c:"green",e:"brain_leech",n:"层",max:10}
# ---- 回锋「断刃」(最多 3 层; 攻击攒层, 主动消耗全部、每层重复一次) ----
data modify storage zx:reg layer append value {o:"zx.rb_blade",l:"断刃",c:"white",e:"rebound",n:"层",max:4}
# ---- 歌谣「曲调」(最多 8 层; 手持歌谣击杀攒层, 主动消耗殆尽) ----
data modify storage zx:reg layer append value {o:"zx.bd_tune",l:"曲调",c:"gold",e:"ballad",n:"层",max:8}
# ---- 威霆「天煌」(0..2000 点; 手持未攻击时每刻 +1, 换术阵时清空) ----
data modify storage zx:reg layer append value {o:"zx.tc_n",l:"天煌",c:"aqua",e:"thunderclap",n:"点",max:2000}
# ---- 葬火「放空的魔力值 X」(0 = 没有待结算的葬火; 打出下一次攻击后 X 转成第二段伤害) ----
data modify storage zx:reg layer append value {o:"zx.py_x",l:"葬火",c:"red",e:"pyre",n:"",max:0}
# ---- 苍蓝星「被动翻倍」(1 = 攒着一次"本武器伤害倍率翻倍"; 下一次技能消费后消失) ----
data modify storage zx:reg layer append value {o:"zx.as_x2",l:"翻倍",c:"blue",e:"azure_star",n:"次",max:0}
# ---- 超限·万念 / 千散「剑魂」(最多 5 个; 每有一个则本武器技能重复一次, 满 5 进「居合」) ----
#   ★ 两把各登记一条 ★ layer 的 e 只能填一个 id("只在拿着这件时显示"), 而这套机制
#     是"换手两用": 拿到千散时本该照样看见剑魂, 少登记一条就是"换个手 层数消失了"。
data modify storage zx:reg layer append value {o:"zx.mq_soul",l:"剑魂",c:"light_purple",e:"myriad",n:"个",max:5}
data modify storage zx:reg layer append value {o:"zx.mq_soul",l:"剑魂",c:"light_purple",e:"qiansan",n:"个",max:5}
# ---- 万念 / 千散「居合」(居合期内每切换一次 +1 层; 下一次技能伤害 = ×(1 + 0.20×层数), 独立乘区) ----
#   ★ 与剑魂同款: e 只能填一个 id, 而这两把是"换手两用"(居合期来回切) —— 两把各登记一条,
#     少一条就是"换个手 层数消失了"。无硬上限(层数 = 3 秒内切换次数) -> max:0 只显示当前层数。
data modify storage zx:reg layer append value {o:"zx.mq_jb",l:"居合",c:"gold",e:"myriad",n:"层",max:0}
data modify storage zx:reg layer append value {o:"zx.mq_jb",l:"居合",c:"gold",e:"qiansan",n:"层",max:0}
# ---- 狄俄尼索斯之桂冠「酒浆」(最多 10 层; 受击 / 满蓄力攻击攒层, 5 层换一次爆发) ----
#   ★ 玩家 2026-10-10: "酒浆没有在观测镜显示" —— 批次 H 实装了「酒浆」经济却没登记观测镜。
data modify storage zx:reg layer append value {o:"zx.dio_wine",l:"酒浆",c:"light_purple",e:"dionysus_helmet",n:"层",max:10}
# ---- 风行于大地之上「风声」(点数, 无硬上限; 召唤术阵后每命中一个生物 +1, >60 触发加成) ----
#   上限是动态阈值(60)而非硬顶, 且点数会冲到很大 -> max:0 只显示当前点数, 不摆 "x/N"。
data modify storage zx:reg layer append value {o:"zx.wg_sound",l:"风声",c:"white",e:"wind_ontheground",n:"点",max:0}
# ---- 缝心「绯结」(最多 3 层; 为原本未附「噬心」者附加噬心后积攒 1 层, 真伤命中时消耗 1 层换 +15%) ----
#   ★ 与「剑魂」「居合」同款: 这是**双件套**(●针眠 头盔 + ●绯缝 胸甲)的私有积攒,
#     而 layer 的 e 只能填一个 id("只在那件在身时显示") ⇒ 两件各登记一条。
#     少登记一条 = 只戴其中一件时层数凭空消失(玩家只会说"有时候显示有时候不显示")。
#   ★ 2026-10-17 补: 15-4 实装时漏登记, 玩家自攒了 3 层却看不见。
data modify storage zx:reg layer append value {o:"zx.cr_knit",l:"绯结",c:"red",e:"needle_sleep",n:"层",max:3}
data modify storage zx:reg layer append value {o:"zx.cr_knit",l:"绯结",c:"red",e:"crimson_seam",n:"层",max:3}
# ---- 失血「心血」(最多 3 层; 平A 命中带「噬心」者消耗之 +1, 主动一次清零) ----
#   ★ 2026-10-17 补(玩家原话: "给自己附加的层数观测镜没显示"): 15-7 实装时漏登记。
#   ★ 凡是"给自己攒层"的机制, 加完代码必须回来登记这张表 —— 守门规则 layreg 会抓。
data modify storage zx:reg layer append value {o:"zx.bld_n",l:"心血",c:"dark_red",e:"blood_loss",n:"层",max:3}
# ---- 沉砣「砣」(最多 5 层; 每次命中 +1, 每层 +2 固定伤害、-4% 移速, 受伤立刻清零) ----
#   ★ 2026-10-21 补(玩家第三次提"哪些地方没接入观测镜"): 实装时漏登记。
#     它是**武器**不是护甲, e 填 sunken_weight 即可(手持才显示), 没有第二件。
#   ★ 数值是 lore 原话: "最多 5 层", 所以 max 写 5。
data modify storage zx:reg layer append value {o:"zx.sw_n",l:"砣",c:"dark_gray",e:"sunken_weight",n:"层",max:5}
# ---- 幻昼「白昼梦叠层」(最多 10 层 = 基础攻击力 +20; 攻击附有白昼梦的生物时 +1) ----
#   ★ 2026-10-21 补: lore 明写"最多叠加 10 次", 但观测镜从来没显示过。
#   ★ 与「剑魂/居合」同款判定: 这套加成写在「● 异彩 ● 幻昼」套装效果里, 但它加的是
#     **攻击力**而不是"只在两件都在时才成立的条件值" —— 只要穿着幻昼就有这条机制
#     (异彩只是套装另一半), 所以 e 只填 mirage, 不重复登记 iridescent。
data modify storage zx:reg layer append value {o:"zx.mr_atk2",l:"白昼",c:"light_purple",e:"mirage",n:"层",max:10}
# ---- 幻昼「受伤叠层」(无硬上限; 每次受到伤害 +1 层, 每层基础攻击力 +1, 5 秒逐层到期) ----
#   ★ 2026-10-21 补。lore 只说"可叠加"、没给数字 —— 所以 max 写 0(只显示当前层数,
#     不摆 "x/N", 否则会凭空给玩家一个不存在的上限)。
#   ★ 它和「白昼」是**两条独立机制**(一个受击、一个命中), 必须分开显示,
#     合成一条会让"刚挨打攻击力却没涨"看起来像 bug。
data modify storage zx:reg layer append value {o:"zx.mr_atk1",l:"受击",c:"red",e:"mirage",n:"层",max:0}
# ---- 迟暮「回光」(2026-10-25 用户原稿) ----
#   玩家自己攒的层数(自身被附加白昼梦 ⇒ +1 层, 15 秒统一到期) ⇒ 必须登记,
#   否则观测镜上看不见(规则 layreg 会拦)。
#   ★ max 写 0: 原文没说层数上限("附加一层…累计消耗 3 层") —— 凭空给个 x/N 上限
#     会让玩家以为攒到 N 就满, 而实际还能继续攒。
data modify storage zx:reg layer append value {o:"zx.ld_s",l:"回光",c:"dark_purple",e:"late_dusk",n:"层",max:3}


# ============================================================
# names: 装备 id → 中文**全名**(worn / stats / name_row 都用它)
#   键 = give 里 custom_data 的 zx:[ "<id>" ] 那一段
#   ★ 做了新装备, 记得在这里补一行, 否则只显示英文 id ★
# ============================================================
data modify storage zx:reg names.intravenous_pump set value "静脉泵"
data modify storage zx:reg names.external_power set value "体外供能装置"
data modify storage zx:reg names.dionysus_helmet set value "狄俄尼索斯之桂冠"
data modify storage zx:reg names.brain_leech set value "脑髓蛭"
data modify storage zx:reg names.spine_symbiote set value "脊骨共生"
data modify storage zx:reg names.stellar_elegy set value "群星坠落之挽歌"
data modify storage zx:reg names.dusk_dawn set value "黄昏黎明之交界"
data modify storage zx:reg names.ember set value "余烬"
data modify storage zx:reg names.immolate set value "焚舟"
data modify storage zx:reg names.iridescent set value "异彩"
data modify storage zx:reg names.mirage set value "幻昼"
data modify storage zx:reg names.deepsea_echo set value "深海的回响"
data modify storage zx:reg names.flame_brokenbody set value "烈火, 残躯"
data modify storage zx:reg names.sickle_dreams set value "引梦镰"
data modify storage zx:reg names.cold_crow set value "寒鸦"
data modify storage zx:reg names.liaoyuan set value "燎原"
data modify storage zx:reg names.wind_ontheground set value "风行于大地之上"
data modify storage zx:reg names.liuguang set value "流光"
data modify storage zx:reg names.hengdao set value "横刀"
data modify storage zx:reg names.charge set value "超·负·荷"
data modify storage zx:reg names.shadow_blade set value "影刃"
data modify storage zx:reg names.remelt set value "热熔"
data modify storage zx:reg names.aurora_dream set value "极光与幻梦"
data modify storage zx:reg names.chenyuan set value "沉渊"
data modify storage zx:reg names.angel_core set value "天使核心"
data modify storage zx:reg names.meteor set value "陨星"
data modify storage zx:reg names.skyvault set value "天穹"
data modify storage zx:reg names.look set value "观测镜"
# ---- 第五批(2026-10-05, 15 件) ----
data modify storage zx:reg names.myriad set value "万念"
data modify storage zx:reg names.qiansan set value "千散"
data modify storage zx:reg names.agony set value "苦痛"
data modify storage zx:reg names.polarized_light set value "偏振光"
data modify storage zx:reg names.delusion set value "惑梦"
data modify storage zx:reg names.fallen_dream set value "堕梦"
data modify storage zx:reg names.apocalypse set value "启示录"
data modify storage zx:reg names.sculk_echo set value "幽匿残响"
data modify storage zx:reg names.bone_erode set value "蚀骨"
data modify storage zx:reg names.lucid_dream set value "清醒梦"
data modify storage zx:reg names.rainbow set value "虹彩"
data modify storage zx:reg names.withered_garden set value "枯枝园"
data modify storage zx:reg names.lightless_sea set value "无光海"
data modify storage zx:reg names.furnace_core set value "炉心"
data modify storage zx:reg names.resonance set value "共振"
# ---- 第六批(2026-10-06 建, 只有 give, 效果待做) ----
#   ★ 键必须等于 give 里 custom_data 的 zx:[ "<id>" ] 那一段, 否则 debug/worn 显示英文 id。
data modify storage zx:reg names.final_revelation set value "终末天启"
data modify storage zx:reg names.anion set value "负离子"
data modify storage zx:reg names.styx_walk set value "漫步冥河之上"
data modify storage zx:reg names.lethe_shore set value "沉溺忘川彼岸"
data modify storage zx:reg names.eternity set value "永恒"
data modify storage zx:reg names.thunder set value "雷鸣"
data modify storage zx:reg names.blaze_plume set value "炽翎"
data modify storage zx:reg names.bitter_cold set value "苦寒"
data modify storage zx:reg names.mana_pump set value "体外魔力泵"
data modify storage zx:reg names.nullify set value "无效"
data modify storage zx:reg names.wrath set value "愠怒"
data modify storage zx:reg names.seraph_wing set value "炽天使之翼"
# ---- 第七批(2026-10-07, 28 件: 21 武器 + 7 盔甲, 只有 give, 效果待做) ----
#   ★ 键必须等于 give 里 custom_data 的 zx:[ "<id>" ] 那一段, 否则 debug/worn 显示英文 id。
data modify storage zx:reg names.hush set value "无息"
data modify storage zx:reg names.rogue_star set value "游星"
data modify storage zx:reg names.everfrost set value "永霜"
data modify storage zx:reg names.verdict set value "神裁"
data modify storage zx:reg names.tinder set value "火种"
data modify storage zx:reg names.rebound set value "回锋"
data modify storage zx:reg names.fissure set value "崩裂"
data modify storage zx:reg names.dream_reader set value "释梦"
data modify storage zx:reg names.draught set value "饮鸩"
data modify storage zx:reg names.pyre set value "葬火"
data modify storage zx:reg names.ballad set value "歌谣"
data modify storage zx:reg names.thunderclap set value "威霆"
data modify storage zx:reg names.red_lotus set value "红莲"
data modify storage zx:reg names.azure_star set value "苍蓝星"
data modify storage zx:reg names.chime set value "共鸣"
data modify storage zx:reg names.palette set value "调色盘"
data modify storage zx:reg names.begonia set value "海棠"
data modify storage zx:reg names.gu_poison set value "蛊毒"
data modify storage zx:reg names.twilight set value "暮光"
data modify storage zx:reg names.sail set value "风帆"
data modify storage zx:reg names.arc set value "电弧"
data modify storage zx:reg names.mana_helm set value "聚魔头盔"
data modify storage zx:reg names.mana_plate set value "聚魔胸甲"
data modify storage zx:reg names.hex_belt set value "魔化腰带"
data modify storage zx:reg names.flesh_mill set value "血肉磨坊"
data modify storage zx:reg names.blaze_armor set value "焱"
data modify storage zx:reg names.spirit_sight set value "灵视"
data modify storage zx:reg names.fade set value "息影"
# ---- 第八批(2026-10-11《新的装备-超限等.md》新武器 11 件, 只有 give; 效果/外观待做) ----
#   ★ 键必须等于 give 里 custom_data 的 zx:[ "<id>" ] 那一段, 否则 debug/worn 显示英文 id。
data modify storage zx:reg names.sacred_relic set value "圣骸"
data modify storage zx:reg names.anchor set value "沉锚"
data modify storage zx:reg names.scorch_bone set value "焦骨"
data modify storage zx:reg names.tidemark set value "潮痕"
data modify storage zx:reg names.grayscale set value "灰度"
data modify storage zx:reg names.crescent set value "缺月"
data modify storage zx:reg names.dragon_tongue set value "龙舌"
data modify storage zx:reg names.cloudtrail set value "云迹"
data modify storage zx:reg names.burst_dawn set value "爆裂黎明"
data modify storage zx:reg names.triad set value "很冰的斧"
data modify storage zx:reg names.five_curses set value "五世恶咒"

# ---- 批 13 · 过渡/终端补缺(2026-10-13)----
data modify storage zx:reg names.backstring set value "退弦"
data modify storage zx:reg names.frostmirror set value "冰鉴"
data modify storage zx:reg names.everlit set value "长明"
data modify storage zx:reg names.thunderrod set value "引雷针"

# ---- 批 14 · NEW.md 42 件(2026-10-15)----
data modify storage zx:reg names.backflow_tide set value "退汐"
data modify storage zx:reg names.fate_thread set value "命缕"
data modify storage zx:reg names.other_shore set value "彼岸"
data modify storage zx:reg names.feather_sleep set value "眠羽"
data modify storage zx:reg names.blind_candle set value "盲烛"
data modify storage zx:reg names.death_bell set value "丧铃"
data modify storage zx:reg names.deep_brine set value "重溟"
data modify storage zx:reg names.broken_page set value "断页"
data modify storage zx:reg names.last_breath set value "归息"
data modify storage zx:reg names.renew_fire set value "续火"
data modify storage zx:reg names.wake_bell set value "醒梦钟"
data modify storage zx:reg names.long_night set value "长夜"
data modify storage zx:reg names.cross_dream set value "渡梦"
data modify storage zx:reg names.tide_buckle set value "回潮扣"
data modify storage zx:reg names.ember_string set value "烬弦"
data modify storage zx:reg names.blood_loss set value "失血"
data modify storage zx:reg names.bent_ray set value "折径"
data modify storage zx:reg names.condensed_shell set value "凝壳"
data modify storage zx:reg names.coffin_silk set value "殓丝"
data modify storage zx:reg names.tread_ash set value "踏灰"
data modify storage zx:reg names.backlight set value "返照"
data modify storage zx:reg names.gyre set value "回旋"
data modify storage zx:reg names.reverse_string set value "逆弦"
data modify storage zx:reg names.late_court set value "迟庭"
data modify storage zx:reg names.thunder_wedge set value "雷楔"
data modify storage zx:reg names.frost_carve set value "剜霜"
data modify storage zx:reg names.dark_sun set value "黯日"
data modify storage zx:reg names.flint_hat set value "燧帽"
data modify storage zx:reg names.smoke_step set value "烟履"
data modify storage zx:reg names.tide_watch set value "候潮"
data modify storage zx:reg names.beach_vein set value "滩纹"
data modify storage zx:reg names.needle_sleep set value "针眠"
data modify storage zx:reg names.crimson_seam set value "绯缝"
data modify storage zx:reg names.mirror_sleep set value "镜寐"
data modify storage zx:reg names.light_pillow set value "轻枕"
data modify storage zx:reg names.char_coat set value "焦衣"
data modify storage zx:reg names.candle_step set value "烛跬"
data modify storage zx:reg names.boil_trace set value "沸痕"
data modify storage zx:reg names.thorn_vein set value "刺纹"
data modify storage zx:reg names.rain_trace set value "雨迹"
data modify storage zx:reg names.empty_pillow set value "空枕"
data modify storage zx:reg names.mottle_vein set value "杂纹"
# ---- 批一 · 阶段补全(2026-10-20) ----
data modify storage zx:reg names.yebu set value "曳步"
data modify storage zx:reg names.xiugou set value "锈犬"
data modify storage zx:reg names.zhuzu set value "驻足"
data modify storage zx:reg names.gousi set value "钩丝"
data modify storage zx:reg names.lianshi set value "连矢"
data modify storage zx:reg names.tiejili set value "铁蒺藜"
data modify storage zx:reg names.lvshuang set value "履霜"
data modify storage zx:reg names.dongtu set value "冻土"
data modify storage zx:reg names.huilan set value "回澜"
data modify storage zx:reg names.chengxing set value "秤星"
# ---- 批二 · 标签补缺(2026-10-20) ----
data modify storage zx:reg names.profane set value "剖心"
data modify storage zx:reg names.grave_tablet set value "断碑"
data modify storage zx:reg names.burst_bank set value "决堤"
data modify storage zx:reg names.breathing_soil set value "息土"
data modify storage zx:reg names.cage_day set value "囚昼"
data modify storage zx:reg names.way_back set value "归途"
data modify storage zx:reg names.stop_needle set value "停针"
data modify storage zx:reg names.empty_seat set value "虚位"
data modify storage zx:reg names.bind_ember set value "缚烬"
data modify storage zx:reg names.sunken_weight set value "沉砣"
data modify storage zx:reg names.night_bind set value "夜缚"
data modify storage zx:reg names.sip_frost set value "饮霜"
data modify storage zx:reg names.retro_shine set value "反照"
data modify storage zx:reg names.pour_sack set value "倾囊"
# ---- 批 15 · 白昼梦系列 9 件(2026-10-25) ----
data modify storage zx:reg names.bone_breaker set value "碎骨"
data modify storage zx:reg names.bright_candle set value "明烛"
data modify storage zx:reg names.borrow_fire set value "借火"
data modify storage zx:reg names.heart_vein set value "心脉"
data modify storage zx:reg names.profile set value "剖面"
data modify storage zx:reg names.tide_fold set value "折潮"
data modify storage zx:reg names.ebb_tide set value "返汐"
data modify storage zx:reg names.glimmer set value "浮光"
data modify storage zx:reg names.late_dusk set value "迟暮"

# ============================================================
# tg: 每个 /trigger 调试入口
#   obj  = 计分项(core/load 里建的 trigger 型)
#   name = 菜单上显示的名字
#   fn   = 真正干活的那个函数(tg_xxx 那层只做归零/enable 的收尾)
#   ★ 加新入口: ① core/load 建 trigger 计分项 ② lib/reg/build 这里加一条
#              ③ debug/tg_router 加一行路由 ④ debug/second 加一行 enable
#              ⑤ 想上菜单就把键名写进 menu
# ============================================================
data modify storage zx:reg tg.stats set value {obj:"zx.dbg_stats",name:"查看自己的全部数值",fn:"sweetdream:debug/stats"}
data modify storage zx:reg tg.worn set value {obj:"zx.dbg_worn",name:"身上穿了什么装备",fn:"sweetdream:debug/worn"}
data modify storage zx:reg tg.diff set value {obj:"zx.dbg_diff",name:"对比上次快照: 变了什么",fn:"sweetdream:debug/diff"}
data modify storage zx:reg tg.raw set value {obj:"zx.dbg_raw",name:"原始面板数据(全部字段)",fn:"sweetdream:debug/raw"}
data modify storage zx:reg tg.cd set value {obj:"zx.dbg_cd",name:"立刻结束主手武器冷却",fn:"sweetdream:debug/cd_clear"}
data modify storage zx:reg tg.mana set value {obj:"zx.dbg_mana",name:"回满魔力(1000)",fn:"sweetdream:debug/recover_mana"}
data modify storage zx:reg tg.fadd set value {obj:"zx.dbg_fadd",name:"自己的术阵 +1",fn:"sweetdream:debug/form_add"}
data modify storage zx:reg tg.fdel set value {obj:"zx.dbg_fdel",name:"自己的术阵 -1",fn:"sweetdream:debug/form_del"}
data modify storage zx:reg tg.menu set value {obj:"zx.dbg_menu",name:"打开这个调试菜单",fn:"sweetdream:debug/menu"}
data modify storage zx:reg tg.give set value {obj:"zx.dbg_give",name:"发一套潜影盒(全部东西)",fn:"sweetdream:debug/give_all"}

# ============================================================
# menu: 菜单里按顺序列出来(tg 的键名; 顺序 = 屏幕上从上到下)
#   n = 鼠标悬停时显示的说明
# ============================================================
data modify storage zx:reg menu append value {k:"stats",n:"魔力 / 伤害 / 原版属性 / 回魔 / 在身装备的加成"}
data modify storage zx:reg menu append value {k:"worn",n:"6 个槽位各穿了什么, id 有没有认出来"}
data modify storage zx:reg menu append value {k:"diff",n:"先按一次存快照, 换完装备再按一次看变了什么"}
data modify storage zx:reg menu append value {k:"cd",n:"把主手那把武器自己的冷却清掉"}
data modify storage zx:reg menu append value {k:"mana",n:"瞬间回 1000 魔力(被上限夹住 = 回满)"}
data modify storage zx:reg menu append value {k:"fadd",n:"登记一个空的永久术阵, 用完记得按 -1 摘掉"}
data modify storage zx:reg menu append value {k:"fdel",n:"摘掉编号最大的那个术阵(技能建的也摘)"}
data modify storage zx:reg menu append value {k:"raw",n:"manacore:players 里那份原始数据 + 冷却表"}
data modify storage zx:reg menu append value {k:"menu",n:"重新打印这个菜单"}
data modify storage zx:reg menu append value {k:"give",n:"发潜影盒: 装备 28 件 + 强化材料 7 块(分两盒)"}

# ---------- 记录本版本的表位上限(给 gen_reg_unroll.py / check.py 数用) ----------
data modify storage zx:reg cap set value {b:60,a:8,menu:12,layer:27}

# Shared armor ledgers were not exposed in self-stats (58 -> 60 rows, existing cap 60).
data modify storage zx:reg b append value {l:"通用盔甲魔力上限合计",o:"zx.am_mana",c:"aqua",n:"含浮光·迟暮套装",e:"all"}
data modify storage zx:reg b append value {l:"通用盔甲生命上限合计",o:"zx.ah_hp",c:"red",n:"",e:"all"}
