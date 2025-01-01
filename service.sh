#!/data/adb/magisk/busybox sh
MODDIR=${0%/*}
echo $MODDIR >> ${MODDIR}/frpc.log

chmod 755 ${MODDIR}/*
CONF=$(cat ${MODDIR}/frpc.toml)
# 读取配置文件
while true; do
    CONF2=$(cat ${MODDIR}/frpc.toml)
    #如果配置文件与之前的不一致，则停止任务等5秒后重启
    if $CONF2!=$CONF; then
        echo "检测到配置修改，即将停止任务待重启" >> ${MODDIR}/frpc.log
        PID=$(ps -ef|grep "${MODDIR}/frpc -c ${MODDIR}/frpc.toml" | awk '{print $2}')
        kill PID
        $CONF=$CONF2
        $CONF=''
        sleep 5
    fi
    if ! pgrep -f "${MODDIR}/frpc" > ${MODDIR}/frpc.log; then
        echo "检测任务已停止，开始启动" >> ${MODDIR}/frpc.log
        nohup ${MODDIR}/frpc -c ${MODDIR}/frpc.toml >> ${MODDIR}/frpc.log 2>&1 &
        echo "启动完成" >> ${MODDIR}/frpc.log
    fi
    # 每隔2分钟检查任务进程，不存在则启动任务
    sleep 120
done
