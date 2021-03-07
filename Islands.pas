unit Islands;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, Math, DateUtils;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Button3: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Memo1: TMemo;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

cart=record x,y,z: double end;
intcart=record x,y,z: integer end;
sph=record lo,la: double end;
plistelement=record n:integer; d:double; ei,ee:cart end;
pachelement=record p,c1,c2,s,i:integer; d,a:double; mi,ma,ei,ee:sph end;

var
  Form1: TForm1;
  f,f0,f1: file of char;
  f2,f3,f4: file of integer;
  f5: file of double;
  f6: file of pachelement;
  f7: textfile;
  fn,st,st1:string;
  ac:array[0..10000] of char;
  it:array[1..1] of integer;          // [1..5000000]
  sx:array[0..1] of integer;          // [0..10695479]
  //bn:array[1..188290] of integer;
  //ip,s,pai:array[1..188290] of integer;
  //na,pa:array[1..188290] of string;
  //level:array[1..188290] of byte;
  //ip,s,pai:array[1..188620] of integer;
  na,pa:array[1..188620] of string;
  level:array[1..188620] of byte;
  //b:array[0..10695479] of byte;
  //area:array[1..188290] of double;
  //ic:array[1..188290] of sph;
  area:array[1..188620] of double;
  //ic:array[1..188620] of sph;
  h:array[1..24] of array of double;
  ah:array[1..24] of double;
  r,npoints,pachsize,ipachsize,sib,san,root:integer;
  pt:array[0..50] of int64;
  ci,ni:array[0..5,1..1] of integer;    // [0..5,1..188290]
  nd:array[0..5,1..1] of double;        // [0..5,1..188290]
  cu:array[0..7] of intcart;
  eighttwo:array[0..131071] of int64;
  cubes:array[1..14] of array of intcart;
  cubesl:array[1..14] of array of int64;
  cubesb:array of array[0..7] of boolean;
  cubeslist:array[1..14] of array of array of integer;
  cubeslistsize,cubeoffset:array[1..14] of array of integer;
  cubelen:array[1..14] of array of byte;
  cubeslisttotalsize:array[1..14] of integer;
  sar:array[1..100] of integer;
  //pach:array[1..363225] of pachelement;
  pach{,pach1}:array[1..365000] of pachelement;
  ipach:array[1..190000] of integer;
  cubeslastlist:array of array of record c:{array[0..1] of sph}integer; n:integer end;
  cubeslastlistsize:array of integer;
  //plist:array[1..363225] of array of plistelement;
  //plistsize:array[1..363225] of integer;
  plist:array[1..365000] of array of plistelement;
  plistsize,part:array[1..365000] of integer;
  pm:array[1..365000] of double;
  //plistcomplete:array[1..365000] of boolean;
  //n:array[0..10695479] of integer;
  //c,c1:array[0..10695479] of sph;
  //n:array[0..10938830] of integer;
  //c,c1:array[0..10938830] of sph;
  n:array[0..10741400] of integer;
  c,c1:array[0..10741400] of sph;
  ei,ee:cart;
  pe:pachelement;
  sas,sac:array[0..100] of integer;
  
implementation

{$R *.dfm}





function d(lo1,la1,lo2,la2:double):double;
begin
lo1:=lo1/180*pi;
la1:=la1/180*pi;
lo2:=lo2/180*pi;
la2:=la2/180*pi;
result:=r*sqrt(2*(1-cos(la1-la2)+cos(la1)*cos(la2)*(1-cos(lo1-lo2))));
end;





function dsph(a,z:sph):double;
begin
a.lo:=a.lo/180*pi;
a.la:=a.la/180*pi;
z.lo:=z.lo/180*pi;
z.la:=z.la/180*pi;
result:=r*sqrt(2*(1-cos(a.la-z.la)+cos(a.la)*cos(z.la)*(1-cos(a.lo-z.lo))));
end;





// spherical coordinates to cartesian coordinates
function stc(s:sph):cart;
begin
s.lo:=s.lo/180*pi;
s.la:=s.la/180*pi;
result.x:=r*cos(s.lo)*cos(s.la);
result.y:=r*sin(s.lo)*cos(s.la);
result.z:=r*sin(s.la);
end;





// cartesian coordinates to spherical coordinates
function cts(c:cart):sph;
begin
result.la:=180/pi*arcsin(c.z/(sqrt(c.x*c.x+c.y*c.y+c.z*c.z)));
result.lo:=180/pi*(arccos(c.x/sqrt(c.x*c.x+c.y*c.y)))*ifthen(c.y<0,-1,1);
end;





procedure QuickSort(var A: array of Integer; b:boolean=true; iLo: Integer=0; iHi: Integer=0);
 var
   Lo, Hi, Pivot, T: Integer;
 begin
   if b then
      begin
      iLo:=Low(a);
      iHi:=High(a);
      end;
   Lo := iLo;
   Hi := iHi;
   Pivot := A[(Lo + Hi) div 2];
   repeat
     while A[Lo] < Pivot do Inc(Lo) ;
     while A[Hi] > Pivot do Dec(Hi) ;
     if Lo <= Hi then
     begin
       T := A[Lo];
       A[Lo] := A[Hi];
       A[Hi] := T;
       Inc(Lo) ;
       Dec(Hi) ;
     end;
   until Lo > Hi;
   if Hi > iLo then QuickSort(A, false, iLo, Hi) ;
   if Lo < iHi then QuickSort(A, false, Lo, iHi) ;
 end;





function anc(q:integer):integer;
begin
result:=q;
while pach[result].p>0 do
   result:=pach[result].p;
end;





procedure quicksortlist(y,i:integer;b:boolean=true;ilo:integer=0;ihi:integer=0);
var
lo,hi,pivot,t,e,u:integer;
begin
if b then
   begin
   ilo:=0;
   ihi:=cubeslistsize[y,i]-1;
   for e:=0 to ihi do
   //if pach[cubeslist[y,i,e]].p>0 then
   //   cubeslist[y,i,e]:=pach[cubeslist[y,i,e]].p;
   cubeslist[y,i,e]:=anc(cubeslist[y,i,e]);
   end;

lo:=ilo;
hi:=ihi;
pivot:=cubeslist[y,i,(lo+hi) div 2];
repeat
   while cubeslist[y,i,lo]<pivot do inc(lo);
   while cubeslist[y,i,hi]>pivot do dec(hi);
   if lo<=hi then
      begin
      t:=cubeslist[y,i,lo];
      cubeslist[y,i,lo]:=cubeslist[y,i,hi];
      cubeslist[y,i,hi]:=t;
      inc(lo);
      dec(hi);
      end;
   until lo>hi;
if hi>ilo then quicksortlist(y,i,false,ilo,hi);
if lo<ihi then quicksortlist(y,i,false,lo,ihi);

if b then
   begin
   e:=0;
   u:=0;
   t:=0;
   repeat
      if cubeslist[y,i,e]>t then
         begin
         t:=cubeslist[y,i,e];
         cubeslist[y,i,u]:=t;
         inc(u);
         end;
      inc(e);
      until e=cubeslistsize[y,i];
   cubeslistsize[y,i]:=u;
   end;
end;





procedure quicksortp(i:integer;b:boolean=true;ilo:integer=0;ihi:integer=0);
var
lo,hi,pivot:integer;
t:plistelement;
begin
if b then
   begin
   ilo:=0;
   ihi:=plistsize[i]-1;
   end;

lo:=ilo;
hi:=ihi;
pivot:=plist[i,(lo+hi) div 2].n;
repeat
   while plist[i,lo].n<pivot do inc(lo);
   while plist[i,hi].n>pivot do dec(hi);
   if lo<=hi then
      begin
      t:=plist[i,lo];
      plist[i,lo]:=plist[i,hi];
      plist[i,hi]:=t;
      inc(lo);
      dec(hi);
      end;
   until lo>hi;
if hi>ilo then quicksortp(i,false,ilo,hi);
if lo<ihi then quicksortp(i,false,lo,ihi);
end;





procedure quicksortptrue(i:integer;b:boolean=true;ilo:integer=0;ihi:integer=0);
var
lo,hi:integer;
pivot:double;
t:plistelement;
begin
if b then
   begin
   ilo:=0;
   ihi:=plistsize[i]-1;
   end;

lo:=ilo;
hi:=ihi;
pivot:=plist[i,(lo+hi) div 2].d;
repeat
   while plist[i,lo].d<pivot do inc(lo);
   while plist[i,hi].d>pivot do dec(hi);
   if lo<=hi then
      begin
      t:=plist[i,lo];
      plist[i,lo]:=plist[i,hi];
      plist[i,hi]:=t;
      inc(lo);
      dec(hi);
      end;
   until lo>hi;
if hi>ilo then quicksortptrue(i,false,ilo,hi);
if lo<ihi then quicksortptrue(i,false,lo,ihi);
end;





procedure quicksortipach(b:boolean=true;ilo:integer=0;ihi:integer=0);
var
lo,hi,pivot,t:integer;
begin
if b then
   begin
   ilo:=1;
   ihi:=ipachsize;
   end;

lo:=ilo;
hi:=ihi;
pivot:=plistsize[ipach[(lo+hi) div 2]];
repeat
   while plistsize[ipach[lo]]<pivot do inc(lo);
   while plistsize[ipach[hi]]>pivot do dec(hi);
   if lo<=hi then
      begin
      t:=ipach[lo];
      ipach[lo]:=ipach[hi];
      ipach[hi]:=t;
      inc(lo);
      dec(hi);
      end;
   until lo>hi;
if hi>ilo then quicksortipach(false,ilo,hi);
if lo<ihi then quicksortipach(false,lo,ihi);
end;





// 2^n is 4 times less than cube size
function compareintcart(a,z:intcart;n:integer):integer;
begin
if (a.x=z.x) and (a.y=z.y) and (a.z=z.z) then
   result:=0
else if (a.x<0) and (z.x>=0) then
   result:=-1
else if (a.x>=0) and (z.x<0) then
   result:=1
else if (a.y<0) and (z.y>=0) then
   result:=-1
else if (a.y>=0) and (z.y<0) then
   result:=1
else if (a.z<0) and (z.z>=0) then
   result:=-1
else if (a.z>=0) and (z.z<0) then
   result:=1
else
   begin
   if a.x<0 then
      begin
      a.x:=a.x+pt[n];
      z.x:=z.x+pt[n];
      end
   else
      begin
      a.x:=a.x-pt[n];
      z.x:=z.x-pt[n];
      end;

   if a.y<0 then
      begin
      a.y:=a.y+pt[n];
      z.y:=z.y+pt[n];
      end
   else
      begin
      a.y:=a.y-pt[n];
      z.y:=z.y-pt[n];
      end;

   if a.z<0 then
      begin
      a.z:=a.z+pt[n];
      z.z:=z.z+pt[n];
      end
   else
      begin
      a.z:=a.z-pt[n];
      z.z:=z.z-pt[n];
      end;
   result:=compareintcart(a,z,n-1);
   end;
end;





// 2^n is 4 times less than cube size
function searchincube(cube:array of intcart;a:intcart;n:integer;lo:integer=0;hi:integer=0;b:boolean=true):integer;
var
mid,rc:integer;
begin
result:=-1;
if b then
   begin
   lo:=0;
   hi:=length(cube)-1;
   if compareintcart(cube[lo],a,n)=0 then
      result:=lo
   else if compareintcart(cube[hi],a,n)=0 then
      result:=hi;
   end;
if result=-1 then
   begin
   mid:=(lo+hi) div 2;
   {if (mid=hi) or (mid=lo) then
      begin
      inc(mid);
      dec(mid);
      end;}
   rc:=compareintcart(cube[mid],a,n);
   if rc=0 then
      result:=mid
   else
      begin
      if rc=1 then
         hi:=mid
      else
         lo:=mid;
      result:=searchincube(cube,a,n,lo,hi,false);
      end;
   end;
end;





function searchincubel(y:integer;a:int64;lo:integer=0;hi:integer=0;b:boolean=true):integer;
var
mid:integer;
begin
result:=-1;
if b then
   begin
   lo:=0;
   hi:=length(cubesl[y])-1;
   if cubesl[y,lo]=a then
      result:=lo
   else if cubesl[y,hi]=a then
      result:=hi;
   end;
//if lo=hi then
//   result:=hi;
if result=-1 then
   begin
   mid:=(lo+hi) div 2;
   {if (mid=hi) or (mid=lo) then
      begin
      inc(mid);
      dec(mid);
      end;}
   if cubesl[y,mid]=a then
      result:=mid
   else
      begin
      if cubesl[y,mid]>a then
         hi:=mid
      else
         lo:=mid;
      result:=searchincubel(y,a,lo,hi,false);
      end;
   end;
end;





function noincubeslist(y,i,u:integer;lo:integer=0;hi:integer=0;b:boolean=true):boolean;
var
mid:integer;
begin
//if hi<lo then
//   inc(lo);
result:=true;
//if cubeslistsize[y,i]>0 then
//   begin
   if b then
      begin
      lo:=0;
      hi:=cubeslistsize[y,i]-1;
      if (cubeslist[y,i,lo]=u) or (cubeslist[y,i,hi]=u) then
         result:=false;
   //   end
   //else if (result=true) and (lo<>hi) then
      end;
   //if result and (lo<>hi) then
   while result and (hi>lo+1) do
      begin
      mid:=(lo+hi) div 2;
      {if (mid=hi) or (mid=lo) then
         begin
         inc(mid);
         dec(mid);
         end;}
      if cubeslist[y,i,mid]=u then
         result:=false
      else
         begin
         if cubeslist[y,i,mid]>u then
            hi:=mid
         else
            lo:=mid;
         //result:=noincubeslist(y,i,u,lo,hi,false);
         end;
      end;
//   end;
end;





function noothersincubeslist(y,i,u:integer):boolean;
begin
result:=(cubeslistsize[y,i]=1) and (cubeslist[y,i,0]=u);
end;





function setcube(cc:cart;y,u:integer;{icc,icc1:sph;}ec:integer;inin:integer):intcart;
var
a:intcart;
e,i:integer;
b:boolean;
begin
cc.x:=cc.x/r*pt[y];
cc.y:=cc.y/r*pt[y];
cc.z:=cc.z/r*pt[y];

a.x:=floor(cc.x/2);
a.y:=floor(cc.y/2);
a.z:=floor(cc.z/2);

result.x:=floor(cc.x);
result.y:=floor(cc.y);
result.z:=floor(cc.z);

i:=searchincubel(y,eighttwo[a.x+pt[y-1]]*4+eighttwo[a.y+pt[y-1]]*2+eighttwo[a.z+pt[y-1]]);
cubesb[i,(result.x-2*a.x)*4+(result.y-2*a.y)*2+result.z-2*a.z]:=true;

if (cubeslistsize[y,i]=0) or (cubeslist[y,i,cubeslistsize[y,i]-1]<>u) then
   begin
   inc(cubeslistsize[y,i]);
   if cubeslistsize[y,i]>length(cubeslist[y,i]) then
      setlength(cubeslist[y,i],length(cubeslist[y,i])*2);
   cubeslist[y,i,cubeslistsize[y,i]-1]:=u;
   end;

if y=length(cubes) then
//if y>length(cubes) then
   begin
   b:=true;
   if (cubeslastlistsize[i]>0) then
      begin
      e:=0;
      repeat
         if (cubeslastlist[i,e].n=inin) and

            {(cubeslastlist[i,e].c[0].lo=icc.lo) and
            (cubeslastlist[i,e].c[0].la=icc.la) and
            //(cubeslastlist[i,e].c[0].z=icc.z) and
            (cubeslastlist[i,e].c[1].lo=icc1.lo) and
            (cubeslastlist[i,e].c[1].la=icc1.la) then
            //(cubeslastlist[i,e].c[1].z=icc1.z) then}

            (cubeslastlist[i,e].c=ec) then
            b:=false;
         inc(e);
         until not b or (e=cubeslastlistsize[i]);
      end;
   if b then
      begin
      inc(cubeslastlistsize[i]);
      if cubeslastlistsize[i]>length(cubeslastlist[i]) then
         setlength(cubeslastlist[i],length(cubeslastlist[i])*2);
      cubeslastlist[i,cubeslastlistsize[i]-1].n:=inin;
      {cubeslastlist[i,cubeslastlistsize[i]-1].c[0]:=icc;
      cubeslastlist[i,cubeslastlistsize[i]-1].c[1]:=icc1;}
      cubeslastlist[i,cubeslastlistsize[i]-1].c:=ec;
      end;
   end;
end;





procedure settwopoints(cc,cc1:cart;z,z1:intcart;y,u:integer;{icc,icc1:sph;}ec:integer;inin:integer);
var
ccs:cart;
zs:intcart;
begin
if abs(z.x-z1.x)+abs(z.y-z1.y)+abs(z.z-z1.z)>1 then
   begin
   ccs.x:=(cc.x+cc1.x)/2;
   ccs.y:=(cc.y+cc1.y)/2;
   ccs.z:=(cc.z+cc1.z)/2;
   {zs:=setcube(ccs,y,u,icc,icc1,inin);
   settwopoints(cc,ccs,z,zs,y,u,icc,icc1,inin);
   settwopoints(ccs,cc1,zs,z1,y,u,icc,icc1,inin);}
   zs:=setcube(ccs,y,u,ec,inin);
   settwopoints(cc,ccs,z,zs,y,u,ec,inin);
   settwopoints(ccs,cc1,zs,z1,y,u,ec,inin);
   end;
end;





procedure generateipach(b:boolean=true);
var
e:integer;
begin
ipachsize:=0;
for e:=1 to pachsize do
   if pach[e].p<0 then
      begin
      inc(ipachsize);
      ipach[ipachsize]:=e;
      end
   else
      setlength(plist[e],0);
if b then
   quicksortipach;
end;





function am(q:cart):double;
begin
result:=sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
end;





function vm(a,b:cart):cart;
begin
result.x:=a.y*b.z-b.y*a.z;
result.y:=a.z*b.x-b.z*a.x;
result.z:=a.x*b.y-b.x*a.y;
end;





function getmindcube(y,a,z:integer):double;
var
q:intcart;
begin
q.x:=abs(cubes[y,a].x-cubes[y,z].x)-1;
q.y:=abs(cubes[y,a].y-cubes[y,z].y)-1;
q.z:=abs(cubes[y,a].z-cubes[y,z].z)-1;
if q.x<0 then q.x:=0;
if q.y<0 then q.y:=0;
if q.z<0 then q.z:=0;
result:=r/pt[y-1]*sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
end;





{function getmindcubel(y,a,z:integer):double;
var
e1,e2,e3,i1,i2,i3:integer;
q:intcart;
m:double;
begin
result:=1000000000;
for e1:=0 to 1 do
for e2:=0 to 1 do
for e3:=0 to 1 do
for i1:=0 to 1 do
for i2:=0 to 1 do
for i3:=0 to 1 do
   begin
   q.x:=cubes[y,a].x+e1-cubes[y,z].x-i1;
   q.y:=cubes[y,a].y+e2-cubes[y,z].y-i2;
   q.z:=cubes[y,a].z+e3-cubes[y,z].z-i3;
   m:=r/pt[y-1]*sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
   if m<result then
      result:=m;
   end;
end;}





function getmaxdcube(y,a,z:integer):double;
var
q:intcart;
begin
q.x:=abs(cubes[y,a].x-cubes[y,z].x)+1;
q.y:=abs(cubes[y,a].y-cubes[y,z].y)+1;
q.z:=abs(cubes[y,a].z-cubes[y,z].z)+1;
result:=r/pt[y-1]*sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
end;





function det3(a,b,c:cart):double;
begin
result:=a.x*b.y*c.z+b.x*c.y*a.z+c.x*a.y*b.z-a.z*b.y*c.x-b.z*c.y*a.x-c.z*a.y*b.x;
end;





function getlinesegd(a0,a1,b0,b1:cart):double;
var
a,b,d,n:cart;
t,t1,de:double;
begin
a.x:=a1.x-a0.x;
a.y:=a1.y-a0.y;
a.z:=a1.z-a0.z;
b.x:=b1.x-b0.x;
b.y:=b1.y-b0.y;
b.z:=b1.z-b0.z;
d.x:=b0.x-a0.x;
d.y:=b0.y-a0.y;
d.z:=b0.z-a0.z;
n:=vm(a,b);
t:=0;
t1:=0;
if (n.x=0) and (n.y=0) and (n.z=0) then
if (b.x=0) and (b.y=0) and (b.z=0) then
if (a.x=0) and (a.y=0) and (a.z=0) then
   //result:=am(d)
else
   t:=(a.x*d.x+a.y*d.y+a.z*d.z)/(a.x*a.x+a.y*a.y+a.z*a.z)
   //result:=am(vm(d,a))/am(a)
else
   t1:=-(b.x*d.x+b.y*d.y+b.z*d.z)/(b.x*b.x+b.y*b.y+b.z*b.z)
   //result:=am(vm(d,b))/am(b)
else
   begin
   de:=-det3(a,b,n);
   t:=-det3(d,b,n)/de;
   t1:=det3(a,d,n)/de;
   end;
if (t=0) and (t1=0) then
   begin
   ei:=a0;
   ee:=b0;
   result:=am(d);
   end
else
   begin
   if t>1 then t:=1
   else if t<0 then t:=0;
   if t1>1 then t1:=1
   else if t1<0 then t1:=0;

   if t=0 then a:=a0
   else if t=1 then a:=a1
   else
   begin
   a.x:=a0.x+a.x*t;
   a.y:=a0.y+a.y*t;
   a.z:=a0.z+a.z*t;
   end;
   if t1=0 then b:=b0
   else if t1=1 then b:=b1
   else
   begin
   b.x:=b0.x+b.x*t1;
   b.y:=b0.y+b.y*t1;
   b.z:=b0.z+b.z*t1;
   end;
   d.x:=b.x-a.x;
   d.y:=b.y-a.y;
   d.z:=b.z-a.z;
   ei:=a;
   ee:=b;
   result:=am(d);
   end;
end;





function getd(q:integer):double;
var
e,i,y,u,j:integer;
a:array[1..14] of array of array[0..1] of integer;
ab:array[1..14] of array of boolean;
m:double;
begin
sib:=0;
result:=1000000000;
y:=1;
setlength(a[y],sar[y]*sar[y]);
setlength(ab[y],sar[y]*sar[y]);
u:=0;
for e:=0 to sar[y]-1 do
for i:=0 to sar[y]-1 do
   begin
   a[y,u,0]:=e;
   a[y,u,1]:=i;
   ab[y,u]:=true;
   inc(u);
   end;

for y:=1 to length(cubes) do
   begin
   for e:=0 to length(a[y])-1 do
   if noincubeslist(y,a[y,e,0],q) or noothersincubeslist(y,a[y,e,1],q) then
      ab[y,e]:=false;

   for e:=0 to length(a[y])-1 do
   if ab[y,e] then
      begin
      m:=getmaxdcube(y,a[y,e,0],a[y,e,1]);
      if m<result then
         result:=m;
      end;

   for e:=0 to length(a[y])-1 do
   if ab[y,e] and (getmindcube(y,a[y,e,0],a[y,e,1])>result) then
      ab[y,e]:=false;

   if y<length(cubes) then
      begin
      u:=0;
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
         u:=u+cubelen[y,a[y,e,0]]*cubelen[y,a[y,e,1]];
      setlength(a[y+1],u);
      setlength(ab[y+1],u);
      u:=0;
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
      for i:=0 to cubelen[y,a[y,e,0]]-1 do
      for j:=0 to cubelen[y,a[y,e,1]]-1 do
         begin
         a[y+1,u,0]:=cubeoffset[y,a[y,e,0]]+i;
         a[y+1,u,1]:=cubeoffset[y,a[y,e,1]]+j;
         ab[y+1,u]:=true;
         inc(u);
         end;
      end
   else
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
      for i:=0 to cubeslastlistsize[a[y,e,0]]-1 do
      if cubeslastlist[a[y,e,0],i].n=q then
      for j:=0 to cubeslastlistsize[a[y,e,1]]-1 do
      if cubeslastlist[a[y,e,1],j].n<>q then
         begin
         //m:=getlinesegd(stc(cubeslastlist[a[y,e,0],i].c[0]),stc(cubeslastlist[a[y,e,0],i].c[1]),stc(cubeslastlist[a[y,e,1],j].c[0]),stc(cubeslastlist[a[y,e,1],j].c[1]));
         m:=getlinesegd(stc(c[cubeslastlist[a[y,e,0],i].c]),stc(c1[cubeslastlist[a[y,e,0],i].c]),stc(c[cubeslastlist[a[y,e,1],j].c]),stc(c1[cubeslastlist[a[y,e,1],j].c]));
         if m<result then
            begin
            sib:=cubeslastlist[a[y,e,1],j].n;
            result:=m;
            end;
         end;
   end;
end;





function searchinp(q,n:integer;lo:integer=0;hi:integer=0;b:boolean=true):integer;
var
mid:integer;
begin
result:=-1;
if b then
   begin
   lo:=0;
   hi:=plistsize[q]-1;
   if plist[q,lo].n=n then
      result:=lo
   else if plist[q,hi].n=n then
      result:=hi;
   end;
if result=-1 then
   begin
   mid:=(lo+hi) div 2;
   if plist[q,mid].n=n then
      result:=mid
   else
      begin
      if plist[q,mid].n>n then
         hi:=mid
      else
         lo:=mid;
      result:=searchinp(q,n,lo,hi,false);
      end;
   end;
end;





procedure setp(q:integer);
var
e,i,y,u,j,k,l{,cl}:integer;
//ts,ti:TDateTime;
a:array[1..14] of array of array[0..1] of integer;
ab:array[1..14] of array of boolean;
m,result:double;
bst:array of array[-1..1] of integer;
begin
//cl:=length(cubes)+1;
//ti:=0;
//while (ti<1) and (cl>=0) do
//begin
//ts:=now;
plistsize[q]:=0;
result:=1000000000;
y:=1;
setlength(a[y],sar[y]*sar[y]);
setlength(ab[y],sar[y]*sar[y]);
u:=0;
for e:=0 to sar[y]-1 do
for i:=0 to sar[y]-1 do
   begin
   a[y,u,0]:=e;
   a[y,u,1]:=i;
   ab[y,u]:=true;
   inc(u);
   end;

for y:=1 to length(cubes) do
   begin
   for e:=0 to length(a[y])-1 do
   if noincubeslist(y,a[y,e,0],q) or noothersincubeslist(y,a[y,e,1],q) then
      ab[y,e]:=false;

   for e:=0 to length(a[y])-1 do
   if ab[y,e] then
      begin
      m:=getmaxdcube(y,a[y,e,0],a[y,e,1]);
      if m<result then
         result:=m;
      end;

   //if y<cl then
   for e:=0 to length(a[y])-1 do
   if ab[y,e] and (getmindcube(y,a[y,e,0],a[y,e,1])>result+1000) then
      ab[y,e]:=false;

   if y<length(cubes) then
      begin
      u:=0;
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
         u:=u+cubelen[y,a[y,e,0]]*cubelen[y,a[y,e,1]];
      setlength(a[y+1],u);
      setlength(ab[y+1],u);
      u:=0;
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
      for i:=0 to cubelen[y,a[y,e,0]]-1 do
      for j:=0 to cubelen[y,a[y,e,1]]-1 do
         begin
         a[y+1,u,0]:=cubeoffset[y,a[y,e,0]]+i;
         a[y+1,u,1]:=cubeoffset[y,a[y,e,1]]+j;
         ab[y+1,u]:=true;
         inc(u);
         end;
      end
   else
      begin
      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
      for i:=0 to cubeslastlistsize[a[y,e,0]]-1 do
      if cubeslastlist[a[y,e,0],i].n=q then
      for j:=0 to cubeslastlistsize[a[y,e,1]]-1 do
      if cubeslastlist[a[y,e,1],j].n<>q then
      if plistsize[q]=0 then
         begin
         setlength(bst,1);
         inc(plistsize[q]);
         bst[0,-1]:=cubeslastlist[a[y,e,1],j].n;
         bst[0,0]:=-1;
         bst[0,1]:=-1;
         end
      else
         begin
         u:=0;
         k:=0;
         l:=0;
         while (u<>-1) and (bst[u,-1]<>cubeslastlist[a[y,e,1],j].n) do
            begin
            k:=u;
            l:=ifthen(cubeslastlist[a[y,e,1],j].n>bst[u,-1],1,0);
            u:=bst[u,l];
            end;
         if u=-1 then
            begin
            if plistsize[q]>=length(bst) then
               setlength(bst,length(bst)*2);
            bst[k,l]:=plistsize[q];
            bst[plistsize[q],-1]:=cubeslastlist[a[y,e,1],j].n;
            bst[plistsize[q],0]:=-1;
            bst[plistsize[q],1]:=-1;
            inc(plistsize[q]);
            end;
         end;
      setlength(plist[q],length(bst));
      for u:=0 to plistsize[q]-1 do
         begin
         plist[q,u].n:=bst[u,-1];
         plist[q,u].d:=1000000000;
         end;
      quicksortp(q);

      for e:=0 to length(a[y])-1 do
      if ab[y,e] then
      for i:=0 to cubeslastlistsize[a[y,e,0]]-1 do
      if cubeslastlist[a[y,e,0],i].n=q then
      for j:=0 to cubeslastlistsize[a[y,e,1]]-1 do
      if cubeslastlist[a[y,e,1],j].n<>q then
         begin
         //m:=getlinesegd(stc(cubeslastlist[a[y,e,0],i].c[0]),stc(cubeslastlist[a[y,e,0],i].c[1]),stc(cubeslastlist[a[y,e,1],j].c[0]),stc(cubeslastlist[a[y,e,1],j].c[1]));
         m:=getlinesegd(stc(c[cubeslastlist[a[y,e,0],i].c]),stc(c1[cubeslastlist[a[y,e,0],i].c]),stc(c[cubeslastlist[a[y,e,1],j].c]),stc(c1[cubeslastlist[a[y,e,1],j].c]));
         u:=searchinp(q,cubeslastlist[a[y,e,1],j].n);
         if m<plist[q,u].d then
            begin
            plist[q,u].d:=m;
            plist[q,u].ei:=ei;
            plist[q,u].ee:=ee;
            end;
         end;
      quicksortptrue(q);
      pm[q]:=plist[q,0].d+1000;
      e:=0;
      while (e<plistsize[q]) and (plist[q,e].d<=pm[q]) do
         inc(e);
      plistsize[q]:=e;
      setlength(plist[q],e);
      end;
   end;
//ti:=MilliSecondsBetween(ts,now);
//dec(cl);
//end;
//if cl<0 then
//   plistcomplete[q]:=true;
end;





procedure setpd(q:integer);
var
e,i:integer;
begin
for e:=0 to plistsize[q]-1 do
   plist[q,e].n:=anc(plist[q,e].n);
quicksortp(q);
e:=0;
i:=0;
while i<plistsize[q] do
   begin
   if plist[q,e].n=plist[q,i].n then
      if plist[q,i].d<plist[q,e].d then
         plist[q,e]:=plist[q,i]
      else
   else
      begin
      inc(e);
      plist[q,e]:=plist[q,i];
      end;
   inc(i);
   end;
plistsize[q]:=e+1;
setlength(plist[q],plistsize[q]);

{while e<plistsize[q] do
   begin
   while (i<plistsize[q]) and (plist[q,e].n=plist[q,i].n) do
      begin
      if plist[q,i].d<plist[q,e].d then
         plist[q,e]:=plist[q,i];
      inc(i);
      end;
   e:=i;
   end;}
   
quicksortptrue(q);
end;





{procedure setph(q:integer);
var
e,u,k,l,c1,c2:integer;
m:double;
bst:array of array[-1..1] of integer;
begin
c1:=pach[q].c1;
c2:=pach[q].c2;
plistsize[q]:=0;
plistcomplete[q]:=plistcomplete[c1] and plistcomplete[c2];

for e:=1 to plistsize[c1]-1 do
while pach[plist[c1,e].n].p>0 do
   plist[c1,e].n:=pach[plist[c1,e].n].p;
for e:=1 to plistsize[c2]-1 do
while pach[plist[c2,e].n].p>0 do
   plist[c2,e].n:=pach[plist[c2,e].n].p;

while (plistsize[c1]>1) and (plist[c1,plistsize[c1]-1].n=q) do
   dec(plistsize[c1]);
while (plistsize[c2]>1) and (plist[c2,plistsize[c2]-1].n=q) do
   dec(plistsize[c2]);

if (plistsize[c1]>1) and (plistsize[c2]>1) then
if not plistcomplete[q] then
   begin
   m:=plist[c1,plistsize[c1]-1].d;
   m:=min(m,plist[c2,plistsize[c2]-1].d);
   if not plistcomplete[c1] then
   while (plistsize[c1]>1) and (plist[c1,plistsize[c1]-1].d>m) do
      dec(plistsize[c1]);
   if not plistcomplete[c2] then
   while (plistsize[c2]>1) and (plist[c2,plistsize[c2]-1].d>m) do
      dec(plistsize[c2]);
   end;

while (plistsize[c1]>1) and (plist[c1,plistsize[c1]-1].n=q) do
   dec(plistsize[c1]);
while (plistsize[c2]>1) and (plist[c2,plistsize[c2]-1].n=q) do
   dec(plistsize[c2]);

if (plistsize[c1]>1) and (plistsize[c2]>1) then
begin
for e:=1 to plistsize[c1]-1 do
if plist[c1,e].n<>q then
if plistsize[q]=0 then
   begin
   setlength(bst,1);
   inc(plistsize[q]);
   bst[0,-1]:=plist[c1,e].n;
   bst[0,0]:=-1;
   bst[0,1]:=-1;
   end
else
   begin
   u:=0;
   k:=0;
   l:=0;
   while (u<>-1) and (bst[u,-1]<>plist[c1,e].n) do
      begin
      k:=u;
      l:=ifthen(plist[c1,e].n>bst[u,-1],1,0);
      u:=bst[u,l];
      end;
   if u=-1 then
      begin
      if plistsize[q]>=length(bst) then
         setlength(bst,length(bst)*2);
      bst[k,l]:=plistsize[q];
      bst[plistsize[q],-1]:=plist[c1,e].n;
      bst[plistsize[q],0]:=-1;
      bst[plistsize[q],1]:=-1;
      inc(plistsize[q]);
      end;
   end;

for e:=1 to plistsize[c2]-1 do
if plist[c2,e].n<>q then
if plistsize[q]=0 then
   begin
   setlength(bst,1);
   inc(plistsize[q]);
   bst[0,-1]:=plist[c2,e].n;
   bst[0,0]:=-1;
   bst[0,1]:=-1;
   end
else
   begin
   u:=0;
   k:=0;
   l:=0;
   while (u<>-1) and (bst[u,-1]<>plist[c2,e].n) do
      begin
      k:=u;
      l:=ifthen(plist[c2,e].n>bst[u,-1],1,0);
      u:=bst[u,l];
      end;
   if u=-1 then
      begin
      if plistsize[q]>=length(bst) then
         setlength(bst,length(bst)*2);
      bst[k,l]:=plistsize[q];
      bst[plistsize[q],-1]:=plist[c2,e].n;
      bst[plistsize[q],0]:=-1;
      bst[plistsize[q],1]:=-1;
      inc(plistsize[q]);
      end;
   end;

setlength(plist[q],length(bst));
for u:=0 to plistsize[q]-1 do
   begin
   plist[q,u].n:=bst[u,-1];
   plist[q,u].d:=1000000000;
   end;

if plistsize[q]>0 then
   begin
   quicksortp(q);

   for e:=1 to plistsize[c1]-1 do
   if plist[c1,e].n<>q then
      begin
      m:=plist[c1,e].d;
      u:=searchinp(q,plist[c1,e].n);
      if m<plist[q,u].d then
         plist[q,u].d:=m;
      end;

   for e:=1 to plistsize[c2]-1 do
   if plist[c2,e].n<>q then
      begin
      m:=plist[c2,e].d;
      u:=searchinp(q,plist[c2,e].n);
      if m<plist[q,u].d then
         plist[q,u].d:=m;
      end;

   quicksortptrue(q);
   end;
end;

setlength(plist[c1],0);
setlength(plist[c2],0);
end;}





function mp(e:integer):integer;
var
i:integer;
begin
if e=0 then
   result:=24
else
   begin
   result:=0;
   i:=2;
   while e mod i=0 do
      begin
      inc(result);
      i:=i*2;
      end;
   end;
end;





function o(lo1,la1,lo2,la2:double;loq:double=180;laq:double=90):boolean;
begin
if (lo1=lo2) and (la1=la2) then result:=false else
begin
{if lo1=360 then lo1:=259.9999999999;
if la1=180 then la1:=179.9999999999;
if lo2=360 then lo2:=259.9999999999;
if la2=180 then la2:=179.9999999999;}
result:=true;
if (lo1<loq) and (lo2>=loq) then else
if (lo2<loq) and (lo1>=loq) then
   result:=false
else
if (la1<laq) and (la2>=laq) then else
if (la2<laq) and (la1>=laq) then
   result:=false
else
   begin
   if lo1>=loq then lo1:=lo1-loq;
   if lo2>=loq then lo2:=lo2-loq;
   if la1>=laq then la1:=la1-laq;
   if la2>=laq then la2:=la2-laq;
   result:=o(lo1,la1,lo2,la2,loq/2,laq/2);
   end;
end;   
end;





{procedure qs(lo,hi:integer);
var
l,h,q:integer;
loc,lac:double;
begin
if lo<hi then
begin
l:=lo;
h:=hi;
loc:=ic[s[lo]].lo;
lac:=ic[s[lo]].la;
if o(loc,lac,ic[s[hi]].lo,ic[s[hi]].la) then
   begin
   loc:=ic[s[hi]].lo;
   lac:=ic[s[hi]].la;
   end;
while l<=h do
   begin
   if not o(ic[s[l]].lo,ic[s[l]].la,loc,lac) and not o(loc,lac,ic[s[h]].lo,ic[s[h]].la) then
      begin
      q:=s[l];
      s[l]:=s[h];
      s[h]:=q;
      end;
   if o(ic[s[l]].lo,ic[s[l]].la,loc,lac) then inc(l);
   if not o(ic[s[h]].lo,ic[s[h]].la,loc,lac) then dec(h);
   end;
inc(h);
l:=h-1;}

{q:=lo;
while q<h do
   begin
   if not o(ic[s[q]].lo,ic[s[q]].la,loc,lac) then
      inc(l);
   inc(q);
   end;

q:=h;
while q<hi do
   begin
   if o(ic[s[q]].lo,ic[s[q]].la,loc,lac) then
      inc(l);
   inc(q);
   end;}

{qs(lo,l);
qs(h,hi);
end;
end;}





{procedure qsx(lo,hi:integer);
var
l,h,q:integer;
loc,lac:double;
begin
if lo<hi then
begin
l:=lo;
h:=hi;
loc:=c[sx[lo]].lo;
lac:=c[sx[lo]].la;
{if o(loc+180,lac+90,c[sx[hi]].lo+180,c[sx[hi]].la+90) then
   begin
   loc:=c[sx[hi]].lo;
   lac:=c[sx[hi]].la;
   end;}
{while l<=h do
   begin
   if not o(c[sx[l]].lo+180,c[sx[l]].la+90,loc+180,lac+90) and not o(loc+180,lac+90,c[sx[h]].lo+180,c[sx[h]].la+90) then
      begin
      q:=sx[l];
      sx[l]:=sx[h];
      sx[h]:=q;
      end;
   if o(c[sx[l]].lo+180,c[sx[l]].la+90,loc+180,lac+90) then inc(l);
   if not o(c[sx[h]].lo+180,c[sx[h]].la+90,loc+180,lac+90) then dec(h);
   end;
inc(h);
l:=h-1;

{q:=lo;
while q<h do
   begin
   if not o(c[sx[q]].lo+180,c[sx[q]].la+90,loc+180,lac+90) then
      inc(l);
   inc(q);
   end;

q:=h;
while q<hi do
   begin
   if o(c[sx[q]].lo+180,c[sx[q]].la+90,loc+180,lac+90) then
      inc(l);
   inc(q);
   end;}

{qsx(lo,l);
if h=lo then inc(h);
qsx(h,hi);
end;
end;}





procedure quicksortc(b:boolean=true;ilo:integer=0;ihi:integer=0);
var
lo,hi,pivot,t:integer;
t1:sph;
begin
if b then
   begin
   ilo:=low(n);
   //ihi:=high(n);
   ihi:=npoints-1;
   end;
lo:=ilo;
hi:=ihi;
pivot:=n[(lo+hi) div 2];
repeat
   while n[lo]<pivot do inc(lo);
   while n[hi]>pivot do dec(hi);
   if lo<=hi then
      begin
      t:=n[lo];
      n[lo]:=n[hi];
      n[hi]:=t;
      t1:=c[lo];
      c[lo]:=c[hi];
      c[hi]:=t1;
      t1:=c1[lo];
      c1[lo]:=c1[hi];
      c1[hi]:=t1;
      inc(lo);
      dec(hi);
      end;
   until lo>hi;
if hi>ilo then quicksortc(false,ilo,hi);
if lo<ihi then quicksortc(false,lo,ihi);
end;





{function getdl(q:integer):double;
var
e,i:integer;
m,m1:double;
q0,q1,w0,w1:cart;
begin
sib:=0;
result:=1000000000;
for e:=0 to npoints-1 do
if n[e]=q then
for i:=0 to npoints-1 do
if n[i]<>q then
   begin
   q0:=stc(c[e]);
   q1:=stc(c1[e]);
   w0:=stc(c[i]);
   w1:=stc(c1[i]);
   m:=getlinesegd(q0,q1,w0,w1);
   m1:=getlinesegd(w0,w1,q0,q1);
   //m1:=getlinesegd(q1,q0,w0,w1);
   //m1:=getlinesegd(q0,q1,w1,w0);
   //if (m<>m1) and (sign(m)<>sign(m1)) then
   if m<>m1 then
   //if abs(m-m1)>0.000001 then
      result:=getlinesegd(q0,q1,w0,w1);
   if m<result then
      begin
      sib:=n[i];
      result:=m;
      end;
   end;

   {begin
   q0:=stc(c[e]);
   q1:=stc(c1[e]);
   w0:=stc(c[i]);
   w1:=stc(c1[i]);
   //m:=dsph(c[e],c[i]);
   //m:=sqrt((q0.x-w0.x)*(q0.x-w0.x)+(q0.y-w0.y)*(q0.y-w0.y)+(q0.z-w0.z)*(q0.z-w0.z));
   m:=getlinesegd(q0,q1,w0,w1);
   if m<result then
      begin
      sib:=n[i];
      //result:=m;
      result:=getlinesegd(q0,q1,w0,w1);
      end;
   //m:=dsph(c1[e],c1[i]);
   {m:=sqrt((q1.x-w1.x)*(q1.x-w1.x)+(q1.y-w1.y)*(q1.y-w1.y)+(q1.z-w1.z)*(q1.z-w1.z));
   if m<result then
      begin
      sib:=n[i];
      result:=m;
      end;
   //m:=dsph(c[e],c1[i]);
   m:=sqrt((q0.x-w1.x)*(q0.x-w1.x)+(q0.y-w1.y)*(q0.y-w1.y)+(q0.z-w1.z)*(q0.z-w1.z));
   if m<result then
      begin
      sib:=n[i];
      result:=m;
      end;
   //m:=dsph(c1[e],c[i]);
   m:=sqrt((q1.x-w0.x)*(q1.x-w0.x)+(q1.y-w0.y)*(q1.y-w0.y)+(q1.z-w0.z)*(q1.z-w0.z));
   if m<result then
      begin
      sib:=n[i];
      result:=m;
      end;
   end;}
{end;}





procedure readarrays;
var
e,i,u,y,j,k:integer;
cc,cc1:cart;
t:tbitmap;
begin
form1.Label1.Caption:='.dbf...                                               ';
form1.Label1.Refresh;
//st:=fn+'.txt';
st:=fn+'_with_ice.txt';
assignfile(f,st);
reset(f);
e:=0;
repeat
   inc(e);
   blockread(f,ac,80);
   st:=leftstr(ac,80);
   delete(st,pos(' ',st),80);

   // na - array of IDs (names with "E" or "W") of islands (parameter - island number)
   na[e]:=st;
   blockread(f,ac,9);
   st:=leftstr(ac,9);

   // level - array of level of islands
   // (1 - island, 2 - lake, 3 - lake island, 4 - lake island lake, 5 - ice (not used), 6 - iced ground; parameter - island number)
   level[e]:=strtoint(st);
   blockread(f,ac,9);
   st:=leftstr(ac,9);
   while pos(' ',st)<>0 do delete(st,1,1);

   // pa - array of PARENT_IDs (without "E" or "W"; if no parent, then -1; parameter - island number)
   pa[e]:=st;
   blockread(f,ac,24);
   st:=leftstr(ac,24);

   // area - array of areas, km^2 (parameter - island number)
   area[e]:=strtofloat(st);
   until eof(f);
closefile(f);

{form1.Label1.Caption:='shp_list...                                           ';
form1.Label1.Refresh;
//st:=fn+'_shp_list.txt';
st:=fn+'_shp_list_with_ice.txt';
assignfile(f4,st);
reset(f4);

// n - array of island numbers (parameter - point number)
blockread(f4,n,npoints);
closefile(f4);

form1.Label1.Caption:='shp...                                           ';
form1.Label1.Refresh;
//st:=fn+'_shp.txt';
st:=fn+'_shp_with_ice.txt';
assignfile(f5,st);
reset(f5);

// c - array of coordinates, degrees (parameter - point number)
blockread(f5,c,2*npoints);
closefile(f5);

form1.Label1.Caption:='initial...                                           ';
form1.Label1.Refresh;
i:=npoints;
e:=0;
repeat
   u:=e;

   // ic - array of initial coordinates, degrees (parameter - island number)
   ic[n[e]].la:=c[e].la+90;
   ic[n[e]].lo:=c[e].lo+180;
   if ic[n[e]].lo=360 then ic[n[e]].lo:=359.99999999;
   if ic[n[e]].la=180 then ic[n[e]].la:=179.99999999;

   // ip - array of initial point numbers (parameter - island number)
   ip[n[e]]:=e;
   repeat
      inc(u);
      until (u=i) or (n[u]<>n[e]);
   repeat
      //x[e]:=u;
      inc(e);
      until e=u;
   until u=i;

// pai - array of numbers of parent islands (parameter - island number)
//for e:=1 to 188290 do
for e:=1 to 188620 do
if (level[e]=2) or (level[e]=4) then
   begin
   i:=0;
   repeat
      inc(i);
      until pa[e]=leftstr(na[i],length(pa[e]));
   pai[e]:=i
   end
else if (level[e]=5) and (area[e]>5000000) then
   pai[e]:=1000000
else if (pos('W',na[e])>0) then
   pai[e]:=e-1
else
   pai[e]:=e;}

// pai - array of numbers of parent islands (parameter - island number)
{st:=fn+'NumbersOfParentIslands.txt';
assignfile(f4,st);
reset(f4);
blockread(f4,pai1,188290);
//blockread(f4,pai,188620);
closefile(f4);}

{for e:=1 to 188290 do
if pai[e]<>pai1[e] then
//if (level[e]<>2) and (level[e]<>4) then
   begin
   form1.Label1.Caption:=inttostr(e)+'                                  ';
   form1.Label1.Refresh;
   form1.Label2.Caption:=inttostr(pai[e])+'                                  ';
   form1.Label2.Refresh;
   form1.Label3.Caption:=inttostr(pai1[e])+'                                  ';
   form1.Label3.Refresh;
   end;}

// c1 - array of second points of segment lines (parameter - point number)
{for e:=0 to npoints-1 do
   begin
   i:=e+1;
   if (i=npoints) or (n[i]<>n[e]) then
      i:=ip[n[e]];
   c1[e]:=c[i];
   end;

// island numbers -> numbers of parent islands
for e:=0 to npoints-1 do
   n[e]:=pai[n[e]];

quicksortc;

while (n[npoints-1]=1000000) do
   dec(npoints);}

{st:=fn+'_n.txt';
assignfile(f4,st);
rewrite(f4);
blockwrite(f4,n,npoints);
closefile(f4);
st:=fn+'_c.txt';
assignfile(f5,st);
rewrite(f5);
blockwrite(f5,c,2*npoints);
closefile(f5);
st:=fn+'_c1.txt';
assignfile(f5,st);
rewrite(f5);
blockwrite(f5,c1,2*npoints);
closefile(f5);}

npoints:=10741401;

st:=fn+'_n.txt';
assignfile(f4,st);
reset(f4);
blockread(f4,n,npoints);
closefile(f4);
st:=fn+'_c.txt';
assignfile(f5,st);
reset(f5);
blockread(f5,c,2*npoints);
closefile(f5);
st:=fn+'_c1.txt';
assignfile(f5,st);
reset(f5);
blockread(f5,c1,2*npoints);
closefile(f5);

{t:=tbitmap.Create;
k:=16;
t.Width:=k*360;
t.Height:=k*180;
for e:=0 to npoints-1 do
if (area[n[e]]<5000000) or (level[n[e]]<>5) then
t.Canvas.Pixels[floor(k*(c[e].lo+180)),floor(k*(90-c[e].la))]:=clblack;
st:=fn+'_map_with_ice-ant.bmp';
t.SaveToFile(st);}

{npoints:=1550000;
for e:=0 to npoints-1 do
   begin
   n[e]:=n[8000000+e];
   c[e]:=c[8000000+e];
   c1[e]:=c1[8000000+e];
   end;}

{npoints:=npoints-8000000;
for e:=0 to npoints-1 do
   begin
   n[e]:=n[8000000+e];
   c[e]:=c[8000000+e];
   c1[e]:=c1[8000000+e];
   end;}

//pach - final array
pachsize:=0;
i:=0;
for e:=0 to npoints-1 do
   begin
   if n[e]<>i then
      begin
      i:=n[e];
      inc(pachsize);
      pach[pachsize].p:=-1;
      pach[pachsize].c1:=-1;
      pach[pachsize].c2:=-1;
      pach[pachsize].i:=1;
      pach[pachsize].d:=-1;
      pach[pachsize].a:=area[n[e]];
      pach[pachsize].mi.lo:=1000;
      pach[pachsize].mi.la:=1000;
      pach[pachsize].ma.lo:=-1000;
      pach[pachsize].ma.la:=-1000;
      //plistcomplete[pachsize]:=false;
      end;
   n[e]:=pachsize;
   if c[e].lo<pach[pachsize].mi.lo then pach[pachsize].mi.lo:=c[e].lo;
   if c[e].la<pach[pachsize].mi.la then pach[pachsize].mi.la:=c[e].la;
   if c[e].lo>pach[pachsize].ma.lo then pach[pachsize].ma.lo:=c[e].lo;
   if c[e].la>pach[pachsize].ma.la then pach[pachsize].ma.la:=c[e].la;
   end;

//pach[1]:=pach[46734];
{pach[1]:=pach[179835];
pach[2]:=pach[90034];
pach[3]:=pach[63109];
pach[4]:=pach[14393];
pach[5]:=pach[178919];
pach[6]:=pach[101528];
pach[7]:=pach[178373];
pach[8]:=pach[72718];
pach[9]:=pach[5745];
pach[10]:=pach[95969];
pach[11]:=pach[178158];
pach[12]:=pach[126940];
pach[13]:=pach[50318];
pach[14]:=pach[124190];
pach[15]:=pach[161576];}

generateipach(false);

sar[1]:=8;
setlength(cubes[1],sar[1]);
setlength(cubesl[1],sar[1]);
setlength(cubeslist[1],sar[1]);
setlength(cubeslistsize[1],sar[1]);
setlength(cubelen[1],sar[1]);
setlength(cubeoffset[1],sar[1]);
y:=0;
for e:=-1 to 0 do
for i:=-1 to 0 do
for u:=-1 to 0 do
   begin
   cubes[1,y].x:=e;
   cubes[1,y].y:=i;
   cubes[1,y].z:=u;
   inc(y);
   end;

for e:=0 to 7 do
   begin
   cubesl[1,e]:=e;
   setlength(cubeslist[1,e],1);
   cubeslistsize[1,e]:=0;
   end;

form1.Label1.Caption:='0                                                 ';
form1.Label1.Refresh;
form1.Label2.Caption:=inttostr(sar[1]);
form1.Label2.Refresh;

for y:=1 to length(cubes) do
   begin
   setlength(cubesb,sar[y]);
   for e:=0 to sar[y]-1 do
      begin
      for i:=0 to 7 do
         cubesb[e,i]:=false;
      cubelen[y,e]:=0;
      end;

   //k:=0;
   //j:=0;
   for e:=0 to npoints-1 do
   //if (j<1) or (n[e]<>k) then
      begin
      u:=n[e];
      {inc(j);
      if u<>k then
         j:=0;
      k:=u;}
      cc:=stc(c[e]);
      cc1:=stc(c1[e]);
      //settwopoints(cc,cc1,setcube(cc,y,u,c[e],c1[e],u),setcube(cc1,y,u,c[e],c1[e],u),y,u,c[e],c1[e],u);
      settwopoints(cc,cc1,setcube(cc,y,u,e,u),setcube(cc1,y,u,e,u),y,u,e,u);

      if e mod 1000=0 then
         begin
         form1.Label3.Caption:=inttostr(e)+'                              ';
         form1.Label3.Refresh;
         end;
      end;

   u:=0;
   for e:=0 to sar[y]-1 do
   for i:=0 to 7 do
      if cubesb[e,i] then inc(u);
   sar[y+1]:=u;

   if y<length(cubes) then
      begin
      setlength(cubes[y+1],u);
      setlength(cubesl[y+1],u);
      setlength(cubeslist[y+1],u);
      setlength(cubeslistsize[y+1],u);
      setlength(cubeoffset[y+1],u);
      setlength(cubelen[y+1],u);
      if y=length(cubes)-1 then
         begin
         setlength(cubeslastlist,u);
         setlength(cubeslastlistsize,u);
         end;
      u:=0;
      for e:=0 to sar[y]-1 do
      for i:=0 to 7 do
         if cubesb[e,i] then
            begin
            cubes[y+1,u].x:=2*cubes[y,e].x+cu[i].x;
            cubes[y+1,u].y:=2*cubes[y,e].y+cu[i].y;
            cubes[y+1,u].z:=2*cubes[y,e].z+cu[i].z;
            cubesl[y+1,u]:=8*cubesl[y,e]+i;
            setlength(cubeslist[y+1,u],1);
            cubeslistsize[y+1,u]:=0;
            if cubelen[y,e]=0 then
                cubeoffset[y,e]:=u;
            inc(cubelen[y,e]);
            if y=length(cubes)-1 then
               begin
               setlength(cubeslastlist[u],1);
               cubeslastlistsize[u]:=0;
               end;
            inc(u);
            end;
      end;

   cubeslisttotalsize[y]:=0;
   for e:=0 to sar[y]-1 do
      cubeslisttotalsize[y]:=cubeslisttotalsize[y]+cubeslistsize[y,e];

   for e:=0 to sar[y]-1 do
   for i:=1 to cubeslistsize[y,e]-1 do
   if cubeslist[y,e,i]<=cubeslist[y,e,i-1] then
      cubeslist[y,e,i]:=0;

   form1.Label1.Caption:=inttostr(y);
   form1.Label1.Refresh;
   form1.Label2.Caption:=inttostr(sar[y+1]);
   form1.Label2.Refresh;
   end;
setlength(cubesb,0);
for e:=1 to 14 do
   setlength(cubesl[e],0);
end;





function stfill(st:string;e:integer):string;
begin
result:=st;
while length(result)<e do
   result:=' '+result;
end;





procedure saf(c,l:integer);
var
mi,ma,n:integer;
begin
if l>2500 then
   l:=2500;
inc(san);
n:=san;
sac[n]:=c;
if pach[c].i<l then
   sas[n]:=pach[c].i
else
   begin
   sas[n]:=0;
   repeat
      if pach[pach[c].c1].i<pach[pach[c].c2].i then
         begin
         mi:=pach[c].c1;
         ma:=pach[c].c2;
         end
      else
         begin
         mi:=pach[c].c2;
         ma:=pach[c].c1;
         end;
      if sas[n]+pach[mi].i<l then
         sas[n]:=sas[n]+pach[mi].i
      else if pach[mi].i<l/2 then
         saf(c,l*2)
      else
         saf(mi,l*2);
      c:=ma;
      until (san>n) or (sas[n]+pach[c].i<l);
   if san>n then
   if pach[mi].i>=l/2 then
      saf(c,l*2)
   else
   else
      sas[n]:=sas[n]+pach[c].i;
   end;
end;





function gets(n:integer):integer;
var
p:integer;
begin
p:=pach[n].p;
result:=ifthen(pach[p].c1=n,pach[p].c2,pach[p].c1);
end;





procedure setc(p,c1,c2:integer);
begin
pach[p].c1:=ifthen(pach[c2].a>pach[c1].a,c1,c2);
pach[p].c2:=ifthen(pach[c2].a>pach[c1].a,c2,c1);
end;





procedure updatei(n:integer);
var
c1,c2:integer;
begin
while n>0 do
   begin
   c1:=pach[n].c1;
   c2:=pach[n].c2;
   pach[n].i:=pach[c1].i+pach[c2].i;
   pach[n].a:=pach[c1].a+pach[c2].a;
   pach[n].mi.lo:=min(pach[c1].mi.lo,pach[c2].mi.lo);
   pach[n].mi.la:=min(pach[c1].mi.la,pach[c2].mi.la);
   pach[n].ma.lo:=max(pach[c1].ma.lo,pach[c2].ma.lo);
   pach[n].ma.la:=max(pach[c1].ma.la,pach[c2].ma.la);
   setc(n,c1,c2);
   n:=pach[n].p;
   end;
end;





procedure insertnode(n,s:integer;d,ilo,ila,elo,ela:double);
var
p,ps,ss,sp:integer;
begin
p:=pach[n].p;
ps:=pach[s].p;
ss:=gets(s);
pach[s].p:=p;
pach[s].d:=d;
pach[s].ee.lo:=ilo;
pach[s].ee.la:=ila;
pach[s].ei.lo:=elo;
pach[s].ei.la:=ela;
//setc(p,n,s);
pach[p].c1:=n;
pach[p].c2:=s;
pach[p].p:=ps;
//setc(ps,ss,p);
pach[ps].c1:=ss;
pach[ps].c2:=p;
updatei(p);
sp:=gets(p);
pach[p].d:=pach[sp].d;
pach[p].ei:=pach[sp].ee;
pach[p].ee:=pach[sp].ei;
end;





procedure addnode(s:integer;a,milo,mila,malo,mala,ilo,ila,elo,ela:double);
var
ed:double;
begin
inc(pachsize);
pach[pachsize].p:=pachsize+1;
pach[pachsize].c1:=-1;
pach[pachsize].c2:=-1;
pach[pachsize].a:=a;
ed:=d(ilo,ila,elo,ela);
pach[pachsize].d:=ed;
pach[pachsize].i:=1;
pach[pachsize].mi.lo:=milo;
pach[pachsize].mi.la:=mila;
pach[pachsize].ma.lo:=malo;
pach[pachsize].ma.la:=mala;
pach[pachsize].ei.lo:=ilo;
pach[pachsize].ei.la:=ila;
pach[pachsize].ee.lo:=elo;
pach[pachsize].ee.la:=ela;
insertnode(pachsize,s,ed,ilo,ila,elo,ela);
inc(pachsize);
end;





procedure addnodes(p:integer;a1,milo1,mila1,malo1,mala1,a2,milo2,mila2,malo2,mala2,ilo,ila,elo,ela:double);
var
ed:double;
begin
inc(pachsize);
pach[p].c1:=pachsize;
pach[pachsize].p:=p;
pach[pachsize].c1:=-1;
pach[pachsize].c2:=-1;
pach[pachsize].i:=1;
ed:=d(ilo,ila,elo,ela);
pach[pachsize].d:=ed;
pach[pachsize].a:=a1;
pach[pachsize].mi.lo:=milo1;
pach[pachsize].mi.la:=mila1;
pach[pachsize].ma.lo:=malo1;
pach[pachsize].ma.la:=mala1;
pach[pachsize].ei.lo:=ilo;
pach[pachsize].ei.la:=ila;
pach[pachsize].ee.lo:=elo;
pach[pachsize].ee.la:=ela;
inc(pachsize);
pach[p].c2:=pachsize;
pach[pachsize].p:=p;
pach[pachsize].c1:=-1;
pach[pachsize].c2:=-1;
pach[pachsize].i:=1;
pach[pachsize].d:=ed;
pach[pachsize].a:=a2;
pach[pachsize].mi.lo:=milo2;
pach[pachsize].mi.la:=mila2;
pach[pachsize].ma.lo:=malo2;
pach[pachsize].ma.la:=mala2;
pach[pachsize].ei.lo:=elo;
pach[pachsize].ei.la:=ela;
pach[pachsize].ee.lo:=ilo;
pach[pachsize].ee.la:=ila;
updatei(p);
end;





procedure movenode(n,s:integer;ilo,ila,elo,ela:double);
var
p,pp,sn,sp:integer;
ed:double;
begin
p:=pach[n].p;
if ilo=0 then ilo:=pach[n].ei.lo;
if ila=0 then ila:=pach[n].ei.la;
if elo=0 then elo:=pach[n].ee.lo;
if ela=0 then ela:=pach[n].ee.la;
ed:=d(ilo,ila,elo,ela);
pach[n].d:=ed;
pach[n].ei.lo:=ilo;
pach[n].ei.la:=ila;
pach[n].ee.lo:=elo;
pach[n].ee.la:=ela;
pp:=pach[p].p;
//setc(pp,gets(p),gets(n));
sn:=gets(n);
sp:=gets(p);
pach[pp].c1:=sp;
pach[pp].c2:=sn;
pach[sn].d:=pach[sp].d;
pach[sn].p:=pp;
pach[sn].ei:=pach[sp].ee;
pach[sn].ee:=pach[sp].ei;
updatei(pp);
insertnode(n,s,ed,ilo,ila,elo,ela);
end;





// create file GSHHS_f_L.txt
procedure TForm1.Button1Click(Sender: TObject);
var
e,j:integer;
begin
st1:=fn+'_with_ice.txt';
assignfile(f0,st1);
rewrite(f0);

j:=0;
for e:=1 to 6 do
//if e<>5 then
   begin
   st:=fn+inttostr(e)+'.dbf';
   assignfile(f,st);
   reset(f);
   seek(f,226);
   repeat
      inc(j);
      blockread(f,ac,89);
      blockwrite(f0,ac,89);
      blockread(f,ac,80);
      blockread(f,ac,9);
      blockwrite(f0,ac,9);
      blockread(f,ac,9);
      blockread(f,ac,24);
      blockwrite(f0,ac,24);
      blockread(f,ac,1);
      until eof(f);
   closefile(f);
   form1.Label1.Caption:=inttostr(j);
   form1.Label1.Refresh;
   end;

closefile(f0);
end;





// create files GSHHS_f_L_shp_list.txt, GSHHS_f_L_shp.txt
procedure TForm1.Button2Click(Sender: TObject);
var
e,i,y,u,j:integer;
begin
st1:=fn+'_shp_list_without_ice.txt';
assignfile(f3,st1);
rewrite(f3);
st1:=fn+'_shp_without_ice.txt';
assignfile(f4,st1);
rewrite(f4);

j:=0;
for e:=1 to 6 do
if e<>5 then
   begin
   st:=fn+inttostr(e)+'.shp';
   assignfile(f2,st);
   reset(f2);
   seek(f2,25);
   repeat
      inc(j);
      BlockRead(f2,it,11);
      read(f2,i);
      read(f2,y);
      BlockRead(f2,it,i);
      BlockRead(f2,it,4*y);
      BlockWrite(f4,it,4*y);
      for u:=1 to y do
         write(f3,j);
      until eof(f2);
   closefile(f2);
   form1.Label1.Caption:=inttostr(j);
   form1.Label1.Refresh;
   end;
closefile(f3);
closefile(f4);
end;






// start
procedure TForm1.Button3Click(Sender: TObject);
{var
e,i,y,u,j,k,q,cc:integer;
a,m,z,lo,la:double;
mi:array[0..1] of double;
x:array[0..10695479] of integer;}
begin
{readarrays;

i:=10695480;
e:=0;
repeat
   inc(e);
   i:=ceil(i/2);
   setlength(h[e],i);
   until e=24;

{form1.Label1.Caption:='sorting...                                           ';
form1.Label1.Refresh;
for e:=1 to 188290 do
   s[e]:=e;
qs(1,188290);}

{e:=0;
q:=0;
repeat
   inc(e);
   if not o(ic[s[e]].lo,ic[s[e]].la,ic[s[e+1]].lo,ic[s[e+1]].la) then
      inc(q);
   until e=188289;
s[1]:=s[1]+q;}

{form1.Label1.Caption:='sx...                                           ';
form1.Label1.Refresh;

{e:=0;
i:=0;
repeat
   inc(e);
   y:=ip[s[e]];
   repeat
      sx[i]:=y;
      inc(i);
      inc(y);
      until n[y]<>s[e];
   until e=188290;}

{for e:=0 to 10695479 do
   sx[e]:=e;
qsx(0,10695479);}

{st:=fn+'sx.txt';
assignfile(f4,st);
rewrite(f4);
blockwrite(f4,sx,10695480);
closefile(f4);}

{e:=0;
q:=0;
repeat
   if o(c[sx[e+1]].lo+180,c[sx[e+1]].la+90,c[sx[e]].lo+180,c[sx[e]].la+90) then
      inc(q);
   inc(e);
   until e=10695479;
sx[1]:=sx[1]+q;}

{st:=fn+'sx.txt';
assignfile(f4,st);
reset(f4);

// sx - sorted array of point numbers (parameter - point number)
blockread(f4,sx,10695480);
closefile(f4);

form1.Label1.Caption:='x...                                           ';
form1.Label1.Refresh;
i:=10695480;
e:=0;
repeat
   u:=e;
   repeat
      inc(u);
      until (u=i) or (n[sx[u]]<>n[sx[e]]);
   repeat
      // x - array of next initial points in sx (parameter - point number)
      x[e]:=u;
      inc(e);
      until e=u;
   until u=i;

// h - array of largest distances between first point of a block in sx and other points of this block, m
// (1st parameter - level (2^level is maximal block size); 2nd - block number)
// ah - array of average h, m (parameter - level)

u:=0;
j:=1;
repeat
   inc(u);
   ah[u]:=0;
   form1.Label1.Caption:='h['+inttostr(u)+']...                                           ';
   form1.Label1.Refresh;
   i:=ceil(i/2);
   e:=0;
   j:=j*2;
   repeat
      h[u,e]:=0;
      for y:=1 to j-1 do
      if j*e+y<10695480 then
         begin
         //a:=d(c[j*e].lo,c[j*e].la,c[j*e+y].lo,c[j*e+y].la);
         a:=d(c[sx[j*e]].lo,c[sx[j*e]].la,c[sx[j*e+y]].lo,c[sx[j*e+y]].la);
         if a>h[u,e] then h[u,e]:=a;
         end;
      ah[u]:=ah[u]+h[u,e];
      inc(e);
      until e=i;
   ah[u]:=ah[u]/length(h[u]);
   until u=24;

// ci[0] - array of central islands (parameter - island number)
// ni[0] - array of nearest islands (parameter - island number)
// nd[0] - array of distances to nearest island, m (parameter - island number)
st:=fn+'ci.txt';
assignfile(f4,st);
reset(f4);
blockread(f4,ci[0],188290);
closefile(f4);

st:=fn+'ni.txt';
assignfile(f4,st);
reset(f4);
blockread(f4,ni[0],188290);
closefile(f4);

st:=fn+'nd.txt';
assignfile(f5,st);
reset(f5);
blockread(f5,nd[0],188290);
closefile(f5);

{a:=0;
for e:=1 to 188290 do
if nd[0,e]>500000 then
if e=ci[0,e] then
   begin
   a:=nd[0,e];
   y:=e;
   lo:=ic[y].lo-180;
   la:=ic[y].la-90;
   z:=ci[0,y];
   u:=ni[0,y];
   y:=floor(lo+la+z+a);
   lo:=ic[u].lo-180;
   la:=ic[u].la-90;
   y:=floor(lo+la+z+y);
   end;}

// moving central island to nearset island, if distance to nearset island is less than 1000000 m
{e:=0;
repeat
   inc(e);
   if (e=ci[0,e]) and (nd[0,e]<1000000) then
      if e>ci[0,ni[0,e]] then
         ci[0,e]:=ci[0,ni[0,e]]
      else
         ci[0,ni[0,e]]:=e;
   until e=188290;

// counting number of archipelagoes
i:=0;
for e:=1 to 188290 do
if e=ci[0,e] then
inc(i);
form1.Label4.Caption:=inttostr(i)+'...                                           ';
form1.Label4.Refresh;

{form1.Label1.Caption:='arrays...                                           ';
form1.Label1.Refresh;
for e:=1 to 188290 do
   begin
   ci[0,e]:=e;
   if (level[e]=2) or (level[e]=4) then
      begin
      i:=0;
      repeat
         inc(i);
         st:=na[i];
         if pos('-',st)<>0 then st:=leftstr(st,pos('-',st)-1);
         until st=pa[e];
      ci[0,e]:=i;
      end;
   if pos('-W',na[e])<>0 then
      ci[0,e]:=ci[0,e-1];
   ni[0,e]:=0;
   nd[0,e]:=1000000000;
   end;}

{repeat

for e:=1 to 188290 do
   begin
   ni[0,e]:=0;
   nd[0,e]:=1000000000;
   end;

y:=24;
repeat
form1.Label3.Caption:=inttostr(y)+'...                                           ';
form1.Label3.Refresh;
e:=0;
if y<24 then e:=pt[y];
cc:=0;
repeat
   z:=10000000000;
   lo:=0;
   la:=0;
   j:=24;
   repeat
      i:=0;
      q:=0;
      {if nd[0,n[e]]=1000000000 then
         begin
         while ci[0,n[e]]=ci[0,n[i]] do
            inc(i);
         ni[0,n[e]]:=ci[0,n[i]];
         nd[0,n[e]]:=d(c[i].lo,c[i].la,c[e].lo,c[e].la);
         i:=0;
         end;}
      {while i<10695480 do
         begin
         {a:=d(c[i].lo,c[i].la,c[e].lo,c[e].la);
         if (n[e]<>n[i]) and (ci[0,n[e]]<>ci[0,n[i]]) and (a<nd[0,n[e]]) then
            begin
            ni[0,n[e]]:=ci[0,n[i]];
            nd[0,n[e]]:=a;
            end;
         u:=mp(i);
         if ci[0,n[e]]=ci[0,n[i]] then
            i:=pt[j]*ceil(x[i]/pt[j])
         else
            begin
            while (u>j) and (a-h[u,i div pt[u]]<nd[0,n[e]]) do
               dec(u);
            i:=i+pt[u];
            end;}

         {a:=d(c[sx[i]].lo,c[sx[i]].la,c[sx[e]].lo,c[sx[e]].la);
         if (n[sx[e]]<>n[sx[i]]) and (ci[0,n[sx[e]]]<>ci[0,n[sx[i]]]) and (a<z) then
            begin
            z:=a;
            lo:=c[sx[e]].lo;
            la:=c[sx[e]].la;
            cc:=ci[0,n[sx[e]]];
            if z<nd[0,ci[0,n[sx[e]]]] then
               begin
               ni[0,ci[0,n[sx[e]]]]:=ci[0,n[sx[i]]];
               nd[0,ci[0,n[sx[e]]]]:=a;
               end;
            end;
         u:=mp(i);
         {if ci[0,n[sx[e]]]=ci[0,n[sx[i]]] then
            i:=pt[j]*ceil(x[i]/pt[j])
         else}
            {begin
            while (u>j) and (a-h[u,i div pt[u]]<nd[0,ci[0,n[sx[e]]]]) do
               dec(u);
            i:=i+pt[u];
            end;

         inc(q);
         end;
      dec(j);
      until j<0;
   form1.Label1.Caption:=inttostr(q)+'...                                           ';
   form1.Label1.Refresh;
   form1.Label2.Caption:=inttostr(e)+'...                                           ';
   form1.Label2.Refresh;

   {repeat
      inc(e);
      until (e>=10695480) or (ci[0,n[sx[e]]]<>cc) or (z-d(lo,la,c[sx[e]].lo,c[sx[e]].la)<nd[0,ci[0,n[sx[e]]]]);}

   {repeat
      e:=e+pt[y+1];
      until (e>=10695480) or (ci[0,n[sx[e]]]<>cc) or (z-d(lo,la,c[sx[e]].lo,c[sx[e]].la)<nd[0,ci[0,n[sx[e]]]]);

   {if e<10695480 then
      begin
      i:=e-pt[y];
      a:=nd[0,n[sx[i]]]+d(c[sx[i]].lo,c[sx[i]].la,c[sx[e]].lo,c[sx[e]].la);
      if a<nd[0,n[sx[e]]] then
         begin
         ni[0,n[sx[e]]]:=ci[0,n[sx[i]]];
         nd[0,n[sx[e]]]:=a;
         end;
      end;}
   {until e>=10695480;
   dec(y);
   until y<8;

k:=0;
e:=0;
repeat
   inc(e);
   if (e=ci[0,e]) and (nd[0,e]<1000000) then
      begin
      ci[0,e]:=ci[0,ni[0,e]];
      k:=1;
      end;
   until e=188290;

i:=0;
for e:=1 to 188290 do
if e=ci[0,e] then
inc(i);
form1.Label4.Caption:=inttostr(i)+'...                                           ';
form1.Label4.Refresh;

until k=0;

st:=fn+'ci_king.txt';
assignfile(f4,st);
rewrite(f4);
blockwrite(f4,ci[0],188290);
closefile(f4);

st:=fn+'ni_king.txt';
assignfile(f4,st);
rewrite(f4);
blockwrite(f4,ni[0],188290);
closefile(f4);

st:=fn+'nd_king.txt';
assignfile(f5,st);
rewrite(f5);
blockwrite(f5,nd[0],188290);
closefile(f5);

{e:=0;
y:=0;
k:=1;
form1.Label1.Caption:=inttostr(k)+'...                                           ';
form1.Label1.Refresh;
repeat
   if y=0 then
      begin
      y:=1;
      b[0]:=0;
      bn[1]:=0;
      st:=na[1];
      if pos('-',st)<>0 then st:=leftstr(st,pos('-',st)-1);
      end
   else if y=1 then
      begin
      if (level[n[e]]=2) or (level[n[e]]=4) then
         st1:=pa[n[e]]
      else
         begin
         st1:=na[n[e]];
         if pos('-',st1)<>0 then st1:=leftstr(st1,pos('-',st1)-1);
         end;
      if st1=st then
         b[e]:=0
      else
         begin
         y:=2;
         st:=st1;
         b[e]:=1;
         k:=2;
         form1.Label1.Caption:=inttostr(k)+'...                                           ';
         form1.Label1.Refresh;
         bn[2]:=1;
         m:=d(c[0].lo,c[0].la,c[e].lo,c[e].la);
         j:=24;
         while e<pt[j] do
            dec(j);
         repeat
            i:=0;
            while i<e do
               begin
               a:=d(c[i].lo,c[i].la,c[e].lo,c[e].la);
               if a<m then
                  m:=a;
               u:=mp(i);
               while (u>0) and (a-h[u,i div pt[u]]<m) do
                  dec(u);
               if u<j then
                  u:=j;
               i:=i+pt[u];
               end;
            dec(j);
            until j<0;
         end;
      end
   else
      begin
      mi[0]:=1000000000;
      mi[1]:=1000000000;
      if (level[n[e]]=2) or (level[n[e]]=4) then
         st1:=pa[n[e]]
      else
         begin
         st1:=na[n[e]];
         if pos('-',st1)<>0 then st1:=leftstr(st1,pos('-',st1)-1);
         end;
      if st1=st then
         begin
         b[e]:=b[e-1];
         mi[b[e]]:=0;
         end
      else
         begin
         st:=st1;
         if (level[n[e]]=2) or (level[n[e]]=4) then
            begin
            i:=0;
            repeat
               inc(i);
               if st1=pa[i] then
                  begin
                  b[e]:=bn[i];
                  mi[b[e]]:=0;
                  i:=k;
                  end;
               until i=k;
            end
         else
            begin
            inc(k);
            form1.Label1.Caption:=inttostr(k)+'...                                           ';
            form1.Label1.Refresh;
            end;
         end;
      for q:=0 to 1 do
      if mi[q]>0 then
         begin
         j:=24;
         while e<pt[j] do
            dec(j);
         repeat
         i:=0;
         while i<e do
            begin
            if q=b[i] then
               a:=d(c[i].lo,c[i].la,c[e].lo,c[e].la)
            else
               a:=1000000000;
            if a<mi[q] then
               mi[q]:=a;
            u:=mp(i);
            while (u>0) and (a-h[u,i div pt[u]]<mi[q]) do
               dec(u);
            if u<j then
               u:=j;
            i:=i+pt[u];
            end;
         dec(j);
         until j<0;
         end;
      if (mi[0]>m) and (mi[1]>m) then
         begin
         m:=mi[ifthen(mi[0]>mi[1],1,0)];
         for i:=1 to k-1 do
            bn[i]:=0;
         bn[k]:=1;
         for i:=0 to e-1 do
            b[i]:=0;
         b[e]:=1;
         end
      else
         begin
         q:=ifthen(mi[0]>mi[1],1,0);
         bn[k]:=q;
         b[e]:=q;
         if mi[q]=0 then
            q:=1-q;
         if mi[q]<m then
            m:=mi[q];
         end;
      end;
   inc(e);
   until e=10695480;}
end;





procedure TForm1.Button4Click(Sender: TObject);
var
e,i,u,y,j,k,l,asize:integer;
cc,cc1:cart;
m:double;
a:array of record n,s,j: integer; d:double; ei,ee:cart end;
b:boolean;
begin
readarrays;
setlength(a,1);
y:=0;
repeat
form1.Label1.Caption:=inttostr(y)+'                                  ';
form1.Label1.Refresh;
form1.Label2.Caption:=inttostr(ipachsize)+'                                  ';
form1.Label2.Refresh;

for e:=1 to ipachsize do
//for e:=ipachsize downto 1 do
   begin
   {if (pach[ipach[e]].d<0) and (pach[ipach[e]].p>=0) then
      begin
      form1.Label1.Caption:=inttostr(pach[ipach[e]].p)+'                                  ';
      form1.Label1.Refresh;
      form1.Label2.Caption:=floattostr(pach[ipach[e]].d)+'                                  ';
      form1.Label2.Refresh;
      end;}

   {if (pach[ipach[e]].d>=0) and (pach[ipach[e]].p<0) then
      begin
      form1.Label1.Caption:=inttostr(pach[ipach[e]].p)+'                                  ';
      form1.Label1.Refresh;
      form1.Label2.Caption:=floattostr(pach[ipach[e]].d)+'                                  ';
      form1.Label2.Refresh;
      end;}

   if pach[ipach[e]].d<0 then
      begin
      form1.Label3.Caption:=inttostr(e)+'                                 ';
      form1.Label3.Refresh;
      //if plistsize[ipach[e]]=0 then
         setp(ipach[e]);
      //pach[ipach[e]].d:=getd(ipach[e]);
      //pach[ipach[e]].s:=sib;
      pach[ipach[e]].d:=plist[ipach[e],0].d;
      pach[ipach[e]].s:=plist[ipach[e],0].n;

      if pach[ipach[e]].d<=0 then
         begin
         form1.Label1.Caption:=inttostr(ipach[e])+'                                  ';
         form1.Label1.Refresh;
         form1.Label2.Caption:=floattostr(pach[ipach[e]].d)+'                                  ';
         form1.Label2.Refresh;
         end;
      {if (pach[ipach[e]].d<>getd(ipach[e])) and (pach[ipach[e]].s=sib) then
         pach[ipach[e]].d:=getd(ipach[e]);
      if (pach[ipach[e]].d=getd(ipach[e])) and (pach[ipach[e]].s<>sib) then
         pach[ipach[e]].s:=sib;}

      {if pach[ipach[e]].d<>getd(ipach[e]) then
         pach[ipach[e]].d:=getd(ipach[e]);
      if pach[ipach[e]].s<>sib then
         begin
         pach[ipach[e]].s:=sib;
         end;}
      end
   else
      begin
      setpd(ipach[e]);
      {setp(ipach[e]);
      if pach[ipach[e]].d<>plist[ipach[e],0].d then
         pach[ipach[e]].d:=plist[ipach[e],0].d;
      pach[ipach[e]].s:=plist[ipach[e],0].n;}
      end;
   //if e mod 100=0 then
   //   begin
   //   form1.Label3.Caption:=inttostr(e)+'                                 ';
   //   form1.Label3.Refresh;
   //   end;
   end;

for e:=1 to ipachsize do
if pach[ipach[e]].p<0 then
begin
{if e=18184 then
   form1.Label1.Caption:=inttostr(e)+'                                  ';}
j:=0;
i:=ipach[e];
//m:=1000;
//u:=plist[ipach[e],j].n;
u:=plist[i,j].n;
//if (plistsize[u]>1) and (plist[u,1].d-plist[u,0].d<m) then
//   m:=plist[u,1].d-plist[u,0].d;

m:=pm[i];

asize:=0;
//while (asize<plistsize[ipach[e]]) and (plist[ipach[e],asize].d-plist[ipach[e],0].d<1000) do
while (asize<plistsize[i]) and (plist[i,asize].d<=m) do
   begin
   if asize>=length(a) then
      setlength(a,length(a)*2);
   a[asize].n:=asize+1;
   //a[asize].s:=ipach[e];
   a[asize].s:=i;
   a[asize].j:=asize;
   //a[asize].d:=plist[ipach[e],asize].d;
   //a[asize].ei:=plist[ipach[e],asize].ei;
   //a[asize].ee:=plist[ipach[e],asize].ee;
   a[asize].d:=plist[i,asize].d;
   a[asize].ei:=plist[i,asize].ei;
   a[asize].ee:=plist[i,asize].ee;
   inc(asize);
   end;
a[asize-1].n:=1000000000;
b:=false;

//if (a[j].s=pach[u].s) and (a[j].d<=min(m,pm[u])) then
//if (i<1) or (i>pachsize) or (u<1) or (u>pachsize) then
if m<pach[i].d then
   a[asize-1].n:=1000000000;

while (j<asize) and (pach[i].p<0) and (pach[u].p<0) and (a[j].s=pach[u].s) and (a[j].d<=min(m,pm[u])) do
//while (j<asize) and (a[j].s=pach[u].s) and (a[j].d<=min(m,pm[u])) do
//while (j<asize) and (a[j].s=pach[u].s) and (a[j].d-a[0].d<1000) do
//while (j<plistsize[ipach[e]]) and (ipach[e]=pach[u].s) and (plist[ipach[e],j].d-plist[ipach[e],0].d<m) do
//while (j<plistsize[ipach[e]]) and ((j<1) or (y=0)) and (ipach[e]=pach[plist[ipach[e],j].n].s) and (plist[ipach[e],j].d-plist[ipach[e],0].d<1000) do
//while (j=0) and (ipach[e]=pach[plist[ipach[e],j].n].s) do
//if ipach[e]=pach[plist[ipach[e],j].n].s then
//if ipach[e]=pach[pach[ipach[e]].s].s then
   begin
   {if (i<1) or (i>pachsize) or (u<1) or (u>pachsize) then
      a[asize-1].n:=1000000000;}

   b:=true;
   inc(pachsize);

   //i:=ipach[e];
   //u:=pach[i].s;
   m:=min(m,pm[u]);

   pach[i].p:=pachsize;
   pach[i].s:=u;
   pach[i].d:=a[j].d;
   pach[i].ei:=cts(a[j].ei);
   pach[i].ee:=cts(a[j].ee);
   pach[u].p:=pachsize;
   //pach[u].ei:=pach[i].ei;
   //pach[u].ee:=pach[i].ee;
   pach[u].ei:=pach[i].ee;
   pach[u].ee:=pach[i].ei;

  if {(j>0) and} (pach[i].c1>0) and (pach[pach[i].c1].d>pach[i].d) then
     pach[i].d:=pach[u].d;

   {if pach[u].s<>i then
      pach[u].s:=i;}

   {form1.Label2.Caption:=floattostr(pach[i].d)+'                                            ';
   form1.Label2.Refresh;
   form1.Label3.Caption:=floattostr(pach[u].d)+'                                            ';
   form1.Label3.Refresh;}
   if pach[i].d<>pach[u].d then
      pach[u].d:=pach[i].d;

   pach[pachsize].p:=-1;
   pach[pachsize].c1:=ifthen(pach[i].a>pach[u].a,u,i);
   pach[pachsize].c2:=ifthen(pach[i].a>pach[u].a,i,u);
   pach[pachsize].i:=pach[i].i+pach[u].i;
   pach[pachsize].d:=-1;
   pach[pachsize].a:=pach[i].a+pach[u].a;
   pach[pachsize].mi.lo:=min(pach[i].mi.lo,pach[u].mi.lo);
   pach[pachsize].mi.la:=min(pach[i].mi.la,pach[u].mi.la);
   pach[pachsize].ma.lo:=max(pach[i].ma.lo,pach[u].ma.lo);
   pach[pachsize].ma.la:=max(pach[i].ma.la,pach[u].ma.la);
   //plistcomplete[pachsize]:=false;

   k:=1;
   l:=0;
   //while (k<plistsize[u]) and (plist[u,k].d-a[0].d<1000) do
   while (k<plistsize[u]) and (plist[u,k].d<=m) do
      begin
      if asize>=length(a) then
         setlength(a,length(a)*2);
      while (a[l].n<1000000000) and (a[a[l].n].d<plist[u,k].d) do
         l:=a[l].n;
      a[asize].n:=ifthen(a[l].n<asize,a[l].n,1000000000);
      a[l].n:=asize;
      a[asize].s:=u;
      a[asize].j:=k;
      a[asize].d:=plist[u,k].d;
      //a[asize].ei:=plist[u,k].ei;
      //a[asize].ee:=plist[u,k].ee;
      a[asize].ei:=plist[u,k].ee;
      a[asize].ee:=plist[u,k].ei;
      inc(asize);
      inc(k);
      //l:=asize;
      end;

   l:=0;
   while a[l].n<1000000000 do
      begin
      if a[a[l].n].d<a[l].d then
         l:=a[l].n;
      l:=a[l].n;
      end;

   i:=pachsize;

   j:=a[j].n;
   if j<asize then
      //u:=a[j].s;
      u:=plist[a[j].s,a[j].j].n;

   {inc(j);
   if j<plistsize[ipach[e]] then
      begin
      u:=plist[ipach[e],j].n;
      if (plistsize[u]>1) and (plist[u,1].d-plist[u,0].d<m) then
         m:=plist[u,1].d-plist[u,0].d;
      end;}
   //setph(pachsize);
   end;

//b:=false;   
if b then
if j<asize then
if plist[a[j].s,a[j].j].d<=m then
//if false then
   begin
   pm[i]:=m;
   plistsize[i]:=0;
   l:=j;
   while l<asize do
      begin
      //if pach[plist[a[l].s,a[l].j].n].p<0 then
      //if pach[a[l].s].p<0 then
      if anc(a[l].s)<>i then
         inc(plistsize[i]);
      l:=a[l].n;
      end;
   setlength(plist[i],plistsize[i]);
   l:=0;
   while j<asize do
      begin
      //if pach[plist[a[j].s,a[j].j].n].p<0 then
      //if pach[a[j].s].p<0 then
      if anc(a[j].s)<>i then
         begin
         plist[i,l].n:=plist[a[j].s,a[j].j].n;
         plist[i,l].d:=plist[a[j].s,a[j].j].d;
         plist[i,l].ei:=plist[a[j].s,a[j].j].ei;
         plist[i,l].ee:=plist[a[j].s,a[j].j].ee;
         inc(l);
         end;
      j:=a[j].n;
      end;
   if l>0 then
      begin
      pach[i].d:=plist[i,0].d;
      pach[i].s:=plist[i,0].n;
      end;
   if m<pach[i].d then
      a[asize-1].n:=1000000000;
   end;
end;

{for e:=1 to pachsize do
if pach[ipach[e]].p>0 then
   setlength(plist[ipach[e]],0);}

{for e:=1 to pachsize do
if pach[e].p<0 then
for i:=0 to plistsize[e]-1 do
while pach[plist[e,i].n].p>0 do
   plist[e,i].n:=pach[plist[e,i].n].p;}

for e:=1 to ipachsize do
//if pach[pach[ipach[e]].s].p>0 then
//   pach[ipach[e]].s:=pach[pach[ipach[e]].s].p;
pach[ipach[e]].s:=anc(pach[ipach[e]].s);

{for e:=1 to pachsize do
pach[e].s:=anc(pach[e].s);}

generateipach;

for e:=1 to length(cubes) do
for i:=0 to sar[e]-1 do
if cubeslistsize[e,i]>0 then
   quicksortlist(e,i);

for e:=0 to length(cubeslastlist)-1 do
for i:=0 to cubeslastlistsize[e]-1 do
//if pach[cubeslastlist[e,i].n].p>0 then
//   cubeslastlist[e,i].n:=pach[cubeslastlist[e,i].n].p;
cubeslastlist[e,i].n:=anc(cubeslastlist[e,i].n);

inc(y);
until ipachsize=1;

i:=0;
for e:=1 to pachsize do
   begin
   if (pach[e].c1>0) and (pach[e].d>0) and (pach[pach[e].c1].d>pach[e].d) then
      begin
      form1.Label1.Caption:=floattostr(pach[e].d)+'; '+floattostr(pach[pach[e].c1].d)+'                                            ';
      form1.Label1.Refresh;
      inc(i);
      end;
   if (pach[e].c1>0) and (pach[pach[e].c1].p<>e) then
      inc(i);
   if (pach[e].c2>0) and (pach[pach[e].c2].p<>e) then
      inc(i);
   if (pach[e].p>0) and (pach[pach[e].p].c1<>e) and (pach[pach[e].p].c2<>e) then
      inc(i);
   if (pach[e].c1>0) and (pach[e].c2<0) then
      inc(i);
   if (pach[e].c1<0) and (pach[e].c2>0) then
      inc(i);
   if pach[e].c1>0 then
      begin
      if pach[pach[e].c1].ee.lo<>pach[pach[e].c2].ei.lo then
         inc(i);
      if pach[pach[e].c1].ee.la<>pach[pach[e].c2].ei.la then
         inc(i);
      if pach[pach[e].c1].ei.lo<>pach[pach[e].c2].ee.lo then
         inc(i);
      if pach[pach[e].c1].ei.la<>pach[pach[e].c2].ee.la then
         inc(i);
      end;
   end;

{for e:=1 to pachsize do
for u:=1 to pachsize do
if e<>u then
   begin
   if (pach[e].c1>0) and (pach[e].c1=pach[u].c1) then
      inc(i);
   if (pach[e].c1>0) and (pach[e].c1=pach[u].c2) then
      inc(i);
   if (pach[e].c2>0) and (pach[e].c2=pach[u].c1) then
      inc(i);
   if (pach[e].c2>0) and (pach[e].c2=pach[u].c2) then
      inc(i);
   end;}

{e:=1;
while pach[e].p>0 do
   begin
   e:=pach[e].p;
   inc(i);
   end;}

form1.Label2.Caption:=inttostr(i)+'                                            ';
form1.Label2.Refresh;

{st:=fn+'_pach.txt';
assignfile(f6,st);
reset(f6);
blockread(f6,pach1,pachsize);
closefile(f6);}

{j:=0;
e:=1;}
{for e:=1 to 100 do
if pach[e].p<>pach1[e].p then
   inc(j);}
{while pach[e].p>0 do
   begin
   inc(j);
   e:=pach[e].p;
   end;
form1.Label1.Caption:=inttostr(j)+'                                            ';
form1.Label1.Refresh;
j:=0;
e:=1;
while pach[e].p>0 do
   begin
   inc(j);
   e:=pach1[e].p;
   end;
form1.Label1.Caption:=inttostr(j)+'                                            ';
form1.Label1.Refresh;}

st:=fn+'_pach.txt';
assignfile(f6,st);
rewrite(f6);
blockwrite(f6,pach,pachsize);
closefile(f6);

e:=1;
while pach[e].p>0 do
   e:=pach[e].p;
pach[1]:=pach[pach[e].c1];
e:=pach[e].c2;
pach[2]:=pach[e];
pach[3]:=pach[pach[e].c1];
e:=pach[e].c2;
pach[4]:=pach[pach[e].c1];
e:=pach[e].c2;
pach[5]:=pach[pach[e].c1];
e:=pach[e].c2;
pach[6]:=pach[pach[e].c1];
e:=pach[e].c2;
pach[7]:=pach[pach[e].c1];
pach[8]:=pach[pach[e].c1];
pach[9]:=pach[pach[e].c2];
end;





procedure updatememo;
begin
form1.Memo1.Lines[0]:='i: '+inttostr(pe.i);
form1.Memo1.Lines[1]:='d: '+floattostr(pe.d);
form1.Memo1.Lines[2]:='a: '+floattostr(pe.a);
form1.Memo1.Lines[3]:='lo: '+floattostr(pe.mi.lo)+'     '+floattostr(pe.ma.lo);
form1.Memo1.Lines[4]:='la: '+floattostr(pe.mi.la)+'     '+floattostr(pe.ma.la);
end;





procedure TForm1.Button5Click(Sender: TObject);
var
e,i,u:integer;
p:pachelement;
a:double;
//sc1,sc2:sph;
begin
pachsize:=363881;
root:=pachsize;
st:=fn+'_pach.txt';
assignfile(f6,st);
reset(f6);
blockread(f6,pach,pachsize);
closefile(f6);

{e:=181615;
while e>0 do
   begin
   p:=pach[e];
   dec(e);
   end;}

addnode(363861,0.015,-29.3467352,0.9153921,-29.3440812,0.9184306,-29.346734,0.9153619,-32.378703,-3.8048157);            // Saint Peter and Saint Paul Archipelago 623700
addnode(360051,0.042,-179.9117,-67.3783,-179.9117,-67.3732,-179.9117,-67.3783,170.2942698,-71.305298);                   // Scott Island 588550
movenode(291525,363860,-177.9754734,-29.2404344,-179.1195427,-23.9751125);                                               // Kermadec Islands 595000
addnode(340199,0,-179.1645188,-23.9698416,-178.8814063,-23.6117325,-178.9159102,-23.6096484,-178.8451428,-21.0525872);   // Minerva Reefs 284290
addnode(340205,0,174.7383,-21.64,174.92,-21.64,174.7383,-21.64,172.0888621,-22.3910578);                                 // Conway Reef 265380
addnodes(363884,0.04,-179.9117,-67.3783,-179.9117,-67.3732,0.002,-179.9167,-67.4,-179.9167,-67.3995, -179.9117,-67.3783,-179.9167,-67.4); // Scott Island
pach[363890].d:=250;
pach[363891].d:=250;
addnodes(363886,0,-178.9493268,-23.6717286,-178.8814063,-23.6117325,0,-179.1645188,-23.9698416,-179.0414231,-23.881014,-178.9493268,-23.6717286,-179.0414231,-23.881014); // Minerva Reefs
addnode(291543,0,159.0212595,-29.9842365,159.122883,-29.4476764,159.0212595,-29.9842365,159.0710306,-31.4867432);        // Elizabeth, Middleton
addnodes(363894,0,159.0212595,-29.9842365,159.1172182,-29.9135852,0,159.0694963,-29.4711426,159.122883,-29.4476764,159.1172182,-29.9135852,159.122883,-29.4711426); // Elizabeth, Middleton
movenode(363895,363856,159.0553343,-29.4444531,153.6088381,-28.8434455);                                                 // Lord Howe
addnode(8905,0.004,-170.6278,25.4933,-170.6199,25.5051,-170.6278,25.5051,-171.73044,25.75788);                           // Maro Reef
movenode(313846,320213,-170.6199,25.4933,0,0);                                                                           // Midway
addnode(304539,2.1,-134.5066137,-23.3772377,-134.4494884,-23.3157491,-134.5022528,-23.3189512,-134.8442237,-23.2090608); // Temoe
addnode(334010,9,-141.8622073,-18.8158151,-141.7452201,-18.7031328,-141.8622073,-18.7031328,-142.1765193,-18.3228838);   // Nengonengo
movenode(291804,339276,0,0,0,0);
movenode(313844,336796,0,0,0,0);                                                                                         // Hao
movenode(284903,335026,-141.2612208,-19.1776489,-141.7742738,-18.7982858);                                               // Paraoa
addnode(296888,0.014,-112.0653261,18.9971491,-112.0653261,18.998,-112.0653261,18.9971491,-111.0585428,18.8313338);       // Roca Partida
addnode(278048,0.048,-178.82662,-31.35604,-178.82378,-31.35317,-178.82378,-31.35317,-178.55781,-30.54476);               // L'Esperance Rock
addnode(363814,0,117.7104392,15.1033194,117.8474679,15.222799,117.8467384,15.1383273,119.88995,15.431087);               // Scarborough Shoal
                                                  
i:=0;
for e:=1 to pachsize do
//if (pach[e].c1>0) and (pach[e].c2>0) and (pach[pach[e].c1].d<>pach[pach[e].c2].d) then
if (pach[e].c1>0) and (pach[e].d>0) and (pach[pach[e].c1].d>pach[e].d) then
   begin
   inc(i);
   form1.Label1.Caption:=inttostr(i)+'                                            ';
   form1.Label1.Refresh;
   form1.Label2.Caption:=inttostr(e)+'                                            ';
   form1.Label2.Refresh;
   form1.Label3.Caption:=floattostr(pach[pach[e].c2].d)+'                 ';
   form1.Label3.Refresh;
   end;

for e:=1 to pachsize do
if (pach[e].c1>0) and (pach[e].i<>pach[pach[e].c1].i+pach[pach[e].c2].i) then
   inc(i);
form1.Label1.Caption:=inttostr(i)+'                                            ';
form1.Label1.Refresh;

san:=-1;
saf(root,100);

{i:=0;
for e:=0 to san do
   i:=i+sas[e];}



for e:=1 to pachsize do
   begin
   u:=e;
   repeat
      i:=0;
      while (u<>sac[i]) and (i<=san) do
         inc(i);
      if i>san then
         u:=pach[u].p;
      until i<=san;
   part[e]:=i;
   end;

e:=1;
while pach[e].p>0 do
   begin
   e:=pach[e].p;
   p:=pach[e];
   end;

pe:=p;
updatememo;

i:=0;
while pach[e].c2>0 do
   begin
   inc(i);
   p:=pach[pach[e].c1];
   e:=pach[e].c2;
   //if (p.c1>0) and (pach[p.c1].d>1000000) then
   {if p.d<10000 then
      begin
      form1.Label2.Caption:=inttostr(i-1)+'                                            ';
      form1.Label2.Refresh;
      end;}
   end;

form1.Label1.Caption:=inttostr(i)+'                                            ';
form1.Label1.Refresh;

i:=0;
a:=1000000;
for e:=1 to pachsize do
if (pach[e].d>=a) and ((pach[e].c1<0) or (pach[pach[e].c1].d<a)) then
   inc(i);

form1.Label1.Caption:=inttostr(i)+'                                            ';
form1.Label1.Refresh;

i:=0;
for e:=1 to pachsize do
if length(floattostr(roundto(pach[e].ee.la,-6)))>i then
   i:=length(floattostr(roundto(pach[e].ee.la,-6)));

form1.Label1.Caption:=inttostr(i)+'                                            ';
form1.Label1.Refresh;

st:=fn+'_pach_sac.txt';
assignfile(f7,st);
rewrite(f7);
for e:=0 to san do
   writeln(f7,stfill(inttostr(sac[e]),6));
closefile(f7);

for i:=0 to san do
begin
st:=fn+'_pach_text'+inttostr(i)+'.txt';
assignfile(f7,st);
rewrite(f7);
//writeln(f7,'    id      p     c1     c2      i      int. d      ext. d                 a       mi.lo      mi.la       ma.lo      ma.la       ei.lo      ei.la       ee.lo      ee.la');
//writeln(f7,'');
for e:=1 to pachsize do
if part[e]=i then
   begin
   st:='';
   st:=st+stfill(inttostr(e),6);
   st:=st+stfill(ifthen(pach[e].p<0,'-',inttostr(pach[e].p)),7);
   st:=st+stfill(ifthen(pach[e].c1<0,'-',inttostr(pach[e].c1)),7);
   st:=st+stfill(ifthen(pach[e].c2<0,'-',inttostr(pach[e].c2)),7);
   st:=st+stfill(inttostr(pach[e].i),7);
   st:=st+stfill(floattostr(roundto(ifthen(pach[e].c1<0,0,pach[pach[e].c1].d/1000),-6)),12);
   st:=st+stfill(floattostr(roundto(ifthen(pach[e].d<0,0,pach[e].d/1000),-6)),12);
   st:=st+stfill(floattostr(pach[e].a),18);
   st:=st+stfill(floattostr(roundto(pach[e].mi.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].mi.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ma.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ma.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ei.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ei.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ee.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ee.la,-6)),11);
   writeln(f7,st);
   end;
closefile(f7);
end;

st:=fn+'_pach_text.txt';
assignfile(f7,st);
rewrite(f7);
writeln(f7,'    id      p     c1     c2      i      int. d      ext. d                 a       mi.lo      mi.la       ma.lo      ma.la       ei.lo      ei.la       ee.lo      ee.la');
writeln(f7,'');
for e:=1 to pachsize do
   begin
   st:='';
   st:=st+stfill(inttostr(e),6);
   st:=st+stfill(ifthen(pach[e].p<0,'-',inttostr(pach[e].p)),7);
   st:=st+stfill(ifthen(pach[e].c1<0,'-',inttostr(pach[e].c1)),7);
   st:=st+stfill(ifthen(pach[e].c2<0,'-',inttostr(pach[e].c2)),7);
   st:=st+stfill(inttostr(pach[e].i),7);
   st:=st+stfill(floattostr(roundto(ifthen(pach[e].c1<0,0,pach[pach[e].c1].d/1000),-6)),12);
   st:=st+stfill(floattostr(roundto(ifthen(pach[e].d<0,0,pach[e].d/1000),-6)),12);
   st:=st+stfill(floattostr(pach[e].a),18);
   st:=st+stfill(floattostr(roundto(pach[e].mi.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].mi.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ma.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ma.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ei.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ei.la,-6)),11);
   st:=st+stfill(floattostr(roundto(pach[e].ee.lo,-6)),12);
   st:=st+stfill(floattostr(roundto(pach[e].ee.la,-6)),11);
   writeln(f7,st);
   end;
closefile(f7);

{sc1.lo:=-32.3787217;
sc1.la:=-3.8048172;
sc2.lo:=-29.3465036;
sc2.la:=0.9155453;
form1.Label2.Caption:=floattostr(dsph(sc1,sc2))+'                                            ';
form1.Label2.Refresh;}

//form1.Label1.Caption:='                                            ';
//form1.Label1.Refresh;
end;





procedure TForm1.Button6Click(Sender: TObject);
var
t:tbitmap;
e,k:integer;
begin
st:=fn+'_with_ice.txt';
assignfile(f,st);
reset(f);
e:=0;
repeat
   inc(e);
   blockread(f,ac,80);
   st:=leftstr(ac,80);
   delete(st,pos(' ',st),80);

   // na - array of IDs (names with "E" or "W") of islands (parameter - island number)
   na[e]:=st;
   blockread(f,ac,9);
   st:=leftstr(ac,9);

   // level - array of level of islands
   // (1 - island, 2 - lake, 3 - lake island, 4 - lake island lake, 5 - ice (not used), 6 - iced ground; parameter - island number)
   level[e]:=strtoint(st);
   blockread(f,ac,9);
   st:=leftstr(ac,9);
   while pos(' ',st)<>0 do delete(st,1,1);

   // pa - array of PARENT_IDs (without "E" or "W"; if no parent, then -1; parameter - island number)
   pa[e]:=st;
   blockread(f,ac,24);
   st:=leftstr(ac,24);

   // area - array of areas, km^2 (parameter - island number)
   area[e]:=strtofloat(st);
   until eof(f);
closefile(f);

st:=fn+'_shp_list_with_ice.txt';
assignfile(f4,st);
reset(f4);
blockread(f4,n,npoints);
closefile(f4);
st:=fn+'_shp_with_ice.txt';
assignfile(f5,st);
reset(f5);
blockread(f5,c,2*npoints);
closefile(f5);
t:=tbitmap.Create;
k:=16;
t.Width:=k*360;
t.Height:=k*180;
for e:=0 to npoints-1 do
if (area[n[e]]<5000000) or (level[n[e]]<>5) then
t.Canvas.Pixels[floor(k*(c[e].lo+180)),floor(k*(90-c[e].la))]:=clblack;
st:=fn+'_map_with_ice-ant.bmp';
t.SaveToFile(st);
end;





procedure TForm1.Button7Click(Sender: TObject);
begin
if pe.c1>0 then
   pe:=pach[pe.c1];
   updatememo;
end;





procedure TForm1.Button8Click(Sender: TObject);
begin
if pe.c2>0 then
   pe:=pach[pe.c2];
   updatememo;
end;





procedure TForm1.Button9Click(Sender: TObject);
begin
if pe.p>0 then
   pe:=pach[pe.p];
   updatememo;
end;





procedure TForm1.FormCreate(Sender: TObject);
var
e,i:integer;
//s:sph;
begin
fn:='D:\Vector maps\gshhg-2.3.7\gshhg-shp-2.3.7\GSHHS_shp\f\GSHHS_f_L';
decimalseparator:='.';
pt[0]:=1;
for e:=1 to 50 do
   pt[e]:=pt[e-1]*2;
r:=6371000;
//npoints:=10695480;
npoints:=10938831;           // with ice
for e:=0 to 7 do
   begin
   cu[e].x:=e div 4;
   cu[e].y:=(e div 2) mod 2;
   cu[e].z:=e mod 2;
   end;
eighttwo[0]:=0;
for e:=0 to 16 do
for i:=0 to pt[e]-1 do
   eighttwo[pt[e]+i]:=pt[e*3]+eighttwo[i];

{s.lo:=0;
s.la:=0;
form1.Label1.Caption:=floattostr(cts(stc(s)).lo)+'; '+floattostr(cts(stc(s)).la)+'                                            ';
form1.Label1.Refresh;}
end;

end.
