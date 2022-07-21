# Simple log rotation tool

Use `rotate` in a daily cron job or systemd unit to rotate log files.

`rotate` maintains 7 log files, optionally compressed with `zstd`.

```console
% echo message > debug.log
% ls
debug.log
% rotate debug.log
% ls
debug.log.1
% echo another message > debug.log
% ls
debug.log
debug.log.1
% rotate --zstd debug.log
debug.log.1
debug.log.2.zst
```
