#运行时会自动检查windows物理磁盘、存储空间的工作状态,并将状态记录到log文件中
#在发现异常的时候弹窗提醒用户及时处理相关故障,避免问题扩大造成数据丢失.
#脚本由ZST(mrweek@sohu.com)编制
#Version 0.6beta 2022-08-16 脚本初次建立.
#Version 0.7beta 2022-08-23 实现基本信息收集. 
#Version 0.8beta 2022-09-03 完善信息采集流程，信息提示测试.
#Version 1.0     2022-09-04 基本提醒功能实现.

#Parameter LOG
set-location 'C:\Users\abc\'             #LOG文件存储路径
$LogFileName="StoragePool_Info_Log.txt"  #LOG文件名称
$date_info=get-date                      #当前日期
#Parameter ERR
$phydisk_err=0                           #物理磁盘健康异常 0=无异常 1=异常
$storagepool_err=0                       #存储池健康异常
$phydisk_get_err=0                       #获取物理磁盘信息失败
$storagepool_get_err=0                   #获取存储池信息失败
#Parameter MSGBOX
$msg_title_text="windows存储空间故障"
$msg_info_text="存储空间磁盘异常,阵列处降级运行状态. 请及时排除故障,恢复阵列正常运行.否则数据丢失风险增加！"

#Physical Disk info
$n=10
$phydisk_info=Get-physicaldisk #提取信息到变量$phydisk_info
While(($phydisk_info.count -eq 0) -and ($n -ne 0)){ $phydisk_info=Get-physicaldisk; $n=$n-1; Start-Sleep -s 1} #如果没有提取到，间歇1s重试10次。
if($phydisk_info.count -eq 0){$phydisk_get_err=1}
if ($phydisk_get_err -eq 0) 
{
write-output "####################" >>$LogFileName
$date_info                          >>$LogFileName
$phydisk_info|format-table          >>$LogFileName
}

#Storage Pool info
$n=10
$storagepool_info=Get-storagepool  #提取信息到变量$phydisk_info
While(($storagepool_info.count -eq 0) -and ($n -ne 0)){ $storagepool_info=Get-storagepool; $n=$n-1; Start-Sleep -s 1} #如果没有提取到，间歇1s重试10次。
if($storagepool_info.count -eq 0){$storagepool_get_err=1}
if ($storagepool_get_err -eq 0) 
{
$storagepool_info|format-table      >>$LogFileName
}

#Info processer
$phydisk_health_state=$phydisk_info|foreach-object -membername healthstatus
$storagepool_health_state=$storagepool_info|foreach-object -membername healthstatus

if($phydisk_health_state -eq "warning"){$phydisk_err=1}
if($phydisk_health_state -eq "Unhealthy"){$phydisk_err+=2}
if($phydisk_health_state -eq "Unknown"){$phydisk_err+=4}

if($storagepool_health_state -eq "warning"){$storagepool_err=1}
if($storagepool_health_state -eq "Unhealthy"){$storagepool_err+=2}
if($storagepool_health_state -eq "Unknown"){$storagepool_err+=4}

#build test
#write-output phydisk_err=$phydisk_err
#write-output storagepool_err=$storagepool_err

#Msg processer
$msg_pop_switch=0
$msg_pop_switch=$phydisk_err+$storagepool_err+$phydisk_get_err+$storagepool_get_err

#Msgbox ERR
if ($msg_pop_switch -ne 0) 
{
    $info_msgbox=New-Object -ComObject WScript.Shell
    $info_msgbox_select=$info_msgbox.Popup($msg_info_text,0,$msg_title_text,1+48)
}

#Msgbox more info
if ($info_msgbox_select -eq 1)
{
    $storagepool_info_text=$storagepool_info|format-table FriendlyName,OperationalStatus,HealthStatus|out-string 
    $phydisk_info_text=$phydisk_info|format-table FriendlyName,OperationalStatus,HealthStatus|out-string 
    $more_info=("存储池状态:" + $storagepool_info_text + "物理磁盘状态:" + $phydisk_info_text)
    $no_use=$info_msgbox.Popup($more_info,0,$msg_title_text,0+48)
}

#build tset 
#read-host "press enter to continue"