
#
# Minimum UID settings, to protect system accounts.  nipasswd will refuse to
# authorize or change accounts with UIDs below these thresholds.
#
MIN_AUTH_UID = 100
MIN_CHANGE_UID = 100

#
# Bad password checking.  Possible values are:  enabled, disabled, optional.
#
#BADPW_CHECKS = enabled
#BADPW_CHECKS = disabled
BADPW_CHECKS = optional

#
# Force insecure connections (http) to secure connections (https).
# Possible values are: enabled, disabled.
#
#FORCE_HTTPS = disabled
FORCE_HTTPS = enabled

#
# The GID your web server uses when running CGIs.  For security reasons, the
# privileged "nipasswd" will be installed with use restricted to this group.
#
CGI_GROUP = www-data

#
# The web-chpass support files installed in this directory.  If the
# directory does not exist, it will be created.
#
DIR_LIB = /usr/local/lib/web-chpass

#
# The chpass.cgi script installed in this directory.
#
DIR_CGI = /usr/local/lib/cgi-bin

#
# Extension (if any) to place on script installed in DIR_CGI.
#
#CGIEXT = .cgi
CGIEXT =

#
# Directory where administrative manpages go.  The nipasswd(8) man page
# will be put here.
#
DIR_MAN8 = /usr/local/man/man8

#
# PAM modules configuration directory.
#
DIR_PAMD = /etc/pam.d

#
# end of configuration settings
#
##############################################################################

CC = gcc
OPTIM = -O2 -Wall
DEFS = -DMIN_AUTH_UID=$(MIN_AUTH_UID) -DMIN_CHANGE_UID=$(MIN_CHANGE_UID)
CFLAGS = $(OPTIM) $(DEFS)
LIBS = -lpam -ldl

INSTALL		= install
INSTALL_PROG	= $(INSTALL) -m 555
INSTALL_DATA	= $(INSTALL) -m 444

INSTALL_ALL = \
	$(DIR_LIB) \
	$(DIR_LIB)/nipasswd \
	$(DIR_LIB)/NiPasswd.pm \
	$(DIR_LIB)/chpass-cgi.pl \
	$(DIR_LIB)/chpass.tmpl \
	$(DIR_CGI)/chpass$(CGIEXT) \
	$(DIR_MAN8)/nipasswd.8 \
	$(DIR_PAMD)/nipasswd

ALL = nipasswd chpass.cgi

FILES = \
	README \
	CHANGES \
	INSTALL \
	Makefile \
	NiPasswd.pm \
	chpass-cgi.pl \
	chpass.cgi.in \
	chpass.tmpl \
	nipasswd.8 \
	nipasswd.c


all : $(FILES) $(ALL)

OBJS = nipasswd.o

nipasswd : $(OBJS)
	$(CC) -o $@ $(CFLAGS) $(OBJS) $(LIBS)

chpass.cgi : chpass.cgi.in Makefile
	sed \
		-e 's!%LIBDIR%!$(DIR_LIB)!g' \
		-e 's!%BADPW_CHECKS%!$(BADPW_CHECKS)!g' \
		-e 's!%FORCE_HTTPS%!$(FORCE_HTTPS)!g' \
		$< >$@

clean :
	rm -f $(ALL) $(OBJS)


install : $(INSTALL_ALL)

$(DIR_LIB) :
	mkdir $@

$(DIR_LIB)/nipasswd : nipasswd
	$(INSTALL) -m 4110 -o root -g $(CGI_GROUP) $< $@

$(DIR_LIB)/NiPasswd.pm : NiPasswd.pm
	$(INSTALL_DATA) $< $@

$(DIR_LIB)/chpass.tmpl : chpass.tmpl
	@if [ -f $@ ] ; then echo "***** Preserving existing $@" ; \
	else ( set -v ; $(INSTALL_DATA) $< $@ ) ; \
	fi

$(DIR_LIB)/chpass-cgi.pl : chpass-cgi.pl
	$(INSTALL_PROG) $< $@

$(DIR_CGI)/chpass$(CGIEXT) : chpass.cgi
	$(INSTALL_PROG) $< $@

$(DIR_MAN8)/nipasswd.8 : nipasswd.8
	$(INSTALL_DATA) $< $@

#
# The "nipasswd" PAM module probably should look the same as what's used
# for "passwd".
#
$(DIR_PAMD)/nipasswd : $(DIR_PAMD)/passwd
	$(INSTALL_DATA) $< $@

