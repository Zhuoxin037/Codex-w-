# -*- coding: utf-8 -*-
"""把 axo(DamageTypeTags) 的 <clinit> 里 '每个 TagKey 字段 <- 哪个 tag 字符串' 对上，
   确认 byf(LivingEntity) 里 getstatic 的那个字段是不是 bypasses_cooldown。"""
import struct, zipfile
J = r'D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar'
z = zipfile.ZipFile(J)
data = z.read('axo.class')


class R:
    def __init__(s, b): s.b = b; s.i = 0
    def u1(s): v = s.b[s.i]; s.i += 1; return v
    def u2(s): v = struct.unpack_from(">H", s.b, s.i)[0]; s.i += 2; return v
    def u4(s): v = struct.unpack_from(">I", s.b, s.i)[0]; s.i += 4; return v
    def raw(s, n): v = s.b[s.i:s.i+n]; s.i += n; return v


r = R(data); assert r.u4() == 0xCAFEBABE; r.u2(); r.u2()
cpc = r.u2()
utf8 = {}; string = {}
i = 1
while i < cpc:
    t = r.u1()
    if t == 1: utf8[i] = r.raw(r.u2()).decode("utf-8", "replace"); i += 1
    elif t in (3, 4): r.u4(); i += 1
    elif t in (5, 6): r.u4(); r.u4(); i += 2
    elif t == 7: r.u2(); i += 1
    elif t == 8: string[i] = r.u2(); i += 1
    elif t in (9, 10, 11, 12, 17, 18): r.u2(); r.u2(); i += 1
    elif t in (16, 19, 20): r.u2(); i += 1
    elif t == 15: r.u1(); r.u2(); i += 1
    else: raise RuntimeError(t)
r.u2(); r.u2(); r.u2()
for _ in range(r.u2()): r.u2()
print('--- fields ---')
nf = r.u2(); FIELDS = []
for _ in range(nf):
    acc = r.u2(); ni = r.u2(); di = r.u2()
    for _ in range(r.u2()):
        r.u2(); r.raw(r.u4())
    FIELDS.append((utf8.get(ni), utf8.get(di)))
for fn, fd in FIELDS:
    print('  ', fn, fd)


nm = r.u2(); methods = []
for _ in range(nm):
    acc = r.u2(); ni = r.u2(); di = r.u2()
    mname = utf8.get(ni); mdesc = utf8.get(di); code = None
    for _ in range(r.u2()):
        an = r.u2(); ln = r.u4()
        if utf8.get(an) == "Code":
            sub = R(r.raw(ln)); sub.u2(); sub.u2(); code = sub.raw(sub.u4())
        else: r.raw(ln)
    methods.append((mname, mdesc, code))

# 常量池里 index->字符串
strval = {}
for idx, si in string.items():
    strval[idx] = utf8.get(si)
print('--- 常量池里含 bypasses 的字符串 idx ---')
want = {}
for idx, s in strval.items():
    if s and 'bypasses' in s:
        want[idx] = s
        print('  idx', idx, '=', s)

LEN = {}
for op in list(range(0x00, 0x10)) + list(range(0x1a, 0x36)) + list(range(0x3b, 0x84)) + list(range(0x85, 0x99)) + list(range(0xac, 0xb2)) + [0xbe, 0xbf, 0xc2, 0xc3]: LEN[op] = 0
for op in [0x10, 0x12, 0x15, 0x16, 0x17, 0x18, 0x19, 0x36, 0x37, 0x38, 0x39, 0x3a, 0xa9, 0xbc]: LEN[op] = 1
for op in [0x11, 0x13, 0x14, 0x84, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xbb, 0xbd, 0xc0, 0xc1, 0xc6, 0xc7] + list(range(0x99, 0xa9)): LEN[op] = 2
for op in [0xb9, 0xba, 0xc8, 0xc9]: LEN[op] = 4
LEN[0xc5] = 3


def instrs(code):
    out = []; pc = 0; n = len(code)
    while pc < n:
        op = code[pc]; st = pc; pc += 1
        if op in (0xaa, 0xab):
            pad = (4 - (pc % 4)) % 4; pc += pad
            if op == 0xaa:
                pc += 4; lo = struct.unpack_from(">i", code, pc)[0]; pc += 4
                hi = struct.unpack_from(">i", code, pc)[0]; pc += 4; pc += 4*(hi-lo+1)
            else:
                pc += 4; np = struct.unpack_from(">i", code, pc)[0]; pc += 4; pc += 8*np
            out.append((st, op, None)); continue
        if op == 0xc4:
            sub = code[pc]; pc += 1; pc += 4 if sub == 0x84 else 2; out.append((st, op, None)); continue
        l = LEN.get(op)
        if l is None: out.append((st, -1, None)); break
        operand = code[pc] if l == 1 else (struct.unpack_from(">H", code, pc)[0] if l else None)
        pc += l; out.append((st, op, operand))
    return out


# fieldref: 需要 fieldref 表, 重建
r2 = R(data); r2.u4(); r2.u2(); r2.u2(); cpc2 = r2.u2()
u8 = {}; s8 = {}; fref = {}; nat = {}
i = 1
while i < cpc2:
    t = r2.u1()
    if t == 1: u8[i] = r2.raw(r2.u2()).decode('utf-8', 'replace'); i += 1
    elif t in (3, 4): r2.u4(); i += 1
    elif t in (5, 6): r2.u4(); r2.u4(); i += 2
    elif t == 7: r2.u2(); i += 1
    elif t == 8: s8[i] = r2.u2(); i += 1
    elif t in (9, 10, 11, 12, 17, 18):
        a = r2.u2(); b = r2.u2()
        if t == 9: fref[i] = (a, b)
        if t == 12: nat[i] = (a, b)
        i += 1
    elif t in (16, 19, 20): r2.u2(); i += 1
    elif t == 15: r2.u1(); r2.u2(); i += 1
    else: raise RuntimeError(t)


def fname(x):
    if x not in fref: return '?'
    ci, ni = fref[x]
    if ni not in nat: return '?'
    a, b = nat[ni]; return u8.get(a)


print('--- <clinit>: ldc 字符串 -> 紧随的 putstatic 字段 ---')
for (mn, md, code) in methods:
    if mn != '<clinit>': continue
    ins = instrs(code)
    for k, (pc, op, opd) in enumerate(ins):
        if op == 0x12 or op == 0x13:  # ldc / ldc_w
            s = strval.get(opd) if op == 0x12 else strval.get(opd)
            if s and 'bypasses' in s:
                # 往后找最近的 putstatic
                for (pc2, op2, opd2) in ins[k+1:k+6]:
                    if op2 == 0xb3:
                        print('  %-28s -> putstatic %s' % (s, fname(opd2)))
                        break
