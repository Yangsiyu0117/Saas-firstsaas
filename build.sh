#!/bin/bash
# @author：morton
ver=$1
APP_CODE=$(grep 'app_code:' app.yml | cut -c 10-|sed 's/^[ \t]*//g')
CURRENT=`date "+%Y%m%d%H%M%S"`


# app.yml文件构建
rm -rf $APP_CODE
mkdir -p $APP_CODE/src $APP_CODE/pkgs || exit 1
rsync -av --exclude="$APP_CODE" --exclude=".*" --exclude="*.tar.gz" --exclude=" __pycache__" --exclude="app.yml" --exclude="build.sh" ./* ./$APP_CODE/src/ || exit 1
cp app.yml $APP_CODE/ || exit 1
echo "libraries:" >> $APP_CODE/app.yml
pip download -d $APP_CODE/pkgs/ -r requirements.txt || exit 1
# 版本修改，smart版本与静态文静版本一致
sed -i "s/STATIC_VERSION = .*/STATIC_VERSION = \"${ver}\"/" $APP_CODE/src/config/default.py
sed -i "s/APP_CODE = .*/APP_CODE = \"${APP_CODE}\"/" $APP_CODE/src/config/__init__.py
sed -i "s/version: .*/version: ${ver}/" $APP_CODE/app.yml
grep -e "^[^#].*$" requirements.txt | awk '{split($1,b,"==");printf "- name: "b[1]"\n  version: "b[2]"\n"}' >> $APP_CODE/app.yml

# 编译打包
python -m compileall -b $APP_CODE/src/ && find $APP_CODE/src -f name "*.py"  | xargs rm -f
tar -zcvf "$APP_CODE-$CURRENT.tar.gz" $APP_CODE
echo "current version: ${ver}"
rm -rf $APP_CODE
