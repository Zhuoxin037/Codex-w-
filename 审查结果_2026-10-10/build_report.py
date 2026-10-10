import json
from pathlib import Path

ROOT = Path(r'D:\数据包')
OUT = Path(__file__).parent
functions = json.loads((OUT / 'functions.json').read_text(encoding='utf-8'))
stats = json.loads((OUT / 'scan.json').read_text(encoding='utf-8'))['stats']
resources = json.loads((OUT / 'resource_details.json').read_text(encoding='utf-8'))

def source(key, line):
    path = functions[key]['path'] if key in functions else key
    target = ROOT / path
    if not target.is_file():
        raise ValueError(f'Missing evidence file: {target}')
    if line > len(target.read_text(encoding='utf-8-sig').splitlines()):
        raise ValueError(f'Invalid evidence line: {target}:{line}')
    return {'path': path, 'line': line}

def links(sources):
    return '；'.join(f"[{s['path']}:{s['line']}]({(ROOT / s['path']).as_posix()}:{s['line']})" for s in sources)

findings = []
def add(code, priority, title, scope, evidence, impact, reproduce, fix):
    findings.append(dict(id=code, priority=priority, title=title, scope=scope,
                         sources=[source(k, n) for k, n in evidence], impact=impact,
                         reproduce=reproduce, fix=fix))

add('F01', 'P1', '正常在线玩家每秒都会重新走加入流程', 'manacore，所有在线玩家',
    [('manacore:core/second',24), ('manacore:internal/session/tick_self',18), ('manacore:internal/join/slot_check',25), ('manacore:internal/join/register',21)],
    '`#sec` 先加 1，再判断玩家旧心跳是否大于等于新秒数。正常在线玩家的心跳比新秒数小 1，因此每秒触发 join，扫描 UUID 索引并再次派发 player_join。当前威霆加入回调还会执行清理与重建。这里不能把每秒事件当成真正上线事件，人数增加时也会产生额外扫描。',
    '单玩家持续在线，在 player_join 标签末尾临时加入计数回调，等待 10 秒；按当前路径会收到约 10 次事件，而非只在加入时收到 1 次。',
    '用“上一秒正常心跳”与“首次上线/断线重连/加载代际变化”分开判断。已有有效 slot 的玩家直接更新心跳，不要重新注册和发 join。')

add('F02', 'P1', '回收池仅剩一个槽位时，会连续执行两次分配', 'manacore，重连/新玩家分配',
    [('manacore:internal/slot/alloc',9), ('manacore:internal/slot/from_free',8)],
    'alloc 的两个条件顺序执行。from_free 弹出最后一个元素后，第二条 unless 判断变为真，马上再执行 new，覆盖刚取得的槽位。最后一个回收槽位因此被丢弃，next_slot 提前增长，加速触发溢出。',
    'free_slots.list=[5]、next_slot=10：期望分配 5；当前路径先取 5，再分配 11，最终拿到 11，5 从池中消失。',
    '把分配做成互斥分支，例如命中回收分支后直接 return run function from_free，或先保存分支条件再执行。')

add('F03', 'P1', 'UUID 查找遗漏最后一个合法槽位', 'manacore，默认第 64 个槽位',
    [('manacore:internal/join/slot_check',14), ('manacore:internal/index/find_uuid_loop',10), ('manacore:internal/slot/new',10)],
    '分配槽位是 1..max_slots，但查找从 0 开始，并在 i>=max_slots 时退出，只查到 0..63。默认 slot=64 的记录永远找不到；与 F01 叠加时会反复补发槽位，留下旧索引并快速触发 F04。',
    '在 index."64" 放入某玩家 UUID，令 max_slots=64，调用加入查找；该 UUID 不会被命中。',
    '查找统一为 1..max_slots，包括上界；同时统一所有 foreach、分配和校验的编号约定。')

add('F04', 'P1', '槽位耗尽后回绕到 1，直接覆盖正在使用的索引', 'manacore，超过容量或槽位泄漏后',
    [('manacore:internal/slot/new',11), ('manacore:internal/slot/overflow',9), ('manacore:internal/join/register',14)],
    'overflow 把 next_slot 重置为 1，register 随后无条件重写 index."1"。旧玩家仍持有 slot=1，两人索引归属冲突；self_uuid、心跳、离线扫除以及后续 mana API 都可能作用到错误记录。回绕还让 foreach 的遍历上界缩小，高位索引无法正常维护。',
    '默认 max_slots=64，在所有槽位占用时分配第 65 次；index."1" 的 UUID 会被新玩家覆盖。F02/F03 可使较少玩家也提前到达该路径。',
    '容量耗尽时明确拒绝注册并返回 slot_full，或安全扩容；只能复用已经确认空闲的槽位，禁止绕回覆盖。')

add('F05', 'P1', 'self_uuid 查询失败时会返回上一次调用留下的 UUID', 'manacore API，未注册/失效槽位玩家',
    [('manacore:api/player/self_uuid',20), ('manacore:internal/debug/self_uuid',7), ('sweetdream:lib/uuid',19)],
    'self_uuid 不先清空 work.a.uuid。索引不存在时，debug/self_uuid 的条件写入被跳过，旧 uuid 仍存在，外层便当成成功结果返回。sweetdream 的 lib/uuid 会将非空结果标为有效；首次注册前、reload 窗口或索引异常时可能串用别人的 UUID。',
    '先让玩家 A 成功读取 self_uuid，再让没有有效 index 的玩家 B 调用；work.a.uuid 可仍是 A 的 UUID。',
    '每次调用先清空查询结果；读取前验证 slot 及 UUID 归属。缺索引必须返回空结果和明确失败原因。')

add('F06', 'P1', 'skill/cast 的 mana 参数没有传给实际扣费函数', 'manacore 一步施法 API；应用层多数技能走另一条分步路径',
    [('manacore:api/skill/cast',37), ('manacore:internal/skill/stage_mana',9), ('manacore:internal/mana/consume',21)],
    'cast 的入参字段是 mana，stage_mana 直接调用内部 consume，而 consume 读取的是 a.value，途中没有转换。标准 cast 调用不能按 mana 正确扣费；缺失字段的 execute store 结果会落为 0。不能据此推断 sweetdream 的全部技能都免魔，因为多数技能另行调用 mana/consume 并传 value。',
    '按文档使用 {uuid:有效UUID,skill:"audit:test",mana:20.0,consume:1b} 调用 cast，并比较前后 current_mana；当前链路不会按 20 正常扣费。',
    '在 stage_mana 建立独立扣费参数，将 mana 映射为 value，再恢复施法上下文。增加成功扣费、魔力不足、consume=0 三种引擎回归场景。')

add('F07', 'P1', '伤害事件调用其他 API 后，会破坏外层 deal/cast 的参数', 'manacore public API + sweetdream 共振护甲',
    [('manacore:internal/damage/deal',2), ('manacore:internal/skill/go',18), ('manacore:internal/damage/calc',104), ('sweetdream:equipment/armor/resonance/hook_calc',39), ('manacore:api/formation/count',9)],
    'deal/cast 在 calc 结束后继续读全局 work.a.target。共振的 damage_calc 回调调用 formation/count；后者直接把整个 work.a 替换为 {uuid:""}，target 等字段消失。外层随后跳过 apply，出现进入冷却或扣费后未执行伤害的路径。这是可重入 API 的共享临时区冲突；应用层“先 calc，再重新组装自己的伤害参数”的路径不等同于此。',
    '穿共振胸甲，以有效 target 调用 manacore:api/damage/deal；在 damage_calc 回调后检查 work.a.target，当前会被 count 的参数覆盖。',
    '保存完整调用上下文并采用栈式恢复；不同 API 使用独立临时节点。不能仅保存 manacore:in，而遗漏 work.a 和 out。')

add('F08', 'P1', '多目标伤害的易伤数值会传到下一个目标', 'sweetdream，夜火技能易伤/噬心真伤易伤',
    [('sweetdream:internal/damage/with_from',50), ('sweetdream:internal/damage/one',34), ('sweetdream:internal/damage/one',62), ('sweetdream:internal/damage/vuln_tag',23)],
    'one 为每个目标恢复 num_str、damage 等字段，却没有恢复 a.num。vuln_tag 优先读取 num 并把放大结果写回 num。连续两个带对应易伤标记的目标，会让第二个目标在第一个的放大数值上再次乘 1.15，伤害依赖选择器遍历顺序。',
    '基础伤害 100、两个同条件易伤目标：期望各 115；当前路径第一个 115、第二个 132.25。第三个仍会继续放大。',
    '每个目标开始时从不可变 ob 完整复制伤害包，至少恢复 num、damage、num_str、type、src、来源 UUID。用目标顺序交换验证结果一致。')

add('F09', 'P1', '回手备份架的缺失计数共用，部分玩家无法创建备份', 'sweetdream，多人右键消耗后回手',
    [('sweetdream:internal/stand/summon',30), ('sweetdream:internal/stand/summon',33), ('sweetdream:internal/stand/summon',36), ('sweetdream:internal/itembackup/backup',26), ('sweetdream:internal/itembackup/effect_2',25)],
    '所有玩家共用 #stand_miss。已有备份架的 A 每次执行时把它清零，没有备份架的 B 只能再加 1，无法累积到 40。B 的备份目标一直不存在，消耗式道具的回手复制也不会成功，存在道具消失的实际代码路径。',
    'A 已有 test_stand_A，B 没有；持续在线 100 tick，每轮执行 A 再 B。计数一直停在 1，B 不会生成备份架。',
    '改为每玩家计数或 UUID 对应记录；UUID 有效后直接幂等创建更简单。备份失败时应阻止进入消耗流程或保留可重试的恢复状态。')

add('F10', 'P1', '无息的跨 tick 命中和路径标签没有按施法者隔离', 'sweetdream，无息多人同时施放',
    [('sweetdream:equipment/sword/hush/cast',64), ('sweetdream:equipment/sword/hush/dash_tick',28), ('sweetdream:equipment/sword/hush/dash_tick',35), ('sweetdream:equipment/sword/hush/back_finish',27)],
    'hs_hit/hs_path 在多个 tick 间保留，cast 又直接清除所有实体上的同名标签。B 施放会清掉 A 的命中与回程路径；共用目标时，A 的 hs_hit 又会使 B 跳过本该属于 B 的命中。虽然起点 marker 有 UUID，目标命中状态仍是共享的。',
    'A 冲刺触碰目标后、回程结束前让 B 施放无息；A 的路径标签被清空。两人对同一组目标并行冲刺时也会互相抑制命中。',
    '用 owner UUID + cast 序号记录每次施法的命中集合；清理只作用于该次施法。不要用跨 tick 的无归属全局标签保存个人技能状态。')

add('F11', 'P2', '回锋/红莲在校验之前清掉已经开始的多段攻击', 'sweetdream，技能发动后连续右键',
    [('sweetdream:equipment/sword/rebound/cast',27), ('sweetdream:equipment/sword/rebound/cast',37), ('sweetdream:equipment/axe/red_lotus/cast',47), ('sweetdream:equipment/axe/red_lotus/cast',67)],
    '两者先 reset 各自的计时和剩余次数，再检查冷却/魔力。成功施放后，在后续段尚未结算时再次右键，即使第二次因冷却失败，也已经删掉第一轮的队列，损失后续攻击。',
    '回锋保留至少一段追加斩击，成功施放后 7 tick 内再右键；或红莲消耗多个标记后连点。后续段会被失败的施法尝试取消。',
    '校验失败必须无副作用；将清队列移到全部校验、扣费成功之后，或显式定义并提示主动取消机制。')

add('F12', 'P2', '两处副手逻辑仍使用 1.21.5 已迁移的旧 Inventory 路径', 'sweetdream，寒鸦副手刷新、梦镰副手扫击重置',
    [('sweetdream:equipment/bow/cold_crow/model/offhand',10), ('sweetdream:equipment/sword/sickle_dreams/sweep/tick',5)],
    '读取 Inventory[{Slot:-106b}] 得不到新版副手数据。寒鸦的 oldice/oldframe 一直保持 -1，变化检查失效，从而反复 item modify；梦镰的 sd_sweep 副手重置条件无法成立。应读取 equipment.offhand.components。',
    '寒鸦放副手保持静止，观察修改函数仍每轮执行；将带 sd_sweep 状态的梦镰移到副手，观察重置条件不能命中。',
    '迁移到 equipment.offhand 或直接使用 if items 谓词；将装备 NBT 路径统一封装，避免不同技能各维护旧写法。')

add('F13', 'P1', '调色盘/海棠召唤物计算伤害时跳过玩家装备加成', 'sweetdream，调色盘提色法球、海棠漩涡收尾',
    [('sweetdream:equipment/staff/palette/color_hit',19), ('sweetdream:equipment/staff/palette/color_hit',22), ('sweetdream:equipment/staff/begonia/vortex_end',33), ('sweetdream:upgrade/api/dmg_held',21), ('sweetdream:equipment/armor/resonance/hook_calc',29)],
    '伤害计算传了主人 uuid，但执行者仍是 item_display/marker。升级技能增伤、共振等回调先检查 @s 是否为玩家，因而直接退出。主人面板能读到，主人当前装备加成却不能读到；这是两种上下文不一致。不能扩展为“所有投射物都有这个问题”，部分投射物在生成时已快照伤害。',
    '比较同一主人、同一面板、带/不带愿景类技能增伤时提色法球及海棠漩涡收尾伤害；理论应受对应增伤影响，当前玩家限定回调不会执行。',
    '在主人玩家上下文中 calc、保留召唤物位置上下文；或生成时快照明确的伤害加成包。统一决定召唤物采用发射时快照还是命中时实时面板。')

add('F14', 'P2', '同时使用多条伤害通道时，同一增伤会重复放大全部伤害', 'sweetdream 伤害框架；单通道技能不触发此重复',
    [('sweetdream:upgrade/api/dmg_held',30), ('sweetdream:lib/dmg_add_apply',25), ('sweetdream:lib/dmg_add_apply',32), ('sweetdream:lib/dmg_add_apply',49)],
    'dmg_held 把同一个百分比写入 mm/atk/oth；dmg_add_apply 对存在的通道把百分比相加，之后统一乘总 damage。两条通道都存在时，一个 30% 增伤变成总伤害 +60%。当前多数技能只走一条通道，因此主要影响框架支持的混合公式和后续扩展。',
    '魔力通道伤害 100 + 攻击通道 10，统一增伤 30%：按逐通道同幅增伤应为 143；当前汇总池计算为 176。',
    '每个通道分别乘对应加成，再求和；或把全局增伤单独存为一次性总池，不能既派发多通道又累加后乘全体。')

add('F15', 'P2', '参数备份只能保存一层，现有调用已经发生嵌套', 'sweetdream，lib/second → upgrade/second 等嵌套调用',
    [('sweetdream:lib/in_bak',19), ('sweetdream:lib/in_restore',11), ('sweetdream:lib/second',10), ('sweetdream:lib/second',74), ('sweetdream:upgrade/second',10)],
    '所有 in_bak 都写同一个 zx:bak.in。内层覆盖外层备份，内层 restore 又删除它，外层无法恢复原来的入参。初始不存在 arg 时，restore 也不会删除期间新增的 arg，无法恢复“原本不存在”的状态。',
    '外层入参 A → in_bak → 改成 B → 内层 in_bak/restore → 外层 restore：最终恢复不回 A。现有 lib/second 调 upgrade/second 就具备这一结构。',
    '建立备份栈，并存储 had_arg 标记；push/pop 对称恢复，包括不存在状态。将通用库的可重入契约写进接口说明。')

add('F16', 'P2', 'reset_all 只清在线索引，且没有同步应用层属性账本', 'manacore 调试重置与 sweetdream 装备属性联动',
    [('manacore:debug/reset_all',10), ('manacore:internal/debug/purge_one',12), ('manacore:internal/leave/body',14), ('sweetdream:equipment/armor/armor_mana/passive',52)],
    '离线玩家保留 players 记录但移除 index；reset_all 只 foreach 当前索引，因此“已清空全部玩家数据”的提示不准确。在线玩家底层属性被删掉后，sweetdream 的 zx.am_mana 等“已加成”账本仍在，下一轮 want-old 为 0，穿着的装备不重新加回该属性。',
    '玩家 B 离线后运行 reset_all，查看 B 的 players 记录仍存在。在线 A 穿聚魔装备后 reset_all，重新注册后比较面板与装备应有增益。',
    '维护可遍历的全部 UUID 清单，或支持整个 players 存储根的重置；派发明确 reset/rebuild 事件，同步清理并重建应用层账本。')

add('F17', 'P2', '相邻威霆术阵结束时会误删另一玩家的域显示', 'sweetdream，两座威霆场中心相距不超过 2 格',
    [('sweetdream:equipment/axe/thunderclap/domain',6), ('sweetdream:equipment/axe/thunderclap/field_end',32)],
    'domain 只带 zx.tc_dom，无主人/场实例标识；field_end 清掉附近所有同标签 item_display。A 场先结束时会把仍活动的 B 场显示一起删掉，B 的逻辑 marker 仍存在，出现术阵有效但域模型消失。',
    '两玩家间隔几秒，在相近中心各建威霆术阵；第一座结束时，第二座显示也被删除。',
    '为 marker 与 display 保存相同 owner + formation 实例 ID，按 ID 精确清理；距离仅作为补充校验。')

add('F18', 'P2', '目标黑名单遗漏非生物，最近目标锁定可能被船等占用', 'sweetdream，广泛使用 type=!#sweetdream:no_damage 的技能',
    [('sweetdream/data/sweetdream/tags/entity_type/no_damage.json',2), ('sweetdream:equipment/staff/palette/color_body',32), ('sweetdream:equipment/staff/palette/color_body',49)],
    '名单排除了玩家、展示实体和常见投射物，却没有船、矿车、TNT、falling_block 等非生物。仅按黑名单筛选不等于筛出生物；调色盘等最近目标锁定可选中更近的船，偏离有效怪物。不同非生物的 damage 行为不同，这里不把它们一律描述为可受伤或不可受伤。',
    '在法球附近摆一艘船，怪物稍远；检查被选中的 zx.pal_t，船符合当前候选条件并可占据最近目标。',
    '候选阶段增加生物性/Health 存在检查，或维护明确的可伤害目标集合；如果允许打船，另行定义选择优先级和对应效果。')

add('F19', 'P2', 'API 必填参数缺失/空字符串没有可靠的失败返回', 'manacore 对外 API 与后续技能开发',
    [('manacore:api/skill/check',10), ('manacore:api/skill/check',12), ('manacore:api/skill/check',15), ('manacore:internal/player/ensure',9)],
    'skill/check 先设 success=1，skill 缺失时跳过内部校验，最终仍成功。默认 uuid="" 又被当成“存在 uuid 字段”，ensure 有机会创建空字符串键记录。条件检查的是字段存在性，未校验非空和归属。当前规范传参的技能未必触发，但错误调用会被伪装成成功。',
    '以只有有效 uuid、没有 skill 的 arg 调 skill/check，当前 success 保持 1。再检查空 uuid 的 ensure/cast 是否创建 players.""。',
    '每个公开 API 先验证必填字段及取值范围，失败默认关闭，返回 invalid_uuid / invalid_skill / invalid_value；仅全部校验通过后设置 success=1。')

add('F20', 'P2', '部署脚本选错资源包，后续完整版改动不会随一键部署进入游戏', '发布工作流；已确认今后主力使用完整版',
    [('deploy.ps1',70), ('deploy.ps1',74)],
    '脚本的 RpSrc 固定为 sweetdream_rp，目标也固定为 resourcepacks/sweetdream_rp，没有选择 sweetdream_rp_完整版。今后只改完整版，再双击部署，会继续复制另一套资源，导致工作区与游戏外观不一致。',
    '只在完整版做一个明显图标变化，使用当前一键部署；脚本读取的源目录仍是 sweetdream_rp。此次审查未实际执行部署。',
    '将默认源和目标统一切到完整版；显式给出可选变体参数、GameDir 参数，并在完成提示写清实际部署变体。先校验，再打包/部署同一份产物。')

add('F21', 'P2', '两处原版音效 ID 拼写错误，对应音效不会播放', 'sweetdream，息影触发、清醒梦大效果',
    [('sweetdream:equipment/armor/fade/go',27), ('sweetdream:equipment/bow/lucid_dream/big',80)],
    '息影使用 entity.allay.item_throw，清醒梦使用 entity.evoker.cast。已按本机 1.21.5 资产索引读取原版 sounds.json 核实，两者都不在其中；实际名称分别是 entity.allay.item_thrown、entity.evoker.cast_spell。这里只影响相应音效，不会使整条函数停止执行。',
    '触发这两种效果或单独播放错误 ID，对比正确 ID；粒子/其他音效可正常，指定的这两段音效缺失。',
    '修正两个名称；把 playsound 原版 ID 对照版本资产索引纳入静态检查。')

release = [
    dict(id='C01', title='公开服务器发布时，普通玩家可使用调试发物、魔力和冷却入口', priority='P2（发布配置）',
         sources=[source('sweetdream:debug/second',25),source('sweetdream:debug/tg_router',38)],
         text='debug/second 每秒为全部 @a 开启 trigger，包括 dbg_give、dbg_mana、dbg_cd、dbg_fadd/fdel，路由没有管理员标签判断。开发测试时方便；生存服普通玩家也能拿到全套道具或调整状态。建议开发模式开关 + 管理员标签，仅开发构建默认开启。'),
    dict(id='C02', title='player_attack 绕过受击无敌帧，影响整个世界的原版近战', priority='P2（玩法取舍）',
         sources=[source('sweetdream/data/minecraft/tags/damage_type/bypasses_cooldown.json',5)],
         text='这里额外加入 minecraft:player_attack，因此所有采用该伤害类型的玩家近战都会绕过目标受击冷却，包含普通武器及 PvP；不代表移除了攻击蓄力时间。项目历史上对此有触发稳定性的设计考虑，不能直接认定为误写。建议把该改变写进发布说明并提供开关；优先让自定义技能伤害类型承担所需行为。'),
]

risks = [
    dict(id='R01', title='回手跨 tick 时切换快捷栏，可能覆盖新选中的物品',
         sources=[source('sweetdream:internal/itembackup/effect_1',43), source('sweetdream:internal/itembackup/effect_2',28)],
         text='返回时复制到当前 weapon.mainhand，没有记住消耗时的快捷栏 slot。需要在实际 1.21.5 的输入包/消耗事件顺序中验证：消耗完成与 1 tick 后返回之间切槽，原槽和新槽分别剩下什么。建议记录原 slot 与完整物品，并验证返回目标未被其他物品占用。'),
    dict(id='R02', title='死亡/重生后实体属性与已应用账本是否仍一致',
         sources=[source('sweetdream:equipment/armor/armor_mana/passive',52),source('sweetdream:upgrade/second',12)],
         text='装备增益使用 want-old 差量账本。F16 已确认 reset 会使其失配；死亡重生、keepInventory 开/关、不同模组修改属性时是否保留同样实体属性，需要实机验证。测试重生后原地不换装备与脱穿装备的面板差异，必要时按重生代际重建账本。'),
    dict(id='R03', title='术阵卸载期间，实体倒计时与框架绝对到期时间可能不同步',
         sources=[source('sweetdream:equipment/axe/thunderclap/field_tick',13),source('sweetdream:lib/second',60)],
         text='威霆 marker 的 tc_ft 只在已加载实体参加 second 时递减，而框架术阵有全局时钟到期语义。让场所在区块卸载至后台术阵已经到期，再返回，检查旧 marker、域显示、tc_on 和 formation 记录是否一致。建议实体也保存绝对 end_tick，重新加载时立即核对过期。'),
    dict(id='R04', title='额外维度不在多处硬编码的实体维护循环中',
         sources=[source('sweetdream:lib/second',60)],
         text='多个场、束和实体更新只显式扫描 overworld/the_nether/the_end。原版三维度使用范围内不构成缺陷；与自定义维度数据包/模组联用时，召唤物可能不更新或不清理。应明确支持范围，或把维度清单变为统一配置和分发入口。'),
    dict(id='R05', title='计分板时钟和中间乘法的整数边界',
         sources=[source('sweetdream:internal/damage/vuln_tag',25),source('sweetdream:lib/dmg_add_apply',53)],
         text='伤害先缩放成整数，再乘百分比，乘法中间值可能先超过 32 位有符号范围，而最终除回后的值本来仍合理。vuln_tag 的伤害×1000×115 在约 18,674 原始伤害附近即触及中间乘法上界；具体阈值受取整影响。20 TPS 全局 tick 计分板约 1,242.76 天触及正上界。现阶段普通数值不一定达到，但建议设定 API 数值上限、检查乘法顺序，并测试极限装备/配置。'),
    dict(id='R06', title='消耗后立即退出/死亡，挂起的回手缺少主动恢复路径',
         sources=[source('sweetdream:internal/itembackup/return',13),source('sweetdream:internal/itembackup/return_go',10)],
         text='schedule 只运行一次，执行对象是当时在线且带 test_pending_return 的 @a。玩家恰好离线时不会被处理，离线玩家的 tag 也不会被那次 @a 清除；重新上线后可能持续挂起，或等其他人触发下一次全局 return 时才恢复。需要验证重连、死亡与多人连续消耗。建议持久化每玩家待归还记录，并在 join/重生时显式重试。'),
]

optimizations = [
    dict(id='O01', priority='P2', title='减少每 tick 对全体玩家的重复 advancement revoke',
         sources=[source('sweetdream:core/tick',25),source('sweetdream:lib/rearm',31)],
         text='rearm 有 136 条活动命令，每 tick 全部 revoke @a，即 20 TPS 下每秒 2,720 次命令调用，且各条还要处理匹配玩家。很多奖励函数本身已经先撤销自己的进度。不要直接全部删除，应核对事件时序后保留确有必要的兜底；其余可仅在成功触发、join/reload 时撤销。优先与 F01 一并处理。'),
    dict(id='O02', priority='P2', title='集中玩家与实体路由，减少全局重复扫描',
         sources=[source('sweetdream:core/tick',25),source('sweetdream:lib/second',19)],
         text='core/tick 单文件有 113 条活动命令，含 67 处 @e、36 处 @a 字面选择器；这只是直接入口统计，不是实际每 tick 总执行数。按玩家统一分发佩戴/持有状态，按活动技能 tag 分发高频逻辑；无活动时避免扫描全部相关实体。粒子和音效按附近观看者发送，并设视觉质量档。用 profiler 比较 1/8/16 玩家与多法球场景。'),
    dict(id='O03', priority='P2', title='减少永久备份实体，补离线与卸载清理',
         sources=[source('sweetdream:core/load',564),source('sweetdream:internal/stand/summon',36)],
         text='当前强加载主世界 0,0 区块，并按曾加入的 UUID 留备份 armor_stand；没有看到配套的离线回收入口。长期多人世界会累计实体，即使是 Marker/NoGravity 也需要选择器和存档维护。可将完整物品保存在 UUID 键 storage，在需要返回时复制到明确槽位；若仍保留备份架，至少设计 TTL、离线清理与卸载指令。'),
    dict(id='O04', priority='P3', title='完整版发布包可按实际物品入口裁剪未引用模型',
         sources=[source('sweetdream_rp_完整版/assets/angelcore/items/axe.json',1)],
         text=f"从全部 {resources['item_definitions']} 个 items 定义递归收集 model，再追踪模型 parent，可到达集合之外有 {resources['unused_models']} 个模型，合计 {resources['unused_model_bytes']:,} 字节（约 20.6 MB，占整个未压缩资源包约 22.3%）。这是当前入口可达性分析，不包含其他未来资源或外部包的引用，不应据此直接删创作源文件。建议保留完整版源资产，构建发布产物时按清单裁剪，并进游戏检查代表模型。"),
    dict(id='O05', priority='P2/P3', title='高复杂度模型与大量逐帧 JSON 的客户端成本',
         sources=[source('sweetdream_rp_完整版/assets/flameremnant/models/item/sword.json',1)],
         text='完整版有 7,034 个模型。烈火残躯单模型 1,952 个 elements；sail 模型约 28.27 MB，palette 约 22.38 MB，sweetdream 命名空间有 5,369 个模型。文件多不等于它们都会同时渲染，但加载/烘焙内存、重载耗时和手持模型面数值得测量。复用 parent/不变几何，删内遮挡面，减少重复逐帧几何；比较资源重载时间、内存和手持 FPS，再决定低面数档位。'),
    dict(id='O06', priority='P3', title='四件物品默认走平面入口，保留的动画刷新可能没有可见收益',
         sources=[source('sweetdream_rp_完整版/assets/angelcore/items/axe.json',1),source('sweetdream_rp_完整版/assets/sail/items/staff.json',1),source('sweetdream_rp_完整版/assets/sweetdream/items/aurora_dream.json',1),source('sweetdream_rp_完整版/assets/sweetdream/items/look.json',1)],
         text='这四个 items 入口直接使用 item/vanilla 下的模型，没有按 custom_model_data 切换独立 3D 帧。数据包仍保留相关模型/动画状态更新；在这些平面入口下，部分 CMD 刷新不可见。这属于完整版当前“原版风”外观选择，不能当成缺贴图错误。建议明确是否需要 GUI 平面、手持 3D 的分派；若保持全平面，则按视觉模式减少无意义的物品组件更新。'),
    dict(id='O07', priority='P3', title='发布 ZIP 内混入备份与工具',
         sources=[source('sweetdream_rp_完整版/tools/make_icons.py',1)],
         text='发现 1 个 tools/make_icons.py 和 6 个 .bak/.broken-* 备份文件。它们不影响当前资源解析，但属于创作工作文件，没必要给最终使用者。构建 ZIP 时按白名单保留 pack.mcmeta、pack.png、assets 内实际资源，排除脚本、备份和临时文件。'),
    dict(id='O08', priority='P3', title='主说明与实际清单/兼容版本过时',
         sources=[source('README.md',12),source('README.md',61),source('README.md',79),source('manacore-1.0.0/README.md',91)],
         text='根 README 仍写 55 件装备、3 个潜影盒、22 块石头和 42 项自检；实际是 83 件装备、25 个升级/消除材料入口、24 个超限材料入口，调试全发合计 132 件、5 个潜影盒，自检已有 82 项。安装说明也指向 sweetdream_rp。兼容范围以实际 pack.mcmeta 的数据格式 71/资源格式 55、Java 1.21.5 为准，旧文档中的更宽范围不能作为保证。建议从清单自动生成装备数、debug give 列表和文档摘要。'),
    dict(id='O09', priority='P3', title='把生成与发布工具纳入可复现的构建流程',
         sources=[source('deploy.ps1',40)],
         text='部署前可选调用 .workbuddy 下的同步脚本，而当前生成/校验工具也集中在那里。应把发布所需工具固定在受版本管理的 tools/build 目录，区分生成、检查、打包与部署；不要靠不同机器恰好有某个可选脚本来决定产物。当前 batch5/6 管理的 43 件 give 无漂移，建议持续保留这一检查。'),
    dict(id='O10', priority='P2', title='现有静态检查补上状态转移和多人回归',
         sources=[source('.workbuddy/check.py',1)],
         text='82 项静态检查能抓文件引用、宏、部分数值/清单约定，但未抓本报告的共享临时区、分配互斥、上下界及跨玩家持久标签问题。补至少：单元素回收池、最后槽位、满容量、invalid API、带共振的 deal/cast、双易伤目标顺序交换、两个无息、已备份 A 与未备份 B、连点回锋/红莲。发布前由真实 1.21.5 引擎解析并运行；静态 0 问题不应等同于逻辑无缺陷。'),
]

parts = ['# manacore / sweetdream / 完整版资源包全面审查',
         '', '审查日期：2026-10-10。审查对象为工作区当前文件：`manacore-1.0.0`、`sweetdream`、`sweetdream_rp_完整版` 及其 ZIP；部署、文档与本地生成检查作为配套工作流核对。',
         '', '**已确认后续资源工作的主力是 `sweetdream_rp_完整版`。本报告的资源结论均以完整版为准；另一资源目录仅用于解释部署源选错的问题。此次没有修改任何数据包、资源包、部署或生成器源文件。**',
         '', '## 结论与优先级',
         '', f'列出 **{len(findings)} 项源码可确定的问题、{len(release)} 项发布/玩法注意事项、{len(risks)} 项需实机验证的风险、{len(optimizations)} 项优化建议**。P1 表示应优先修复，可能造成玩家状态串用、道具回手失败、伤害偏差或公开 API 不正确；P2 是具体功能、工作流或兼容性问题；P3 是体积、维护和文档改进。条件触发的问题已在各项写明范围。没有发现必须将当前包整体判为无法加载的 P0。',
         '', '基础文件完整性良好；真正值得优先修复的是槽位/心跳/UUID、事件回调的共享参数、目标间伤害状态、多人技能隔离和道具备份。现有自检通过并不覆盖这些状态问题。',
         '', '## 审查覆盖与验证结果',
         '', '| 对象 | 核对规模 | 结果 |', '| --- | ---: | --- |',
         '| manacore-1.0.0 | 277 文件，262 个函数 | 路径/宏等既有静态检查通过，逻辑问题见 F01–F07、F16、F19 |',
         '| sweetdream | 1,564 文件，1,311 个函数 | 与前置共计 1,573 个函数，技能/状态/升级/回手链路检查 |',
         '| sweetdream_rp_完整版 | 7,550 文件，92,500,817 字节 | 7,198 JSON、309 PNG；语法、图片完整性、引用/模型基本结构未报错 |',
         '| 完整版 ZIP | 7,550 文件，11,806,894 字节 | ZIP 无损坏条目，解压内容与目录逐文件字节一致 |',
         '| 当前物品清单 | 83 装备 + 25 升级/消除材料 + 24 超限材料 | give_all 132 件、5 个潜影盒核对通过 |',
         '| 既有主自检 | 82 项，1,573 函数 | 0 问题 |',
         '| 标签/材料图标/发全套检查 | 83 装备，49 个材料 CMD，132 个发放项 | 通过 |',
         '| 生成器漂移检查 | batch5/6 管理 43 件装备 | 0 漂移 |',
         '| 新增资源检查 | 父模型/贴图变量/装备层贴图/动画帧范围/UV/元素旋转与边界 | 未发现缺失或无效；原版音效 ID 对照发现 F21 两处错误 |',
         '', '模型与原版资源对照使用本机 1.21.5 客户端 JAR 和对应资产索引 24。未对所有模型做逐件游戏画面检查，未在游戏中新执行 reload、多人交互或性能压测。因此“源码路径确定”与“游戏表现待实测”分别列出，不能把命令数换算成 TPS。',
         '', '已读取本机 latest.log：早期 reload 曾报 atk_charge 旧属性名错误，当前源码已修正，后续日志 reload 未见该错误；此项不列为仍待修复的问题。',
         '', 'Java 1.21.5 对应数据格式 71、资源格式 55；该版本玩家盔甲与副手已迁入 equipment，支持 F12 的版本判断。参见 [Minecraft Java Edition 1.21.5 官方更新说明](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21-5)。',
         '', '## 确定问题总表', '', '| 编号 | 优先级 | 问题 | 影响范围 |', '| --- | --- | --- | --- |']
for f in findings:
    parts.append(f"| {f['id']} | {f['priority']} | {f['title']} | {f['scope']} |")
parts += ['', '## 确定问题详单', '']
for f in findings:
    parts += [f"### {f['id']} · {f['priority']} · {f['title']}", '', f"**范围：**{f['scope']}。", '', f"**源码：**{links(f['sources'])}", '',
              f"**问题与影响：**{f['impact']}", '', f"**复现/路径推演：**{f['reproduce']}", '', f"**建议：**{f['fix']}", '']
parts += ['## 发布配置与玩法取舍', '', '以下两项是明确存在的行为，但是否需要改变取决于发布用途及玩法选择，不混作误写缺陷。', '']
for f in release:
    parts += [f"### {f['id']} · {f['priority']} · {f['title']}", '', links(f['sources']), '', f['text'], '']
parts += ['## 需要进游戏验证的风险', '', '以下项目有代码依据，但没有在此次审查中重现实际游戏表现；应按列出的场景验收后决定是否修复。', '']
for f in risks:
    parts += [f"### {f['id']} · {f['title']}", '', links(f['sources']), '', f['text'], '']
parts += ['## 优化建议', '']
for f in optimizations:
    parts += [f"### {f['id']} · {f['priority']} · {f['title']}", '', links(f['sources']), '', f['text'], '']
parts += ['## 建议处理顺序与验收场景', '',
          '1. **先稳定前置状态：**F01–F05。验收首次加入、持续在线、离线重连、reload、单元素回收池、第 64 槽位和满容量；同一 UUID 只应占一个有效 slot，任何分配都不能覆盖其他玩家。',
          '2. **稳定 API：**F06/F07/F15/F19。验收扣费正确、参数非法返回失败、嵌套调用保留上下文；穿共振调用 deal/cast 后伤害能实际落地。',
          '3. **稳定伤害与多人技能：**F08/F09/F10/F11/F13/F14/F17。至少两名玩家，同一组与不同组目标并行；目标遍历顺序不改变每个目标伤害，第二次失败施法不取消第一轮攻击，回手不丢物品。',
          '4. **修功能和工作流：**F12/F16/F18/F20/F21。尤其把部署源切到完整版，再做一轮游戏 reload 与代表外观检查。',
          '5. **发布前验收：**处理 C01/C02 的配置，执行 R01–R06；再按 O01–O10 做性能、体积与维护改进。性能记录至少包含版本、人数、实体量、活动技能、MSPT、客户端 FPS 和资源重载耗时。',
          '', '## 附件与可复核数据', '',
          f"- [扫描数据]({(OUT / 'scan.json').as_posix()})：文件数、ZIP 一致性、入口统计。",
          f"- [资源详情]({(OUT / 'resource_details.json').as_posix()})：模型规模、不可达数量、额外文件与音效 ID 检查结果。",
          f"- [问题结构化清单]({(OUT / 'findings.json').as_posix()})：每项范围、源码行号、路径推演和建议。",
          f"- [函数索引]({(OUT / 'functions.json').as_posix()})：当前 1,573 个函数的非注释命令和原文件行号。",
          '', '本报告只记录审查结果与建议，未代替用户修改包体；后续修复应以完整版资源为主，并逐项完成引擎内回归。', '']

(OUT / 'findings.json').write_text(json.dumps({'confirmed':findings,'release_choices':release,'runtime_risks':risks,'optimizations':optimizations}, ensure_ascii=False, indent=2), encoding='utf-8')
(OUT / '全面审查报告.md').write_text('\n'.join(parts), encoding='utf-8')
print(json.dumps({'report':str(OUT / '全面审查报告.md'),'confirmed':len(findings),'p1':sum(f['priority']=='P1' for f in findings),'release_choices':len(release),'runtime_risks':len(risks),'optimizations':len(optimizations),'lines':len(parts)},ensure_ascii=False))
