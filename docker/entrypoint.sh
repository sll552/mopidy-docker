#!/bin/bash

set -e

MOPIDY_CMD_ARGS=()
MOPIDY_UID=${MOPIDY_UID:-"$(id -u)"}
MOPIDY_GID=${MOPIDY_GID:-"$(id -g)"}

if [[ -f ${MOPIDY_ADDITIONAL_REQUIREMENTS} ]]; then
  pip install -r "${MOPIDY_ADDITIONAL_REQUIREMENTS}"
fi

if [[ -f ${MOPIDY_ADDITIONAL_CONFIG} ]]; then
  MOPIDY_CMD_ARGS+=("--config" "${MOPIDY_BASE_CONFIG_DIR}:${MOPIDY_ADDITIONAL_CONFIG}")
else
  MOPIDY_CMD_ARGS+=("--config" "${MOPIDY_BASE_CONFIG_DIR}")
fi

while IFS= read -r conf; do
  conf_name="${conf%%=*}"
  conf_value="${conf#*=}"
  MOPIDY_CMD_ARGS+=("-o" "$(echo "${conf_name##MOPIDY_CONFIG_}" | tr _ / | tr '[:upper:]' '[:lower:]')=${conf_value}")
done < <(env | grep "MOPIDY_CONFIG_")

audio_group="audio"
if [[ -d /dev/snd ]]; then
  audio_group=$(stat -c "%g" "$(find /dev/snd -type c | head -n1)")
fi

if [[ ${MOPIDY_UID} != root && ${MOPIDY_UID} != 0 ]]; then
  adduser -s /bin/false -G "${MOPIDY_GID}" -D -u "${MOPIDY_UID}" mopidy
  adduser mopidy "${audio_group}"
fi

find "${MOPIDY_BASE_CONFIG_DIR}" -name "*.conf" -type f -exec sh -c 'envsubst < "$1" > "/tmp/tmpconf" && mv /tmp/tmpconf "$1"' _ {} \;

mopidy_exec="$(which mopidy)"
mopidy_old_exec="$(dirname "${mopidy_exec}")"/mopidy-orig

if [[ ! -f "${mopidy_old_exec}" ]]; then
  mv "${mopidy_exec}" "${mopidy_old_exec}"
  cat << EOF > "${mopidy_exec}"
#! /bin/bash
exec "${mopidy_old_exec}" $(printf "%q " "${MOPIDY_CMD_ARGS[@]}") "\$@"
EOF
  chmod +x "${mopidy_exec}"
fi

# Make iris local scan trigger work
iris_system_sh_loc="$(find /usr/lib/python* -name "system.sh" | head -n1)"
iris_system_py_loc="$(dirname "${iris_system_sh_loc}")"/system.py

cp /root/mopidy/iris-system.sh "${iris_system_sh_loc}"
chmod +x "${iris_system_sh_loc}"
sed -i 's/_USE_SUDO = True/_USE_SUDO = False/g' "${iris_system_py_loc}"

exec gosu "${MOPIDY_UID}:${MOPIDY_GID}" mopidy
