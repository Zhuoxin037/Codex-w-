# 发布可选配置（非运行时加载）

这里的文件**不会**被 `deploy.ps1` 部署进数据包 —— 它们是给"打包发布"的人准备的**可替换件**，
按需覆盖 `sweetdream/` 下的同名文件即可。之所以不能做成本包内的"运行时开关"：
原版 `tags/damage_type/*.json` 是**数据驱动**的，只在 `/reload` 时解析一次，
没有任何函数能在游戏内改它的成员。

---

## 1. `bypasses_cooldown.no_player_attack.json`

**对应审查报告 C02。**

### 默认行为（当前包里的样子）

`sweetdream/data/minecraft/tags/damage_type/bypasses_cooldown.json`：
```json
{ "values": [ "sweetdream:skill", "sweetdream:true_damage", "minecraft:player_attack" ] }
```

`minecraft:player_attack` 在列 ⇒ **所有玩家的原版近战伤害都会绕过目标的受击无敌帧**，
包括普通武器和 PvP（注意：这不等于取消攻击蓄力时间）。

### 为什么保留它

本包的整套伤害管线（`api/damage/calc` → 加算 hook → 平A 触发技能）是**以"平A 一定落地"
为前提**搭的：若平A 被目标的受击无敌帧吃掉，则依赖"命中事件"的技能/被动不会触发。
这是项目历史上的**玩法取舍**，不是误写。因此默认保留。

### 什么时候换成这个文件

面向**公开 PvP / 生存服**，且能接受"平A 偶尔被无敌帧吃掉、依赖它触发的技能随之漏触发"时，
用本文件覆盖 `sweetdream/data/minecraft/tags/damage_type/bypasses_cooldown.json`：
- 效果：只有本包的自定义技能伤害类型（`sweetdream:skill` / `sweetdream:true_damage`）绕过无敌帧，
  `minecraft:player_attack` 回到原版语义（受无敌帧限制）。
- 之后必须 `/reload`（改数据包 registry / tag ⇒ 建议退世界重进）才生效。

### 更彻底的做法（报告原话）

> 优先让自定义技能伤害类型承担所需行为。

即：逐步把"需要必定触发"的平A 检测改到本包自己的伤害类型或 `minecraft:player_attack`
之外的入口上。这是较大的重构，暂未实施；本条先提供"能立刻收窄影响面"的开关。
