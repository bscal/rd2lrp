# RD2lRP
GTA V fivem rp server for rd2l players

This relies heavily on vRP framework by ImagicTheCat https://github.com/ImagicTheCat/vRP

Also database driver by https://github.com/GHMatti/FiveM-MySQL

Also there are several other scrips and models I have gotten from the fivem forums

### My Work
The scripts I have written are 
* cars
* cops
* dispatch
* jobs
* robberies
* utils

I have heavily modified several of the files from their original state expecielly vRP

I would not look at cops or take cops it was one of my first scripts and stuff and is not implemented well with vRP nor written nicely

Here is the list of server resources for server.cfg and the mysqlstring
<details> 
  <summary>Replace your start resources or mysql strings with this</summary>
    <br>set mysql_connection_string "server=;database=;userid=;password=;Allow User Variables=True"
	<br>set mysql_debug false
	<br>#required
	<br>start mapmanager
	<br>start chat
	<br>start spawnmanager
	<br>start fivem
	<br>start hardcap
	<br>start rconlog
	<br>#start scoreboard
	<br>start playernames
    <br>
	<br>#vrp main
	<br>start GHMattiMySQL
	<br>start vrp
	<br>start vrp_ghmattimysql
    <br>
	<br>#vrp other
	<br>start vrp_carwash
    <br>
	<br>#mine
	<br>start pvp
	<br>start map
	<br>start indicators
	<br>start lux_vehcontrol
	<br>start VK_interiors
	<br>start RealisticVehicleFailure
	<br>start CustomScripts
	<br>start clothing
	<br>start 3dme
	<br>start voicechat
	<br>start rpemotes
	<br>start cars
	<br>start wk_wrs
	<br>start frfuel
	<br>start pNotify
	<br>start cops
	<br>start robberies
	<br>start core_hideintrunk
	<br>start sahp
	<br>start unmarked-police-pack
	<br>start bob74_ipl
	<br>start PillboxHospital
	<br>start dispatch
	<br>start utils
	<br>start policeboost
	<br>start ServerPassword
	<br>start schafter
	<br>start unmarked-megapack
	<br>start jobs
	<br>#start MattomcLoad
	<br>start bx-loading-screen
	<br>start vrp_lscustoms
	<br>start vRP_doorsControl
	<br>start [Police Skins]
	<br>start online
	<br>start Ped
    <br>
	<br># Assets
	<br>start club_B
	<br>start club_R
	<br>start blips
	<br>start Bentley2013
	<br>start BentleyBen
	<br>start BentleyMul
	<br>start BMW_7L
	<br>start BMW_M4
	<br>start BMW_M5
	<br>start BMW_M6
	<br>start BMW_X5
	<br>start BMW_X6
	<br>start Bugatti_Chiron
	<br>start Bugatti_Divo
	<br>start Bugatti_Veyron
	<br>start Buick1970
	<br>start Buick1987
	<br>start Spider
    <br>
	<br>#Keep this here, it stops some errors
	<br>restart sessionmanager
</details>
