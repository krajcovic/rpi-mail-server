FROM resin/rpi-raspbian
MAINTAINER Dusan Krajcovic <dusan.krajcovic@gmail.com>

ENV DOMAIN_NAME=krajcovic.info

RUN apt-get update && apt-get upgrade -y && apt-get install postfix dovecot-common dovecot-imapd -y

# Tohle smazat
RUN apt-get install vim mc telnet -y

RUN sed -i 's/inet_interfaces = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
RUN sed -i 's/^\(myhostname\s*=\s*\).*$/\1krajcovic\.info/' /etc/postfix/main.cf
RUN sed -i 's/^\(mydestination\s*=\s*\).*$/\1krajcovic\.info/' /etc/postfix/main.cf
RUN sed -i 's/^\(mynetworks\s*=\s*\).*$/\1127\.0\.0\.0\/8/' /etc/postfix/main.cf
#RUN sed -i 's/^\(smtpd_relay_restrictions\s*=\s*\).*$/\1permit_sasl_authenticated,permit_mynetworks/' /etc/postfix/main.cf

RUN echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf
RUN echo "mailbox_command = " >> /etc/postfix/main.cf
#RUN echo "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination" >> /etc/postfix/main.cf
RUN echo "smtpd_recipient_restrictions = permit_sasl_authenticated, reject_unauth_destination" >> /etc/postfix/main.cf
RUN echo "smtpd_helo_required = yes" >> /etc/postfix/main.cf
RUN echo "smtpd_helo_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname, check_helo_access hash:/etc/postfix/helo_access" >> /etc/postfix/main.cf
RUN echo "krajcovic.info		REJECT		Get lost - you're lying about who are you" >> /etc/postfix/helo_access
RUN postmap /etc/postfix/helo_access


RUN maildirmake.dovecot /etc/skel/Maildir;maildirmake.dovecot /etc/skel/Maildir/.Drafts;maildirmake.dovecot /etc/skel/Maildir/.Sent;maildirmake.dovecot /etc/skel/Maildir/.Spam;maildirmake.dovecot /etc/skel/Maildir/.Trash;maildirmake.dovecot /etc/skel/Maildir/.Templates;
RUN echo "listen = *" >> /etc/dovecot/dovecot.conf
RUN sed -i 's/^\(mail_location\s*=\s*\).*$/\1maildir\:\~\/Maildir/' /etc/dovecot/conf.d/10-mail.conf
RUN echo "smtpd_sasl_type = dovecot" >> /etc/postfix/main.cf
RUN echo "smtpd_sasl_path = private/auth" >> /etc/postfix/main.cf
RUN echo "smtpd_sasl_auth_enable = yes" >> /etc/postfix/main.cf
COPY etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf

RUN echo "Postfix/dovecot installed" >> /var/log/mail.log
#RUN /etc/init.d/postfix reload

EXPOSE 25
EXPOSE 143
EXPOSE 993
EXPOSE 110
EXPOSE 995

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
