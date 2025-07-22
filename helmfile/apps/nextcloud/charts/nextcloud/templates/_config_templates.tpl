{{/*
Nextcloud Configuration Templates Library
*/}}

{{/*
.htaccess template
*/}}
{{- define "nextcloud.htaccess-config" -}}
# line below if for Apache 2.4
<ifModule mod_authz_core.c>
Require all denied
</ifModule>
# line below if for Apache 2.2
<ifModule !mod_authz_core.c>
deny from all
</ifModule>
# section for Apache 2.2 and 2.4
<ifModule mod_autoindex.c>
IndexIgnore *
</ifModule>
{{- end -}}

{{/*
Apache pretty URLs config
*/}}
{{- define "nextcloud.apache-pretty-urls-config" -}}
<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
);
{{- end -}}

{{/*
APCu cache config
*/}}
{{- define "nextcloud.apcu-config" -}}
<?php
$CONFIG = array (
  'memcache.local' => '\OC\Memcache\APCu',
);
{{- end -}}

{{/*
Apps paths config
*/}}
{{- define "nextcloud.apps-config" -}}
<?php
$CONFIG = array (
  'apps_paths' => array (
      0 => array (
              'path'     => OC::$SERVERROOT.'/apps',
              'url'      => '/apps',
              'writable' => false,
      ),
      1 => array (
              'path'     => OC::$SERVERROOT.'/custom_apps',
              'url'      => '/custom_apps',
              'writable' => true,
      ),
  ),
);
{{- end -}}

{{/*
Auto-configuration for databases
*/}}
{{- define "nextcloud.autoconfig" -}}
<?php
$autoconfig_enabled = false;
if (getenv('SQLITE_DATABASE')) {
    $AUTOCONFIG["dbtype"] = "sqlite";
    $AUTOCONFIG["dbname"] = getenv('SQLITE_DATABASE');
    $autoconfig_enabled = true;
} elseif (getenv('MYSQL_DATABASE_FILE') && getenv('MYSQL_USER_FILE') && getenv('MYSQL_PASSWORD_FILE') && getenv('MYSQL_HOST')) {
    $AUTOCONFIG['dbtype'] = 'mysql';
    $AUTOCONFIG['dbname'] = trim(file_get_contents(getenv('MYSQL_DATABASE_FILE')));
    $AUTOCONFIG['dbuser'] = trim(file_get_contents(getenv('MYSQL_USER_FILE')));
    $AUTOCONFIG['dbpass'] = trim(file_get_contents(getenv('MYSQL_PASSWORD_FILE')));
    $AUTOCONFIG['dbhost'] = getenv('MYSQL_HOST');
    $autoconfig_enabled = true;
} elseif (getenv('MYSQL_DATABASE') && getenv('MYSQL_USER') && getenv('MYSQL_PASSWORD') && getenv('MYSQL_HOST')) {
    $AUTOCONFIG["dbtype"] = "mysql";
    $AUTOCONFIG["dbname"] = getenv('MYSQL_DATABASE');
    $AUTOCONFIG["dbuser"] = getenv('MYSQL_USER');
    $AUTOCONFIG["dbpass"] = getenv('MYSQL_PASSWORD');
    $AUTOCONFIG["dbhost"] = getenv('MYSQL_HOST');
    $autoconfig_enabled = true;
} elseif (getenv('POSTGRES_DB_FILE') && getenv('POSTGRES_USER_FILE') && getenv('POSTGRES_PASSWORD_FILE') && getenv('POSTGRES_HOST')) {
    $AUTOCONFIG['dbtype'] = 'pgsql';
    $AUTOCONFIG['dbname'] = trim(file_get_contents(getenv('POSTGRES_DB_FILE')));
    $AUTOCONFIG['dbuser'] = trim(file_get_contents(getenv('POSTGRES_USER_FILE')));
    $AUTOCONFIG['dbpass'] = trim(file_get_contents(getenv('POSTGRES_PASSWORD_FILE')));
    $AUTOCONFIG['dbhost'] = getenv('POSTGRES_HOST');
    $autoconfig_enabled = true;
} elseif (getenv('POSTGRES_DB') && getenv('POSTGRES_USER') && getenv('POSTGRES_PASSWORD') && getenv('POSTGRES_HOST')) {
    $AUTOCONFIG["dbtype"] = "pgsql";
    $AUTOCONFIG["dbname"] = getenv('POSTGRES_DB');
    $AUTOCONFIG["dbuser"] = getenv('POSTGRES_USER');
    $AUTOCONFIG["dbpass"] = getenv('POSTGRES_PASSWORD');
    $AUTOCONFIG["dbhost"] = getenv('POSTGRES_HOST');
    $autoconfig_enabled = true;
}
if ($autoconfig_enabled) {
    $AUTOCONFIG["directory"] = getenv('NEXTCLOUD_DATA_DIR') ?: "/var/www/html/data";
}
{{- end -}}

{{/*
Redis cache config
*/}}
{{- define "nextcloud.redis-config" -}}
<?php
if (getenv('REDIS_HOST')) {
  $CONFIG = array(
    'memcache.distributed' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => array(
      'host' => getenv('REDIS_HOST'),
      'password' => getenv('REDIS_HOST_PASSWORD_FILE') ? trim(file_get_contents(getenv('REDIS_HOST_PASSWORD_FILE'))) : (string) getenv('REDIS_HOST_PASSWORD'),
    ),
  );

  if (getenv('REDIS_HOST_PORT') !== false) {
    $CONFIG['redis']['port'] = (int) getenv('REDIS_HOST_PORT');
  } elseif (getenv('REDIS_HOST')[0] != '/') {
    $CONFIG['redis']['port'] = 6379;
  }
}
{{- end -}}

{{/*
Reverse proxy config
*/}}
{{- define "nextcloud.reverse-proxy-config" -}}
<?php
$overwriteHost = getenv('OVERWRITEHOST');
if ($overwriteHost) {
  $CONFIG['overwritehost'] = $overwriteHost;
}

$overwriteProtocol = getenv('OVERWRITEPROTOCOL');
if ($overwriteProtocol) {
  $CONFIG['overwriteprotocol'] = $overwriteProtocol;
}

$overwriteCliUrl = getenv('OVERWRITECLIURL');
if ($overwriteCliUrl) {
  $CONFIG['overwrite.cli.url'] = $overwriteCliUrl;
}

$overwriteWebRoot = getenv('OVERWRITEWEBROOT');
if ($overwriteWebRoot) {
  $CONFIG['overwritewebroot'] = $overwriteWebRoot;
}

$overwriteCondAddr = getenv('OVERWRITECONDADDR');
if ($overwriteCondAddr) {
  $CONFIG['overwritecondaddr'] = $overwriteCondAddr;
}

$trustedProxies = getenv('TRUSTED_PROXIES');
if ($trustedProxies) {
  $CONFIG['trusted_proxies'] = array_filter(array_map('trim', explode(' ', $trustedProxies)));
}

$forwardedForHeaders = getenv('FORWARDED_FOR_HEADERS');
if ($forwardedForHeaders) {
  $CONFIG['forwarded_for_headers'] = array_filter(array_map('trim', explode(' ', $forwardedForHeaders)));
}
{{- end -}}

{{/*
S3 object storage config
*/}}
{{- define "nextcloud.s3-config" -}}
<?php
if (getenv('OBJECTSTORE_S3_BUCKET')) {
  $use_ssl = getenv('OBJECTSTORE_S3_SSL');
  $use_path = getenv('OBJECTSTORE_S3_USEPATH_STYLE');
  $use_legacyauth = getenv('OBJECTSTORE_S3_LEGACYAUTH');
  $autocreate = getenv('OBJECTSTORE_S3_AUTOCREATE');
  $CONFIG = array(
    'objectstore' => array(
      'class' => '\OC\Files\ObjectStore\S3',
      'arguments' => array(
        'bucket' => getenv('OBJECTSTORE_S3_BUCKET'),
        'region' => getenv('OBJECTSTORE_S3_REGION') ?: '',
        'hostname' => getenv('OBJECTSTORE_S3_HOST') ?: '',
        'port' => getenv('OBJECTSTORE_S3_PORT') ?: '',
        'storageClass' => getenv('OBJECTSTORE_S3_STORAGE_CLASS') ?: '',
        'objectPrefix' => getenv("OBJECTSTORE_S3_OBJECT_PREFIX") ? getenv("OBJECTSTORE_S3_OBJECT_PREFIX") : "urn:oid:",
        'autocreate' => strtolower($autocreate) !== 'false',
        'use_ssl' => strtolower($use_ssl) !== 'false',
        // required for some non Amazon S3 implementations
        'use_path_style' => $use_path == true && strtolower($use_path) !== 'false',
        // required for older protocol versions
        'legacy_auth' => $use_legacyauth == true && strtolower($use_legacyauth) !== 'false'
      )
    )
  );

  if (getenv('OBJECTSTORE_S3_KEY_FILE')) {
    $CONFIG['objectstore']['arguments']['key'] = trim(file_get_contents(getenv('OBJECTSTORE_S3_KEY_FILE')));
  } elseif (getenv('OBJECTSTORE_S3_KEY')) {
    $CONFIG['objectstore']['arguments']['key'] = getenv('OBJECTSTORE_S3_KEY');
  } else {
    $CONFIG['objectstore']['arguments']['key'] = '';
  }

  if (getenv('OBJECTSTORE_S3_SECRET_FILE')) {
    $CONFIG['objectstore']['arguments']['secret'] = trim(file_get_contents(getenv('OBJECTSTORE_S3_SECRET_FILE')));
  } elseif (getenv('OBJECTSTORE_S3_SECRET')) {
    $CONFIG['objectstore']['arguments']['secret'] = getenv('OBJECTSTORE_S3_SECRET');
  } else {
    $CONFIG['objectstore']['arguments']['secret'] = '';
  }

  if (getenv('OBJECTSTORE_S3_SSE_C_KEY_FILE')) {
    $CONFIG['objectstore']['arguments']['sse_c_key'] = trim(file_get_contents(getenv('OBJECTSTORE_S3_SSE_C_KEY_FILE')));
  } elseif (getenv('OBJECTSTORE_S3_SSE_C_KEY')) {
    $CONFIG['objectstore']['arguments']['sse_c_key'] = getenv('OBJECTSTORE_S3_SSE_C_KEY');
  }
}
{{- end -}}

{{/*
SMTP mail config
*/}}
{{- define "nextcloud.smtp-config" -}}
<?php
if (getenv('SMTP_HOST') && getenv('MAIL_FROM_ADDRESS') && getenv('MAIL_DOMAIN')) {
  $CONFIG = array (
    'mail_smtpmode' => 'smtp',
    'mail_smtphost' => getenv('SMTP_HOST'),
    'mail_smtpport' => getenv('SMTP_PORT') ?: (getenv('SMTP_SECURE') ? 465 : 25),
    'mail_smtpsecure' => getenv('SMTP_SECURE') ?: '',
    'mail_smtpauth' => getenv('SMTP_NAME') && (getenv('SMTP_PASSWORD') || getenv('SMTP_PASSWORD_FILE')),
    'mail_smtpauthtype' => getenv('SMTP_AUTHTYPE') ?: 'LOGIN',
    'mail_smtpname' => getenv('SMTP_NAME') ?: '',
    'mail_from_address' => getenv('MAIL_FROM_ADDRESS'),
    'mail_domain' => getenv('MAIL_DOMAIN'),
  );

  if (getenv('SMTP_PASSWORD_FILE')) {
      $CONFIG['mail_smtppassword'] = trim(file_get_contents(getenv('SMTP_PASSWORD_FILE')));
  } elseif (getenv('SMTP_PASSWORD')) {
      $CONFIG['mail_smtppassword'] = getenv('SMTP_PASSWORD');
  } else {
      $CONFIG['mail_smtppassword'] = '';
  }
}
{{- end -}}

{{/*
Swift object storage config
*/}}
{{- define "nextcloud.swift-config" -}}
<?php
if (getenv('OBJECTSTORE_SWIFT_URL')) {
    $autocreate = getenv('OBJECTSTORE_SWIFT_AUTOCREATE');
  $CONFIG = array(
    'objectstore' => [
      'class' => 'OC\\Files\\ObjectStore\\Swift',
      'arguments' => [
        'autocreate' => $autocreate == true && strtolower($autocreate) !== 'false',
        'user' => [
          'name' => getenv('OBJECTSTORE_SWIFT_USER_NAME'),
          'password' => getenv('OBJECTSTORE_SWIFT_USER_PASSWORD'),
          'domain' => [
            'name' => (getenv('OBJECTSTORE_SWIFT_USER_DOMAIN')) ?: 'Default',
          ],
        ],
        'scope' => [
          'project' => [
            'name' => getenv('OBJECTSTORE_SWIFT_PROJECT_NAME'),
            'domain' => [
              'name' => (getenv('OBJECTSTORE_SWIFT_PROJECT_DOMAIN')) ?: 'Default',
            ],
          ],
        ],
        'serviceName' => (getenv('OBJECTSTORE_SWIFT_SERVICE_NAME')) ?: 'swift',
        'region' => getenv('OBJECTSTORE_SWIFT_REGION'),
        'url' => getenv('OBJECTSTORE_SWIFT_URL'),
        'bucket' => getenv('OBJECTSTORE_SWIFT_CONTAINER_NAME'),
      ]
    ]
  );
}
{{- end -}}

{{/*
Disable web-based updater config
*/}}
{{- define "nextcloud.upgrade-disable-web-config" -}}
<?php
$CONFIG = array (
  'upgrade.disable-web' => true,
);
{{- end -}}
