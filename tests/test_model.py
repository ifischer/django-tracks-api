import pytest
from tracks.models import Track


@pytest.mark.django_db
def test_foo():
    track = Track(artist='Foo', title='Bar')
    track.save()

    print(f"Tracks: {Track.objects.count()}")
