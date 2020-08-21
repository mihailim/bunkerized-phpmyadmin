#!/bin/sh

# replace pattern in file
function replace_in_file() {
	# escape slashes
	pattern=$(echo "$2" | sed "s/\//\\\\\//g")
	replace=$(echo "$3" | sed "s/\//\\\\\//g")
	sed -i "s/$pattern/$replace/g" "$1"
}

# define default variables
PMA_DIRECTORY="${PMA_DIRECTORY-/}"
BLOWFISH_SECRET="${BLOWFISH_SECRET-random}"
if [ "$BLOWFISH_SECRET" = "random" ] ; then
	BLOWFISH_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
fi
LOGIN_COOKIE_RECALL="${LOGIN_COOKIE_RECALL-false}"
LOGIN_COOKIE_VALIDITY="${LOGIN_COOKIE_VALIDITY-720}"
LOGIN_COOKIE_STORE="${LOGIN_COOKIE_STORE-0}"
LOGIN_COOKIE_DELETE_ALL="${LOGIN_COOKIE_DELETE_ALL-true}"
SEND_ERROR_REPORTS="${SEND_ERROR_REPORTS-never}"
ALLOW_THIRD_PARTY_FRAMING="${ALLOW_THIRD_PARTY_FRAMING-false}"
VERSION_CHECK="${VERSION_CHECK-false}"
ALLOW_USER_DROP_DATABASE="${ALLOW_USER_DROP_DATABASE-false}"
CONFIRM="${CONFIRM-true}"
ALLOW_ARBITRARY_SERVER="${ALLOW_ARBITRARY_SERVER-false}"
ARBITRARY_SERVER_REGEXP="${ARBITRARY_SERVER_REGEXP-}"
CAPTCHA_METHOD="${CAPTCHA_METHOD-invisible}"
CAPTCHA_LOGIN_PUBLIC_KEY="${CAPTCHA_LOGIN_PUBLIC_KEY-}"
CAPTCHA_LOGIN_PRIVATE_KEY="${CAPTCHA_LOGIN_PRIVATE_KEY-}"
CAPTCHA_SITE_VERIFY_URL="${CAPTCHA_SITE_VERIFY_URL-https://www.google.com/recaptcha/api/siteverify}"
SHOW_STATS="${SHOW_STATS-false}"
SHOW_SERVER_INFO="${SHOW_SERVER_INFO-false}"
SHOW_PHP_INFO="${SHOW_PHP_INFO-false}"
SHOW_GIT_REVISION="${SHOW_GIT_REVISION-false}"
ALL_SERVERS_SSL="${ALL_SERVERS_SSL-false}"
ALL_SERVERS_HIDE_DB="${ALL_SERVERS_HIDE_DB-^(information_schema|performance_schema)\$}"
ALL_SERVERS_ALLOW_ROOT="${ALL_SERVERS_ALLOW_ROOT-true}"
ALL_SERVERS_ALLOW_NO_PASSWORD="${ALL_SERVERS_ALLOW_NO_PASSWORD-false}"

# TODO : move to a subdirectory

# replace variables
cp /opt/config.inc.php /opt/phpmyadmin/
replace_in_file "/opt/phpmyadmin/config.inc.php" "%BLOWFISH_SECRET%" "$BLOWFISH_SECRET"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%LOGIN_COOKIE_RECALL%" "$LOGIN_COOKIE_RECALL"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%LOGIN_COOKIE_VALIDITY%" "$LOGIN_COOKIE_VALIDITY"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%LOGIN_COOKIE_STORE%" "$LOGIN_COOKIE_STORE"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%LOGIN_COOKIE_DELETE_ALL%" "$LOGIN_COOKIE_DELETE_ALL"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%SEND_ERROR_REPORTS%" "$SEND_ERROR_REPORTS"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%ALLOW_THIRD_PARTY_FRAMING%" "$ALLOW_THIRD_PARTY_FRAMING"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%VERSION_CHECK%" "$VERSION_CHECK"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%ALLOW_USER_DROP_DATABASE%" "$ALLOW_USER_DROP_DATABASE"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%CONFIRM%" "$CONFIRM"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%ALLOW_ARBITRARY_SERVER%" "$ALLOW_ARBITRARY_SERVER"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%ARBITRARY_SERVER_REGEXP%" "$ARBITRARY_SERVER_REGEXP"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%CAPTCHA_METHOD%" "$CAPTCHA_METHOD"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%CAPTCHA_LOGIN_PUBLIC_KEY%" "$CAPTCHA_LOGIN_PUBLIC_KEY"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%CAPTCHA_LOGIN_PRIVATE_KEY%" "$CAPTCHA_LOGIN_PRIVATE_KEY"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%CAPTCHA_SITE_VERIFY_URL%" "$CAPTCHA_SITE_VERIFY_URL"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%SHOW_STATS%" "$SHOW_STATS"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%SHOW_SERVER_INFO%" "$SHOW_SERVER_INFO"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%SHOW_PHP_INFO%" "$SHOW_PHP_INFO"
replace_in_file "/opt/phpmyadmin/config.inc.php" "%SHOW_GIT_REVISION%" "$SHOW_GIT_REVISION"

# include custom servers
ALL_SERVERS=""
for var in $(env) ; do
	#echo "$var"
	var_name=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 1)
	if [ "$var_name" = "SERVERS" ] ; then
		index=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 2)
		param=$(echo "$var" | cut -d '=' -f 1 | cut -d '_' -f 3)
		value=$(echo "$var" | cut -d '=' -f 2)
		ALL_SERVERS="${ALL_SERVERS}\$cfg['Servers'][${index}]['${param}'] = $value;\n"
	fi
done
replace_in_file "/opt/phpmyadmin/config.inc.php" "%ALL_SERVERS%" "$ALL_SERVERS"