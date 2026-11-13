/* 坠梦 · 装备台 —— 交互逻辑（纯前端，改动存本机浏览器） */
(function () {
  'use strict';
  const D = window.SD_DATA;
  const ITEMS = D.items;
  const BY_ID = Object.fromEntries(ITEMS.map(i => [i.id, i]));
  const KEY = 'sweetdream-arsenal-v1';
  const DEFAULT_BASE = { atk: 1, mana: 100, hp: 20 };

  const PARAM_DEFS = [
    { k: 'atk',       label: '基础攻击力加成',        unit: '点 · 加算', step: 1 },
    { k: 'atkMul',    label: '基础攻击力乘区',        unit: '× 独立乘区', step: 0.05 },
    { k: 'maxMana',   label: '最大魔力值加成',        unit: '点 · 加算', step: 5 },
    { k: 'maxHp',     label: '最大生命值加成',        unit: '点 · 加算', step: 1 },
    { k: 'manaCost',  label: '单次魔力消耗',          unit: '点', step: 5 },
    { k: 'cooldown',  label: '冷却',                  unit: '秒', step: 1 },
    { k: 'dmgMul',    label: '伤害系数 ×基础攻击力',  unit: '×', step: 0.05 },
    { k: 'manaScale', label: '伤害系数 ×最大魔力',    unit: '×', step: 0.005 },
    { k: 'flatDmg',   label: '固定伤害',              unit: '点 · 不吃乘区', step: 1 },
    { k: 'duration',  label: '持续时间',              unit: '秒', step: 1 },
    { k: 'radius',    label: '半径',                  unit: '格 · 仅领域', step: 1 },
    { k: 'hits',      label: '目标数',                unit: '个 · 自估', step: 1 },
  ];

  const OBJ_ORDER = ['formation', 'field', 'summon', 'status', 'control', 'motion', 'lightning', 'heal', 'buff', 'debuff'];
  const OBJ_SHORT = { formation: '术阵', field: '领域', summon: '召唤物', status: '状态附着', control: '控制', motion: '位移', lightning: '落雷', heal: '治疗', buff: '增益', debuff: '削弱' };

  // ---------------------------------------------------------------- 状态
  function fresh() {
    return { baseline: { ...DEFAULT_BASE }, overrides: {}, status: {}, customPending: [],
             compare: { a: 'apocalypse', b: 'ablation' } };
  }
  let S;
  try { S = Object.assign(fresh(), JSON.parse(localStorage.getItem(KEY) || '{}')); }
  catch (e) { S = fresh(); }
  S.baseline = Object.assign({ ...DEFAULT_BASE }, S.baseline || {});
  S.overrides = S.overrides || {}; S.status = S.status || {};
  S.customPending = S.customPending || []; S.compare = S.compare || { a: null, b: null };

  const ui = { view: 'overview', cat: 'all', rarity: 'all', status: 'all', tag: 'all', q: '', selected: ITEMS[0].id, cmpTab: 'all' };

  function save() { try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) { toast('本机存储写入失败，请用「导出存档」备份'); } }
  function toast(msg) {
    const t = document.getElementById('toast'); t.textContent = msg; t.classList.add('show');
    clearTimeout(toast._t); toast._t = setTimeout(() => t.classList.remove('show'), 2200);
  }
  function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])); }
  function n(v, d) { const x = Number(v); return Number.isFinite(x) ? x : (d || 0); }
  function fx(v, p) { const x = Number(v) || 0; return (Math.abs(x) >= 100 || p === undefined) ? String(+x.toFixed(2)) : String(+x.toFixed(p === undefined ? 2 : p)); }
  function deltaTag(cur, orig) {
    const d = cur - orig;
    if (Math.abs(d) < 1e-9) return '<span class="d zero">±0</span>';
    return '<span class="d ' + (d > 0 ? 'pos' : 'neg') + '">' + (d > 0 ? '+' : '') + fx(d, 3) + '</span>';
  }
  function statusOf(item) {
    const s = S.status[item.id];
    if (s) return s;
    if (item.epicStaff && !item.puExclusive) return { s: 'pending', note: '规则自动标记：史诗及以上法杖的普攻需有专属效果，本件普攻段目前只有数值行。', at: '' };
    return { s: 'confirmed', note: '', at: '' };
  }

  // ---------------------------------------------------------------- 数值
  function paramsOf(item) {
    const p = Object.assign({}, item.params);
    Object.assign(p, S.overrides[item.id] || {});
    for (const d of PARAM_DEFS) p[d.k] = Math.max(0, n(p[d.k], d.k === 'atkMul' || d.k === 'dmgMul' ? 1 : 0));
    if (p.atkMul <= 0) p.atkMul = 1;
    if (p.dmgMul <= 0) p.dmgMul = 1;
    if (p.hits < 1) p.hits = 1;
    return p;
  }
  function simulate(item, p, b) {
    const A = (n(b.atk, 1) + p.atk) * p.atkMul;
    const M = n(b.mana, 100) + p.maxMana;
    const H = n(b.hp, 20) + p.maxHp;
    const D = A * p.dmgMul + M * p.manaScale + p.flatDmg;
    const total = D * p.hits;
    const casts = p.manaCost > 0 ? Math.floor(M / p.manaCost) : null;
    const cycle = Math.max(p.cooldown > 0 ? p.cooldown : (p.duration > 0 ? p.duration : 1), 1);
    const windows = Math.floor(60 / cycle);
    const effective = casts === null ? windows : Math.min(casts, windows);
    return { A, M, H, D, total, casts, cycle, windows, effective, out60: total * effective,
             dpm: p.manaCost > 0 ? D / p.manaCost : null };
  }
  function simPair(item) {
    const cur = simulate(item, paramsOf(item), S.baseline);
    const orig = simulate(item, Object.assign({}, item.params, { atkMul: item.params.atkMul || 1, dmgMul: item.params.dmgMul || 1, hits: item.params.hits || 1 }), DEFAULT_BASE);
    return { cur, orig };
  }

  // ---------------------------------------------------------------- 图标
  const ICON = {
    formation: '<circle cx="16" cy="16" r="11" fill="none" stroke="currentColor" stroke-width="1.4" stroke-dasharray="3 3"/><text x="16" y="20" text-anchor="middle" font-size="11" fill="currentColor" font-family="monospace">3</text>',
    field: '<circle cx="16" cy="16" r="12" fill="currentColor" opacity=".13"/><circle cx="16" cy="16" r="12" fill="none" stroke="currentColor" stroke-width="1.4"/><path d="M16 16 L28 16" stroke="currentColor" stroke-width="1.4"/><circle cx="16" cy="16" r="2.2" fill="currentColor"/><circle cx="9" cy="10" r="1.6" fill="currentColor"/><circle cx="23" cy="22" r="1.6" fill="currentColor"/>',
    summon: '<path d="M16 4 L27 16 L16 28 L5 16 Z" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M16 10 L21 16 L16 22 L11 16 Z" fill="currentColor" opacity=".55"/>',
    status: '<circle cx="16" cy="16" r="5" fill="currentColor" opacity=".75"/><circle cx="16" cy="16" r="11" fill="none" stroke="currentColor" stroke-width="1.2" stroke-dasharray="2 4"/>',
    control: '<path d="M9 5h14M9 27h14M11 5c0 7 10 9 10 11s-10 4-10 11M21 5c0 7-10 9-10 11s10 4 10 11" fill="none" stroke="currentColor" stroke-width="1.4"/>',
    motion: '<path d="M4 16h20M18 9l7 7-7 7" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>',
    lightning: '<path d="M18 3 L8 17h7l-2 12 11-15h-7z" fill="currentColor" opacity=".8"/>',
    heal: '<path d="M16 6v20M6 16h20" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/>',
    buff: '<path d="M6 22L16 10l10 12M6 27h20" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>',
    debuff: '<path d="M6 10L16 22l10-12M6 5h20" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linejoin="round"/>',
  };
  function svg(k, cls) { return '<svg class="' + (cls || '') + '" viewBox="0 0 32 32" aria-hidden="true">' + (ICON[k] || ICON.status) + '</svg>'; }

  // ---------------------------------------------------------------- 筛选
  function filtered() {
    const q = ui.q.trim().toLowerCase();
    return ITEMS.filter(it => {
      if (ui.cat !== 'all' && it.cat !== ui.cat) return false;
      if (ui.rarity === 'none') { if (it.rarity) return false; }
      else if (ui.rarity !== 'all' && it.rarity !== ui.rarity) return false;
      if (ui.status !== 'all' && statusOf(it).s !== ui.status) return false;
      if (ui.tag !== 'all' && !it.tags.includes(ui.tag)) return false;
      if (q) {
        const hay = (it.name + ' ' + it.catLabel + ' ' + it.rarityLabel + ' ' + it.profession + ' ' +
          it.tags.join(' ') + ' ' + it.body + ' ' + it.roles.join(' ')).toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }
  function tagFreq() {
    const c = {}; ITEMS.forEach(i => i.tags.forEach(t => c[t] = (c[t] || 0) + 1));
    return Object.entries(c).sort((a, b) => b[1] - a[1]);
  }
  const TF = tagFreq();

  // ---------------------------------------------------------------- 左栏
  function renderRail() {
    const cats = D.meta.cats;
    document.getElementById('catCount').textContent = cats.length + ' 类';
    document.getElementById('catChips').innerHTML =
      '<button class="chip ' + (ui.cat === 'all' ? 'on' : '') + '" data-cat="all">全部 <span class="n">' + ITEMS.length + '</span></button>' +
      cats.map(c => '<button class="chip ' + (ui.cat === c.k ? 'on' : '') + '" data-cat="' + c.k + '">' + c.label + ' <span class="n">' + c.n + '</span></button>').join('');
    document.getElementById('rarChips').innerHTML =
      '<button class="chip ' + (ui.rarity === 'all' ? 'on' : '') + '" data-rar="all">全部</button>' +
      D.meta.rarities.map(r => '<button class="chip ' + (ui.rarity === r.k ? 'on' : '') + '" data-rar="' + r.k + '"><i class="dot" style="background:' + r.hex + '"></i>' + r.label + ' <span class="n">' + r.n + '</span></button>').join('') +
      '<button class="chip ' + (ui.rarity === 'none' ? 'on' : '') + '" data-rar="none">不参与 <span class="n">17</span></button>';
    document.getElementById('statusChips').innerHTML =
      [['all', '全部'], ['confirmed', '已确认'], ['pending', '待调整']].map(([k, l]) =>
        '<button class="chip ' + (ui.status === k ? 'on' : '') + '" data-status="' + k + '">' + l + '</button>').join('');
    document.getElementById('tagChips').innerHTML =
      '<button class="chip ' + (ui.tag === 'all' ? 'on' : '') + '" data-tag="all">全部标签</button>' +
      TF.slice(0, 24).map(([t, c]) => '<button class="chip ' + (ui.tag === t ? 'on' : '') + '" data-tag="' + t + '">' + esc((D.vocab[t] || [, , t])[2]) + ' <span class="n">' + c + '</span></button>').join('');

    const list = filtered();
    document.getElementById('listCount').textContent = list.length;
    document.getElementById('itemList').innerHTML = list.length ? list.map(it => {
      const st = statusOf(it);
      return '<div class="li ' + (ui.selected === it.id ? 'sel' : '') + '" data-id="' + it.id + '">' +
        '<i class="li-bar" style="background:' + it.rarityHex + '"></i>' +
        '<div class="li-main"><div class="li-name">' + esc(it.name) + '</div>' +
        '<div class="li-meta">' + it.rarityLabel + ' · ' + it.catLabel + ' · ' + it.profession + '</div></div>' +
        (st.s === 'pending' ? '<span class="li-flag pending">待</span>' : '') + '</div>';
    }).join('') : '<div class="empty" style="padding:24px 6px">没有匹配的装备</div>';
    document.getElementById('baselineMini').innerHTML =
      '基线 <b>' + fx(S.baseline.atk) + '</b> 攻 / <b>' + fx(S.baseline.mana) + '</b> 魔 / <b>' + fx(S.baseline.hp) + '</b> 命';
  }

  // ---------------------------------------------------------------- 公共片段
  function objPill(k) {
    const o = D.objects[k]; if (!o) return '';
    return '<span class="objpill ' + (k === 'field' ? 'field' : '') + '">' + svg(k) + esc(o[0]) + '</span>';
  }
  function glanceOf(it) {
    const s = it.sections.find(x => x.lines.length);
    let t = s ? s.lines.join('') : it.body;
    t = t.replace(/\s+/g, '');
    if (t.length > 108) t = t.slice(0, 108) + '…';
    return t || '（本件只有数值行，没有正文机制描述）';
  }
  function simPanel(it) {
    const { cur, orig } = simPair(it);
    const p = paramsOf(it);
    const changed = Object.keys(S.overrides[it.id] || {}).length > 0 ||
      S.baseline.atk !== 1 || S.baseline.mana !== 100 || S.baseline.hp !== 20;
    const rows = [
      ['有效基础攻击力', cur.A, orig.A, 'big'],
      ['有效最大魔力值', cur.M, orig.M, 'big'],
      ['有效最大生命值', cur.H, orig.H, 'big'],
      ['单发伤害', cur.D, orig.D, ''],
      ['单次总伤（×目标数）', cur.total, orig.total, ''],
      ['满蓝可施放次数', cur.casts === null ? '不限' : cur.casts, null, ''],
      ['60 秒理论输出（估算）', cur.out60, orig.out60, ''],
      ['每点魔力伤害', cur.dpm === null ? '—' : fx(cur.dpm, 3), null, ''],
    ];
    return '<div class="card sticky">' +
      '<div class="panel-t"><span>数值模拟 · 基线影响</span><span class="mini">' + (changed ? '已改动' : '原始数值') + '</span></div>' +
      '<div class="base3">' +
      ['atk:基础攻击力', 'mana:最大魔力值', 'hp:最大生命值'].map(s => {
        const [k, l] = s.split(':');
        return '<div class="base-cell"><label>' + l + '</label><input type="number" data-base="' + k + '" step="any" value="' + fx(S.baseline[k]) + '"></div>';
      }).join('') + '</div>' +
      '<div class="hint" style="margin-bottom:8px">你给的基线是 攻 1 / 魔 100 / 命 20。改上面任一格，或改下面装备数值，右侧结果立刻重算。</div>' +
      rows.map(([k, v, o, cls]) => '<div class="simrow"><span class="k">' + k + '</span><span class="v ' + cls + '">' +
        (typeof v === 'number' ? fx(v, 3) : v) + (o !== null && changed ? deltaTag(v, o) : '') + '</span></div>').join('') +
      (cur.casts === 0 ? '<div class="bigwarn" style="margin-top:10px">当前最大魔力 ' + fx(cur.M) + ' 付不起单次消耗 ' + fx(p.manaCost) + '，满蓝也放不出这一下。调高基线魔力 / 最大魔力加成，或调低消耗即可看到输出变化。</div>' : '') +
      '<div class="formula">A = (基线攻 + 加成) × 乘区 = ' + fx(cur.A, 3) + '<br>' +
      'M = 基线魔 + 加成 = ' + fx(cur.M, 3) + '　H = 基线命 + 加成 = ' + fx(cur.H, 3) + '<br>' +
      '单发 = A×' + fx(p.dmgMul, 3) + ' + M×' + fx(p.manaScale, 3) + ' + ' + fx(p.flatDmg) + ' = ' + fx(cur.D, 3) + '</div>' +
      '<div class="hint" style="margin-top:10px">※ 60 秒输出按「冷却 / 持续 / 1 秒」取循环节奏估算，只用于对比手感，不是游戏内实测伤害。目标数默认 1，群体效果请自行调整。</div>' +
      '</div>';
  }
  function paramPanel(it) {
    const p = paramsOf(it), orig = it.params;
    const ov = S.overrides[it.id] || {};
    const lockRadius = it.tags.includes('formation') && !it.tags.includes('field');
    return '<div class="card">' +
      '<div class="panel-t"><span>可编辑数值</span><span class="mini">改完即时重算</span></div>' +
      PARAM_DEFS.map(d => {
        const locked = d.k === 'radius' && lockRadius;
        return '<div class="prow"><label>' + d.label + '<span class="unit">' + d.unit + '</span></label>' +
          '<input type="number" step="' + d.step + '" data-param="' + d.k + '" value="' + fx(p[d.k], 3) + '"' +
          (locked ? ' disabled title="术阵没有半径，此栏锁定"' : '') + ' class="' + (ov[d.k] !== undefined ? 'changed' : '') + '">' +
          '<span class="orig">' + (ov[d.k] !== undefined ? fx(orig[d.k], 2) : (locked ? '锁' : '')) + '</span></div>';
      }).join('') +
      (lockRadius ? '<div class="bigwarn">本件带「术阵」标签：术阵没有实体、位置、半径与范围，半径栏已锁定。若要描述范围效果，应写成「领域」或技能自身扫描。</div>' : '') +
      '<div class="hint" style="margin-top:10px">数值初值只从 lore / 拼色数值行的明确数字抽取；空值是原文没写，不是 0 强度。橙色边框 = 你改过，右侧显示原值。</div>' +
      '</div>';
  }

  // ---------------------------------------------------------------- 视图：战场总览
  function overviewHTML() {
    const fm = ITEMS.filter(i => i.tags.includes('formation')).length;
    const fd = ITEMS.filter(i => i.tags.includes('field')).length;
    const pend = ITEMS.filter(i => statusOf(i).s === 'pending').length;
    const objs = OBJ_ORDER.map(k => {
      const o = D.objects[k];
      const cnt = k === 'formation' ? fm : k === 'field' ? fd :
        ITEMS.filter(i => i.objects.includes(k)).length;
      return '<div class="obj ' + (k === 'formation' ? 'special' : k === 'field' ? 'field' : '') + '">' +
        '<div class="obj-n">' + cnt + '</div>' + '<div class="obj-ico">' + svg(k) + '</div>' +
        '<div class="obj-t">' + esc(o[0]) + ' <span class="obj-k">' + o[1] + '</span></div>' +
        '<div class="obj-d">' + esc(o[2]) + '</div></div>';
    }).join('');
    const checks = D.checks.map(c => '<div class="chk ' + (c.pass ? 'ok' : 'no') + '">' +
      '<div class="ic">' + (c.pass ? '✓' : '!') + '</div><div><div class="t">' + esc(c.title) + '</div>' +
      '<div class="d">' + esc(c.detail) + '</div>' +
      '<div class="n">扫描 ' + c.total + ' 件 · ' + (c.pass ? '全部符合' : '待复核 ' + c.bad.length + ' 件：' + c.bad.slice(0, 8).join('、') + (c.bad.length > 8 ? ' …' : '')) + '</div></div></div>').join('');
    const dist = D.meta.cats.map(c => {
      const pct = Math.round(c.n / ITEMS.length * 100);
      return '<div style="margin-bottom:9px"><div style="display:flex;justify-content:space-between;font-size:11px"><span>' + c.label + '</span><span class="mono" style="color:var(--txt3)">' + c.n + '</span></div>' +
        '<div class="bar"><i style="width:' + pct + '%"></i></div></div>';
    }).join('');
    const rdist = D.meta.rarities.map(r => '<div style="margin-bottom:9px"><div style="display:flex;justify-content:space-between;font-size:11px"><span style="color:' + r.hex + '">' + r.label + '</span><span class="mono" style="color:var(--txt3)">' + r.n + '</span></div>' +
      '<div class="bar"><i class="b" style="width:' + Math.round(r.n / ITEMS.length * 100) + '%;background:' + r.hex + '"></i></div></div>').join('');

    return '<h1 class="h1">战场总览</h1>' +
      '<p class="lead">先看战场上「看得见的东西」——术阵、领域、召唤物、状态、落雷、位移，再看数值。《坠梦》的机制都长在幻想概念和战斗行为里，装备不是一串系数，是你站进场里会遇到的对象。</p>' +
      '<div class="grid g4 sec" style="margin-top:20px">' +
      '<div class="kpi"><div class="v">231</div><div class="l">已实装装备</div><div class="sub">来自 231 个 give.mcfunction 真源</div></div>' +
      '<div class="kpi"><div class="v">410</div><div class="l">机制段</div><div class="sub">普攻 / 主动 / 被动 / 套装 / 专属段</div></div>' +
      '<div class="kpi"><div class="v">' + fm + ' <span style="font-size:14px;color:var(--txt3)">/</span> ' + fd + '</div><div class="l">术阵 / 领域</div><div class="sub">严格分开统计，不混为一谈</div></div>' +
      '<div class="kpi"><div class="v" style="color:var(--warn)">' + pend + '</div><div class="l">待调整</div><div class="sub">含规则自动标记与人工记录</div></div></div>' +

      '<div class="sec"><div class="h2">术阵与领域：两条完全不同的口径</div>' +
      '<div class="split">' +
      '<div class="split-col fm"><h3>' + svg('formation', 'obj-ico') + '术阵 · 纯占位</h3>' +
      '<div class="cap">manacore 玩家名下登记条目（8 槽 / 默认上限 3）。建阵时自动在脚下生成追随者 marker —— 那是独立效果，不是术阵本身。</div>' +
      [['实体', 'no', '✗ 没有'], ['位置', 'no', '✗ 没有'], ['半径', 'no', '✗ 没有'], ['范围 / 范围效果', 'no', '✗ 没有'], ['能打人 / 划圈', 'no', '✗ 不能'], ['作用', 'yes', '只记「有几个」']].map(([k, c, v]) =>
        '<div class="attr"><span>' + k + '</span><span class="' + c + '">' + v + '</span></div>').join('') +
      '<div class="bigwarn">✗ 错误写法：「生成一个术阵，阵内生物每秒受伤」——这是把领域写成了术阵。范围效果一律归领域或技能自身扫描。</div></div>' +
      '<div class="split-col fd"><h3>' + svg('field', 'obj-ico') + '领域 · 有范围</h3>' +
      '<div class="cap">包内固定叫法：范围增益 / 减益。实现上占 1 个术阵位，但两者语义不能互换。</div>' +
      [['位置', 'yes', '✓ 有'], ['半径', 'yes', '✓ 有'], ['范围 / 范围效果', 'yes', '✓ 有'], ['实体', 'yes', '由技能自己挂标签扫周围'], ['能打人 / 划圈', 'yes', '✓ 能'], ['作用', 'yes', '范围内增益 / 减益']].map(([k, c, v]) =>
        '<div class="attr"><span>' + k + '</span><span class="' + c + '">' + v + '</span></div>').join('') +
      '<div class="bigwarn" style="background:rgba(166,139,250,.08);border-color:rgba(166,139,250,.28);color:#c3b1ed">✓ 正确写法：「以某点为中心，N 格内全部生物…」——先例 威霆 / 神裁 / 云迹。领域有位置、半径、范围，术阵没有。</div></div>' +
      '</div></div>' +

      '<div class="sec"><div class="h2">可感知的战场对象</div><div class="objects">' + objs + '</div></div>' +
      '<div class="sec"><div class="h2">口径校验（从真源逐件扫出）</div><div class="grid g2">' + checks + '</div></div>' +
      '<div class="sec"><div class="h2">分布</div><div class="grid g2"><div class="card">' + dist + '</div><div class="card">' + rdist + '</div></div></div>' +
      '<div class="sec"><div class="h2">待调整清单</div>' + D.pending.map(p =>
        '<div class="pend"><span class="idx">' + p.id.toUpperCase() + '</span><div><div class="t">' + esc(p.title) + ' <span class="scope">' + esc(p.scope) + '</span></div><div class="n">' + esc(p.note) + '</div></div></div>').join('') +
      '<p class="hint">以上只收录盘点报告里的事实差异，未加入任何未确认的机制提案。</p></div>';
  }

  // ---------------------------------------------------------------- 视图：装备图鉴
  function libraryHTML() {
    const list = filtered();
    const title = ui.cat === 'all' ? '全部装备' : D.meta.cats.find(c => c.k === ui.cat).label;
    const cards = list.map(it => {
      const st = statusOf(it);
      const objs = it.objects.slice(0, 3).map(k => '<span class="mini-obj ' + (k === 'formation' ? 'fm' : k === 'field' ? 'fd' : '') + '">' + esc(OBJ_SHORT[k] || k) + '</span>').join('');
      return '<div class="ecard" data-id="' + it.id + '" style="--rc:' + it.rarityHex + '">' +
        '<div class="ec-h"><div><div class="ec-name">' + esc(it.name) + '</div>' +
        '<div class="ec-meta">' + it.catLabel + ' · ' + it.slotLabel + ' · ' + it.profession + '</div></div>' +
        '<span class="ec-r" style="color:' + it.rarityHex + ';border-color:' + it.rarityHex + '55">' + it.rarityLabel + '</span></div>' +
        '<div class="ec-snip">' + esc(glanceOf(it)) + '</div>' +
        '<div class="ec-objs">' + (objs || '<span class="mini-obj">纯数值</span>') + '</div>' +
        '<div class="ec-foot"><span>' + esc(it.roles.join(' / ')) + '</span><span>' + (st.s === 'pending' ? '待调整' : '已确认') + (it.overlimit ? ' · 超限' : '') + '</span></div></div>';
    }).join('');
    return '<h1 class="h1">装备图鉴 · ' + title + '</h1>' +
      '<p class="lead">按武器类型、稀有度档位、确认状态和标签联动筛选。点任意一件进入完整机制卡片；文案逐字来自 give.mcfunction，未改写。</p>' +
      '<div class="sec" style="margin-top:18px"><div class="grid" style="grid-template-columns:repeat(auto-fill,minmax(238px,1fr));gap:11px">' +
      (cards || '<div class="empty"><span class="big">◌</span>没有匹配的装备，换个筛选条件试试</div>') + '</div></div>';
  }

  // ---------------------------------------------------------------- 视图：机制卡片
  function detailHTML() {
    const it = BY_ID[ui.selected];
    if (!it) return '<div class="empty"><span class="big">✧</span>从左侧选一件装备</div>';
    const st = statusOf(it);
    const sections = it.sections.map(s =>
      '<div class="lore-sec"><div class="lore-h">✦ ' + esc(s.title) + '</div><div class="lore-b">' +
      s.stat.map(r => '<div class="statline">' + esc(r) + '</div>').join('') +
      (s.lines.length ? '<div>' + esc(s.lines.join('')) + '</div>' : '') + '</div></div>').join('');
    const tags = it.tags.map(t => {
      const v = D.vocab[t]; if (!v) return '';
      const cls = v[0] === '状态' ? 'violet' : v[0] === '数值' ? 'gold' : t === 'formation' ? 'teal' : t === 'field' ? 'violet' : '';
      return '<button class="tag ' + cls + '" data-jump-tag="' + t + '" title="' + esc(v[3]) + '">' + esc(v[2]) + ' <span style="opacity:.55;font-family:var(--mono);font-size:9px">' + t + '</span></button>';
    }).join('');
    const flags = [
      it.active ? '主动段' : '', it.passive ? '被动段' : '', it.hasPu ? '普攻段' : '',
      it.set ? '套装' : '', it.overlimit ? '超限形态' : '',
      it.rightClick ? '右键主动' : (it.cat === 'bow' ? '射击触发（无右键）' : ''),
      it.epicStaff ? (it.puExclusive ? '史诗+法杖 · 普攻有专属效果' : '史诗+法杖 · 普攻待补专属效果') : '',
    ].filter(Boolean);
    return '<div class="detail-grid">' +
      '<div>' +
      '<div class="dhead" style="--glow:' + it.rarityHex + '33">' +
      '<div class="dname">' + esc(it.name) +
      '<span class="ec-r" style="color:' + it.rarityHex + ';border-color:' + it.rarityHex + '55;font-size:11px">' + it.rarityLabel + '</span></div>' +
      '<div class="dsub">' + it.catLabel + ' · ' + it.slotLabel + ' · ' + it.profession + ' · 底材 ' + esc(it.base) + ' · 主题色 ' + esc(it.theme) + '</div>' +
      '<div class="droles">' + it.roles.map(r => '<span class="tag teal">' + esc(r) + '</span>').join('') +
      flags.map(f => '<span class="tag">' + esc(f) + '</span>').join('') + '</div>' +
      '<div class="glance"><span class="lb">战场一瞥 · 原文摘录</span>' + esc(glanceOf(it)) + '</div>' +
      '<div class="fieldnote">眉批原文：' + esc(it.head) + '　|　来源：<span class="mono">' + esc(it.source) + '</span></div></div>' +

      '<div class="sec" style="margin-top:16px"><div class="h2">战场对象（可感知）</div>' +
      '<div class="objline">' + (it.objects.length ? it.objects.map(objPill).join('') : '<span class="hint">本件不直接生成战场对象</span>') + '</div>' +
      (it.objects.includes('formation') ? '<div class="bigwarn">术阵：无实体 / 无位置 / 无半径 / 无范围，只记数量。此处的范围描述若存在，属于「领域」或技能自身扫描，不归术阵。</div>' : '') +
      (it.objects.includes('field') ? '<div class="bigwarn" style="background:rgba(166,139,250,.08);border-color:rgba(166,139,250,.28);color:#c3b1ed">领域：有位置、半径与范围效果，占 1 个术阵位。与术阵是两个独立概念。</div>' : '') +
      '</div>' +

      '<div class="sec"><div class="h2">完整机制卡片 · 原文</div>' + (sections || '<div class="hint">本件没有 ✦ 段（功能道具）</div>') +
      '<p class="hint">以上逐字来自 lore，未按设计意图重写；拼色数值行单独高亮。</p></div>' +

      '<div class="sec"><div class="h2">标签联动</div><div class="tagrow">' + tags + '</div>' +
      '<p class="hint" style="margin-top:8px">点标签可跳回图鉴筛选同词装备。词表共 28 词，全部来自 _tags_data.py 真源。</p></div>' +

      '<div class="sec"><div class="h2">确认状态与复盘记录</div>' + statusPanel(it, st) + '</div>' +
      '</div>' +
      '<div>' + simPanel(it) + '<div style="height:14px"></div>' + paramPanel(it) + '</div></div>';
  }

  function statusPanel(it, st) {
    return '<div class="card">' +
      '<div style="display:flex;justify-content:space-between;align-items:center;gap:10px;flex-wrap:wrap">' +
      '<div class="status-toggle"><button data-set-status="confirmed" class="' + (st.s === 'confirmed' ? 'on' : '') + '">已确认</button>' +
      '<button data-set-status="pending" class="' + (st.s === 'pending' ? 'on warn' : '') + '">待调整</button></div>' +
      '<span class="mini">' + (st.at ? '更新于 ' + esc(st.at.slice(0, 16).replace('T', ' ')) : '尚未手动编辑') + '</span></div>' +
      '<div style="margin-top:11px"><textarea class="note-area" data-note placeholder="记下要调整的点、已确认的结论、待复盘的问题…">' + esc(st.note) + '</textarea></div>' +
      '<div style="margin-top:8px"><button class="ghost-btn" data-save-note>保存记录</button></div></div>';
  }

  // ---------------------------------------------------------------- 视图：双件对比
  function cmpSelect(side) {
    const cur = S.compare[side];
    return '<div><label>' + (side === 'a' ? '装备 A' : '装备 B') + '</label><select data-cmp="' + side + '">' +
      '<option value="">— 请选择 —</option>' +
      D.meta.cats.map(c => '<optgroup label="' + c.label + '">' +
        ITEMS.filter(i => i.cat === c.k).map(i => '<option value="' + i.id + '"' + (cur === i.id ? ' selected' : '') + '>' + esc(i.name) + ' · ' + i.rarityLabel + '</option>').join('') + '</optgroup>').join('') +
      '</select></div>';
  }
  function compareHTML() {
    const a = BY_ID[S.compare.a], b = BY_ID[S.compare.b];
    let body = '<div class="empty"><span class="big">⇄</span>选两件装备，比较数值、战场对象与战斗定位</div>';
    if (a && b) {
      const pa = paramsOf(a), pb = paramsOf(b), sa = simPair(a).cur, sb = simPair(b).cur;
      const max = (x, y) => Math.max(Math.abs(x), Math.abs(y), 1e-9);
      const row = (k, va, vb, isNum) => {
        let extra = '';
        if (isNum) {
          const m = max(n(va), n(vb));
          extra = '<div class="bar"><i style="width:' + Math.round(Math.abs(n(va)) / m * 100) + '%"></i></div>' +
            '<div class="bar"><i class="b" style="width:' + Math.round(Math.abs(n(vb)) / m * 100) + '%"></i></div>';
        }
        return '<tr><td>' + k + '</td><td class="val">' + va + extra + '</td><td class="val">' + vb + extra + '</td></tr>';
      };
      const diff = (k, va, vb, p) => '<tr><td>' + k + '</td><td class="val">' + fx(va, p) + '</td><td class="val">' + fx(vb, p) + '</td></tr>';
      const verdict = [];
      if (sa.D !== sb.D) verdict.push('单发伤害 ' + (sa.D > sb.D ? 'A「' + a.name + '」' : 'B「' + b.name + '」') + '更高 ' + fx(Math.abs(sa.D - sb.D), 3) + ' 点');
      if (sa.casts !== sb.casts) verdict.push('满蓝可施放次数：A ' + (sa.casts === null ? '不限' : sa.casts) + ' 次 / B ' + (sb.casts === null ? '不限' : sb.casts) + ' 次');
      if (sa.M !== sb.M) verdict.push('有效最大魔力：A ' + fx(sa.M) + ' / B ' + fx(sb.M));
      if (sa.H !== sb.H) verdict.push('有效最大生命：A ' + fx(sa.H) + ' / B ' + fx(sb.H));
      if (sa.out60 !== sb.out60) verdict.push('60 秒理论输出：' + (sa.out60 > sb.out60 ? 'A' : 'B') + ' 更高 ' + fx(Math.abs(sa.out60 - sb.out60), 2));
      body = '<div class="card" style="margin-bottom:14px"><div class="cmp-head"><span></span>' +
        '<span class="side" style="color:' + a.rarityHex + '">' + esc(a.name) + ' <span class="mini">' + a.rarityLabel + '</span></span>' +
        '<span class="side" style="color:' + b.rarityHex + '">' + esc(b.name) + ' <span class="mini">' + b.rarityLabel + '</span></span></div>' +
        '<table class="cmp-table">' +
        row('类别 / 槽位', a.catLabel + ' · ' + a.slotLabel, b.catLabel + ' · ' + b.slotLabel, false) +
        row('职业', a.profession, b.profession, false) +
        row('战斗定位', esc(a.roles.join(' / ')), esc(b.roles.join(' / ')), false) +
        row('战场对象', a.objects.map(k => OBJ_SHORT[k]).join('、') || '—', b.objects.map(k => OBJ_SHORT[k]).join('、') || '—', false) +
        row('术阵 / 领域', (a.tags.includes('formation') ? '术阵' : '—') + ' / ' + (a.tags.includes('field') ? '领域' : '—'),
          (b.tags.includes('formation') ? '术阵' : '—') + ' / ' + (b.tags.includes('field') ? '领域' : '—'), false) +
        '<tr><td colspan="3" style="background:rgba(255,255,255,.025);font-size:10px;color:var(--txt3);letter-spacing:.1em">数值参数</td></tr>' +
        PARAM_DEFS.map(d => diff(d.label, pa[d.k], pb[d.k], 3)).join('') +
        '<tr><td colspan="3" style="background:rgba(255,255,255,.025);font-size:10px;color:var(--txt3);letter-spacing:.1em">基线影响（攻 ' + fx(S.baseline.atk) + ' / 魔 ' + fx(S.baseline.mana) + ' / 命 ' + fx(S.baseline.hp) + '）</td></tr>' +
        diff('有效基础攻击力', sa.A, sb.A, 3) + diff('有效最大魔力值', sa.M, sb.M, 3) + diff('有效最大生命值', sa.H, sb.H, 3) +
        diff('单发伤害', sa.D, sb.D, 3) + diff('单次总伤', sa.total, sb.total, 3) +
        row('满蓝可施放次数', sa.casts === null ? '不限' : sa.casts, sb.casts === null ? '不限' : sb.casts, false) +
        diff('60 秒理论输出（估算）', sa.out60, sb.out60, 2) +
        '</table></div>' +
        '<div class="card"><div class="h2">数值差异读出</div>' +
        (verdict.length ? verdict.map(v => '<div class="pend" style="border:none;background:transparent;padding:5px 0"><span class="idx">·</span><div class="n">' + esc(v) + '</div></div>').join('') : '<div class="hint">两件在当前基线下的模拟结果相同。</div>') +
        '<div class="divider"></div><div class="h2">战斗定位对照</div>' +
        '<div class="grid g2"><div class="card"><div style="font-weight:600;color:' + a.rarityHex + '">' + esc(a.name) + '</div><div class="hint" style="margin-top:6px">' + esc(glanceOf(a)) + '</div></div>' +
        '<div class="card"><div style="font-weight:600;color:' + b.rarityHex + '">' + esc(b.name) + '</div><div class="hint" style="margin-top:6px">' + esc(glanceOf(b)) + '</div></div></div>' +
        '<p class="hint" style="margin-top:10px">「战场一瞥」为 lore 原文摘录，不改写、不补写机制。</p></div>';
    }
    return '<h1 class="h1">双件对比</h1><p class="lead">并排看两件装备的数值、基线影响与战斗定位。所有数字都用同一套基线（攻 1 / 魔 100 / 命 20）重算。</p>' +
      '<div class="cmp-sel sec" style="margin-top:18px">' + cmpSelect('a') + cmpSelect('b') + '</div>' + body;
  }

  // ---------------------------------------------------------------- 视图：复盘记录
  function reviewHTML() {
    const pend = ITEMS.filter(i => statusOf(i).s === 'pending');
    const conf = ITEMS.length - pend.length;
    return '<h1 class="h1">复盘记录</h1>' +
      '<p class="lead">「已确认」是已实装、文案与数值都从真源读到的内容；「待调整」是需要你拍板的地方。状态与备注保存在本机，可导出 JSON 长期留存。</p>' +
      '<div class="grid g3 sec" style="margin-top:18px">' +
      '<div class="kpi"><div class="v">' + conf + '</div><div class="l">已确认</div></div>' +
      '<div class="kpi"><div class="v" style="color:var(--warn)">' + pend.length + '</div><div class="l">待调整</div></div>' +
      '<div class="kpi"><div class="v">' + S.customPending.length + '</div><div class="l">自建待办</div></div></div>' +

      '<div class="sec"><div class="h2">待调整装备</div>' +
      (pend.length ? pend.map(i => '<div class="pend"><span class="idx">◇</span><div style="flex:1"><div class="t">' + esc(i.name) +
        ' <span class="scope">' + i.rarityLabel + ' · ' + i.catLabel + '</span></div><div class="n">' + esc(statusOf(i).note || '（未填写备注）') + '</div></div>' +
        '<button class="ghost-btn small" data-go="' + i.id + '">查看</button></div>').join('') : '<div class="hint">暂无待调整装备。</div>') + '</div>' +

      '<div class="sec"><div class="h2">自建待办（补充、调整、复盘）</div>' +
      '<div class="card"><div style="display:flex;gap:8px;flex-wrap:wrap"><input id="newPend" placeholder="写一条要补 / 要改 / 要复盘的内容…" style="flex:1;min-width:220px;background:rgba(0,0,0,.28);border:1px solid var(--line);border-radius:7px;color:var(--txt);padding:8px 10px;font-family:inherit;font-size:12px;outline:none">' +
      '<button class="ghost-btn" data-add-pend>加入待办</button></div>' +
      '<div style="margin-top:12px">' + (S.customPending.length ? S.customPending.map((p, ix) =>
        '<div class="pend"><span class="idx">' + (ix + 1) + '</span><div style="flex:1"><div class="n">' + esc(p.text) + '</div><div class="hint">' + esc(p.at.slice(0, 16).replace('T', ' ')) + '</div></div>' +
        '<button class="ghost-btn small" data-del-pend="' + ix + '">移除</button></div>').join('') : '<div class="hint">还没有自建待办。</div>') + '</div></div></div>' +

      '<div class="sec"><div class="h2">口径待确认（盘点报告事实差异）</div>' +
      D.pending.map(p => '<div class="pend"><span class="idx">' + p.id.toUpperCase() + '</span><div><div class="t">' + esc(p.title) + ' <span class="scope">' + esc(p.scope) + '</span></div><div class="n">' + esc(p.note) + '</div></div></div>').join('') + '</div>';
  }

  // ---------------------------------------------------------------- 视图：口径与说明
  function rulesHTML() {
    const vocab = Object.entries(D.vocab).map(([k, v]) =>
      '<div class="vc"><div class="k">' + k + '</div><div class="l">' + esc(v[2]) + ' <span class="g">' + v[0] + '</span></div><div class="d">' + esc(v[3]) + '</div></div>').join('');
    return '<h1 class="h1">口径与说明</h1>' +
      '<p class="lead">这一页是《坠梦》的硬口径。继续补装备、调数值之前先看这里，尤其是术阵与领域的区别。</p>' +
      '<div class="sec"><div class="h2">术阵 ≠ 领域</div>' +
      '<div class="card"><table><thead><tr><th>属性</th><th>术阵 formation</th><th>领域 field</th></tr></thead><tbody>' +
      [['实体', '✗ 没有', '由技能自己挂标签扫周围'], ['位置', '✗ 没有', '✓ 有'], ['半径', '✗ 没有', '✓ 有'],
       ['范围 / 范围效果', '✗ 没有', '✓ 有'], ['能否打人 / 划圈', '不能', '能'],
       ['底层', '玩家名下登记条目（8 槽 / 默认上限 3）', '范围增益 / 减益，占 1 个术阵位'],
       ['写机制时', '只写「生成 / 移除 / 有几个术阵」', '写「以某点为中心，N 格内…」'],
       ['先例', '歌者建阵自动在脚下生成追随者 marker（独立效果）', '威霆 / 神裁 / 云迹']].map(r =>
        '<tr><td style="color:var(--txt2)">' + r[0] + '</td><td style="color:var(--teal)">' + r[1] + '</td><td style="color:var(--violet)">' + r[2] + '</td></tr>').join('') +
      '</tbody></table><div class="bigwarn">「生成一个术阵，阵内生物每秒受伤」是错误写法：范围效果一律归领域或技能自身扫描。术阵没有实体、位置、半径、范围。</div></div></div>' +

      '<div class="sec"><div class="h2">另外三条硬口径</div><div class="grid g3">' +
      '<div class="card"><div style="font-weight:600;color:var(--teal)">弩类不设计右键主动技能</div><div class="hint" style="margin-top:6px">弩 give 里的「主动技能」段指射击本身，触发走 minecraft 的 shot_crossbow，不是右键释放。盔甲也没有任何右键通道；右键主动技能需要 consumable + consume_item。</div></div>' +
      '<div class="card"><div style="font-weight:600;color:var(--gold)">史诗及以上法杖 · 普攻专属效果</div><div class="hint" style="margin-top:6px">精器 / 秘器 / 禁器（旧档 史诗 / 传说 / 禁忌）法杖，普攻要写出独属于它的战场行为，不能只有「魔力 N · 伤害 X」。当前扫描 35 件，5 件待复核，已在总览与复盘中列出。</div></div>' +
      '<div class="card"><div style="font-weight:600;color:var(--violet)">item_name 颜色 ≠ 稀有度</div><div class="hint" style="margin-top:6px">物品名颜色编码技能风格，与稀有度无关，绝不改动。档位色只走 lore 眉批：常器 / 异器 / 精器 / 秘器 / 禁器。</div></div></div></div>' +

      '<div class="sec"><div class="h2">基线影响力怎么算</div><div class="card">' +
      '<p class="hint" style="font-size:11.5px">你给的基线是 <b style="color:var(--teal)">基础攻击力 = 1 · 最大魔力值 = 100 · 最大生命值 = 20</b>。装备的数值改动会先作用到这三条，再往下推伤害与续航：</p>' +
      '<div class="formula" style="font-size:11px;padding:12px">有效基础攻击力 A = (基线攻 + 加成) × 基础攻击力乘区<br>有效最大魔力 M = 基线魔 + 最大魔力值加成<br>有效最大生命 H = 基线命 + 最大生命值加成<br>单发伤害 D = A × 伤害系数 + M × 最大魔力系数 + 固定伤害<br>满蓝可施放 = ⌊M ÷ 单次魔力消耗⌋　·　单次总伤 = D × 目标数<br>60 秒理论输出 = 单次总伤 × min(满蓝次数, ⌊60 ÷ 循环节奏⌋)</div>' +
      '<p class="hint" style="margin-top:10px">循环节奏取「冷却 / 持续 / 1 秒」的最大值。这是给对比手感用的估算，不是游戏内实测伤害；目标数默认 1，群体效果需自行调整。原文没写的数字留 0，不代表「没有强度」，只代表「没读到」。</p></div></div>' +

      '<div class="sec"><div class="h2">标签词表 · 28 词（真源 _tags_data.py）</div><div class="vocab">' + vocab + '</div></div>' +

      '<div class="sec"><div class="h2">数据来源与保真</div><div class="card hint" style="font-size:11.5px">' +
      '231 件来自 <span class="mono">sweetdream/data/sweetdream/function/equipment/**/give.mcfunction</span> 的 item_name / lore / custom_data；' +
      '稀有度取 give 里的 <span class="mono">rarity:t1..t5</span>（与 <span class="mono">rarity_truth.csv</span> 对齐）；标签取 <span class="mono">custom_data.tags</span>；' +
      '术阵与领域的定义取 <span class="mono">_tags_data.py</span> 词汇表口径第 4 / 5 条。<br><br>' +
      '机制卡片里的文案逐字保留，未按设计意图重写；未确认的候选稿、白昼梦系列、补缺四批 24 件等<strong>没有</strong>混入这 231 件。' +
      '数值初值只从明确写出的数字抽取，模拟器允许你自由改，但改动只存在浏览器里，不会写回数据包。' +
      '</div></div>' +

      '<div class="sec"><div class="h2">怎么持续迭代</div><div class="card hint" style="font-size:11.5px">' +
      '<b style="color:var(--teal)">真源更新</b> → 在 <span class="mono">D:/数据包</span> 跑 <span class="mono">python .workbuddy/gen_arsenal_data.py</span> 重生成 <span class="mono">data.js</span>，重新发布即可，链接不变。<br>' +
      '<b style="color:var(--teal)">改数值 / 标状态 / 记待办</b> → 存当前浏览器（localStorage），刷新不丢；换设备或清缓存会丢，用左栏「导出存档」留 JSON，「导入存档」恢复。<br>' +
      '<b style="color:var(--teal)">边界</b> → 这里是设计推演层，改动不写回数据包；要落地改 <span class="mono">give.mcfunction</span> 真源，再走部署。' +
      '</div></div>';
  }

  // ---------------------------------------------------------------- 渲染
  function applyHash() {
    const h = (location.hash || '').replace(/^#/, '').split('/');
    if (['overview', 'library', 'detail', 'compare', 'review', 'rules'].includes(h[0])) ui.view = h[0];
    if (h[1] && BY_ID[h[1]]) ui.selected = h[1];
  }
  function syncHash() {
    const h = '#' + ui.view + (ui.view === 'detail' && ui.selected ? '/' + ui.selected : '');
    if (location.hash !== h) { try { history.replaceState(null, '', h); } catch (e) { location.hash = h; } }
  }
  window.addEventListener('hashchange', () => { applyHash(); render(); });

  function render() {
    syncHash();
    renderRail();
    const names = { overview: '战场总览', library: '装备图鉴', detail: '机制卡片', compare: '双件对比', review: '复盘记录', rules: '口径与说明' };
    document.getElementById('crumbView').textContent = names[ui.view];
    const sel = BY_ID[ui.selected];
    document.getElementById('crumbItem').textContent = ui.view === 'detail' && sel ? sel.name : (ui.cat === 'all' ? '全部装备' : D.meta.cats.find(c => c.k === ui.cat).label);
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.toggle('active', b.dataset.view === ui.view));
    const v = document.getElementById('view');
    v.innerHTML = ({ overview: overviewHTML, library: libraryHTML, detail: detailHTML, compare: compareHTML, review: reviewHTML, rules: rulesHTML })[ui.view]();
    v.scrollTop = 0;
  }

  // ---------------------------------------------------------------- 事件
  document.getElementById('nav').addEventListener('click', e => {
    const b = e.target.closest('.nav-btn'); if (!b) return;
    ui.view = b.dataset.view; render();
  });
  function chipHandler(e, attr, key) {
    const b = e.target.closest('[' + attr + ']'); if (!b) return;
    ui[key] = b.getAttribute(attr);
    if (ui.view === 'overview' || ui.view === 'rules') ui.view = 'library';
    render();
  }
  document.getElementById('catChips').addEventListener('click', e => chipHandler(e, 'data-cat', 'cat'));
  document.getElementById('rarChips').addEventListener('click', e => {
    const b = e.target.closest('[data-rar]'); if (!b) return;
    ui.rarity = b.dataset.rar === 'none' ? 'none' : b.dataset.rar;
    if (ui.view === 'overview' || ui.view === 'rules') ui.view = 'library';
    if (ui.rarity === 'none') { /* 不参与稀有度：rarity 为空串 */ }
    render();
  });
  document.getElementById('statusChips').addEventListener('click', e => chipHandler(e, 'data-status', 'status'));
  document.getElementById('tagChips').addEventListener('click', e => chipHandler(e, 'data-tag', 'tag'));
  document.getElementById('q').addEventListener('input', e => {
    ui.q = e.target.value;
    if (ui.view === 'overview' || ui.view === 'rules') ui.view = 'library';
    renderListOnly();
  });
  function renderListOnly() {
    // 只重画清单与图鉴内容，避免输入焦点被整体重渲染打断
    renderRailList();
    if (ui.view === 'library') document.getElementById('view').innerHTML = libraryHTML();
  }
  function renderRailList() {
    const list = filtered();
    document.getElementById('listCount').textContent = list.length;
    document.getElementById('itemList').innerHTML = list.length ? list.map(it => {
      const st = statusOf(it);
      return '<div class="li ' + (ui.selected === it.id ? 'sel' : '') + '" data-id="' + it.id + '">' +
        '<i class="li-bar" style="background:' + it.rarityHex + '"></i>' +
        '<div class="li-main"><div class="li-name">' + esc(it.name) + '</div>' +
        '<div class="li-meta">' + it.rarityLabel + ' · ' + it.catLabel + ' · ' + it.profession + '</div></div>' +
        (st.s === 'pending' ? '<span class="li-flag pending">待</span>' : '') + '</div>';
    }).join('') : '<div class="empty" style="padding:24px 6px">没有匹配的装备</div>';
  }
  document.getElementById('itemList').addEventListener('click', e => {
    const l = e.target.closest('.li'); if (!l) return;
    ui.selected = l.dataset.id; ui.view = 'detail'; render();
  });

  const view = document.getElementById('view');
  view.addEventListener('click', e => {
    const card = e.target.closest('.ecard');
    if (card) { ui.selected = card.dataset.id; ui.view = 'detail'; render(); return; }
    const jt = e.target.closest('[data-jump-tag]');
    if (jt) { ui.tag = jt.dataset.jumpTag; ui.cat = 'all'; ui.rarity = 'all'; ui.status = 'all'; ui.view = 'library'; render(); return; }
    const go = e.target.closest('[data-go]');
    if (go) { ui.selected = go.dataset.go; ui.view = 'detail'; render(); return; }
    const ss = e.target.closest('[data-set-status]');
    if (ss) {
      const it = BY_ID[ui.selected]; if (!it) return;
      const old = statusOf(it);
      S.status[it.id] = { s: ss.dataset.setStatus, note: old.note, at: new Date().toISOString() };
      save(); render(); toast('状态已更新'); return;
    }
    if (e.target.closest('[data-save-note]')) {
      const it = BY_ID[ui.selected]; if (!it) return;
      const ta = view.querySelector('[data-note]');
      const old = statusOf(it);
      S.status[it.id] = { s: old.s, note: ta ? ta.value : '', at: new Date().toISOString() };
      save(); toast('记录已保存'); render(); return;
    }
    if (e.target.closest('[data-add-pend]')) {
      const inp = document.getElementById('newPend');
      if (inp && inp.value.trim()) { S.customPending.push({ text: inp.value.trim(), at: new Date().toISOString() }); save(); render(); toast('已加入待办'); }
      return;
    }
    const del = e.target.closest('[data-del-pend]');
    if (del) { S.customPending.splice(Number(del.dataset.delPend), 1); save(); render(); return; }
  });

  view.addEventListener('input', e => {
    const pb = e.target.closest('[data-base]');
    if (pb) {
      const k = pb.dataset.base; const val = Number(pb.value);
      if (Number.isFinite(val)) { S.baseline[k] = Math.max(0, val); save(); }
      // 局部更新模拟结果，避免输入框失焦
      softSimUpdate(); return;
    }
    const pp = e.target.closest('[data-param]');
    if (pp && !pp.disabled) {
      const it = BY_ID[ui.selected]; if (!it) return;
      const k = pp.dataset.param; const val = Number(pp.value);
      if (!Number.isFinite(val)) return;
      const ov = S.overrides[it.id] || (S.overrides[it.id] = {});
      ov[k] = Math.max(0, val);
      pp.classList.add('changed');
      const origCell = pp.parentElement.querySelector('.orig');
      if (origCell) origCell.textContent = fx(it.params[k], 2);
      save(); softSimUpdate(); return;
    }
  });
  view.addEventListener('change', e => {
    const cs = e.target.closest('[data-cmp]');
    if (cs) { S.compare[cs.dataset.cmp] = cs.value || null; save(); render(); }
  });
  function softSimUpdate() {
    const it = BY_ID[ui.selected]; if (!it || ui.view !== 'detail') { return; }
    // 基线输入框在模拟面板内部，重绘后要把焦点与光标还回去，避免打字被打断
    const ae = document.activeElement;
    const focusKey = ae && ae.dataset ? ae.dataset.base : null;
    let pos = null;
    try { if (focusKey && typeof ae.selectionStart === 'number') pos = ae.selectionStart; } catch (e) { }
    const holder = view.querySelector('.sticky');
    if (holder) {
      const tmp = document.createElement('div'); tmp.innerHTML = simPanel(it);
      holder.replaceWith(tmp.firstElementChild);
    }
    if (focusKey) {
      const next = view.querySelector('[data-base="' + focusKey + '"]');
      if (next) { next.focus(); if (pos !== null) { try { next.setSelectionRange(pos, pos); } catch (e) { } } }
    }
    document.getElementById('baselineMini').innerHTML = '基线 <b>' + fx(S.baseline.atk) + '</b> 攻 / <b>' + fx(S.baseline.mana) + '</b> 魔 / <b>' + fx(S.baseline.hp) + '</b> 命';
  }

  document.getElementById('resetBtn').addEventListener('click', () => {
    const it = BY_ID[ui.selected]; if (!it) return;
    delete S.overrides[it.id];
    S.baseline = { ...DEFAULT_BASE };
    save(); render(); toast('已还原本件数值与基线');
  });
  document.getElementById('exportBtn').addEventListener('click', () => {
    const blob = new Blob([JSON.stringify({ app: '坠梦装备台', version: 1, exportedAt: new Date().toISOString(), ...S }, null, 2)], { type: 'application/json' });
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob);
    a.download = '坠梦装备台_存档_' + new Date().toISOString().slice(0, 10) + '.json';
    a.click(); setTimeout(() => URL.revokeObjectURL(a.href), 1000); toast('存档已导出');
  });
  document.getElementById('importBtn').addEventListener('click', () => document.getElementById('importFile').click());
  document.getElementById('importFile').addEventListener('change', e => {
    const f = e.target.files[0]; if (!f) return;
    const r = new FileReader();
    r.onload = () => {
      try {
        const d = JSON.parse(r.result);
        S = Object.assign(fresh(), d);
        S.baseline = Object.assign({ ...DEFAULT_BASE }, S.baseline || {});
        save(); render(); toast('存档已导入');
      } catch (err) { toast('导入失败：不是有效的存档 JSON'); }
    };
    r.readAsText(f); e.target.value = '';
  });

  applyHash();
  render();
})();
