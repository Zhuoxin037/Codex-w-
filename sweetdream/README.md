# sweetdream —— 应用层（装备 / 道具 / 技能）

配 `manacore-1.0.0`（数值框架）使用。这个包只做"具体的东西"：武器、道具、技能流程。

## 目录结构

```
sweetdream/
├─ data/minecraft/tags/function/   load / tick 两个入口
├─ data/manacore/tags/function/    挂在框架事件上的钩子(标签会与前置包合并)
└─ data/sweetdream/
   ├─ advancement/
   │  ├─ itembackup/               消耗型道具的"用完还手"三件套
   │  └─ equipment/                每个道具自己的右键触发
   ├─ function/
   │  ├─ core/      load / tick
   │  ├─ api/       公开接口(给别人调, 改要谨慎)
   │  ├─ internal/  内部实现(装备不要直接调)
   │  ├─ lib/       uuid、数字转字符串等小工具
   │  ├─ event/     挂在前置包事件标签上的钩子
   │  ├─ debug/     排错用
   │  ├─ example/   示例
   │  └─ equipment/ ★ 每做一个道具/武器/防具, 在这里建一个文件夹
   │     ├─ liuguang/   流光(武器: 锁定 + 3 秒后结算)
   │     ├─ hengdao/    横刀(武器: 突进 + 落点范围伤害)
   │     └─ look/       观测镜(数值面板道具)
   └─ tags/entity_type/no_damage.json   不该被打的实体(含玩家)
```

## 命名约定

| 东西 | 用什么 | 说明 |
| --- | --- | --- |
| 命名空间 | `sweetdream:` | 函数、进度、标签都用它 |
| 数据存储 | **`zx:`** | `zx:in` / `zx:out` / `zx:work` / `zx:data` / `zx:config` |
| 计分板 | `zx.meta` | 框架内部用 |
| 前置包 | `manacore:*` | 那是它的地盘，别混用 |

## 新增一把武器的步骤

三件东西，**名字必须完全一致**。写错的表现是"右键毫无反应"且不报错，是最难查的一类。

1. `equipment/<名字>/give.mcfunction` —— 给物品。`custom_data` 里必须带两个标记：
   `custom_data={zx:["<名字>","itemreplace"]}`
   - `<名字>`：武器 id，进度 `equipment/<名字>` 靠它认人
   - `itemreplace`：让通用回手线认出"这是消耗型道具"
   （**没有 `skill` 字段了** —— 那个字段没有任何代码读它，已经删掉。）
2. `advancement/equipment/<名字>.json` —— `consume_item` 触发，条件是
   `custom_data.zx` 里出现 `<名字>`，奖励指向 `sweetdream:equipment/<名字>/cast`。
3. `equipment/<名字>/cast.mcfunction` —— 技能本体。
   **第一行必须是 `advancement revoke @s only sweetdream:equipment/<名字>`**，
   否则这个进度一辈子只触发一次（第二次右键毫无反应）。
4. 技能流程照抄 `equipment/liuguang/cast.mcfunction` 的骨架：
   `撤进度 → 读 UUID → 只读检查(冷却+魔力) → 锁目标 → 扣蓝 → 记冷却 → 算伤害 → schedule 延迟结算`
5. 需要延迟结算（"3 秒后再打"这种）就照抄流光那四件套：
   `hit` + `hit_self` + `hit_due` + `hit_calc`。
   那是跨 tick 结算的完整写法 —— 包括"多人同时放不会互相串"的隔离方式，
   以及怎么在 schedule 出来的函数里找回施法者。

### 右键为什么是两条线

| 线 | 进度 | 函数 | 职责 |
| --- | --- | --- | --- |
| 回手线（通用，所有消耗型道具共用） | `itembackup/consume`（条件 `zx:['itemreplace']`） | `internal/itembackup/effect_1` | 只负责把刀还回你手里 |
| 技能线（每把武器一条） | `equipment/<名字>`（条件 `zx:['<名字>']`） | `equipment/<名字>/cast` | 只负责放技能 |

两条线在同一次 `consume_item` 事件上同时触发，互不干扰。好处：

- 冷却中右键 = 刀回来了、技能没放、聊天栏提示还剩多久
- 某把武器的 cast 写坏了，回手机制照样好使

`zx` 数组的匹配规则是"**按顺序包含**"，所以 `zx:["liuguang","itemreplace"]`
能同时被 `zx:['liuguang']` 和 `zx:['itemreplace']` 匹配到。

## 踩过的坑（别重犯）

- **进度奖励函数第一行必须 `advancement revoke @s only <自己那条进度>`**，
  否则进度只会触发一次，第二次右键毫无反应。
- **做新武器时三处名字必须一致**：`give` 里 `zx` 的武器标记 / 进度文件名与条件 /
   进度奖励指向的那个 `cast`。任一处不一致的表现都是"右键静默无反应"，不报错。
- **含 `$(变量)` 的行必须以 `$` 开头；不含变量的行绝对不能加 `$`**
  （后者会报 `Macro without variables`，整个函数作废）。
- **宏变量在函数"被调用那一刻"就固定了**：在函数体里才写进节点的字段，这一层引用不到，
  必须再调一层带宏的函数。同一件事被坑过两次。
- **宏参数必须是复合标签**，不能传单个数字（传 `r.damage` 会直接报错）。
- **右键消耗型道具，退还物品必须延后 1 tick**：消耗流程收尾会把主手设成空，
  同 tick 放回去的会被覆盖。
- **`storage 存储ID 路径` 中间是空格，不是点**（`manacore:players "xxx".cooldowns`）。
- **选择器的 `distance` 下界用 `0.1`**：自己到自己的距离是 0，不排除就会打到/选中自己。
- **别把盔甲架塞到 y < -64**：虚空伤害无视 `Invulnerable`，会被销毁然后反复重造。
- **伤害默认 `minecraft:player_attack`**（吃护甲）；想穿甲自己传 `minecraft:magic`。
- **改了范围要两处一起改**：技能里的"锁定判定"和 `effect` 里的"打伤害选择器"。
- **`manacore:in arg` 是"共享输入口"，不是存档。** 它的生命周期是
  "调用前填 → 函数读走"，中间谁都可以覆盖它。观测镜每刻查术阵数量都会用它，
  所以别把要长期保存的东西塞在里面 —— 要存就用 `zx:data`。

## 每次改动后跑一遍的检查

1. `/reload`，看日志有没有 `Failed to load function`
2. 函数引用、标签引用、进度奖励与撤销、宏前缀 —— 这些都能静态查出来
3. `/function sweetdream:debug/num_probe` 可以看宏渲染出来的数字长什么样
