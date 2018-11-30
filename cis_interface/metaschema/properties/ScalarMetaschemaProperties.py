import numpy as np
from cis_interface import units, backwards
from cis_interface.metaschema.datatypes import MetaschemaTypeError
from cis_interface.metaschema.properties import register_metaschema_property
from cis_interface.metaschema.properties.MetaschemaProperty import MetaschemaProperty


_valid_numpy_types = ['int', 'uint', 'float', 'complex']
_valid_types = {k: k for k in _valid_numpy_types}
_flexible_types = ['string', 'bytes', 'unicode']
_python_scalars = {'float': [float], 'int': [int],
                   'uint': [], 'complex': [complex]}
if backwards.PY2:  # pragma: Python 2
    from __builtin__ import unicode
    _valid_numpy_types += ['string', 'unicode']
    _valid_types['bytes'] = 'string'
    _valid_types['unicode'] = 'unicode'
    _python_scalars.update(bytes=[str], unicode=[unicode])
else:  # pragma: Python 3
    _valid_numpy_types += ['bytes', 'unicode', 'str']
    _valid_types['bytes'] = 'bytes'
    _valid_types['unicode'] = 'str'
    _python_scalars.update(bytes=[bytes], unicode=[str])
for t, t_np in _valid_types.items():
    prec_list = []
    if t in ['float']:
        prec_list = [16, 32, 64, 128]
    if t in ['int', 'uint']:
        prec_list = [8, 16, 32, 64]
    elif t in ['complex']:
        prec_list = [64, 128, 256]
    if hasattr(np, t_np):
        _python_scalars[t].append(getattr(np, t_np))
    _python_scalars[t].append(np.dtype(t_np).type)
    for p in prec_list:
        _python_scalars[t].append(np.dtype(t_np + str(p)).type)
_all_python_scalars = [units._unit_quantity]
for k in _python_scalars.keys():
    _all_python_scalars += list(_python_scalars[k])
    _python_scalars[k] = tuple(_python_scalars[k])
_all_python_arrays = tuple(set([np.ndarray, units._unit_array]))
_all_python_scalars = tuple(set(_all_python_scalars))


def data2dtype(data):
    r"""Get numpy data type for an object.

    Args:
        data (object): Python object.

    Returns:
        np.dtype: Numpy data type.

    """
    data_nounits = units.get_data(data)
    if isinstance(data_nounits, np.ndarray):
        dtype = data_nounits.dtype
    elif isinstance(data_nounits, (list, dict, tuple)):
        raise MetaschemaTypeError
    else:
        dtype = np.array([data_nounits]).dtype
    return dtype


def dtype2definition(dtype):
    r"""Get type definition from numpy data type.

    Args:
        dtype (np.dtype): Numpy data type.

    Returns:
        dict: Type definition.

    """
    out = {}
    for k, v in _valid_types.items():
        if dtype.name.startswith(v):
            out['subtype'] = k
    if 'subtype' not in out:
        raise MetaschemaTypeError('Cannot find type string for dtype %s' % dtype)
    out['precision'] = dtype.itemsize * 8  # in bits
    return out


def definition2dtype(props):
    r"""Get numpy data type for a type definition.

    Args:
        props (dict): Type definition properties.
        
    Returns:
        np.dtype: Numpy data type.

    """
    typename = props.get('subtype', None)
    if typename is None:
        typename = props.get('type', None)
        if typename is None:
            raise KeyError('Could not find type in dictionary')
    if typename == 'unicode':
        out = np.dtype((_valid_types[typename], props['precision'] // 32))
    elif typename in _flexible_types:
        out = np.dtype((_valid_types[typename], props['precision'] // 8))
    else:
        out = np.dtype('%s%d' % (_valid_types[typename], props['precision']))
    return out


@register_metaschema_property
class SubtypeMetaschemaProperty(MetaschemaProperty):
    r"""Property class for 'subtype' property."""

    name = 'subtype'
    schema = {'description': 'The base type for each item.',
              'type': 'string',
              'enum': [k for k in sorted(_valid_types.keys())]}

    @classmethod
    def encode(cls, instance):
        r"""Encoder for the 'subtype' scalar property."""
        dtype = data2dtype(instance)
        out = None
        for k, v in _valid_types.items():
            if dtype.name.startswith(v):
                out = k
        if out is None:
            raise MetaschemaTypeError('Cannot find subtype string for dtype %s'
                                      % dtype)
        return out


@register_metaschema_property
class PrecisionMetaschemaProperty(MetaschemaProperty):
    r"""Property class for 'precision' property."""
    
    name = 'precision'
    schema = {'description': 'The size (in bits) of each item.',
              'type': 'number',
              'minimum': 1}

    @classmethod
    def encode(cls, instance):
        r"""Encoder for the 'precision' scalar property."""
        dtype = data2dtype(instance)
        out = dtype.itemsize * 8  # in bits
        return out

    @classmethod
    def compare(cls, prop1, prop2):
        r"""Comparison for the 'precision' scalar property."""
        if (prop1 > prop2):
            yield '%s is greater than %s' % (prop1, prop2)


@register_metaschema_property
class UnitsMetaschemaProperty(MetaschemaProperty):
    r"""Property class for 'units' property."""

    name = 'units'
    schema = {'description': 'Physical units.',
              'type': 'string'}

    @classmethod
    def encode(cls, instance):
        r"""Encoder for the 'units' scalar property."""
        return units.get_units(instance)

    @classmethod
    def compare(cls, prop1, prop2):
        r"""Comparision for the 'units' scalar property."""
        if not units.are_compatible(prop1, prop2):
            yield "Unit '%s' is not compatible with unit '%s'" % (prop1, prop2)