FROM ubuntu:12.04
# The following line ensures that /tmp is not under AUFS.
# (Some Python packages won't install correctly if /tmp is under AUFS.)
VOLUME /tmp
# It looks like HandyRep listens on port 5000.
EXPOSE 5000
RUN apt-get -qy install python-setuptools libpq-dev python-dev
# pip 1.5 breaks our version of setuptools, so fallback to 1.4.
RUN easy_install pip==1.4
# Pre-install our dependencies.
RUN pip install 'psycopg2>=2.5'
RUN pip install 'fabric>=1.7'
RUN pip install 'ConfigObj>=4.6'
RUN pip install 'jinja2>=2.0'
RUN pip install 'flask>=0.8'
# Re-install dependencies (this will go superfast since we already have them).
# This is a safety net if Dockerfile and requirements.txt go out of sync.
ADD ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
# Add the code itself.
ADD ./handyrep /handyrep
WORKDIR /handyrep
# Make sure that the mountpoint for the configuration file exists.
RUN touch handyrep.conf
# Check that a non-empty config file was bind-mounted on our placeholder,
# and if it's the case, start. Otherwise, give some explanations.
CMD \
	if [ -s handyrep.conf ]; \
	then ./hrdaemon.sh; \
	else echo "Please bind-mount a configuration file to /handyrep/handyrep.conf (with e.g. docker run -v /path/to/config:/handyrep/handyrep.conf)"; \
	fi
