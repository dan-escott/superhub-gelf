# Collect Virgin Media Super Hub log files in GELF format

## What?

The Super Hub is the consumer modem/router/AP provided by Virgin Media.

GELF is the [Graylog Extended Log Format](https://www.graylog.org/features/gelf).

## Why?

The Virgin Media Super Hub has a log file, but there's no out-of-the-box way to centralise it for monitoring and alerting.

## How?

Clone the repo and set up a cron task to run this bash script periodically and push the data into anything that can receive GELF. For example, run `crontab -e` and append:

```
*/1 * * * * cd ~/git/superhub-gelf/ && ./log.sh super_hub log_server log_server_port > /dev/null
```

Arguments:

* `super_hub`: IP address or alias of superhub
    * `192.168.0.1` by default
    * `192.168.100.1` if in modem mode
* `log_server`: IP address or hostname of server that will receive the logs (eg, a running Graylog instance)
* `log_server_port`: the UDP port on which the log server accepts GELF input (eg, `12201` by default for Graylog)

## Support

This is only tested on the Super Hub 3.