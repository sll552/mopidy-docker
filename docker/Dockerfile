FROM alpine:3.19.0

RUN apk --no-cache upgrade && \
    apk --no-cache add python3 py3-gobject3 py3-pip python3-dev build-base tini bash gettext && \
    apk --no-cache add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ gosu && \
    apk --no-cache add py3-gst gst-plugins-good gst-plugins-ugly gst-plugins-base gstreamer-tools

RUN --mount=type=bind,source=requirements.txt,target=/root/mopidy/requirements.txt pip install -r /root/mopidy/requirements.txt

ENV MOPIDY_BASE_CONFIG_DIR "/etc/mopidy"
ENV MOPIDY_BASE_DATA_DIR "/volumes/data"
ENV MOPIDY_BASE_MUSIC_DIR "/volumes/music"

COPY base-config.conf ${MOPIDY_BASE_CONFIG_DIR}/mopidy.conf
COPY --chmod=744 entrypoint.sh /root/
COPY iris-system.sh /root/mopidy/

RUN mopidy deps

VOLUME [ "${MOPIDY_BASE_DATA_DIR}" ]
VOLUME [ "${MOPIDY_BASE_MUSIC_DIR}" ]

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "/root/entrypoint.sh" ]