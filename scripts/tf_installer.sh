#!/usr/bin/env bash

function entrypoint {
	cat <<-EEOF
#!/usr/bin/env bash

source \${CONDA_PREFIX}/etc/profile.d/conda.sh

if [ ! -f ~/.jupyter/jupyter_notebook_config.py ];
then
	mkdir -p ~/.jupyter
	cat > ~/.jupyter/jupyter_notebook_config.py<<-EOF
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.token = ''
EOF
fi

echo "spark.driver.bindAddress    \$(getent hosts \${HOSTNAME} | awk '{print \$1}')" | sudo tee \${SPARK_HOME}/conf/spark-defaults.conf

[ -n "\${SPARK_BLOCKMANAGER_PORT}" ] && echo "spark.blockManager.port    \${SPARK_BLOCKMANAGER_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
[ -n "\${SPARK_BROADCAST_PORT}" ] && echo "spark.broadcast.port    \${SPARK_BROADCAST_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
[ -n "\${SPARK_DRIVER_PORT}" ] && echo "spark.driver.port    \${SPARK_DRIVER_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
[ -n "\${SPARK_EXECUTOR_PORT}" ] && echo "spark.executor.port    \${SPARK_EXECUTOR_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
[ -n "\${SPARK_FILESERVER_PORT}" ] && echo "spark.fileserver.port    \${SPARK_FILESERVER_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
[ -n "\${SPARK_REPLCLASSSERVER_PORT}" ] && echo "spark.replClassServer.port    \${SPARK_REPLCLASSSERVER_PORT}" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.jars.ivy  /data/notebook_data/.ivy2" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf
echo "spark.yarn.archive   /usr/local/spark/spark-archive.zip" | sudo tee -a \${SPARK_HOME}/conf/spark-defaults.conf

bash -c "\$@"
EEOF
}

function environment {
	cat <<-EOF
dependencies:
  - flask=0.12.2
  - ipykernel=4.10.0
  - ipython=5.8.0
  - jupyter=1.0.0
  - networkx=2.1
  - notebook=5.4.1
  - numpy=1.15.0
  - openjdk=8.0.152
  - pandas=0.22.0
  - requests=2.19.1
  - scikit-learn=0.19.2
  - scipy=1.1.0
  - seaborn=0.9.0
  - tensorflow=1.12.0
  - pip:
    - backports-abc==0.5
    - backports.ssl-match-hostname==3.5.0.1
    - docker==3.6.0
    - py4j==0.10.4
    - boto3
    - sagemaker
    - awscli
    - alpine
    - urllib3==1.22
EOF
}

function kernel2 {
	cat<<-EOF
{
 "argv": [
  "/opt/conda/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python 2",
 "env": {
   "IPYTHON": "1",
   "PYSPARK_PYTHON": "/opt/conda/bin/python",
   "PYSPARK_DRIVER_PYTHON": "ipython",
   "PYSPARK_DRIVER_PYTHON_OPTS": "notebook"
 },
 "language": "python"
EOF
}

function kernel3 {
	cat<<-EOF
{
 "argv": [
  "/opt/conda/envs/python3/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python 3",
 "env": {
   "IPYTHON": "1",
   "PYSPARK_PYTHON": "/opt/conda/envs/python3/bin/python",
   "PYSPARK_DRIVER_PYTHON": "ipython",
   "PYSPARK_DRIVER_PYTHON_OPTS": "notebook"
 },
 "language": "python"
}
EOF
}

function dockerfile() {
	cat <<-EOF
FROM alpine

ARG CONDA_PREFIX=/opt/conda
ENV CONDA_DEFAULT_ENV=base \
    CONDA_ENV_FILE=\${CONDA_PREFIX}/environment.yaml \
    CONDA_EXE=\${CONDA_PREFIX}/bin/conda \
    CONDA_PREFIX=\${CONDA_PREFIX} \
    CONDA_PROMPT_MODIFIER=(base) \
    CONDA_PYTHON_EXE=\${CONDA_PREFIX}/bin/python \
    CONDA_SHLVL=2 \
    PATH=\${CONDA_PREFIX}/bin:\${PATH} \
    PYTHONPATH=/usr/local/spark/python:/data \
    SPARK_HOME=/usr/local/spark

RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-bin-2.28-r0.apk \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-i18n-2.28-r0.apk \
 && apk add --allow-untrusted glibc-2.28-r0.apk glibc-bin-2.28-r0.apk glibc-i18n-2.28-r0.apk \
 && rm *.apk \
 && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8

RUN wget https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh \
 && sh Miniconda2-latest-Linux-x86_64.sh -u -b -p \${CONDA_PREFIX} \
 && rm -f Miniconda2-latest-Linux-x86_64.sh

COPY environment.yaml \${CONDA_ENV_FILE}

RUN source activate \
 && conda env update -f \${CONDA_ENV_FILE} \
 && python -m ipykernel install

RUN conda create -y -n python3 python=3.6.6 \
 && source activate python3 \
 && conda env update -f \${CONDA_ENV_FILE} \
 && python -m ipykernel install

COPY python2.json /usr/local/share/jupyter/kernels/python2/kernel.json
COPY python3.json /usr/local/share/jupyter/kernels/python3/kernel.json

RUN apk add --no-cache -t required bash dcron krb5 sudo tini-static \
 && adduser -h /data -D tibco \
 && bash -c "echo 'tibco ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers" \
 && sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers \
 && chmod o+x /usr/bin/crontab \
 && mkdir -p /home/chorus \
 && ln -s /data/hdfs_configs /home/chorus/ChorusCommander \
 && chown -R tibco:tibco /home/chorus \
 && mkdir -p /usr/local/spark \
 && wget -qO- https://archive.apache.org/dist/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.6.tgz \
    | tar xvz -C /usr/local/spark --strip-components=1 \
 && cd /usr/local/spark/jars \
 && jar -cMvf /usr/local/spark/spark-archive.zip * \
 && mkdir -p /etc/krb5.conf.d \
 && bash -c "echo 'tibco ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["tini-static", "--", "/usr/local/bin/entrypoint.sh"]

USER tibco
WORKDIR /data
EOF
}

entrypoint > entrypoint.sh && chmod +x entrypoint.sh
environment > environment.yaml
kernel2 > python2.json
kernel3 > python3.json
cat <(dockerfile) | docker build --force-rm -t sfire-dscpn:pyspark -f - . 
docker image prune -f
rm -f entrypoint.sh environment.yaml *.json
