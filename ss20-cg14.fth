FCode-version2 ( start1 )

hex

" cgfourteen" device-name " display" device-type my-address

constant frame-buf-offset
\ 08 00
my-space 2 + constant frame-buf-space
my-args $number drop constant /frame
my-address constant video-io-offset
my-space constant video-io-space
10000 constant /video-io
video-io-offset video-io-space encode-phys /video-io encode-int encode+
frame-buf-offset frame-buf-space encode-phys /frame encode-int encode+
encode+ " reg" property 8 encode-int " interrupts" property 8
instance value mode
40 instance value blend-source
2 instance value vconfig
200 instance value sam-port-size
0 instance value mihdel
" clock-frequency" get-inherited-property if
   " Parent node does not have clock-frequency property" type
   " Using 40,000,000" type cr 2625a00
else
   drop @
then value mbus-freq
-1 instance value video-base-adr
: do-map-in
   " map-in" $call-parent
;
: do-map-out
   " map-out" $call-parent
;
: video-map
   video-io-offset video-io-space /video-io do-map-in to video-base-adr
;
: video-unmap
   video-base-adr /video-io do-map-out -1 to video-base-adr
;
: frame-buf-map
   frame-buf-offset frame-buf-space /frame do-map-in to frame-buffer-adr
;
: frame-buf-unmap
   frame-buffer-adr /frame do-map-out 0 to frame-buffer-adr
;
64abba8 instance value pixfreq
480 instance value hres
384 instance value vres
4c instance value vfreq
10 instance value hfporch
60 instance value hsync
d0 instance value hbporch
2 instance value vfporch
8 instance value vsync
21 instance value vbporch
0 instance value csc=hsc?
0 instance value vsync?
: set-mon-params
   to vfporch to hfporch to vbporch to hbporch to vsync to hsync to
   pixfreq to vfreq to vres to hres
;


external

: r1024x768x60    400 300 3c 3d27848  80 6  a0 1d 10 2 ;
: r1600x1280x76m  640 500 4c cdfe600  48 8 1b8 32  8 2 ;
: r1280x1024x76m  500 400 4c 80befc0  40 8 120 20 20 2 ;
: r1152x900x66    480 384 42 5a1f4a0  40 8 110 1b 28 2 ;
: r1152x900x76    480 384 4c 66ff300  40 8 104 21 1c 2 ;
: r1024x768x66    400 300 42 4323800  7c 5  a0 27  4 1 ;
: r1600x1280x66   640 500 42 bebc200 100 a 180 2c  0 0 ;
: r1280x1024x66   500 400 42 70a71c8  40 8 118 29 18 2 ;
: r1024x768x70    400 300 46 46cf710  88 6  88 20 10 2 ;
: r1920x1080x72   780 438 48 cdfe600  d8 3 178 56 30 3 ;

headers


: integer-attribute
   2dup get-my-property if
      rot encode-int 2swap property
   else
      2swap drop 2drop !
   then
;
: set-monitor-parameters
   0 to csc=hsc? 0 to vsync? case
   b of r1920x1080x72 -1 to csc=hsc? -1 to vsync? endof
   a of r1024x768x70 endof
   9 of r1280x1024x66 endof
   8 of r1600x1280x66 endof
   7 of r1152x900x66 endof
   6 of r1152x900x76 endof
   5 of r1024x768x60 endof
   4 of r1152x900x76 endof
   3 of r1152x900x66 endof
   2 of r1280x1024x76m endof
   1 of r1600x1280x76m endof
   0 of r1024x768x60 endof
   drop r1152x900x66 0
   endcase
   set-mon-params
;
: monitor-attributes
   mode " depth" integer-attribute mode hres * 8 / " linebytes"
   integer-attribute hres " width" integer-attribute vres " height"
   integer-attribute vfreq " vfreq" integer-attribute pixfreq " pixfreq"
   integer-attribute hfporch " hfporch" integer-attribute vfporch
   " vfporch" integer-attribute hsync " hsync" integer-attribute vsync
   " vsync" integer-attribute hbporch " hbporch" integer-attribute
   vbporch " vbporch" integer-attribute
;
: xlut!
   video-base-adr 3000 + + c!
;
: color!
   2 lshift video-base-adr 4000 + + l!
;
: color@
   2 lshift video-base-adr 4000 + + l@
;
: setcolor
   tuck color! blend-source swap xlut!
;
ffffff constant black
ff constant red
ff00 constant green
ffff constant yellow
ff0000 constant blue
ff00ff constant magenta
ffff00 constant cyan
h# 0 constant white
b44164 constant sun-blue
black instance value foregnd
white instance value backgnd
: init-fore/background
   backgnd 70 setcolor backgnd ff setcolor foregnd 0 setcolor foregnd 88
   setcolor
;
: set-color
   dup 0 = if
      over to foregnd
   then dup 70 = if
      over to backgnd
   then setcolor
;
: setcolors
   8 bounds ?do
      dup i set-color
   loop drop
;
: setcolors16
   100 swap ?do
      dup i set-color 10
   +loop drop
;
: setup-color-lookup
   black h# 0 setcolors red 10 setcolors green 20 setcolors yellow 30
   setcolors blue 40 setcolors magenta 50 setcolors cyan 60 setcolors
   white 70 setcolors black 88 setcolors16 cyan 89 setcolors16 magenta 8a
   setcolors16 blue 8b setcolors16 yellow 8c setcolors16 green 8d
   setcolors16 red 8e setcolors16 white 8f setcolors16
;
: init-color-map
   init-fore/background setup-color-lookup
;


external

-1 instance value toggle-colors?

headers


80 constant input-size


: mdi-c!
   video-base-adr + c!
;
: mdi-c@
   video-base-adr + c@
;
: mctl!
   0 mdi-c!
;
: mctl@
   0 mdi-c@
;
: old-mdi?
   6 mdi-c@ 4 rshift 0=
;
: ppr!
   1 mdi-c!
;
: ppr@
   1 mdi-c@
;
: mstat@
   4 mdi-c@
;
: mod@
   c mdi-c@
;
: mod!
   c mdi-c!
;
: timing!
   video-base-adr + w!
;
: monitor-sense@
   mstat@ e and 1 rshift
;
: vsclk
   pixfreq input-size / 2 * mode *
;
: mdi-hbs
   hfporch hsync + hbporch + hres + 4 / 1 - 0 max
;
: mdi-hbc
   hfporch hsync + hbporch + 4 / 1 - 0 max
;
: mdi-hsc
   hfporch hsync + 4 / 1 - 0 max
;
: mdi-hss
   hfporch 4 / 1 - 0 max
;
: mdi-csc
   hfporch hbporch + hres + 4 / 1 - 0 max
;
: mdi-vbs
   vfporch vsync + vbporch + vres + 1 - 0 max
;
: mdi-vbc
   vfporch vsync + vbporch + 1 - 0 max
;
: mdi-vsc
   vfporch vsync + 1 - 0 max
;
: mdi-vss
   vfporch 1 - 0 max
;
: mdi-xcs
   mdi-hbs pixfreq 8 * mbus-freq / - 1 - 0 max
;
: mdi-xcc
   mdi-hbc pixfreq 4 * mbus-freq / - 2 - 0 max
;
: sync-on
   mctl@ 1 or mctl! 1f4 ms
;
: sync-off
   mctl@ 1 invert and mctl!
;
: video-off
   mctl@ 40 invert and mctl!
;
: video-on
   mctl@ 41 or mctl!
;
: init-mdi
   case
   8 of h# 0 mctl! ppr! endof
   10 of 20 mctl! ff 0 do
         dup i xlut!
      loop drop endof
   20 of 30 mctl! ff 0 do
         dup i xlut!
      loop drop endof
   h# 0 mctl! ppr!
   endcase
   init-color-map mod@ f7 and mod! mdi-hbs 18 timing! mdi-hbc 1a timing!
   mdi-hss 1c timing! mdi-hsc 1e timing! mdi-csc 20 timing! mdi-vbs 22
   timing! mdi-vbc 24 timing! mdi-vss 26 timing! mdi-vsc 28 timing!
   old-mdi? if
      mdi-xcs 2a timing! mdi-xcc 2c timing!
   then csc=hsc? if
      mdi-hsc 20 timing!
   then vsync? if
      mod@ 8 or mod!
   then
;
: cg14-blink-screen
   video-off 20 ms video-on
;
create pcg-table
2d0fa50 , 0 , 337f980 , 1 , 3d27848 , 8 , 46cf710 , 9 , 5a1f4a0 , 2 ,
66ff300 , 3 , 70a71c8 , 4 , 80befc0 , 5 , b43e940 , 6 , cdfe600 , 7 , 2
cells constant /pcg-entry
: >pcg-regval
   pcg-table a 0 do
      dup @ 2 pick > if
         leave
      else
         /pcg-entry +
      then
   loop pcg-table 2dup = if
      /n + @ nip nip exit
   else
      drop
   then pcg-table /pcg-entry 9 * + 2dup > if
      /n + @ nip nip exit
   else
      drop
   then swap >r dup /pcg-entry - @ r@ swap - over @ r> - < if
      /pcg-entry -
   then /n + @
;
: pcg!
   video-base-adr 100 + c!
;
: init-pcg
   pixfreq >pcg-regval pcg!
;

create ics-47MHz
50 c, h# 0 c, h# 0 c, 20 c, 80 c, 10 c, h# 0 c, h# 0 c, 40 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-54MHz
40 c, h# 0 c, 20 c, 20 c, 80 c, 10 c, h# 0 c, h# 0 c, 40 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-64MHz
30 c, h# 0 c, 10 c, 20 c, 80 c, 10 c, h# 0 c, h# 0 c, 40 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-74MHz
50 c, h# 0 c, 30 c, 40 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-81MHz
60 c, h# 0 c, h# 0 c, 50 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-84MHz
30 c, h# 0 c, 10 c, 30 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-94MHz
20 c, h# 0 c, h# 0 c, 20 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-108MHz
30 c, h# 0 c, 20 c, 40 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-117MHz
20 c, h# 0 c, 20 c, 30 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-135MHz
30 c, h# 0 c, 40 c, 50 c, 80 c, 10 c, h# 0 c, h# 0 c, 60 c, a0 c, h# 0 c, 10 c, h# 0 c,
create ics-189MHz
20 c, h# 0 c, h# 0 c, 20 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, h# 0 c, h# 0 c,
create ics-216MHz
30 c, h# 0 c, 20 c, 40 c, 80 c, 10 c, h# 0 c, h# 0 c, 50 c, a0 c, h# 0 c, h# 0 c, h# 0 c,
create ics-freq-table
0 w, ics-47MHz , 2f w, ics-47MHz , 36 w, ics-54MHz , 40 w, ics-64MHz , 4a
w, ics-74MHz , 51 w, ics-81MHz , 5e w, ics-94MHz , 6c w, ics-108MHz , 75
w, ics-117MHz , 87 w, ics-135MHz , bd w, ics-189MHz , d8 w, ics-216MHz ,
-1 w,
: >ics-freq
   f4240 / ics-freq-table >r begin
      r@ <w@ -1 <>
   while
      dup r@ w@ r@ 6 + w@ within if
         drop r> /w + @ exit
      then r> 6 + >r
   repeat r> 2drop ics-freq-table /w + @
;
: ics!
   7 mdi-c!
;
: init-ics-new
   pixfreq >ics-freq 6 ics! d0 0 do
      i 4 or ics! dup c@ 6 or ics! 1 + 10
   +loop drop 20 0 do
      f4 ics! 6 ics!
   loop
;
: init-ics-old
   pixfreq >ics-freq 1 ics! d0 0 do
      i ics! dup c@ 1 or ics! 1 + 10
   +loop drop 20 0 do
      f0 ics! 1 ics!
   loop 3 ics!
;
: init-ics
   sync-off old-mdi? if
      init-ics-old
   else
      init-ics-new
   then 1f4 ms
;
: vbc!
   video-base-adr 200 + + l!
;
: vbc@
   video-base-adr 200 + + l@
;
: old-vbc?
   c vbc@ a rshift 3 and 0=
;
: video-base-reg!
   0 vbc!
;
: reload-control-reg!
   swap 9 lshift or 4 vbc!
;
: video-control-reg!
   400 or 8 vbc!
;
: init-vbc
   0 video-base-reg! old-vbc? if
      20 mihdel + vsclk * swap / - reload-control-reg!
   else
      2drop 2 lshift 1 or 4 vbc!
   then 251 video-control-reg!
;
: dac!
   video-base-adr 2000 + + c!
;
: dac@
   video-base-adr 2000 + + c@
;
: new-dac?
   b dac@ 8c <>
;
: mode!
   300 dac!
;
: addr!
   0 dac!
;
: palette!
   100 dac!
;
: control!
   addr! 200 dac!
;
: init-dac
   3 mode! 2 mode! 3 mode! 0 addr! 100 0 do
      i palette! 0 palette! i palette! 0 palette! i palette! 0 palette!
   loop new-dac? if
      5 5 control!
   then e0 6 control! 43 7 control!
;
: set-vsimm-parameters
   case
   200000 of 1 100 endof
   400000 of 2 200 endof
   800000 of 3 200 old-mdi? 0= if
         1 d mdi-c!
      then endof
   1000000 of 3 200 old-mdi? 0= if
         1 d mdi-c!
      then endof
   2 200
   endcase
   to sam-port-size to vconfig old-vbc? if
      sam-port-size encode-int " sam-port-size" property 0 f 20 memmap
      dup 4 + l@ 1c00 and 6 rshift to mihdel 20 free-virtual mihdel
      encode-int " mih-delay" property
   then
;
: set-mdi-mode
   to mode to blend-source
;
instance defer mem!
['] l! to mem! instance defer mem@
['] l@ to mem@ instance variable mem-mask
mem-mask on
: maskit
   mem-mask @ and
;
: show-status
   diagnostic-mode? if
      type
   else
      2drop
   then
;
0 instance value physmem-base
0 instance value mem-base
instance variable mem-address
instance variable mem-expected
instance variable mem-observed
: >membase
   mem-base - physmem-base +
;
: ??cr
   #out @ if
      cr
   then
;
: .lx
   base @ >r 10 base ! <# u# u# u# u# 2e hold u# u# u# u# u#> r> base !
   type bl emit
;
instance defer done?
" exit?" $find drop to done? instance variable failed
create error
: .mem-test-failure
   ??cr "  PA = " type mem-address @ >membase .lx "  Exp = " type
   mem-expected @ dup .lx "  Obs = " type mem-observed @ dup .lx
   "  Xor = " type xor .lx ??cr done? if
      error throw
   then
;
: ?failed
   2dup <> if
      mem-expected ! mem-observed ! failed on .mem-test-failure
   else
      2drop
   then
;
: mem-test
   dup mem-address ! mem@ maskit swap maskit ?failed
;
variable add-base
variable add-top
: address-line-test
   0 add-base @ mem! 0 add-top @ mem! 1 over lshift add-base @ over +
   ffffffff swap mem! add-top @ over - ffffffff swap mem! 0 add-base @
   mem-test 0 add-top @ mem-test ffffffff add-base @ mem! ffffffff
   add-top @ mem! add-base @ over + 0 swap mem! add-top @ over - 0 swap
   mem! ffffffff add-base @ mem-test ffffffff add-top @ mem-test 2drop
;
: log2
   -1 swap 20 0 do
      dup 80000000 and if
         nip 1f i - swap leave
      then 1 lshift
   loop drop
;
: mem-addr-test
   "     Address quick test" show-status failed off tuck bounds add-base
   ! /l - add-top ! log2 2 do
      i address-line-test
   loop failed @
;
: mem-size-test
   "     Data size test" show-status failed off 1234 over w! 5678 over
   wa1+ w! 12345678 over mem-test 12 over 0 ca+ c! 34 over 1 ca+ c! 56
   over 2 ca+ c! 78 over 3 ca+ c! 12345678 over mem-test drop failed @
;
: mem-data-test
   "     Data lines test" show-status failed off 20 0 do
      1 i lshift over mem! 1 i lshift over mem-test
   loop 20 0 do
      1 i lshift invert over mem! 1 i lshift invert over mem-test /l +
   loop drop failed @
;
: mem-bits-test
   "     Data bits test" show-status failed off bounds 2dup ?do
      ffffffff i 2dup mem! mem-test /l
   +loop ?do
      h# 0 i 2dup mem! mem-test /l
   +loop failed @
;
: address=data-test
   "     Address=data test" show-status bounds 2dup do
      i >membase i mem! /l
   +loop failed off do
      i >membase i mem-test /l
   +loop failed @
;
variable failed
: ?fail
   ?dup if
      failed @ max failed ! diagnostic-mode? if
         "  -- failed." type cr
      then
   else
      diagnostic-mode? if
         "  -- succeeded." type cr
      then
   then
;
: memory-test
   failed off over dup to mem-base >physical drop to physmem-base over
   ['] mem-data-test catch if
      drop -1
   then ?fail 2dup ['] mem-addr-test catch if
      2drop -1
   then ?fail over ['] mem-size-test catch if
      drop -1
   then ?fail diagnostic-mode? if
      2dup ['] mem-bits-test catch if
         2drop -1
      then ?fail 2dup ['] address=data-test catch if
         2drop -1
      then ?fail
   then 2drop failed @
;
200000 constant fb-test-size
: cg14-memory-test
   frame-buf-offset frame-buf-space fb-test-size ['] do-map-in catch if
      drop 2drop -1 exit
   then dup fb-test-size memory-test swap fb-test-size do-map-out
;
: cg14-selftest
   0 cg14-memory-test or
;
: compile-bytes
   rot 2dup + >r swap move r>
;


2b20 alloc-mem constant logo0-data
fload logo0-data.fth

2b20 alloc-mem constant logo1-data
fload logo1-data.fth

2b20 alloc-mem constant logo2-data
fload logo2-data.fth


0 constant prev-logo

create random-logo?
0 ,

: logo#
   random-logo? @ if
      prev-logo dup begin
         2dup =
      while
         drop get-msecs 4 / 3 and 3 mod
      repeat nip dup to prev-logo
   else
      prev-logo 3 and
   then
;


external

: random-logo
   random-logo? on logo# drop
;

: set-logo
   to prev-logo random-logo? off
;

headers


: logo-data
   logo0-data logo1-data logo2-data logo# pick nip nip nip
;
: set-default-font
   default-font set-font
;
: cg14-toggle-cursor
   fb8-toggle-cursor toggle-colors? if
      init-fore/background
   then
;
: slot#
   video-base-adr >physical drop 1a rshift f and
;
: disable-emc-slot-refresh
   0 f 4 memmap 1 slot# 2 + lshift invert over l@ and over l! 4
   free-virtual
;
: init-video-hw
   init-pcg init-ics disable-emc-slot-refresh vconfig sam-port-size
   mbus-freq init-vbc init-dac blend-source mode init-mdi
;
: cg14-reset-screen
   init-color-map sync-on video-on
;
: setup-logo-colors
   dup la1+ swap l@ /l* over + tuck swap do
      i l@ lbsplit >r 0 bljoin r> setcolor /l
   +loop
;
: ul@
   >r r@ c@ 8 lshift r@ 1 ca+ c@ + 8 lshift r@ 2 ca+ c@ + 8 lshift r> 3
   ca+ c@ +
;
: cg14-draw-logo
   2 pick 92 + ul@ bfdfdfe7 <> if
      " oem-logo-color" get-my-property if
         sun-blue
      else
         decode-int nip nip
      then 1 color! fb8-draw-logo
   else
      drop 2drop logo-data setup-logo-colors swap >r dup l@ swap la1+ dup
      l@ swap 2 la+ r> char-height * window-top + hres * window-left +
      frame-buffer-adr + rot 0 do
         2 pick 2 pick 2 pick rot move >r over + r> hres +
      loop drop 2drop
   then
;
: (do-my-args)
   my-args ?dup 0= if
      drop exit
   then begin
      2c left-parse-string ?dup
   while
      2swap >r >r depth 2 - >r my-self ['] $call-method catch if
         drop 2drop
      else
         depth r@ - a = if
            set-mon-params
         then
      then r> drop r> r>
   repeat drop 2drop -1 throw
;
: do-my-args
   ['] (do-my-args) catch drop
;
: do-init
   monitor-attributes init-video-hw set-default-font hres vres hres
   char-width / vres char-height / fb8-install ['] cg14-draw-logo to
   draw-logo ['] cg14-toggle-cursor to toggle-cursor [']
   cg14-blink-screen to blink-screen ['] cg14-reset-screen to
   reset-screen
;


external

: do-mode-switch
   set-monitor-parameters do-init video-on
;

headers


: cg14-install
   frame-buf-map video-map monitor-sense@ set-monitor-parameters
   do-my-args video-off video-base-adr encode-int frame-buffer-adr
   encode-int encode+ " address" property do-init
;
: cg14-remove
   video-off video-unmap frame-buf-unmap " address" delete-property
;
: cg14-probe
   video-map 40 8 set-mdi-mode /frame set-vsimm-parameters [']
   cg14-install is-install ['] cg14-remove is-remove ['] cg14-selftest
   is-selftest monitor-sense@ set-monitor-parameters monitor-attributes
   video-off init-video-hw video-unmap -1 to frame-buffer-adr
;


external

: vsync -1 to vsync? ;
: hdtv  -1 to csc=hsc? ;

headers


: bits
   >r dup 20 r@ - tuck lshift swap rshift swap r> rshift swap
;
: 1ms
   1 ms
;
: send-bit
   dup 1 lshift 0 or mod! 1ms 1 lshift 1 or mod! 1ms
;
: get-bit
   mod@ 2 rshift 1 and
;


external

: send-byte
   0 swap ff xor 8 0 do
      1 bits send-bit swap get-bit i lshift or swap
   loop drop ff xor
;

headers


cg14-probe

end0
