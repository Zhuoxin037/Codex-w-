# -*- coding: utf-8 -*-
import struct, zipfile, sys
J = r"D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/1.21.5-Fabric 0.16.10.jar"
ENTRY = sys.argv[1] if len(sys.argv) > 1 else "byf.class"
data = zipfile.ZipFile(J).read(ENTRY)
class R:
    def __init__(s,b): s.b=b; s.i=0
    def u1(s): v=s.b[s.i]; s.i+=1; return v
    def u2(s): v=struct.unpack_from(">H",s.b,s.i)[0]; s.i+=2; return v
    def u4(s): v=struct.unpack_from(">I",s.b,s.i)[0]; s.i+=4; return v
    def raw(s,n): v=s.b[s.i:s.i+n]; s.i+=n; return v
r=R(data); assert r.u4()==0xCAFEBABE; r.u2(); r.u2()
cpc=r.u2(); utf8={}; string={}; fieldref={}; nat={}
i=1
while i<cpc:
    t=r.u1()
    if t==1: utf8[i]=r.raw(r.u2()).decode("utf-8","replace"); i+=1
    elif t in (3,4): r.u4(); i+=1
    elif t in (5,6): r.u4(); r.u4(); i+=2
    elif t in (7,): r.u2(); i+=1
    elif t==8: string[i]=r.u2(); i+=1
    elif t in (9,10,11,12,17,18):
        a=r.u2(); b=r.u2()
        if t==9: fieldref[i]=(a,b)
        if t==12: nat[i]=(a,b)
        i+=1
    elif t in (16,19,20): r.u2(); i+=1
    elif t==15: r.u1(); r.u2(); i+=1
    else: raise RuntimeError(t)
r.u2(); r.u2(); r.u2()
for _ in range(r.u2()): r.u2()
def skip_attrs():
    for _ in range(r.u2()):
        r.u2(); r.raw(r.u4())
for _ in range(r.u2()):  # fields
    r.u2(); r.u2(); r.u2(); skip_attrs()
nm=r.u2(); methods=[]
for _ in range(nm):
    acc=r.u2(); ni=r.u2(); di=r.u2()
    mname=utf8.get(ni); mdesc=utf8.get(di); code=None
    for _ in range(r.u2()):
        an=r.u2(); ln=r.u4()
        if utf8.get(an)=="Code":
            sub=R(r.raw(ln)); sub.u2(); sub.u2(); code=sub.raw(sub.u4())
        else: r.raw(ln)
    methods.append((mname,mdesc,code))
LEN={}
for op in list(range(0x00,0x10))+list(range(0x1a,0x36))+list(range(0x3b,0x84))+list(range(0x85,0x99))+list(range(0xac,0xb2))+[0xbe,0xbf,0xc2,0xc3]: LEN[op]=0
for op in [0x10,0x12,0x15,0x16,0x17,0x18,0x19,0x36,0x37,0x38,0x39,0x3a,0xa9,0xbc]: LEN[op]=1
for op in [0x11,0x13,0x14,0x84,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xbb,0xbd,0xc0,0xc1,0xc6,0xc7]+list(range(0x99,0xa9)): LEN[op]=2
for op in [0xb9,0xba,0xc8,0xc9]: LEN[op]=4
LEN[0xc5]=3
def instrs(code):
    out=[]; pc=0; n=len(code)
    while pc<n:
        op=code[pc]; st=pc; pc+=1
        if op in (0xaa,0xab):
            pad=(4-(pc%4))%4; pc+=pad
            if op==0xaa:
                pc+=4; low=struct.unpack_from(">i",code,pc)[0]; pc+=4
                hi=struct.unpack_from(">i",code,pc)[0]; pc+=4; pc+=4*(hi-low+1)
            else:
                pc+=4; np=struct.unpack_from(">i",code,pc)[0]; pc+=4; pc+=8*np
            out.append((st,op,None)); continue
        if op==0xc4:
            sub=code[pc]; pc+=1; pc+=4 if sub==0x84 else 2; out.append((st,op,None)); continue
        l=LEN.get(op)
        if l is None: out.append((st,-1,None)); break
        operand=code[pc] if l==1 else (struct.unpack_from(">H",code,pc)[0] if l else None)
        pc+=l; out.append((st,op,operand))
    return out
def fref(x):
    if x not in fieldref: return None
    ci,ni=fieldref[x]
    if ni not in nat: return None
    a,b=nat[ni]; return (utf8.get(a),utf8.get(b))
hstr=[i for i,u in string.items() if utf8.get(u)=="HurtTime"]
print("HurtTime String idx:", hstr)
def opn(op):
    return {0x12:"ldc",0x13:"ldc_w",0xb4:"getfield",0xb5:"putfield",0x10:"bipush",0x11:"sipush",
            0xb6:"invokevirtual",0xb7:"invokespecial",0xb8:"invokestatic"}.get(op,hex(op))
for (mn,md,code) in methods:
    if not code: continue
    ins=instrs(code)
    for k,(pc,op,opd) in enumerate(ins):
        if op in (0x12,0x13) and opd in hstr:
            print("\n>>> 方法 %s%s  在第 %d 条指令引用 'HurtTime':" % (mn,md,k))
            for j in range(k, min(k+8, len(ins))):
                p2,o2,d2=ins[j]
                extra=""
                if o2 in (0xb4,0xb5): extra=" "+str(fref(d2))
                elif o2 in (0x10,0x11): extra=" val=%d"%d2
                print("     %-14s %s%s"%(opn(o2),"" if d2 is None else "idx/arg=%s"%d2,extra))
# 哪个方法把字段设为 10 / 20
print("\n=== 赋常量 10 / 20 的字段 & 所在方法 ===")
for (mn,md,code) in methods:
    if not code: continue
    ins=instrs(code)
    for k in range(len(ins)-1):
        o=ins[k][1]
        if o in (0x10,0x11) or 0x02<=o<=0x08:
            v=ins[k][2]
            if ins[k+1][1]==0xb5 and v in (10,20):
                print("  方法 %s%s  -> 字段 %s = %d" % (mn,md,fref(ins[k+1][2]),v))
