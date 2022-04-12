/// Execute InterSystems ObjectScript over ODBC
Class zrcc.EX.ISOS [ Language = objectscript ]
{

/// check connectivity
ClassMethod Ping() As %String [ SqlName = Ping, SqlProc ]
{
 quit $system.INetInfo.LocalHostName()_"::"_$namespace_"::"_$ZV
}

/// set / kill global over ODBC
/// subs = subscript in ( )
/// dd = $data of source during global copy
ClassMethod Gset(glob As %String, subs As %String, val As %String = "", dd As %Integer = 1) As %String [ SqlName = Gset, SqlProc ]
{
 set $ZT="errset"
 set glb=glob_$s(subs'["(":"",1:subs)
 if dd#10 set @glb=val
 else  zkill @glb
 quit "ok: "_glb	
 
errset
	set $ZT="" quit $ZE_": "_$g(glb)
}

/// eXecute Command over ODBC
/// name of local variable for return value
ClassMethod Xcmd(cmd As %String, retr As %String = "") As %String [ SqlName = Xcmd, SqlProc ]
{
 set $ZT="errx",res=""
 Xecute cmd
 if retr?.1"%"1A set res=$g(@retr)   
 quit "ok: "_res
 
errx
	set $ZT="" quit $ZE_": "_$g(cmd)_":"_$g(res)
}

}
