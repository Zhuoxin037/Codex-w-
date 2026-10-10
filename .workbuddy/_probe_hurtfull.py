# -*- coding: utf-8 -*-
"""完整反汇编 LivingEntity.hurt() —— 只为看清 'aj' 与哪个常量比较。"""
import struct, zipfile, sys
J = r"D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar"
ENTRY = sys.argv[1] if len(sys.argv) > 1 else "byf.class"
WANT = sys.argv[2] if len(sys.argv) > 2 else "a(Lasb;Lbvt;F)Z"
data = zipfile.ZipFile(J).read(ENTRY)


class R:
    def __init__(s, b): s.b = b; s.i = 0
    def u1(s): v = s.b[s.i]; s.i += 1; return v
    def u2(s): v = struct.unpack_from(">H", s.b, s.i)[0]; s.i += 2; return v
    def u4(s): v = struct.unpack_from(">I", s.b, s.i)[0]; s.i += 4; return v
    def raw(s, n): v = s.b[s.i:s.i+n]; s.i += n; return v


r = R(data); assert r.u4() == 0xCAFEBABE; r.u2(); r.u2()
cpc = r.u2(); utf8 = {}; string = {}; fieldref = {}; nat = {}; mref = {}; cls = {}
i = 1
while i < cpc:
    t = r.u1()
    if t == 1: utf8[i] = r.raw(r.u2()).decode("utf-8", "replace"); i += 1
    elif t in (3, 4): r.u4(); i += 1
    elif t in (5, 6): r.u4(); r.u4(); i += 2
    elif t == 7: cls[i] = r.u2(); i += 1
    elif t == 8: string[i] = r.u2(); i += 1
    elif t in (9, 10, 11, 12, 17, 18):
        a = r.u2(); b = r.u2()
        if t == 9: fieldref[i] = (a, b)
        if t == 12: nat[i] = (a, b)
        if t in (10, 11): mref[i] = (a, b)
        i += 1
    elif t in (16, 19, 20): r.u2(); i += 1
    elif t == 15: r.u1(); r.u2(); i += 1
    else: raise RuntimeError(t)
r.u2(); r.u2(); r.u2()
for _ in range(r.u2()): r.u2()


def skip_attrs():
    for _ in range(r.u2()):
        r.u2(); r.raw(r.u4())


for _ in range(r.u2()):
    r.u2(); r.u2(); r.u2(); skip_attrs()
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

LEN = {}
for op in list(range(0x00, 0x10)) + list(range(0x1a, 0x36)) + list(range(0x3b, 0x84)) + list(range(0x85, 0x99)) + list(range(0xac, 0xb2)) + [0xbe, 0xbf, 0xc2, 0xc3]: LEN[op] = 0
for op in [0x10, 0x12, 0x15, 0x16, 0x17, 0x18, 0x19, 0x36, 0x37, 0x38, 0x39, 0x3a, 0xa9, 0xbc]: LEN[op] = 1
for op in [0x11, 0x13, 0x14, 0x84, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xbb, 0xbd, 0xc0, 0xc1, 0xc6, 0xc7] + list(range(0x99, 0xa9)): LEN[op] = 2
for op in [0xb9, 0xba, 0xc8, 0xc9]: LEN[op] = 4
LEN[0xc5] = 3
NAMES = {0x99: 'ifeq', 0x9a: 'ifne', 0x9b: 'iflt', 0x9c: 'ifge', 0x9d: 'ifgt', 0x9e: 'ifle',
         0x9f: 'if_icmpeq', 0xa0: 'if_icmpne', 0xa1: 'if_icmplt', 0xa2: 'if_icmpge', 0xa3: 'if_icmpgt', 0xa4: 'if_icmple',
         0xa5: 'if_acmpeq', 0xa6: 'if_acmpne', 0xa7: 'goto'}


def instrs(code):
    out = []; pc = 0; n = len(code)
    while pc < n:
        op = code[pc]; st = pc; pc += 1
        if op in (0xaa, 0xab):
            pad = (4 - (pc % 4)) % 4; pc += pad
            if op == 0xaa:
                pc += 4; low = struct.unpack_from(">i", code, pc)[0]; pc += 4
                hi = struct.unpack_from(">i", code, pc)[0]; pc += 4; pc += 4 * (hi - low + 1)
            else:
                pc += 4; np = struct.unpack_from(">i", code, pc)[0]; pc += 4; pc += 8 * np
            out.append((st, op, None)); continue
        if op == 0xc4:
            sub = code[pc]; pc += 1; pc += 4 if sub == 0x84 else 2; out.append((st, op, None)); continue
        l = LEN.get(op)
        if l is None: out.append((st, -1, None)); break
        operand = code[pc] if l == 1 else (struct.unpack_from(">H", code, pc)[0] if l else None)
        pc += l; out.append((st, op, operand))
    return out


def f(x):
    if x not in fieldref: return None
    ci, ni = fieldref[x]
    if ni not in nat: return None
    a, b = nat[ni]; return "%s:%s" % (utf8.get(a), utf8.get(b))


def mx(x):
    if x not in mref: return None
    ci, ni = mref[x]
    if ni not in nat: return None
    a, b = nat[ni]; return "%s%s" % (utf8.get(a), utf8.get(b))


for (mn, md, code) in methods:
    if (mn + md) != WANT: continue
    print("== %s%s ==  (%d bytes)" % (mn, md, len(code)))
    ins = instrs(code)
    # pc -> 指令序号，便于看分支目标
    pcmap = {pc: k for k, (pc, op, opd) in enumerate(ins)}
    for k, (pc, op, opd) in enumerate(ins):
        tag = ""
        if op in NAMES:
            tgt = pc + int(struct.unpack(">b", struct.pack(">B", opd))[0]) if opd is not None and opd < 256 else None
            # 分支偏移是有符号 16 位
            if opd is not None:
                tgt = pc + struct.unpack(">h", struct.pack(">H", opd))[0]
            tag = "  -> +%s (pc %s%s)" % (struct.unpack(">h", struct.pack(">H", opd))[0] if opd is not None else "?", tgt, (", #%d" % pcmap[tgt]) if tgt in pcmap else "")
            print("%4d @%4d %s%s" % (k, pc, NAMES[op], tag))
        elif 0x02 <= op <= 0x08:
            print("%4d @%4d iconst %d" % (k, pc, op - 3))
        elif op in (0x10, 0x11):
            print("%4d @%4d %s %d" % (k, pc, 'bipush' if op == 0x10 else 'sipush', opd))
        elif op == 0xb4:
            print("%4d @%4d getfield %s" % (k, pc, f(opd)))
        elif op == 0xb5:
            print("%4d @%4d putfield %s" % (k, pc, f(opd)))
        elif op in (0xb2, 0xb3):
            print("%4d @%4d %s %s" % (k, pc, 'getstatic' if op == 0xb2 else 'putstatic', f(opd)))
        elif op in (0xb6, 0xb7, 0xb8):
            print("%4d @%4d cn %s" % (k, pc, mx(opd)))
        elif op == 0x12:
            print("%4d @%4d ldc" % (k, pc))
        elif op == 0x13:
            print("%4d @%4d ldc_w" % (k, pc))
        elif op == 0x00:
            print("%4d @%4d nop" % (k, pc))
        elif op == 0xa7:
            pass
        else:
            print("%4d @%4d op=0x%02x %s" % (k, pc, op, opd if opd is not None else ''))
