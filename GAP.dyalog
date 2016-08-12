:Namespace GAP
    (⎕IO ⎕ML)←0 1

    :Section Initialise
      Init←{
          c←⎕THIS.cfg←getCfg ⍬
          r←# fixFolder c.src
          c.map←⍉⍪'Name' 'Filepath' 'ReadOnly'
          r←c'#' 0 Import c.src
          r←ImportLibs c
          r←setEditorHooks c
          r←setFileWatcher⍣(jt≡c.watch)⊢c.src
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
          c.watch←jf jt⊃⍨'yY'∊⍨⊃'y'ask'Watch external file changes'
          c.libs←⍬
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
          1=⍺ checkReadOnly(⍕space),'.',⍕new:
          d←⍺ getSpaceFolder space
          value write d,'/',(fsenc new),'.dyalog'
      }
      checkReadOnly←{
      ⍝ ⍺ ←→ cfg space
      ⍝ ⍵ ←→ name
      ⍝ ← ←→ 1 = readonly
          i←(⊣/⍺.map)⍳⊂⍵
          i=≢⍺.map:0
          (⊂i 2)⊃⍺.map
      }
      setFileWatcher←{
          0::0
          ⎕USING←'System.IO,System.dll'
          fw←⎕THIS.fw←⎕NEW FileSystemWatcher(⊂⍵)
          fw.(onChanged onCreated onDeleted onRenamed)←⊂⎕OR'OnExternalChange'
          fw.IncludeSubdirectories←1
          fw.EnableRaisingEvents←1
          ⎕←'Watching: ',⍵
          0
      }

    ∇ OnExternalChange msg;fw;arg;x;t;ct
      fw arg←msg
      ct←arg.ChangeType.ToString ⍬
      :If ct≡'Changed'
      :AndIf '.dyalog' '.props' '.derv' '.ason'∊⍨⊂⊃⌽⎕NPARTS arg.FullPath
          t←1 ⎕NINFO arg.FullPath
      :AndIf t=2
          x←(⎕THIS.cfg.src,'/')reload arg.Name
      :EndIf
      x←2501⌶0      ⍝ discard this thread on exit
    ∇

      getSpaceFolder←{
      ⍝ ⍵ ←→ target ns
      ⍝ ⍺ ←→ cfg ns
      ⍝ ← path to fs folder
          df←⍕⍵
          i←(⊣/⍺.map)⍳⊂df
          i=≢⍺.map:⍺ addMap ⍵ df
          ⍵ fixFolder(⊂i 1)⊃⍺.map
      }

      addMap←{
      ⍝ ⍵ ←→ (target ns)(disp form)
      ⍝ ⍺ ←→ cfg ns
          ns df←⍵
          p←1↓df
          p←⊃,/'/',¨fsenc¨1↓¨('.'=p)⊂p
          p←⍺.src,'/',p
          ⍺.map⍪←df p 0
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
      Save←{
          ns file banner←3↑⍵,⊂''
          ns2script←{
              0≢src←{16::0 ⋄ ⎕SRC ⍵}ns←⍺.⍎⍵:src
              pad←(4⍴' ')∘,
              fns←pad¨ns.(⊃,/⎕NR¨⎕NL-3.1 3.2 4.1 4.2)
              nss←pad¨⊃,/ns ∇¨ns.⎕NL-9
              env←⊂'(⎕IO ⎕ML ⎕WX)←',⍕ns.(⎕IO ⎕ML ⎕WX)
              (⊂':Namespace ',⍵),env,fns,nss,⊂':EndNamespace'
          }
          root name←0 1↓¨1↓⎕NPARTS ns
          src←(⍎root)ns2script name
          src←¯1⌽('⍝ '∘,¨banner),1⌽src
          src write file
      }
    :EndSection ⍝ Export

    :Section Import
      Import←{
      ⍝ ⍺ ←→ (cfg ns) (target ns) (readonly)
      ⍝ ⍵ ←→ source fs folder
          c t ro←⍺
          ns←t getSpace ⍵
          x←ns getProps ⍵
          d f←{(↓1 2∘.=⊣/⍵)/¨⊂⊢/⍵}ls ⍵
          c.map⍪←⍉⍪(⍕ns)⍵ ro
          ~0∊⍴x←c ns ro powerFix⍣≡⊢f:∘∘∘
          0∊⍴d:0
          c ns ro∘∇¨d
      }
      ImportLib←{
      ⍝ ⍺ ←→ (cfg ns)
      ⍝ ⍵ ←→ lib item = filepath [target ns [readonly]]
          0∊⍴⍵:0
          w←⊂⍣(1=|≡⍵)⊢⍵
          fp t ro←w,(≢w)↓'' '#' 1
          ⍺ t ro Import fp
      }
      ImportLibs←{
      ⍝ ⍵ ←→ (cfg ns)
          0=⍵.⎕NC'libs':0
          0∊⍴⍵.libs:0
          ⍵ ImportLib¨⍵.libs
      }
      getProps←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ source fs folder
          ~⎕NEXISTS⊢p←⍵,'/ns.props':0
          ⍺.⍎¨⊃read p 1
      }
      getSpace←{
          0=10|⎕DR ⍺:⍎⍺ ⎕NS''
          ns←fsdec 1⊃⎕NPARTS ⍵,'.'
          ⍎((⍕⍺),'.',ns)⎕NS''
      }
      reload←{
          ⍺←'./'
          dirs←{1↓¨⍵⊂⍨⍵∊'/\'}'/',⍵
          nsn←'#',⊃,/'.',¨fsdec¨¯1↓dirs
          ns←⍎nsn ⎕NS''
          ns fix ⍺,⍵
      }
      fix←{
     ⍝ ⍵ ←→ file path
     ⍝ ⍺ ←→ (cfg ns) (target ns) (readonly)
          c t ro←⍺
          fn ext←1↓⎕NPARTS ⍵
          11::1
          name←fsdec fn
          ext≡'.derv':0⊣t fixDerv ⍵ name
          src←⊃read ⍵ 1
          ext≡'.ason':0⊣name t.{⍎⍺,'←⍵'}ason2a⊃src
          ext≢'.dyalog':0
          fixname←t fixScript src
          c.map⍪←fixname ⍵ ro
          0
      }
      fixDerv←{
      ⍝ ⍺ ←→ target ns
      ⍝ ⍵ ←→ (source file)(name)
          file name←⍵
          (⍺.{(⎕FUNTIE t)⊢⎕FREAD 1,⍨t←⍵ ⎕FSTIE 0}file)⍺.{
              ⍎⍵,'←⍺⍺ ⋄ ⍵' ⋄ ⍺⍺}name
      }
      fixScript←{
      ⍝ ⍵ ←→ source
      ⍝ ⍺ ←→ target ns
          0::''
          ':'=⊃~∘' '⊃⍵:⍕⍺.⎕FIX ⍵
          (⍕⍺),'.',⍺.⎕FX ⍵
      }
      powerFix←{
          0∊⍴⍵:⍵
          r←⍺∘fix¨⍵
          ⍵/⍨~r∊0
      }
    :EndSection ⍝ Import

    :Section Tools

    cc←{⍺←0 ⋄ ⍺(819⌶)⍵}
    ss←{16::0⋄⎕SRC ⍵}
    j2a←{⍺←⊢ ⋄ ⍺(7159⌶)⍵}
    a2j←{⍺←⊢ ⋄ ⍺(7160⌶)⍵}
    jf jt←7161⌶¨0 1

    write←{(⊂⍺)⎕NPUT ⍵ 1}
    read←{⎕NGET ⍵}
      writeDerv←{
          x←1 ⎕NDELETE ⍵
          (⎕FUNTIE t){0}⍺ ⎕FAPPEND⊢t←⍵ ⎕FCREATE 0
      }

      ls←{
    ⍝ ⍵ ←→ filepath
    ⍝ ⍺ ←→ recurse flag
          ⍺←0
          r←⍉↑1 0 ⎕NINFO⍠1⊢⍵,'/*'
          ⍺=0:r
          ~∨/f←1=⊣/r:r
          r⍪⊃⍪/⍺ ∇¨f/⊢/r
      }

      fsenc←{
          0=n←2⊥⍵∊⎕A:⍵,'.0'
          ⍵,'.',(⎕D,⎕A)⌷⍨⊂16⊥⍣¯1⊢n
      }

      fsdec←{
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
          dec←{
              9=⎕NC'⍵':ns ⍵
              t←10|⎕DR ⍵
              (0∊⍴⍴⍵)∧0=≡⍵:⍵
              (1=⍴⍴⍵)∧(1=≡⍵)∧0=t:⍬⍴⍵
              r←⊃⍵ ⋄ s←r↑1↓⍵
              w←(1+r)↓⍵
              v←s⍴⊃⍣(0=10|⎕DR⊃w)⊢w
              6≠t:v
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
