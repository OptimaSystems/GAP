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
          ⎕←'Initialising new GAP project.'
          c←⎕NS''
          c.name←'MyApp'ask'Project name'
          c.version←'0.0.0'ask'Version'
          c.src←'./src'ask'Source folder'
          c.lib←⍬
          r←(0 1 a2j c)write cfg
          c
      }

      ask←{
          ⎕←⍵,' (',⍺,')...'
          ans←{⍵/⍨~(∧\⌽b)∨∧\b←' '=⍵}⍞
          0∊⍴ans:⍺
          ans
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
          '#'≢⍬⍴⍕space:(⍺.⍎'on',event)⍵
          'AfterFix'≡event:
          d←⍺ getSpaceFolder space
          value write d,'/',(fsenc new),'.dyalog'
      }

      getSpaceFolder←{
      ⍝ ⍵ ←→ target ns
      ⍝ ⍺ ←→ cfg ns
      ⍝ ← path to fs folder
          ⎕IO←0 ⋄ ⎕ML←1
          df←⍕⍵
          i←(⊣/⍺.map)⍳⊂df
          i=≢⍺.map:⍺ addMap ⍵ df
          ⍵ fixFolder i⊃⊢/⍺.map
      }

      addMap←{
      ⍝ ⍵ ←→ (target ns)(disp form)
      ⍝ ⍺ ←→ cfg ns
          ns df←⍵
          p←1↓df
          p←⊃,/'/',¨fsenc¨1↓¨('.'=p)⊂p
          p←⍺.src,'/',p
          ⍺.map⍪←df p
          ns fixFolder p
      }

    :EndSection

    :Section Export
      Export←{
    ⍝ ⍺ ←→ ns ref
    ⍝ ⍵ ←→ target fs folder
          ⍺←#
          r←⍺ fixFolder ⍵
          r←⍺ exportNC9 ⍵
          r←⍺ exportNC33 ⍵
          r←⍺ exportNC34 ⍵
          r←⍺ exportNC2 ⍵
          0
      }

      exportNC2←{
    ⍝ ⍺ ←→ root ns
    ⍝ ⍵ ←→ target fs folder
          nms←⍺.⎕NL-2.1
          0∊⍴nms:0
          src←a2ason¨⍺.⍎¨nms
          hn←fsenc¨nms
          r←src write¨(⊂⍵,'/'),¨hn,¨⊂'.ason'
          0
      }

      exportNC33←{
          fns←⍺.⎕NL-3.3
          0∊⍴fns:0
          src←⍺.⎕OR¨fns
          dis←↓¨⎕SE.Dyalog.Utils.disp¨⍺.⎕CR¨fns
          hn←fsenc¨fns
          r←src writeDerv¨(⊂⍵,'/'),¨hn,¨⊂'.derv'
          r←dis write¨(⊂⍵,'/'),¨hn,¨⊂'.txt'
          0
      }

      exportNC34←{
    ⍝ ⍺ ←→ root ns
    ⍝ ⍵ ←→ target fs folder
          fns←⍺.⎕NL-3.1 3.2 4.1 4.2
          0∊⍴fns:0
          src←⍺.⎕NR¨fns
          hn←fsenc¨fns
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
          r←Export/tmask⌿⍉↑nsrefs((⊂⍵,'/'),¨fsenc¨nss)
          ~∨/smask:r    ⍝ no scripts found
          hn←fsenc¨smask/nss
          r←(smask/src)write¨(⊂⍵,'/'),¨hn,¨⊂'.dyalog'
          0
      }

      fixFolder←{
    ⍝ ⍺ ←→ ns ref
    ⍝ ⍵ ←→ target fs folder
          r←3 ⎕MKDIR ⍵
          r←⍺ putProps ⍵
          ⍵
      }

      putProps←{
    ⍝ ⍺ ←→ ns ref
    ⍝ ⍵ ←→ target fs folder
          p←⍺.{⍵,'←',⍕⍎⍵}¨'⎕CT' '⎕DCT' '⎕DIV' '⎕FR' '⎕IO' '⎕ML' '⎕PP'
          p write ⍵,'/ns.props'
      }

    :EndSection ⍝ Export

    :Section Import
      Import←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ source fs folder
          ⎕ML←1
          ⍺←⍬
          ns←⍵ getSpace ⍺
          x←ns getProps ⍵
          d f←{(↓1 2∘.=⊣/⍵)/¨⊂⊢/⍵}ls ⍵
          ~0∊⍴x←ns powerFix⍣≡⊢f:∘∘∘
          map←⍉⍪(⍕ns)⍵
          0∊⍴d:map
          map⍪⊃⍪/ns ∇¨d
      }
      getProps←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ source fs folder
          ⍺.⍎¨⊃read(⍵,'/ns.props')1
      }
      getSpace←{⎕IO←0
          ⍵≡⍬:#
          ns←fsdec 1⊃⎕NPARTS ⍺,'.'
          ⍎((⍕⍵),'.',ns)⎕NS''
      }
      fix←{
     ⍝ ⍵ ←→ file path
     ⍝ ⍺ ←→ target ns
          ⎕ML←1
          fn ext←1↓⎕NPARTS ⍵
          11::1
          name←fsdec fn
          ext≡'.derv':0⊣⍺ fixDerv ⍵ name
          src←⊃read ⍵ 1
          ext≡'.ason':0⊣name ⍺.{⍎⍺,'←⍵'}ason2a⊃src
          ext≢'.dyalog':0
          ':'=⊃~∘' '⊃src:0⊣⍺.⎕FIX src
          0⊣⍺.⎕FX src
      }

      fixDerv←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ (source file)(name)
          file name←⍵
          (⍺.{(⎕FUNTIE t)⊢⎕FREAD 1,⍨t←⍵ ⎕FSTIE 0}file)⍺.{
              ⍎⍵,'←⍺⍺ ⋄ ⍵' ⋄ ⍺⍺}name
      }

      powerFix←{
          0∊⍴⍵:⍵
          r←⍺ fix¨⍵
          ⍵/⍨~r∊0
      }
    :EndSection ⍝ Import

    :Section Tools

    cc←{⍺←0 ⋄ ⍺(819⌶)⍵}
    ss←{16::0⋄⎕SRC ⍵}
    j2a←{⍺←⊢ ⋄ ⍺(7159⌶)⍵}
    a2j←{⍺←⊢ ⋄ ⍺(7160⌶)⍵}

    write←{(⊂⍺)⎕NPUT ⍵ 1}
    read←{⎕NGET ⍵}
      writeDerv←{
          x←1 ⎕NDELETE ⍵
          (⎕FUNTIE t){0}⍺ ⎕FAPPEND⊢t←⍵ ⎕FCREATE 0
      }

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

      fsenc←{⎕IO←0
          0=n←2⊥⍵∊⎕A:⍵,'.0'
          ⍵,'.',(⎕D,⎕A)⌷⍨⊂16⊥⍣¯1⊢n
      }

      fsdec←{⎕IO←0 ⋄ ⎕ML←1
          '.'≡⊃⍵:''
          n b←0 1 cc¨0 1↓¨1↓⎕NPARTS ⍵
          0∊⍴b:⍵
          0=v←16⊥(⎕D,⎕A)⍳b:n
          m←((≢n)⍴2)⊤v
          (m/n)←1 cc m/n
          n
      }

      a2ason←{⍺←⊢
          enc←{
              t←10|⎕DR ⍵
              isns←9=⎕NC'⍵'
              issc←(0∊⍴⍴⍵)∧0=≡⍵
              isns<issc:,⍣(t=0)⊢⍵
              t=0:(⍴⍴⍵),(⍴⍵),⊂,⍵
              2|t:(⍴⍴⍵),(⍴⍵),,⍵
              ~issc:(⍴⍴⍵),(⍴⍵),∇¨,⍵
              vn fn←⍵.⎕NL¨-(2 9)(3 4)
              0∊⍴vn,fn:⍵
              pn←vn,{0(7162⌶)⍵}¨'∇',¨fn
              vv←vn{0∊⍴⍺:⍺ ⋄ enc¨⍵.⍎¨⍺}⍵
              fv←fn{0∊⍴⍺:⍺ ⋄ enc¨⍵.⎕NR¨⍺}⍵
              x←pn(ns←⎕NS'').{⍎⍺,'←⍵'}¨vv,fv
              ns
          }
          ⍺ a2j enc ⍵
      }

      ason2a←{
          dec←{⎕ML←1
              9=⎕NC'⍵':ns ⍵
              (0∊⍴⍴⍵)∧0=≡⍵:⍵
              (1=⍴⍴⍵)∧(1=≡⍵)∧0=10|⎕DR ⍵:⍬⍴⍵
              r←⊃⍵ ⋄ s←r↑1↓⍵
              w←(1+r)↓⍵
              v←s⍴⊃⍣(0=10|⎕DR⊃w)⊢w
              2>|≡v:v
              ∇¨v
          }
          ns←{
              0∊⍴vn←⍵.⎕NL-2 9:⍵
              vv←dec¨⍵.⍎¨vn
              pn←1(7162⌶)¨vn
              x←⍵.⎕EX↑vn~pn
              ⍵⊣pn ⍵.{'∇'=⊃⍺:⎕FX ⍵ ⋄ ⍎⍺,'←⍵'}¨vv
          }
          dec j2a ⍵
      }


    :EndSection ⍝ Tools

:EndNamespace
