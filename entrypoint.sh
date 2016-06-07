#!/bin/bash

/etc/init.d/postfix status
/etc/init.d/postfix start
#/etc/init.d/postfix reload
tail -f /var/log/mail.log
