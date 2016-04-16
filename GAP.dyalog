:Namespace GAP

    :Section Initialise
      Init←{
          c←getCfg ⍬
          r←# fixFolder c.src
          c.map←Import c.src
          r←setEditorHooks c
          'Loaded "',c.name,'" [',c.version,']'
      }

      getCfg←{
          cfg←'./gap.json'
          ⎕NEXISTS cfg:j2a⊃read cfg
          c←⎕NS''
          c.name←'myApp'
          c.version←'0.0.0'
          c.lib←⍬
          c.src←'./src'
          r←(0 1 a2j c)write cfg
          c
      }

      setEditorHooks←{
          qed←'⎕SE'⎕WG'Editor'
          ⍵.(saltFix saltAfterFix)←qed.(onFix onAfterFix)
          qed.(onFix onAfterFix)←⊂'gapFix'⍵
          0
      }

      gapFix←{
          (editor event value space name new)←⍵
           ⎕SE'GAP'≡space new:
          '#'≢⍬⍴⍕space:(⍺.⍎'on',event) ⍵
          'AfterFix'≡event:
          d←⍺ getSpaceFolder space
          value write d,'/',(hash new),'.dyalog'
      }

      getSpaceFolder←{
      ⍝ ⍵ ←→ target ns
      ⍝ ⍺ ←→ cfg ns
      ⍝ ← path to fs folder
           ⎕IO←0 ⋄ ⎕ML←1
          df←⍕⍵
          e←⍵.(⎕IO ⎕ML ⎕WX ⎕CT ⎕PP)
          i←(⊣/⍺.map)⍳⊂df
          i=≢⍺.map:⍺ addMap ⍵ df e
          p1 e1←⍺.map[i;1 2]
          r←⍵ fixFolder⍣(e≡e1)⊢p1
          p1⊣⍺.map[i;2]←⊂e
     }

      addMap←{
      ⍝ ⍵ ←→ (target ns)(disp form)(ns props)
      ⍝ ⍺ ←→ cfg ns
          ns df e←⍵
          p←1↓df
          p←⊃,/'/',¨hash¨1↓¨('.'=p)⊂p
          p←⍺.src,'/',p
          ⍺.map⍪←df p e
          r←ns fixFolder p
          p
      }

    :EndSection

    :Section Export
      Export←{
    ⍝ ⍺ ←→ ns ref
    ⍝ ⍵ ←→ target fs folder
          ⍺←#
          r←⍺ fixFolder ⍵
          r←⍺ exportNC9 ⍵
          r←⍺ exportNC34 ⍵
          0
      }

      exportNC34←{
    ⍝ ⍺ ←→ root ns
    ⍝ ⍵ ←→ target fs folder
          fns←⍺.⎕NL-3.1 3.2 4.1 4.2
          0∊⍴fns:0
          src←⍺.⎕NR¨fns           
          hn←hash¨fns
          r←src write¨(⊂⍵,'/'),¨hn,¨⊂'.dyalog'
          0
      }

      exportNC9←{
    ⍝ ⍺ ←→ root ns
    ⍝ ⍵ ←→ target fs folder
          nss←⍺.⎕NL-9.1 9.4 9.5
          0∊⍴nss:0
          fpns←⍕¨nsrefs←⍺.⍎⍕nss
          src←ss¨nsrefs     ⍝ NOTE: deal with refs to tns
          smask←~tmask←src∊0
          r←Export/tmask⌿⍉↑nsrefs((⊂⍵,'/'),¨nss)
          ~∨/smask:r    ⍝ no scripts found
          hn←hash¨smask/nss
          r←(smask/src)write¨(⊂⍵,'/'),¨hn,¨⊂'.dyalog'
          0
      }

      fixFolder←{
    ⍝ ⍺ ←→ ns ref
    ⍝ ⍵ ←→ target fs folder
          m←⎕NS''
          m.(IO ML WX CT PP)←⍺.(⎕IO ⎕ML ⎕WX ⎕CT ⎕PP)
          m.name←{⍵↓⍨2×1<≢⍵}⍕⍺
          r←3 ⎕MKDIR ⍵
          r←(a2j m)write ⍵,'/ns.json'
          0
      }

    :EndSection ⍝ Export

    :Section Import
      Import←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ source fs folder
          ⎕ML←1
          ⍺←#
          m←j2a⊃read ⍵,'/ns.json'
          ns←⍎((⍕⍺),'.',m.name)⎕NS''
          ns.(⎕IO ⎕ML ⎕WX ⎕CT ⎕PP)←m.(IO ML WX CT PP)
          d f←{(↓1 2∘.=⊣/⍵)/¨⊂⊢/⍵}ls ⍵
          1∊x←ns powerFix⍣≡⊢f:∘∘∘
          map←⍉⍪(⍕ns)⍵ m.(IO ML WX CT PP)
          0∊⍴d:map
          map⍪⊃⍪/ns ∇¨d
      }
    :EndSection ⍝ Import

    :Section Tools
    ss←{16::0⋄⎕SRC ⍵}
    j2a←{7159⌶⍵}
    a2j←{⍺←0 ⋄ ⍺(7160⌶)⍵}

    write←{(⊂⍺)⎕NPUT ⍵ 1}
    read←{⎕NGET ⍵}

      ls←{
          ⎕ML←1
    ⍝ ⍵ ←→ filepath
    ⍝ ⍺ ←→ recurse flag
          ⍺←0
          r←⍉↑1 0 ⎕NINFO⍠1⊢⍵,'/*'
          ⍺=0:r
          ~∨/f←1=⊣/r:r
          r⍪⊃⍪/⍺ ∇¨f/⊢/r
      }

      fix←{
     ⍝ ⍵ ←→ file path
     ⍝ ⍺ ←→ target ns
          ⎕ML←1
          src←⊃read ⍵ 1
          11::1
          ':'=⊃⊃src:0⊣⍺.⎕FIX src
          0⊣⍺.⎕FX src
      }

      powerFix←{
          0∊⍴⍵:⍵
          r←⍺ fix¨⍵
          ⍵/⍨~r∊0
      }
      
      hash←{⎕IO←0                         
         0=n←2⊥⍵∊⎕A:⍵
          ⍵,'.',(⎕D,⎕A)⌷⍨⊂n←16⊥⍣¯1⊢n
      }

    :EndSection ⍝ Tools

:EndNamespace









