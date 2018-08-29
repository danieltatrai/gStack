import os

from .utils import read_secret


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEBUG = os.environ.get('ENV') == 'DEV'
PROD = os.environ.get('ENV') == 'PROD'

STATIC_URL = '/assets/'
STATIC_ROOT = '/src/static/'

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

MEDIA_ROOT = '/data/files/media/'
MEDIA_URL = '/media/'

ROOT_URLCONF = 'core.urls'

SECRET_KEY = read_secret('DJANGO_SECRET_KEY')
ALLOWED_HOSTS = [os.environ.get('HOST_NAME'), os.environ.get('SERVER_IP')]
BASE_URL = os.environ.get('HOST_NAME')

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'core',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# if DEBUG:
#     INSTALLED_APPS.append('debug_toolbar')
#     MIDDLEWARE_CLASSES.append(
#         'debug_toolbar.middleware.DebugToolbarMiddleware'
#     )

pwd_path = 'django.contrib.auth.password_validation.'
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': pwd_path + 'MinimumLengthValidator',
        'OPTIONS': {
            'min_length': 8,
        }
    },
    {
        'NAME': pwd_path + 'UserAttributeSimilarityValidator',
        'OPTIONS': {
            'user_attributes': ('first_name', 'last_name', 'email'),
        }
    },
]

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# Database
db_password = read_secret('DB_PASSWORD')
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': 'postgres',
        'PORT': '5432',
        'NAME': 'django',
        'USER': 'django',
        'PASSWORD': db_password,
        'OPTIONS': {
            'sslmode': 'verify-ca',
        },
    },
}

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = False
USE_TZ = True

# LANGUAGES = (
#     ('en', _('English')),
#     ('hu', _('Hungarian')),
# )

# LOCALE_PATHS = ('/data/files/locale/',)
# MESSAGE_STORAGE = 'django.contrib.messages.storage.session.SessionStorage'

DATE_FORMAT = ('Y-m-d')
DATETIME_FORMAT = ('Y-m-d H:i:s')
TIME_FORMAT = ('H:i:s')

# File Upload max 50MB
DATA_UPLOAD_MAX_MEMORY_SIZE = 52428800
FILE_UPLOAD_MAX_MEMORY_SIZE = 52428800

FILE_UPLOAD_DIRECTORY_PERMISSIONS = 0o750
FILE_UPLOAD_PERMISSIONS = 0o640

# Set up custom user model
# AUTH_USER_MODEL =

# After a successful authentication this is where we go
# LOGIN_REDIRECT_URL =

# The login page is also the start page too
# LOGIN_URL =

# List of the admins
# ADMINS = (('IS', 'is@vertis.com'),)

# DEBUG_TOOLBAR_CONFIG = {
#     'JQUERY_URL': ,
#     'SHOW_TOOLBAR_CALLBACK': lambda x: DEBUG,
#     'DISABLE_PANELS': (
#         'debug_toolbar.panels.redirects.RedirectsPanel',
#         'ddt_request_history.panels.request_history.RequestHistoryPanel'
#     )
# }
#
# DEBUG_TOOLBAR_PANELS = [
#     'ddt_request_history.panels.request_history.RequestHistoryPanel',
#     'debug_toolbar.panels.versions.VersionsPanel',
#     'debug_toolbar.panels.timer.TimerPanel',
#     'debug_toolbar.panels.settings.SettingsPanel',
#     'debug_toolbar.panels.headers.HeadersPanel',
#     'debug_toolbar.panels.request.RequestPanel',
#     'debug_toolbar.panels.sql.SQLPanel',
#     'debug_toolbar.panels.staticfiles.StaticFilesPanel',
#     'debug_toolbar.panels.templates.TemplatesPanel',
#     'debug_toolbar.panels.cache.CachePanel',
#     'debug_toolbar.panels.signals.SignalsPanel',
#     'debug_toolbar.panels.logging.LoggingPanel',
#     'debug_toolbar.panels.redirects.RedirectsPanel',
# ]

# DEFAULT_FROM_EMAIL =
# EMAIL_HOST =
# EMAIL_PORT =
# SERVER_EMAIL =
# EMAIL_BACKEND =
EMAIL_SUBJECT_PREFIX = '[%s] ' % os.environ.get('HOST_NAME')

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
