#!/bin/bash

# 项目自动、打包、上传蒲公英

#注意事项：
  # 1.打包前需要在xcode->building 设置证书和对应的描述文件
  # 2.打包的导出文件夹放在桌面


#echo
 echo_green()
 {
 	echo -e "\033[32m $1 \033[0m"
 }

  echo_red() 
 {
 	echo -e "\033[31m $1 \033[0m"
 }

  echo_blue()
 {
 	echo -e "\033[36m $1 \033[0m" 
 }

uploadIpa()
{
 #是否上传到蒲公英
 if [ $UPLOADPGYER = true ]; then
  # 获取第一个参数
   varBuildUpdateDescription=$1
    
   #如果有设置DISPLAY_NAME则取DISPLAY_NAME ，否则默认取TARGET_NAME
   IPAPATH=""
   if [ -n "$DISPLAY_NAME" ]
     then
     IPAPATH="${EXPORT_PATH}/${DISPLAY_NAME}.ipa"
   else
     IPAPATH="${EXPORT_PATH}/${TARGET_NAME}.ipa"
   fi
   echo $IPAPATH
    
   #上传 返回信息写入json 文件
     filesize=`du -k "${IPAPATH}" | awk '{print $1}'`
     echo_green "文件大小:${filesize}kb 开始上传..."
     parent_res=`uploadPgyer "${IPAPATH}"`


   #解析返回数据
     echo_green "** 上传成功! **"
     echo_green "==========================================================="
     parse_response_info "$parent_res"
     echo_green "==========================================================="

 fi
}

# upload ipa to pgyer
 uploadPgyer()
{
	local api_key=b9d1eee1964b78caa59b5e5dc476b911
	local url=https://www.pgyer.com/apiv2/app/upload

    local response=$(curl -F "file=@${IPAPATH}" -F "_api_key=${api_key}" -F "buildUpdateDescription=${varBuildUpdateDescription}" ${url})

	if [ $? -ne 0 ];then
		echo_red "** 上传失败. **"
        exit 1 
    fi
	
	echo ${response}
}


#解析返回信息
 parse_response_info()
{
	which jq >/dev/null 2>&1
	
	if [ $? -ne 0 ];then
	echo_red "** 没有安装 jq. 解析失败. **"
	exit 1
	fi

	if [ -z "$1" ];then
	echo_read "** 没有返回数据，解析失败. **"
	exit 1
	fi

	#解析主要字段
	err_code=`echo "$1" | jq .'code'`
	err_msg=`echo "$1" | jq .'message'`


	#得到App摘要
	if [[ "${err_code}" -eq 0 ]]; then
		#解析子字段
		local data=`echo "$1" | jq .'data'`
		local pgyer_url='https://www.pgyer.com/'
		local app_name=`echo "$data" | jq .'buildName' | tr -d '"'`
	  	local app_version=`echo "$data" | jq .'buildVersion' | tr -d '"'`
		local app_build_version=`echo "$data" | jq .'buildBuildVersion' | tr -d '"'`
		local app_shortcut_url=`echo "$data" | jq .'buildShortcutUrl' | tr -d '"'`
		local download_url=${pgyer_url}${app_shortcut_url}

		echo_blue  "${app_name} $2 Beta V${app_version} build ${app_build_version}"
		echo_blue  "下载地址: ${download_url}"
	else
		echo_red ${err_msg}
	fi

	return 0;
}

 clean_project()
{
	xcodebuild -configuration "Release" -alltargets -sdk iphoneos clean
	   if [ $? -ne 0 ];then
 			echo_red "** Clean Faild. **"
 			exit 1
 	   fi
}

 build_project()
{
	xcodebuild -workspace EaseIM.xcworkspace -scheme EaseIM -configuration Release -sdk iphoneos

	if [ $? -ne 0 ];then
     	 echo_red "** Build Faild. **"
         exit 1
    fi
}


generateArchive() 
{
    #打包前需要在xcode->building 设置证书和对应的描述文件
	xcodebuild archive -workspace "${APP_PATH}" -scheme "${TARGET_NAME}" -configuration "${CONFIGURATION}" -archivePath "${ARCHIVE_PATH}"
	if [ $? -ne 0 ];then
     	 echo_red "** archive Faild. **"
         exit 1
    fi
}

exportArchive()
{
	xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportPath "${EXPORT_PATH}" -exportOptionsPlist "${PLIST_PATH}"
}


#流程从这里开始
#==========================================
#==========================================
#==========================================


# 选择项目 xcodeproj or xcworkspace 这里是二选一
PROJECT_TYPE="xcworkspace"

# 是否需要上传到蒲公英
UPLOADPGYER=true

#Display_NAME
DISPLAY_NAME="EaseIM"

# 项目的根目录路径
PROJECT_PATH="$( cd "$( dirname "$0"  )" && pwd  )";

# 项目target名字
TARGET_NAME="EaseIM"


# 打包环境 Release / Debug
CONFIGURATION=Release

# 工程文件路径

APP_PATH="${PROJECT_PATH}/${TARGET_NAME}.$PROJECT_TYPE"

# 打包目录
HOME_PATH=$(echo ${HOME})
DESKTOP_PATH="${HOME_PATH}/Desktop"

# 时间戳
CURRENT_TIME=$(date "+%Y-%m-%d %H-%M-%S")

# 归档路径
ARCHIVE_PATH="${DESKTOP_PATH}/${TARGET_NAME} ${CURRENT_TIME}/${TARGET_NAME}.xcarchive"

# 导出路径
EXPORT_PATH="${DESKTOP_PATH}/${TARGET_NAME} ${CURRENT_TIME}"

# plist路径
PLIST_PATH="${PROJECT_PATH}/ExportOptions.plist"

#clean
clean_project

#生成xarchive
generateArchive

# 导出ipa
exportArchive

#上传到蒲公英
uploadIpa




