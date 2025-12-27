"""Django settings for django-secretary project."""
import os

from django.utils.translation import gettext_lazy as _

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

SECRET_KEY = 'FREDTEST'

DEBUG = True

ALLOWED_HOSTS = [
    '*'
]

TIME_ZONE = 'Europe/Prague'
USE_TZ = True
USE_I18N = True
USE_L10N = True

INSTALLED_APPS = (
    'django.contrib.contenttypes.apps.ContentTypesConfig',
    'django.contrib.auth.apps.AuthConfig',
    'django.contrib.admin.apps.AdminConfig',
    'django.contrib.messages.apps.MessagesConfig',
    'django.contrib.sessions.apps.SessionsConfig',
    'django.contrib.staticfiles.apps.StaticFilesConfig',
    'rest_framework',
    'rest_framework.authtoken',
    'django_filters',
    'django_secretary.apps.SecretaryAppConfig',
)

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
]

STATIC_ROOT = '/var/www/fred/secretary/static'
STATIC_URL = '/static/'
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'
MEDIA_ROOT = '/var/www/fred/secretary/media'
MEDIA_URL = '/media/'

ROOT_URLCONF = 'secretary_cfg.urls'

LANGUAGE_CODE = 'en'
LANGUAGES = [
    ('en', _('English')),
]

DATABASES = {
    'default': {
        'NAME': 'secretary',
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': '127.0.0.1',
        'USER': 'secretary',
        'PASSWORD': 'passwd',
    }
}

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.template.context_processors.i18n',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

SECRETARY_RENDERERS = ('django_secretary.renderers.HtmlRenderer',
                       'django_secretary.renderers.TextRenderer',
                       'django_secretary.renderers.PdfRenderer')

SECRETARY_TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'OPTIONS': {'loaders': ['django_secretary.utils.templates.TemplateLoader']},
    },
    {
        'NAME': 'text',
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'OPTIONS': {'autoescape': False,
                    'loaders': ['django_secretary.utils.templates.TemplateLoader']},
    },
]

SECRETARY_STATE_FLAGS_DESCRIPTIONS = {
    'mojeidContact': _('MojeID contact'),
    'contactPassedManualVerification': _('Contact has been verified by helpdesk'),
    'contactInManualVerification': _('Contact is being verified by helpdesk'),
    'contactFailedManualVerification': _('Contact has failed the verification by helpdesk'),
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'syslog': {
            'format': 'secretary: %(levelname)-8s %(module)s:%(funcName)s:%(lineno)s %(message)s'
        },
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler',
            'include_html': True,
        },
        'syslog': {
            'class': 'logging.handlers.SysLogHandler',
            'formatter': 'syslog',
            'address': '/dev/log',
        },
    },
    'loggers': {
        '': {
            'handlers': ['syslog'],
            'level': 'DEBUG',
        },
        # Override django logger to only propagate logs to root logger.
        'django': {
            'propagate': True,
        },
        # Handle logs to django.request separately.
        'django.request': {
            'handlers': ['mail_admins', 'syslog'],
            'level': 'ERROR',
            'propagate': False,
        },
    },
}
