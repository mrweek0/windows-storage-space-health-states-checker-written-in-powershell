# windows-storage-space-health-states-checker-written-in-powershell

# README EN

# Script action

In the process of using Windows storage pools, the system does not warn when the storage pool is degraded or a warning occurs, which greatly increases the risk of data loss. The function of this script is to check the health status of the storage pool when running with the user login as a scheduled task, and pop up a message to remind when it is abnormal.

# Script parameter configuration

In the #Parameter LOG section:

The user needs to customize the following parameters when running for the first time
set-location 'C:\Users\abc\' #LOG file storage path

Users can configure the following parameters as needed
$LogFileName="StoragePool_Info_Log.txt" #LOG file name

# Runtime environment configuration

1. Set the local script execution policy "Set-ExecutionPolicy RemoteSigned" in the powershell console, otherwise the local script will not run

2. Add powershell.exe to the scheduled task to start with the user's login, and you need to specify the path where the script is located
Launcher: powershell.exe
Startup parameters: -NonInteractive -WindowStyle Hidden -NoProfile "C:\users\abc\checkpoolhealth.ps1"

# Notice

1. The script only alerts critical failures. The storage pool space is insufficient, and the status of automatically recoverable errors such as background data verification is not reminded

2. To judge whether the script is running normally, you can view the log file in the previously specified location after execution. The file has a timestamp.

3. The log files are stored in uncompressed text format. Please consider manually backing up or deleting the log files if the number of disks is too large or it is used for a long time.

# README CHS

# 脚本作用

在使用Windows存储池的过程中，当存储池降级或出现警告时系统竟然无提醒，这导致数据丢失的风险大大增加。这个脚本的作用就是作为计划任务随用户登陆运行时会检查存储池的健康状态，并在异常时弹出消息提醒

# 脚本参数配置

在#Parameter LOG部分：
用户首次运行需要自定义如下参数
set-location 'C:\Users\abc\'             #LOG文件存储路径

用户可按需配置如下参数
$LogFileName="StoragePool_Info_Log.txt"  #LOG文件名称

# 运行环境配置

1、在powershell控制台设置本地脚本执行策略“Set-ExecutionPolicy RemoteSigned”否则本地脚本不运行

2、在计划任务中添加powershell.exe随用户登陆启动，需要指定脚本所在路径
启动程序：powershell.exe
启动参数：-NonInteractive -WindowStyle Hidden -NoProfile "C:\users\abc\checkpoolhealth.ps1"

# 注意事项

1、脚本仅提醒严重故障。存储池空间不足，可自动恢复的错误如后台数据校验等状态不提醒

2、判断脚本是否运行正常可在执行后在前面指定的位置查看log文件，文件内带有时间戳

3、log文件采用非压缩文本格式存储，磁盘数量过多或长时间使用请考虑手动备份或删除log文件

# 踩坑记录

1、文件编码要保存为 UTF-8 with BOM，否则中文MSGBOX乱码。 

2、get方法有时得不到结果，猜测可能是powershell不等待执行完成就执行下一条内容，所以脚本设计为第一次获取不到内容时间隔1s重试
