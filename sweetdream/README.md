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
   │     ├─ liuguang/   流光(武器)
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

1. `equipment/<名字>/give.mcfunction` —— 给物品。`custom_data` 里必须带两个东西：
   一个身份标记（进度靠它认人）、一个 `skill:"技能id"`（面板靠它显示冷却）。
2. `advancement/equipment/<名字>.json` —— `consume_item` 触发，奖励指向你的技能函数。
3. `equipment/<名字>/cast.mcfunction` —— **第一行必须撤销自己的进度**（见下）。
4. 技能流程照抄 `equipment/liuguang/damage.mcfunction` 的骨架：
   `读 UUID → 只读检查(冷却+魔力) → 锁目标 → 扣蓝 → 记冷却 → 算伤害 → 打伤害`
5. `equipment/<名字>/effect.mcfunction` —— 真正造成伤害（数字要用宏拼进命令）。

## 踩过的坑（别重犯）

- **进度奖励函数第一行必须 `advancement revoke @s only <自己那条进度>`**，
  否则进度只会触发一次，第二次右键毫无反应。
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

## 每次改动后跑一遍的检查

1. `/reload`，看日志有没有 `Failed to load function`
2. 函数引用、标签引用、进度奖励与撤销、宏前缀 —— 这些都能静态查出来
3. `/function sweetdream:debug/num_probe` 可以看宏渲染出来的数字长什么样
