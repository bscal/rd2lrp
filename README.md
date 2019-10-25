# RD2lRP
GTA V fivem rp server for rd2l players

Was built using a modified version of the current vRP framework. ImagicTheCat https://github.com/ImagicTheCat/vRP

Database driver by https://github.com/GHMatti/FiveM-MySQL

Contains a combination of scripts that were created by us or from the fivem forums (Some are modified by us). 

# Status
The current release is still in development. However you can use an older release that will work but contains several bugs and missing features.

I would recommend not to add/edit/update/remove scripts or files unless you know what you are doing. Many of these scripts are modified from their original forms to work with vRP or other reasons.

There is a lack of documentation for our scripts or any of our changes to scripts.

I do not know how much I will continue to work on this project and am not planning on having much support for bugs or features. So use at your own risk.

# Installation

1. Install a server by following the fivem documentations
	* DO NOT clone fivem's `cfx-server-data` repo (It uses the `resouces` directory)
2. Clone rd2lrp `git clone https://github.com/bscal/rd2lrp.git resources`
3. Copy the server.cfg infomation below and configure it.
4. Import databases.sql into your sql database.
5. Start the server up normally.

### server.cfg
You need to replace you start resources with these and you NEED to change the infomation for your database also. They are both the same but another sql driver was added so it uses 2 different convars.
<details> 
  <summary>Replace your start resources or mysql strings with this</summary>
    	<br>set dhost "host"
	<br>set ddatabase "database"
	<br>set duser "user"
	<br>set dpassword "password"
	<br>set mysql_connection_string "server=host;database=database;userid=user;password=password;Allow User Variables=True"
	<br>set mysql_debug false
	<br>
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
  <summary>
</details>
