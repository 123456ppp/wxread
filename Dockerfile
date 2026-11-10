FROM python:3.10-slim

WORKDIR /app

# 设置中国时区
ENV TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY main.py push.py config.py log_utils.py scheduler.py ./

# 安装 scheduler.py 和 main.py 所需依赖
RUN python -m pip install --no-cache-dir \
    'APScheduler<4' \
    'requests>=2.32.3' \
    'urllib3>=2.2.3'

# 默认每天北京时间 01:00 执行；需要时可在运行容器时覆盖
ENV CRON_SCHEDULE="0 1 * * *"

# 使用项目自带的 APScheduler，不再写入 /etc/cron.d
CMD ["python", "scheduler.py"]
