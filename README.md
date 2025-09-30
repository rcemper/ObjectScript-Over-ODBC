Every now and then you may encounter a situation where for various reasons  
ODBC is the only option to access a remote system. Which is sufficient as long as you need to examine or change tables.  
But you can't directly execute some commands or change some Global.  
 
Special thanks [@Anna Golitsyna](https://community.intersystems.com/user/anna-golitsyna) for inspiring me to publish this.  

This examples provides 3 Methods projected as SQLprocedure that enable this if other ways of access are blocked.  
Typically by some firewall.  

SQLprocedure **Ping()** returns Server::Namespace::$ZV and allows to check the connection  
SQLprocedure **Xcmd(\<commandline>,\<resultvar>)**  executes the command line you submit and returns the result 
that you deposit in a variable that you named.  
SQLprocedure **Gset(\<global>,\<subscript>,\<value>,\<$data>)**  allows you to set or delete a global node   
 - \<global>  is a GlobalName in the remote namespace including leading carret; e.g. '^MyGlobal' (sql quoted!)    
 - \<subscript> stands for the complete subscript including parenthesis ;e.g. '(1,3,"something",3)'  (sql quoted!)   
 - \<$data> controls if you set the Global Node or execute a ZKILL on it; e.g. 1, 11 to set, 0,10 to ZKILL   
As you may guess by the name this is especially useful during a Global copy.  
The procedure Gset is designed to make use of [Global Scanning](https://community.intersystems.com/post/global-scanning-slicing) described earlier.  
Combined, they allow a Global copy across any ODBC connection.  

__Installation:__
- On the remote system you need the class provided with this article in OpenExchange  
- On the local (source) system you need to define the procedures as Linked SQL Procedures  
      _SMP>System>SQL> Wizards>Link Procedure_  
      at that time you local package name is defined    (in the examples I used zrccEX)   
-  If you want to run the Global copy you also need to install the 
[Global  Scanning class from OEX](https://openexchange.intersystems.com/package/Global-Scanning-and-Slicing-to-SQL)   
   (It is just for comfort)  

__Examples:__
~~~  
USER>do $system.SQL.Shell()   
SQL Command Line Shell  
[SQL]USER>>select zrcc_EX.Ping()  
Expression_1  
cemper9::CACHE::IRIS for Windows (x86-64) 2020.1 (Build 215U) Mon Mar 30 2020 20:14:33 EDT  
~~~
Check existence of the Global  
~~~  
[SQL]USER>>select zrcc_EX.Xcmd('set %y=$d(^%SYS)','%y')  
ok: 10  
~~~  
Set some value to ^rcc4(1,"demo",3,4)  
~~~  
[SQL]USER>>select zrcc_EX.Gset('^rcc4','(1,"demo",3,4)','this is a demo',1)  
Expression_1  
ok: ^rcc4(1,"demo",3,4)  
~~~  
Do a global copy from ^%SYS to ^rcc4.  
First show ^rcc2  
~~~
USER>>select reference,value,"$DATA" from rcc_G.Scan where rcc_G.scan('^%SYS')=1  
Reference       Value   $Data  
|  ^%SYS |  | 10 |
| ("CSP") |  | 10 |
| ("CSPAppSec") | 64 | 1 |
| ("CacheTempDir") | "c:\intersystems\iris242\mgr\iristemp\" | 1 |
| ("DBRefByName") |  | 10 |
| ("Ensemble") | "2025-02-03 18:08:28" | 11 |
| ("ErrorPurge") | 30 | 1 |
| ("FIPSMode") | 0 | 1 |
| ("GBLOCKCOPY") | "1.0~" | 1 |
| ("IRISTempDir") | "c:\intersystems\iris242\mgr\iristemp\" | 1 |
| ("JOURNAL") | 0 | 11 |
| ("LANGUAGE") |  | 10 |
| ("LASTSESSIONGUID") | "6V3a¦"_$c(154)_"ð"_$c(17,128,0,0,0,0,0,0,0) | 1 |
| ("LOCALE") |  | 10 |
| ("MPP") |  | 10 |
| ("NLS") |  | 10 |
| ("SERVICE") |  | 10 |
| ("SSPort") | 11972 | 1 |
| ("StreamLocation") |  | 10 |
| ("SystemMode") | "TEST" | 1 |
| ("TempDir") | "C:\InterSystems\IRIS242\mgr\Temp" | 1 |
| ("WQM") |  | 10 |
| ("WebServer") |  | 10 |
| ("bindir") | "c:\intersystems\iris242\bin\" | 1 |
| ("java") |  | 10 |
| ("ml") |  | 10 |
| ("python") |  | 10 |
| ("shutdownlogerrors") | 0 | 1 |
| ("sql") |  | 10 |
| ("sysdir") | "c:\intersystems\iris242\mgr\" | 1 |
| ("tercap") |  | 10 |
31 Rows(s) Affected
~~~
Now run the copy to remote global  
~~~
[SQL]USER>>select zrcc_EX.Gset('^rcc2',reference,value)  from rcc_G.Scan where rcc_G.scan('^%SYS')=1  
| Expression_1 |
| -- |
| ok: ^rcc2 |
| ok: ^rcc2("CSP") |
| ok: ^rcc2("CSPAppSec") |
| ok: ^rcc2("CacheTempDir") |
| ok: ^rcc2("DBRefByName") |
| ok: ^rcc2("Ensemble") |
| ok: ^rcc2("ErrorPurge") |
| ok: ^rcc2("FIPSMode") |
| ok: ^rcc2("GBLOCKCOPY") |
| ok: ^rcc2("IRISTempDir") |
| ok: ^rcc2("JOURNAL") |
| ok: ^rcc2("LANGUAGE") |
| ok: ^rcc2("LASTSESSIONGUID") |
| ok: ^rcc2("LOCALE") |
| ok: ^rcc2("MPP") |
| ok: ^rcc2("NLS") |
| ok: ^rcc2("SERVICE") |
| ok: ^rcc2("SSPort") |
| ok: ^rcc2("StreamLocation") |
| ok: ^rcc2("SystemMode") |
| ok: ^rcc2("TempDir") |
| ok: ^rcc2("WQM") |
| ok: ^rcc2("WebServer") |
| ok: ^rcc2("bindir") |
| ok: ^rcc2("java") |
| ok: ^rcc2("ml") |
| ok: ^rcc2("python") |
| ok: ^rcc2("shutdownlogerrors") |
| ok: ^rcc2("sql") |
| ok: ^rcc2("sysdir") |
| ok: ^rcc2("tercap") |
31 Rows(s) Affected
 ~~~
 
[Article in DC](https://community.intersystems.com/post/objectscript-over-odbc)

[Demo Server SMP](https://isos-over-odbc.demo.community.intersystems.com/csp/sys/UtilHome.csp)   
[Demo Server WebTerminal](https://isos-over-odbc.demo.community.intersystems.com/terminal/)    
        
**Code Quality**   
<img width="85%" src="https://openexchange.intersystems.com/mp/img/packages/1777/screenshots/bgxztcyby72sqyoawwfysts9eg.jpg">
