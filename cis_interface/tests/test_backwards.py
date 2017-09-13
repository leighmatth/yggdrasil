import nose.tools as nt
from cis_interface import backwards
from cis_interface.backwards import unicode


def test_assert_bytes():
    r"""Ensure that the proper byte types are identified."""
    if backwards.PY2:  # pragma: Python 2
        # backwards.assert_bytes(bytearray('hello', 'utf-8'))
        backwards.assert_bytes('hello')
        nt.assert_raises(AssertionError, backwards.assert_bytes,
                         unicode('hello'))
    else:  # pragma: Python 3
        # backwards.assert_bytes(bytearray('hello', 'utf-8'))
        backwards.assert_bytes(b'hello')
        nt.assert_raises(AssertionError, backwards.assert_bytes,
                         'hello')

        
def test_assert_unicode():
    r"""Ensure that the proper unicode types are identified."""
    if backwards.PY2:  # pragma: Python 2
        # backwards.assert_unicode(unicode('hello'))
        # nt.assert_raises(AssertionError, backwards.assert_unicode, 'hello')
        backwards.assert_unicode('hello')
        nt.assert_raises(AssertionError, backwards.assert_unicode,
                         unicode('hello'))
        nt.assert_raises(AssertionError, backwards.assert_unicode,
                         bytearray('hello', 'utf-8'))
    else:  # pragma: Python 3
        backwards.assert_unicode('hello')
        nt.assert_raises(AssertionError, backwards.assert_unicode, b'hello')
        nt.assert_raises(AssertionError, backwards.assert_unicode,
                         bytearray('hello', 'utf-8'))

        
def test_bytes2unicode():
    r"""Ensure what results is proper bytes type."""
    if backwards.PY2:  # pragma: Python 2
        res = backwards.unicode_type('hello')
        backwards.assert_unicode(res)
        nt.assert_equal(backwards.bytes2unicode('hello'), res)
        nt.assert_equal(backwards.bytes2unicode(unicode('hello')), res)
        nt.assert_equal(backwards.bytes2unicode(bytearray('hello', 'utf-8')), res)
        nt.assert_raises(TypeError, backwards.bytes2unicode, 1)
    else:  # pragma: Python 3
        res = 'hello'
        backwards.assert_unicode(res)
        nt.assert_equal(backwards.bytes2unicode('hello'), res)
        nt.assert_equal(backwards.bytes2unicode(b'hello'), res)
        nt.assert_equal(backwards.bytes2unicode(bytearray('hello', 'utf-8')), res)
        nt.assert_raises(TypeError, backwards.bytes2unicode, 1)


def test_unicode2bytes():
    r"""Ensure what results is proper bytes type."""
    if backwards.PY2:  # pragma: Python 2
        res = backwards.bytes_type('hello')
        backwards.assert_bytes(res)
        nt.assert_equal(backwards.unicode2bytes('hello'), res)
        nt.assert_equal(backwards.unicode2bytes(unicode('hello')), res)
        nt.assert_raises(TypeError, backwards.unicode2bytes, 1)
    else:  # pragma: Python 3
        res = backwards.bytes_type('hello', 'utf-8')
        backwards.assert_bytes(res)
        nt.assert_equal(backwards.unicode2bytes('hello'), res)
        nt.assert_equal(backwards.unicode2bytes(b'hello'), res)
        nt.assert_raises(TypeError, backwards.unicode2bytes, 1)