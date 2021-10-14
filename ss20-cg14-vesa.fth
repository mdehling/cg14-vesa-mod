\
\ CG14 FCode extracted from SPARCstation 20 v2.25(r) OBP PROM.
\
\ Detokenized, formatted and (very lightly) commented by
\ Malte Dehling <mdehling@gmail.com>
\
FCode-version2 ( start1 )

hex

" cgfourteen"	device-name
" display"	device-type

my-address		constant frame-buf-offset
my-space 2 +		constant frame-buf-space
my-args $number drop	constant /frame

my-address		constant video-io-offset
my-space		constant video-io-space
10000			constant /video-io

video-io-offset  video-io-space  encode-phys /video-io encode-int encode+
frame-buf-offset frame-buf-space encode-phys /frame    encode-int encode+
encode+ " reg" property
8 encode-int " interrupts" property

8	instance value mode
40	instance value blend-source
2	instance value vconfig
200	instance value sam-port-size
0	instance value mihdel

" clock-frequency" get-inherited-property if
	" Parent node does not have clock-frequency property" type
	" Using 40,000,000" type
	cr
	d# 40.000.000
else
	drop @
then
( mbus-freq )	value mbus-freq


-1	instance value video-base-adr

: do-map-in  ( addr space size -- virt )  " map-in"  $call-parent ;
: do-map-out ( virt size -- )             " map-out" $call-parent ;

: video-map ( -- )
	video-io-offset video-io-space /video-io do-map-in
	to video-base-adr
;

: video-unmap ( -- )
	video-base-adr /video-io do-map-out
	-1 to video-base-adr
;

: frame-buf-map ( -- )
	frame-buf-offset frame-buf-space /frame do-map-in
	to frame-buffer-adr
;

: frame-buf-unmap ( -- )
	frame-buffer-adr /frame do-map-out
	0 to frame-buffer-adr
;


decimal
105.561.000	instance value pixfreq
1152		instance value hres
900		instance value vres
76		instance value vfreq
16		instance value hfporch
96		instance value hsync
208		instance value hbporch
2		instance value vfporch
8		instance value vsync
33		instance value vbporch
0		instance value csc=hsc?
0		instance value vsync?
hex


: set-mon-params ( hres vres vfreq pixfreq hsync vsync hbporch vbporch hfporch vfporch -- )
	to vfporch  to hfporch
	to vbporch  to hbporch
	to vsync    to hsync
	to pixfreq
	to vfreq
	to vres     to hres
;


external

decimal		\ hres vres vfreq    pfreq  hs vs hbp vbp hfp vfp
: r1024x768x60    1024  768 60  64.125.000 128  6 160  29  16   2 ;
: r1024x768x66    1024  768 66  70.400.000 124  5 160  39   4   1 ;
: r1024x768x70    1024  768 70  74.250.000 136  6 136  32  16   2 ;
: r1152x900x66    1152  900 66  94.500.000  64  8 272  27  40   2 ;
: r1152x900x76    1152  900 76 108.000.000  64  8 260  33  28   2 ;
: r1280x1024x60   1280 1024 60 108.000.000 112  3 248  38  48   1 ;
: r1280x1024x66   1280 1024 66 118.125.000  64  8 280  41  24   2 ;
: r1280x1024x76m  1280 1024 76 135.000.000  64  8 288  32  32   2 ;
: r1600x1200x60   1600 1200 60 162.000.000 192  3 304  46  64   1 ;
: r1600x1280x66   1600 1280 66 200.000.000 256 10 384  44   0   0 ;
: r1600x1280x76m  1600 1280 76 216.000.000  72  8 440  50   8   2 ;
: r1920x1080x72   1920 1080 72 216.000.000 216  3 376  86  48   3 ;
: r1920x1200x60   1920 1200 60 193.000.000 200  6 336  36 136   3 ;
hex

headers


\
\ Define or update integer-value attribute.
\
\ Uses:
\ get-my-property ( name-adr name-len -- true | value-adr value-len false )
\
: integer-attribute ( int name-adr name-len -- )
	2dup			( int name-adr name-len name-adr name-len )
	get-my-property
	if			( int name-adr name-len )
		rot		( name-adr name-len int )
		encode-int	( name-adr name-len xdr-adr xdr-len )
		2swap		( xdr-adr xdr-len name-adr name-len )
		property	( -- )
	else			( int name-adr name-len val-adr val-len )
		2swap		( int val-adr val-len name-adr name-len )
		drop 2drop	( int val-adr )
		!		( -- )
	then
;

: set-monitor-parameters ( sense -- )
	0 to csc=hsc?
	0 to vsync?

	case
	b of  r1920x1080x72  -1 to csc=hsc?  -1 to vsync?  endof
	a of  r1024x768x70    endof
	9 of  r1280x1024x66   endof
	8 of  r1600x1280x66   endof
	7 of  r1152x900x66    endof
	6 of  r1152x900x76    endof
	5 of  r1024x768x60    endof
	4 of  r1152x900x76    endof
	3 of  r1152x900x66    endof
	2 of  r1280x1024x76m  endof
	1 of  r1600x1280x76m  endof
	0 of  r1024x768x60    endof
	drop  r1152x900x66    0
	endcase

	set-mon-params
;

: monitor-attributes ( -- )
	mode            " depth"     integer-attribute
	mode hres * 8 / " linebytes" integer-attribute
	hres            " width"     integer-attribute
	vres            " height"    integer-attribute
	vfreq           " vfreq"     integer-attribute
	pixfreq         " pixfreq"   integer-attribute
	hfporch         " hfporch"   integer-attribute
	vfporch         " vfporch"   integer-attribute
	hsync           " hsync"     integer-attribute
	vsync           " vsync"     integer-attribute
	hbporch         " hbporch"   integer-attribute
	vbporch         " vbporch"   integer-attribute
;


: xlut!  ( val idx -- )  video-base-adr 3000 + + c! ;
: color! ( val idx -- )  2 lshift video-base-adr 4000 + + l! ;
: color@ ( idx -- val )  2 lshift video-base-adr 4000 + + l@ ;

: setcolor ( val idx -- )
	tuck				( idx val idx )
	color!				( idx )
	blend-source swap xlut!		( -- )
;


\ Colors in bb.gg.rr .
ff.ff.ff constant black
00.00.ff constant red
00.ff.00 constant green
00.ff.ff constant yellow
ff.00.00 constant blue
ff.00.ff constant magenta
ff.ff.00 constant cyan
00.00.00 constant white
b4.41.64 constant sun-blue


black instance value foregnd
white instance value backgnd


: init-fore/background ( -- )
	backgnd 70 setcolor  backgnd ff setcolor
	foregnd  0 setcolor  foregnd 88 setcolor
;


: set-color ( val idx -- )
	dup 0 = if
		over			( val idx val )
		( val ) to foregnd	( val idx )
	then

	dup 70 = if
		over			( val idx val )
		( val ) to backgnd	( val idx )
	then

	( val idx ) setcolor		( -- )
;


: setcolors ( val idx -- )
	8 bounds ?do
		dup i set-color
	loop

	drop
;


: setcolors16 ( val idx -- )
	100 swap ?do
		dup i set-color 10
	+loop

	drop
;


: setup-color-lookup ( -- )
	black   00 setcolors
	red     10 setcolors
	green   20 setcolors
	yellow  30 setcolors
	blue    40 setcolors
	magenta 50 setcolors
	cyan    60 setcolors
	white   70 setcolors

	black   88 setcolors16
	cyan    89 setcolors16
	magenta 8a setcolors16
	blue    8b setcolors16
	yellow  8c setcolors16
	green   8d setcolors16
	red     8e setcolors16
	white   8f setcolors16
;


: init-color-map ( -- )
	init-fore/background
	setup-color-lookup
;


external

-1 instance	value toggle-colors?

headers


80		constant input-size


: mdi-c! ( value offset -- )  video-base-adr + c! ;
: mdi-c@ ( offset -- value )  video-base-adr + c@ ;

: mctl! ( value -- )  0 mdi-c! ;
: mctl@ ( -- value )  0 mdi-c@ ;

: old-mdi? ( -- flag )  6 mdi-c@ 4 rshift 0= ;

: ppr! ( value -- )  1 mdi-c! ;
: ppr@ ( -- value )  1 mdi-c@ ;

: mstat@ ( -- value )  4 mdi-c@ ;

: mod@ ( value -- )  c mdi-c@ ;
: mod! ( -- value )  c mdi-c! ;

: timing! ( value offset -- )  video-base-adr + w! ;

: monitor-sense@ ( -- sense )  mstat@ e and 1 rshift ;

: vsclk ( -- vsclk )  pixfreq input-size / 2 * mode * ;

: mdi-hbs ( -- hbs )  hfporch hsync + hbporch + hres + 4 / 1 - 0 max ;
: mdi-hbc ( -- hbc )  hfporch hsync + hbporch + 4 / 1 -        0 max ;
: mdi-hsc ( -- hsc )  hfporch hsync + 4 / 1 -                  0 max ;
: mdi-hss ( -- hss )  hfporch 4 / 1 -                          0 max ;

: mdi-csc ( -- csc )  hfporch hbporch + hres + 4 / 1 -         0 max ;

: mdi-vbs ( -- vbs )  vfporch vsync + vbporch + vres + 1 -     0 max ;
: mdi-vbc ( -- vbc )  vfporch vsync + vbporch + 1 -            0 max ;
: mdi-vsc ( -- vsc )  vfporch vsync + 1 -                      0 max ;
: mdi-vss ( -- vss )  vfporch 1 -                              0 max ;

: mdi-xcs ( -- xcs )  mdi-hbs pixfreq 8 * mbus-freq / - 1 -    0 max ;
: mdi-xcc ( -- xcc )  mdi-hbc pixfreq 4 * mbus-freq / - 2 -    0 max ;

: sync-on  ( -- ) mctl@ 1 or mctl! 1f4 ms ;
: sync-off ( -- ) mctl@ 1 invert and mctl! ;

: video-off ( -- ) mctl@ 40 invert and mctl! ;
: video-on  ( -- ) mctl@ 41 or mctl! ;


: init-mdi ( bsrc mode -- )
	( mode ) case				( bsrc )
	08 of  00 mctl! ppr! endof
	10 of  20 mctl! ff 0 do dup i xlut! loop drop endof
	20 of  30 mctl! ff 0 do dup i xlut! loop drop endof
	       00 mctl! ppr!
	endcase					( -- )

	init-color-map

	mod@ f7 and mod!

	mdi-hbs 18 timing!  mdi-hbc 1a timing!  mdi-hss 1c timing!
	mdi-hsc 1e timing!  mdi-csc 20 timing!  mdi-vbs 22 timing!
	mdi-vbc 24 timing!  mdi-vss 26 timing!  mdi-vsc 28 timing!

	old-mdi? if
		mdi-xcs 2a timing!  mdi-xcc 2c timing!
	then

	csc=hsc? if
		mdi-hsc 20 timing!
	then

	vsync? if
		mod@ 8 or mod!
	then
;


: cg14-blink-screen ( -- )  video-off 20 ms video-on ;


decimal

create pcg-table
 47.250.000 , 0 ,
 54.000.000 , 1 ,
 64.125.000 , 8 ,
 74.250.000 , 9 ,
 94.500.000 , 2 ,
108.000.000 , 3 ,
118.125.000 , 4 ,
135.000.000 , 5 ,
189.000.000 , 6 ,
216.000.000 , 7 ,
2 cells constant /pcg-entry

hex


: >pcg-regval ( -?- )
	pcg-table

	a 0 do
		dup @

		2 pick > if
			leave
		else
			/pcg-entry +
		then
	loop

	pcg-table

	2dup = if
		/n + @
		nip nip
		exit
	else
		drop
	then

	pcg-table /pcg-entry 9 * +

	2dup > if
		/n + @
		nip nip
		exit
	else
		drop
	then

	swap >r dup /pcg-entry - @ r@ swap - over @ r> - < if
		/pcg-entry -
	then

	/n + @
;


: pcg! ( value -- )  video-base-adr 100 + c! ;

: init-pcg ( -- )  pixfreq >pcg-regval pcg! ;


\
\ These look suspiciously like the register values for an ICS1562, the same
\ _User Programmable Differential Output Graphcis Clock Generator_ that is used
\ in the SPARCstation LX and the TurboGX+ SBUS card.  The values here are the
\ same as those for the ics47, ics54, etc. words in the LX but in reverse order
\ and shifted by 4 bits.  For additional information, see my explanations at
\ https://github.com/1k5/sslx-vesa-mod or the ICS1562 datasheet.
\
\ create ics-47MHz
\ 50 c, 0 c, 0 c, 20 c, 80 c, 10 c, 0 c, 0 c, 40 c, a0 c, 0 c, 10 c, 0 c,
\ create ics-54MHz
\ 40 c, 0 c, 20 c, 20 c, 80 c, 10 c, 0 c, 0 c, 40 c, a0 c, 0 c, 10 c, 0 c,
create ics-64MHz
30 c, 0 c, 10 c, 20 c, 80 c, 10 c, 0 c, 0 c, 40 c, a0 c, 0 c, 10 c, 0 c,
create ics-74MHz
50 c, 0 c, 30 c, 40 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-81MHz
60 c, 0 c, 0 c, 50 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-84MHz
30 c, 0 c, 10 c, 30 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-94MHz
20 c, 0 c, 0 c, 20 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-108MHz
30 c, 0 c, 20 c, 40 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-117MHz
20 c, 0 c, 20 c, 30 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 10 c, 0 c,
create ics-135MHz
30 c, 0 c, 40 c, 50 c, 80 c, 10 c, 0 c, 0 c, 60 c, a0 c, 0 c, 10 c, 0 c,
create ics-162MHz
70 c, 0 c, 60 c, 60 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 0 c, 0 c,
create ics-189MHz
20 c, 0 c, 0 c, 20 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 0 c, 0 c,
create ics-193MHz
a0 c, 10 c, 10 c, f0 c, 90 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 0 c, 0 c,
create ics-216MHz
30 c, 0 c, 20 c, 40 c, 80 c, 10 c, 0 c, 0 c, 50 c, a0 c, 0 c, 0 c, 0 c,


decimal

create ics-freq-table
  0 w, ics-64MHz ,
\  0 w, ics-47MHz ,
\ 47 w, ics-47MHz ,
\ 54 w, ics-54MHz ,
 64 w, ics-64MHz ,
 74 w, ics-74MHz ,
 81 w, ics-81MHz ,
 84 w, ics-84MHz ,
 94 w, ics-94MHz ,
108 w, ics-108MHz ,
117 w, ics-117MHz ,
135 w, ics-135MHz ,
162 w, ics-162MHz ,
189 w, ics-189MHz ,
193 w, ics-193MHz ,
216 w, ics-216MHz ,
 -1 w,

hex


\
\ Returns address of the appropriate ics-word in the ics-freq-table above.
\
\ For f[i] <= f < f[i+1], the selected word is ics-word[i], e.g., for 192 the
\ word ics-189MHz is selected.
\
: >ics-freq ( pixfreq -- ics-word )
	d# 1.000.000 /			( f )
	ics-freq-table >r		( f )			( rs: addr )

	begin
		r@ <w@			( f [addr] )		( rs: addr )
		-1 <>			( f [addr]<>-1 )	( rs: addr )
	while
		dup r@ w@		( f f [addr] )		( rs: addr )
		r@ 6 + w@		( f f [addr] [addr+6] )	( rs: addr )
		within if		( f )			( rs: addr )
			drop		( -- )			( rs: addr )
			r> /w + @	( [addr+2] )		( rs: -- )
			exit
		then
		r> 6 + >r		( f )			( rs: addr+6 )
	repeat

	r> 2drop			( -- )			( rs: -- )

	ics-freq-table /w + @		( [ics-freq-table+2] )	( rs: -- )
;


: ics! ( -- )  7 mdi-c! ;


: init-ics-new ( -- )
	pixfreq >ics-freq

	6 ics!

	d0 0 do
		i 4 or ics!
		dup
		c@ 6 or ics!
		1 +
	10 +loop

	drop

	20 0 do
		f4 ics! 6 ics!
	loop
;


: init-ics-old ( -- )
	pixfreq >ics-freq

	1 ics!

	d0 0 do
		i ics!
		dup
		c@ 1 or ics!
		1 +
	10 +loop

	drop

	20 0 do
		f0 ics! 1 ics!
	loop

	3 ics!
;


: init-ics ( -- )
	sync-off

	old-mdi? if
		init-ics-old
	else
		init-ics-new
	then

	1f4 ms
;


: vbc! ( value offset -- )  video-base-adr 200 + + l! ;
: vbc@ ( offset -- value )  video-base-adr 200 + + l@ ;

: old-vbc? ( -- flag )  c vbc@ a rshift 3 and 0= ;

: video-base-reg! ( value -- )  0 vbc! ;

: reload-control-reg! ( n1 n2 -- )  swap 9 lshift or 4 vbc! ;
: video-control-reg! ( n1 )  400 or 8 vbc! ;


: init-vbc ( conf size freq -- )
	0 video-base-reg!

	old-vbc? if
		20 mihdel +		( conf size freq z1 )
		vsclk *			( conf size freq z2 )
		swap / -		( conf size-z2/freq )
		reload-control-reg!	( -- )
	else
		2drop			( conf )
		2 lshift 1 or		( z )
		4 vbc!			( -- )
	then

	251 video-control-reg!
;


: dac! ( value offset -- )  video-base-adr 2000 + + c! ;
: dac@ ( offset -- value )  video-base-adr 2000 + + c@ ;

: new-dac? ( -- flag )  b dac@ 8c <> ;

: mode! ( value -- )  300 dac! ;

: addr! ( value -- )  0 dac! ;

: palette! ( value -- )  100 dac! ;

: control! ( val1 val2 -- )  addr! 200 dac! ;


: init-dac ( -- )
	3 mode! 2 mode! 3 mode! 0 addr!

	100 0 do
		i palette!  0 palette!
		i palette!  0 palette!
		i palette!  0 palette!
	loop

	new-dac? if
		5 5 control!
	then

	e0 6 control!  43 7 control!
;


: set-vsimm-parameters ( frame -- )
	( frame ) case
	 20.0000 of  1 100  endof
	 40.0000 of  2 200  endof
	 80.0000 of  3 200  old-mdi? 0= if 1 d mdi-c! then endof
	100.0000 of  3 200  old-mdi? 0= if 1 d mdi-c! then endof
	             2 200
	endcase				( conf size )

	to sam-port-size		( conf )
	to vconfig			( -- )

	old-vbc? if
		sam-port-size encode-int " sam-port-size" property

		0 f 20 memmap		( virt )
		dup 4 + l@		( virt val )
		1c00 and 6 rshift to mihdel
					( virt)
		20 free-virtual		( -- )

		mihdel encode-int " mih-delay" property
	then
;


: set-mdi-mode ( mode bs -- )  to mode to blend-source ;


instance defer mem!
['] l! to mem!

instance defer mem@
['] l@ to mem@

instance variable mem-mask
mem-mask on

: maskit ( ? )  mem-mask @ and ;


: show-status ( msg-adr msg-len -- )
   diagnostic-mode? if
      type
   else
      2drop
   then
;


0	instance value physmem-base
0	instance value mem-base

instance variable mem-address
instance variable mem-expected
instance variable mem-observed


: >membase ( adr -- phys-adr )  mem-base - physmem-base + ;

: ??cr ( ? ) #out @ if cr then ;

: .lx ( ? )
	base @ >r 10 base ! <# u# u# u# u# 2e hold u# u# u# u# u#> r> base !
	type
	bl emit
;


instance defer done?
" exit?" $find drop to done?

instance variable failed
create error


: .mem-test-failure
	??cr
	"  PA = " type mem-address @ >membase .lx
	"  Exp = " type mem-expected @ dup .lx
	"  Obs = " type mem-observed @ dup .lx
	"  Xor = " type xor .lx
	??cr

	done? if
		error throw
	then
;


: ?failed
	2dup <> if
		mem-expected !
		mem-observed !
		failed on .mem-test-failure
	else
		2drop
	then
;


: mem-test
	dup
	mem-address !
	mem@ maskit swap maskit
	?failed
;


variable add-base
variable add-top


: address-line-test
	0 add-base @ mem!
	0 add-top @ mem!
	1 over lshift add-base @ over + ffffffff swap mem!
	add-top @ over - ffff.ffff swap mem!
	0 add-base @ mem-test 0 add-top @ mem-test ffff.ffff add-base @ mem!
	ffff.ffff add-top @ mem!
	add-base @ over + 0 swap mem!
	add-top @ over - 0 swap mem!
	ffff.ffff add-base @ mem-test ffffffff add-top @ mem-test 2drop
;


: log2
	-1 swap

	20 0 do
		dup 8000.0000 and if
			nip 1f i -
			swap leave
		then
		1 lshift
	loop

	drop
;


: mem-addr-test
	"     Address quick test" show-status

	failed off

	tuck
	bounds add-base !
	/l - add-top !

	log2 2 do
		i address-line-test
	loop

	failed @
;


: mem-size-test
	"     Data size test" show-status

	failed off

	1234 over w! 5678 over wa1+ w!
	12345678 over mem-test
	12 over 0 ca+ c! 34 over 1 ca+ c! 56 over 2 ca+ c! 78 over 3 ca+ c!
	12345678 over mem-test

	drop

	failed @
;


: mem-data-test
	"     Data lines test" show-status

	failed off

	20 0 do
		1 i lshift over mem!
		1 i lshift over mem-test
	loop

	20 0 do
		1 i lshift invert over mem!
		1 i lshift invert over mem-test /l +
	loop

	drop

	failed @
;


: mem-bits-test
	"     Data bits test" show-status

	failed off

	bounds 2dup ?do
		ffff.ffff i 2dup mem! mem-test
	/l +loop

	( bounds ) ?do
		0000.0000 i 2dup mem! mem-test
	/l +loop

	failed @
;


: address=data-test
	"     Address=data test" show-status

	bounds 2dup do
		i >membase i mem!
	/l +loop

	failed off

	( bounds ) do
		i >membase i mem-test
	/l +loop

	failed @
;


variable failed


: ?fail
	?dup if
		failed @
		max failed !

		diagnostic-mode? if
			"  -- failed." type cr
		then
	else
		diagnostic-mode? if
			"  -- succeeded." type cr
		then
	then
;


: memory-test
	failed off

	over dup to mem-base
	>physical
	drop to physmem-base

	over

	['] mem-data-test catch if
		drop -1
	then

	?fail 2dup

	['] mem-addr-test catch if
		2drop -1
	then

	?fail over

	['] mem-size-test catch if
		drop -1
	then

	?fail diagnostic-mode? if
		2dup
		['] mem-bits-test catch if
			2drop -1
		then

		?fail

		2dup
		['] address=data-test catch if
			2drop -1
		then
		?fail
	then

	2drop

	failed @
;


200000 constant fb-test-size


: cg14-memory-test
	frame-buf-offset frame-buf-space fb-test-size

	['] do-map-in catch if
		drop 2drop -1 exit
	then

	dup
	fb-test-size
	memory-test
	swap
	fb-test-size
	do-map-out
;


: cg14-selftest ( ? )  0 cg14-memory-test or ;


: compile-bytes ( ? )  rot 2dup + >r swap move r> ;


2b20 alloc-mem constant logo0-data
fload logo0-data.fth

2b20 alloc-mem constant logo1-data
fload logo1-data.fth

2b20 alloc-mem constant logo2-data
fload logo2-data.fth


0 constant prev-logo

create random-logo?
0 ,


: logo# ( -- n )
	random-logo? @ if
		prev-logo dup begin
			2dup =
		while
			drop get-msecs 4 / 3 and 3 mod
		repeat

		nip dup to prev-logo
	else
		prev-logo 3 and
	then
;


external

: random-logo ( -- )  random-logo? on logo# drop ;

: set-logo ( n -- )  to prev-logo random-logo? off ;

headers


: logo-data ( -- logoi-data )
	logo0-data logo1-data logo2-data logo# pick nip nip nip
;


: set-default-font ( -- )
	default-font set-font
;


: cg14-toggle-cursor
	fb8-toggle-cursor

	toggle-colors? if
		init-fore/background
	then
;


: slot# ( -- n )  video-base-adr >physical drop 1a rshift f and ;


: disable-emc-slot-refresh ( -- )
	0 f 4 memmap			( virt )
	1 slot# 2 + lshift invert	( virt x )
	over l@ and			( virt y )
	over l!				( virt )
	4 free-virtual			( -- )
;


: init-video-hw ( -- )
	init-pcg
	init-ics

	disable-emc-slot-refresh

	vconfig sam-port-size mbus-freq init-vbc
	init-dac
	blend-source mode init-mdi
;


: cg14-reset-screen
	init-color-map
	sync-on
	video-on
;


: setup-logo-colors
	dup la1+ swap l@ /l* over + tuck swap do
		i l@ lbsplit
		>r 0 bljoin
		r> setcolor
	/l +loop
;


: ul@
	>r r@
	c@ 8 lshift r@
	1 ca+ c@ + 8 lshift r@
	2 ca+ c@ + 8 lshift r>
	3 ca+ c@ +
;


: cg14-draw-logo
	2 pick 92 + ul@ bfdfdfe7 <> if
		" oem-logo-color" get-my-property if
			sun-blue
		else
			decode-int nip nip
		then

		1 color!

		fb8-draw-logo
	else
		drop 2drop

		logo-data
		setup-logo-colors

		swap >r dup l@ swap la1+ dup l@ swap 2 la+ r> char-height * window-top + hres * window-left + frame-buffer-adr +

		rot 0 do
			2 pick 2 pick 2 pick rot move >r over + r> hres +
		loop

		drop 2drop
	then
;


: (do-my-args)
	my-args ?dup 0= if
		drop exit
	then

	begin
		2c left-parse-string ?dup
	while
		2swap >r >r
		depth 2 - >r
		my-self
		['] $call-method catch if
			drop 2drop
		else
			depth r@ - a = if
				set-mon-params
			then
		then
		r> drop r> r>
	repeat

	drop 2drop -1 throw
;


: do-my-args  ['] (do-my-args) catch drop ;

: do-init ( -- )
	monitor-attributes
	init-video-hw
	set-default-font
	hres vres hres char-width / vres char-height / fb8-install

	['] cg14-draw-logo to draw-logo
	['] cg14-toggle-cursor to toggle-cursor
	['] cg14-blink-screen to blink-screen
	['] cg14-reset-screen to reset-screen
;


external

: do-mode-switch ( sense -- )  set-monitor-parameters do-init video-on ;

headers


: cg14-install ( -- )
	frame-buf-map
	video-map

	monitor-sense@ set-monitor-parameters

	do-my-args
	video-off

	video-base-adr encode-int
	frame-buffer-adr encode-int encode+ " address" property

	do-init
;

 
: cg14-remove ( -- )
	video-off
	video-unmap
	frame-buf-unmap

	" address" delete-property
;


: cg14-probe ( -- )
	video-map

	40 8 set-mdi-mode

	/frame set-vsimm-parameters

	['] cg14-install is-install
	['] cg14-remove is-remove
	['] cg14-selftest is-selftest

	monitor-sense@ set-monitor-parameters

	monitor-attributes
	video-off

	init-video-hw
	video-unmap

	-1 to frame-buffer-adr
;


external

: vsync  -1 to vsync? ;
: hdtv   -1 to csc=hsc? ;

headers


: bits
	>r dup 20 r@ - tuck lshift swap rshift swap r> rshift swap
;

: 1ms  1 ms ;

: send-bit  dup 1 lshift 0 or mod! 1ms 1 lshift 1 or mod! 1ms ;

: get-bit  mod@ 2 rshift 1 and ;


external

: send-byte
	0 swap ff xor

	8 0 do
		1 bits send-bit swap get-bit i lshift or swap
	loop

	drop

	ff xor
;

headers


cg14-probe

end0
