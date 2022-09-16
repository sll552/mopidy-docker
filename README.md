# mopidy-docker

# Example

```bash
docker run \
  -d \
  --restart on-failure \
  --device /dev/snd \
  -v /storage/music/:/volumes/music \
  -v /storage/mopidy/data:/volumes/data \
  -m 2G \
  -e "MOPIDY_CONFIG_AUDIO_MIXER=none" \
  -e "MOPIDY_CONFIG_AUDIO_OUTPUT=alsasink device=hw:1,0" \
  -p 6680:6680 \
  dertyp/mopidy:main
```
