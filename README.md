# Centralise Virgin Media Super Hub log files using GELF

## What?

The Super Hub is the consumer modem/router/AP provided by Virgin Media.

GELF is the [Graylog Extended Log Format](https://www.graylog.org/features/gelf).

## Why?

The Virgin Media Super Hub has a log file, but there's no out-of-the-box way to centralise it for monitoring and alerting.

## How?

The app queries an unauthenticated endpoint on the Super Hub, extracts the logs and pushes the data into anything that can receive GELF (eg, [Graylog](https://www.graylog.org/)).

## Installation

Clone the repo, install the dependencies and set up a cron task to run the bash script periodically. For example, run `crontab -e` and append:

```
*/1 * * * * cd ~/git/superhub-gelf/ && ./log.sh super_hub log_server log_server_port > /dev/null
```

### Options

* `super_hub`: IP address or alias of superhub
    * `192.168.0.1` by default
    * `192.168.100.1` if in modem mode
* `log_server`: IP address or hostname of server that will receive the logs (eg, a running Graylog instance)
* `log_server_port`: the UDP port on which the log server accepts GELF input (eg, `12201` by default for Graylog)
* `timezone`: the time zone of the superhub (defaults to UTC)

### Dependencies

* [jq](https://stedolan.github.io/jq/download)

## Support

This is only tested on the Super Hub 3.
