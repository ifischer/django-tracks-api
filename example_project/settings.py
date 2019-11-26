SECRET_KEY = 'fake-key'

INSTALLED_APPS = [
    'django.contrib.contenttypes',
    'django.contrib.auth',
    'tracks_api',
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}
