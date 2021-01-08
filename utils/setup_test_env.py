import os
import sys
import argparse
import uuid
import pprint
import shutil
import subprocess
PYVER = ('%s.%s' % sys.version_info[:2])
PY2 = (sys.version_info[0] == 2)
_is_osx = (sys.platform == 'darwin')
_is_linux = ('linux' in sys.platform)
_is_win = (sys.platform in ['win32', 'cygwin'])
_on_gha = bool(os.environ.get('GITHUB_ACTIONS', False))
_on_travis = bool(os.environ.get('TRAVIS_OS_NAME', False))
_on_appveyor = bool(os.environ.get('APPVEYOR_BUILD_FOLDER', False))
_on_ci = (_on_gha or _on_travis or _on_appveyor)
_utils_dir = os.path.dirname(os.path.abspath(__file__))
_pkg_dir = os.path.dirname(_utils_dir)
BUILDDOCS = (os.environ.get('BUILDDOCS', '0') == '1')
CONDA_ENV = os.environ.get('CONDA_DEFAULT_ENV', None)
CONDA_PREFIX = os.environ.get('CONDA_PREFIX', None)
CONDA_INDEX = None
CONDA_ROOT = None
try:
    CONDA_CMD_WHICH = shutil.which('conda')
except AttributeError:
    if _is_win:
        CONDA_CMD_WHICH = None
    else:
        try:
            CONDA_CMD_WHICH = subprocess.check_output(
                ['which', 'conda']).strip().decode('utf-8')
        except subprocess.CalledProcessError:
            CONDA_CMD_WHICH = None
if (not CONDA_PREFIX):
    if CONDA_CMD_WHICH:
        CONDA_PREFIX = os.path.dirname(os.path.dirname(CONDA_CMD_WHICH))
    elif _on_gha and os.environ.get('CONDA', None):
        CONDA_PREFIX = os.environ['CONDA']
    if CONDA_PREFIX and (not CONDA_ENV):
        CONDA_ENV = 'base'
if ((isinstance(CONDA_PREFIX, str)
     and os.path.dirname(CONDA_PREFIX).endswith('envs'))):
    CONDA_PREFIX = os.path.dirname(os.path.dirname(CONDA_PREFIX))
if CONDA_PREFIX:
    CONDA_INDEX = os.path.join(CONDA_PREFIX, "conda-bld")
    if not os.path.isdir(CONDA_INDEX):
        if _on_gha and _is_win and CONDA_PREFIX.endswith('Library'):
            CONDA_INDEX = os.path.join(os.path.dirname(CONDA_PREFIX),
                                       "conda-bld")
if CONDA_CMD_WHICH:
    if _is_win:
        CONDA_CMD = 'call conda'
    else:
        CONDA_CMD = 'conda'
    CONDA_ROOT = os.path.dirname(os.path.dirname(CONDA_CMD_WHICH))
elif os.environ.get('CONDA', None):
    if _is_win:
        CONDA_CMD = 'call %s' % os.path.join(os.environ['CONDA'],
                                             'condabin', 'conda.bat')
    else:
        CONDA_CMD = os.path.join(os.environ['CONDA'], 'bin', 'conda')
    CONDA_ROOT = os.environ['CONDA']
else:
    CONDA_CMD = None
PYTHON_CMD = sys.executable
SUMMARY_CMDS = ["%s --version" % PYTHON_CMD,
                "%s -m pip list" % PYTHON_CMD]
if CONDA_ENV:
    SUMMARY_CMDS += ["echo 'CONDA_PREFIX=%s'" % CONDA_PREFIX,
                     "%s info" % CONDA_CMD,
                     "%s list" % CONDA_CMD]


def call_conda_command(args, **kwargs):
    r"""Function for calling conda commands as the conda script is not
    available on subprocesses for windows unless invoked via the shell.

    Args:
        args (list): Command arguments.
        **kwargs: Additional keyword arguments are passed to subprocess.check_output.

    Returns:
        str: The output from the command.

    """
    if _is_win:
        args = ' '.join(args)
        kwargs['shell'] = True  # Conda commands must be run on the shell
    return subprocess.check_output(args, **kwargs).decode("utf-8")


def call_script(lines):
    r"""Write lines to a script and call it.

    Args:
        lines (list): Lines that should be written to the script.

    """
    if not lines:
        return
    if _is_win:  # pragma: windows
        script_ext = '.bat'
        error_check = 'if %errorlevel% neq 0 exit /b %errorlevel%'
        for i in range(len(lines), 0, -1):
            lines.insert(i, error_check)
    else:
        script_ext = '.sh'
        if lines[0] != '#!/bin/bash':
            lines.insert(0, '#!/bin/bash')
        error_check = 'set -e'
        if error_check not in lines:
            lines.insert(1, error_check)
    fname = 'ci_script_%s%s' % (str(uuid.uuid4()), script_ext)
    try:
        pprint.pprint(lines)
        with open(fname, 'w') as fd:
            fd.write('\n'.join(lines))
            
        call_kws = {}
        if _is_win:  # pragma: windows
            call_cmd = [fname]
        else:
            call_cmd = ['./%s' % fname]
            os.chmod(fname, 0o755)
        subprocess.check_call(call_cmd, **call_kws)
    finally:
        if os.path.isfile(fname):
            os.remove(fname)


def conda_env_exists(name):
    r"""Determine if a conda environment already exists.

    Args:
        name (str): Name of the environment to check.

    Returns:
        bool: True the the environment exits, False otherwise.

    """
    args = [CONDA_CMD, 'info', '--envs']
    out = call_conda_command(args)
    envs = []
    for x in out.splitlines():
        if x.startswith('#') or (not x):
            continue
        envs.append(x.split()[0])
    return (name in envs)


def locate_conda_exe(conda_env, name):
    r"""Determine the full path to an executable in a specific conda environment.

    Args:
        conda_env (str): Name of conda environment that executable should be
            returned for.
        name (str): Name of the executable to locate.

    Returns:
        str: Full path to the executable.

    """
    assert(CONDA_ROOT)
    conda_prefix = os.path.join(CONDA_ROOT, 'envs')
    if (sys.platform in ['win32', 'cygwin']):
        if not name.endswith('.exe'):
            name += '.exe'
        if name.startswith('python'):
            out = os.path.join(conda_prefix, conda_env, name)
        else:
            out = os.path.join(conda_prefix, conda_env,
                               'Scripts', name)
    else:
        out = os.path.join(conda_prefix, conda_env, 'bin', name)
    try:
        assert(os.path.isfile(out))
    except AssertionError:
        out = os.path.expanduser(os.path.join('~', '.conda', 'envs', name))
        if not os.path.isfile(out):
            raise
    return out


def get_install_opts(old=None):
    r"""Get optional language/package installation options from CI
    environment variables.

    Args:
        old (dict, optional): If provided, the returned mapping will include
            the values from this dictionary, but will also be updated with any
            that are missing.

    Returns:
        dict: Mapping between languages/packages and whether or not they
            should be installed.

    """
    if _on_ci:
        new = {
            'c': (os.environ.get('INSTALLC', '0') == '1'),
            'lpy': (os.environ.get('INSTALLLPY', '0') == '1'),
            'R': (os.environ.get('INSTALLR', '0') == '1'),
            'fortran': (os.environ.get('INSTALLFORTRAN', '0') == '1'),
            'zmq': (os.environ.get('INSTALLZMQ', '0') == '1'),
            'sbml': (os.environ.get('INSTALLSBML', '0') == '1'),
            'astropy': (os.environ.get('INSTALLAPY', '0') == '1'),
            'rmq': (os.environ.get('INSTALLRMQ', '0') == '1'),
            'trimesh': (os.environ.get('INSTALLTRIMESH', '0') == '1'),
            'pygments': (os.environ.get('INSTALLPYGMENTS', '0') == '1'),
        }
        if not _is_win:
            new['c'] = True  # c compiler usually installed by default
    else:
        new = {
            'c': True,
            'lpy': False,
            'R': True,
            'fortran': True,
            'zmq': True,
            'sbml': True,
            'astropy': False,
            'rmq': False,
            'trimesh': True,
            'pygments': True,
        }
    if old is None:
        out = {}
    else:
        out = old.copy()
    for k, v in new.items():
        out.setdefault(k, v)
    if not out['c']:
        out.update(fortran=False, zmq=False)
    return out


def create_env(method, python, name=None, packages=None, init=_on_ci):
    r"""Setup a test environment on a CI resource.

    Args:
        method (str): Method that should be used to create an environment.
            Supported values currently include 'conda' & 'virtualenv'.
        python (str): Version of Python that should be tested.
        name (str, optional): Name that should be used for the environment.
            Defaults to None and will be craeted based on the method and
            Python version.
        packages (list, optional): Packages that should be installed in the new
            environment. Defaults to None and is ignored.
        init (bool, optional): If True, the environment management program is
            first configured as if it is one CI so that, some interactive
            aspects will be disabled. Default is set based on the presence of
            CI environment variables (it currently checks for Github Actions,
            Travis CI, and Appveyor)

    Raises:
        ValueError: If method is not 'conda' or 'pip'.

    """
    cmds = ["echo Creating test environment using %s..." % method]
    major, minor = [int(x) for x in python.split('.')]
    if name is None:
        name = '%s%s' % (method, python.replace('.', ''))
    if packages is None:
        packages = []
    if method == 'conda':
        if conda_env_exists(name):
            print("Conda env with name '%s' already exists." % name)
            return
        if init:
            cmds += [
                # Configure conda
                "%s config --set always_yes yes --set changeps1 no" % CONDA_CMD,
                "%s config --set channel_priority strict" % CONDA_CMD,
                "%s config --add channels conda-forge" % CONDA_CMD,
                "%s update -q conda" % CONDA_CMD,
                # "%s config --set allow_conda_downgrades true" % CONDA_CMD,
                # "%s install -n root conda=4.9" % CONDA_CMD,
            ]
        cmds += [
            "%s create -q -n %s python=%s %s" % (CONDA_CMD, name, python,
                                                 ' '.join(packages))
        ]
    elif method == 'virtualenv':
        if (sys.version_info[0] != major) or (sys.version_info[1] != minor):
            if _is_osx:
                try:
                    call_script(['python%d --version' % major])
                except BaseException:
                    cmds.append('brew install python%d' % major)
                try:
                    PYTHON_CMD = shutil.which('python%d' % major)
                except AttributeError:
                    PYTHON_CMD = 'python%d' % major
            else:  # pragma: debug
                raise RuntimeError(("The version of Python (%d.%d) does not match the "
                                    "desired version (%s) and virtualenv cannot create "
                                    "an environment with a different version of Python.")
                                   % (sys.version_info[0], sys.version_info[1], python))
        cmds += [
            "%s -m pip install --upgrade pip virtualenv" % PYTHON_CMD,
            "virtualenv -p %s %s" % (PYTHON_CMD, name)
        ]
        if packages:
            cmds.append("%s -m pip install %s" % (PYTHON_CMD, ' '.join(packages)))
    else:  # pragma: debug
        raise ValueError("Unsupport environment management method: '%s'"
                         % method)
    call_script(cmds)


def build_pkg(method, python=None, return_commands=False,
              verbose=False):
    r"""Build the package on a CI resource.

    Args:
        method (str): Method that should be used to build the package.
            Valid values include 'conda' and 'pip'.
        python (str, optional): Version of Python that package should be
            built for. Defaults to None if not provided and the current
            version of Python will be used.
        return_commands (bool, optional): If True, the commands necessary to
            build the package are returned instead of running them. Defaults
            to False.
        verbose (bool, optional): If True, setup steps are run with verbosity
            turned up. Defaults to False.

    """
    if python is None:
        python = PYVER
    cmds = []
    # Upgrade pip and setuptools and wheel to get clean install
    upgrade_pkgs = ['wheel', 'setuptools']
    if not _is_win:
        upgrade_pkgs.insert(0, 'pip')
    cmds += ["%s -m pip install --upgrade %s" % (PYTHON_CMD, ' '.join(upgrade_pkgs))]
    if method == 'conda':
        if verbose:
            build_flags = ''
        else:
            build_flags = '-q'
        # Must always build in base to avoid errors (and don't change the
        # version of Python used in the environment)
        # https://github.com/conda/conda/issues/9124
        # https://github.com/conda/conda/issues/7758#issuecomment-660328841
        assert(CONDA_ENV == 'base')
        assert(CONDA_INDEX)
        if _on_gha:
            cmds += [
                "%s config --add channels conda-forge" % CONDA_CMD,
                "%s update -q conda" % CONDA_CMD,
            ]
        if _is_win:
            # cmds.append("%s clean --all" % CONDA_CMD)  # Might invalidate cache
            if _on_gha:
                # build_flags = ''
                build_flags += ' --no-test'
        cmds += [
            # "%s clean --all" % CONDA_CMD,  # Might invalidate cache
            # "%s deactivate" % CONDA_CMD,
            "%s install -q -n base conda-build conda-verify" % CONDA_CMD,
            "%s build %s --python %s %s" % (
                CONDA_CMD, 'recipe', python, build_flags),
            "%s index %s" % (CONDA_CMD, CONDA_INDEX),
            # "%s activate %s" % (CONDA_CMD, CONDA_ENV),
        ]
    elif method == 'pip':
        if verbose:
            build_flags = ''
        else:
            build_flags = '--quiet'
        # Install from source dist
        cmds += ["%s setup.py %s sdist" % (PYTHON_CMD, build_flags)]
    else:  # pragma: debug
        raise ValueError("Method must be 'conda' or 'pip', not '%s'"
                         % method)
    if return_commands:
        return cmds
    cmds = SUMMARY_CMDS + cmds + SUMMARY_CMDS
    call_script(cmds)
    if method == 'conda':
        assert(CONDA_INDEX and os.path.isdir(CONDA_INDEX))


def install_deps(method, return_commands=False, verbose=False, for_development=False,
                 skip_test_deps=False, include_dev_deps=False, include_doc_deps=False,
                 windows_package_manager='vcpkg', install_opts=None, conda_env=None,
                 always_yes=False, only_python=False, fallback_to_conda=False):
    r"""Install the package dependencies.
    
    Args:
        method (str): Method that should be used to install the package dependencies.
            Valid values include 'conda' and 'pip'.
        return_commands (bool, optional): If True, the commands necessary to
            install the dependencies are returned instead of running them. Defaults
            to False.
        verbose (bool, optional): If True, setup steps are run with verbosity
            turned up. Defaults to False.
        for_development (bool, optional): If True, dependencies are installed that would
            be missed when installing in development mode. Defaults to False.
        skip_test_deps (bool, optional): If True, dependencies required for running
            tests will not be installed. Defaults to False.
        include_dev_deps (bool, optional): If True, dependencies used during development
            will be installed. Defaults to False.
        include_doc_deps (bool, optional): If True, dependencies used during generating
            documentation will be installed. Defaults to False.
        windows_package_manager (str, optional): Name of the package
            manager that should be used on windows. Defaults to 'vcpkg'.
        install_opts (dict, optional): Mapping from language/package to bool
            specifying whether or not the language/package should be installed.
            If not provided, get_install_opts is used to create it.
        conda_env (str, optional): Name of the conda environment that packages
            should be installed in. Defaults to None and is ignored.
        always_yes (bool, optional): If True, conda commands are called with -y flag
            so that user interaction is not required. Defaults to False.
        only_python (bool, optional): If True, only Python packages will be installed.
            Defaults to False.
        fallback_to_conda (bool, optional): If True, conda will be used to install
            non-python dependencies and Python dependencies that cannot be installed
            via pip. Defaults to False.

    """
    install_opts = get_install_opts(install_opts)
    python_cmd = PYTHON_CMD
    conda_flags = ''
    if conda_env:
        python_cmd = locate_conda_exe(conda_env, 'python')
        conda_flags += ' --name %s' % conda_env
    if always_yes:
        conda_flags += ' -y'
    # Uninstall default numpy and matplotlib to allow installation
    # of specific versions
    cmds = ["%s -m pip uninstall -y numpy matplotlib" % python_cmd]
    # Get dependencies
    install_req = os.path.join("utils", "install_from_requirements.py")
    conda_pkgs = []
    pip_pkgs = []
    os_pkgs = []
    choco_pkgs = []
    vcpkg_pkgs = []
    requirements_files = []
    if method == 'conda':
        fallback_to_conda = True
        default_pkgs = conda_pkgs
    elif method == 'pip':
        fallback_to_conda = ((_is_win and _on_appveyor) or install_opts['lpy'])
        # _in_conda = ((_is_win or install_opts['lpy']) and (not _on_gha))
        default_pkgs = pip_pkgs
    else:  # pragma: debug
        raise ValueError("Method must be 'conda' or 'pip', not '%s'"
                         % method)
    # In the case of a development environment install requirements that
    # would be missed when installing in development mode
    if for_development:
        if method == 'conda':
            requirements_files.append('requirements.txt')
        elif method == 'pip':
            requirements_files.append('requirements_piponly.txt')
        if fallback_to_conda:
            # TODO: This includes some 'optional' packages that could be
            # controlled by install_opts, but installing in this way
            # ignores them and assumes that more packages is better than
            # less in the case of development
            requirements_files.append('requirements_condaonly.txt')
        default_pkgs.append('ipython')
        include_dev_deps = True
    if not skip_test_deps:
        requirements_files.append('requirements_testing.txt')
    if include_dev_deps:
        requirements_files.append('requirements_development.txt')
    # Refresh channel
    # https://github.com/conda/conda/issues/8051
    if fallback_to_conda and _on_gha:
        cmds += [
            "%s config --set channel_priority strict" % CONDA_CMD,
            # "%s install -n root conda=4.9" % CONDA_CMD,
            # "%s config --set allow_conda_downgrades true" % CONDA_CMD,
            "%s config --remove channels conda-forge" % CONDA_CMD,
            "%s config --add channels conda-forge" % CONDA_CMD,
        ]
    # Installing via pip causes import error on Windows and
    # a conflict when installing LPy
    conda_pkgs += ['scipy', os.environ.get('NUMPY', 'numpy')]
    default_pkgs += [os.environ.get('MATPLOTLIB', 'matplotlib'),
                     os.environ.get('JSONSCHEMA', 'jsonschema')]
    if _is_linux:
        os_pkgs += ["strace", "valgrind"]
    # Valgrind failure:
    # "valgrind: This formula either does not compile or function as expected
    # on macOS versions newer than High Sierra due to an upstream
    # incompatibility."
    # elif _is_osx:
    #     os_pkgs += ["valgrind"]
    if install_opts['sbml']:
        pip_pkgs.append('libroadrunner')
    if install_opts['astropy']:
        default_pkgs.append('astropy')
    if install_opts['rmq']:
        default_pkgs.append("\"pika<1.0.0b1\"")
        # if _is_linux:
        #     os_pkgs.append("rabbitmq-server")
        # elif _is_osx:
        #     os_pkgs.append("rabbitmq")
    if install_opts['trimesh']:
        default_pkgs.append('trimesh')
    if install_opts['pygments']:
        default_pkgs.append('pygments')
    if install_opts['fortran']:
        if (method == 'pip') and fallback_to_conda:
            if _is_win:
                conda_pkgs += ['m2w64-gcc-fortran', 'make',
                               'm2w64-toolchain_win-64', 'cmake']
            else:
                conda_pkgs += ['fortran-compiler']
        else:
            # elif not shutil.which('gfortran'):
            # Fortran is not installed via conda on linux/macos
            if _is_linux:
                os_pkgs.append("gfortran")
            elif _is_osx:
                os_pkgs.append("gcc")
                os_pkgs.append("gfortran")
            elif _is_win and (not fallback_to_conda):
                choco_pkgs += ["mingw"]
                # vcpkg_pkgs.append("vcpkg-gfortran")
    if install_opts['R']:
        if (method == 'pip') and fallback_to_conda:
            conda_pkgs.append('r-base')
            if _is_win:
                conda_pkgs.append('rtools')
        elif not fallback_to_conda:
            if _is_linux:
                cmds += [("sudo add-apt-repository 'deb https://cloud"
                          ".r-project.org/bin/linux/ubuntu xenial-cran35/'"),
                         ("sudo apt-key adv --keyserver keyserver.ubuntu.com "
                          "--recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9")]
                os_pkgs += ["r-base", "r-base-dev", "libudunits2-dev"]
                os.environ['YGG_USE_SUDO_FOR_R'] = '1'
            elif _is_osx:
                os_pkgs += ["r", "udunits"]
            elif _is_win:
                choco_pkgs += ["r.project"]
            else:
                raise NotImplementedError("Could not determine "
                                          "R installation method.")
    if install_opts['zmq']:
        if (method == 'pip') and fallback_to_conda:
            conda_pkgs += ['czmq', 'zeromq']
        elif not fallback_to_conda:
            if _is_linux:
                os_pkgs += ["libczmq-dev", "libzmq3-dev"]
            elif _is_osx:
                # if _on_travis:
                #     cmds.append("bash ci/install-czmq-osx.sh")
                # else:
                os_pkgs += ["czmq", "zmq"]
            elif _is_win:
                vcpkg_pkgs += ["czmq", "zeromq"]
            else:
                raise NotImplementedError("Could not determine "
                                          "ZeroMQ installation method.")
            # cmds.append("echo Installing ZeroMQ...")
            # if _is_linux:
            #     cmds.append("./ci/install-czmq-linux.sh")
            # elif _is_osx:
            #     cmds.append("bash ci/install-czmq-osx.sh")
            # # elif _is_win:
            # #     cmds += ["call ci\\install-czmq-windows.bat",
            # #              "echo \"%PATH%\""]
            # else:
            #     raise NotImplementedError("Could not determine "
            #                               "ZeroMQ installation method.")
    if include_doc_deps or BUILDDOCS:
        requirements_files.append('requirements_documentation.txt')
        if not fallback_to_conda:
            os_pkgs.append("doxygen")
    if _on_gha and _is_linux and fallback_to_conda:
        conda_prefix = '$CONDA_PREFIX'
        if conda_env:
            conda_prefix = os.path.join(CONDA_ROOT, 'envs', conda_env)
        # Do both to ensure that the path is set for the installation
        # and in following steps
        cmds += [
            "export LD_LIBRARY_PATH=%s/lib:$LD_LIBRARY_PATH" % conda_prefix,
            "echo -n \"LD_LIBRARY_PATH=\" >> $GITHUB_ENV",
            "echo %s/lib:$LD_LIBRARY_PATH >> $GITHUB_ENV" % conda_prefix
        ]
    # Install dependencies
    if (not only_python) and (os_pkgs or (_is_win and (choco_pkgs or vcpkg_pkgs))):
        if _is_linux:
            cmds += ["sudo apt update"]
            cmds += ["sudo apt-get install %s" % ' '.join(os_pkgs)]
        elif _is_osx:
            if 'gcc' in os_pkgs:
                cmds += ["brew reinstall gcc"]
                os_pkgs.remove('gcc')
            pkgs_from_src = []
            if _on_travis:
                for k in ['zmq', 'czmq', 'zeromq']:
                    if k in os_pkgs:
                        pkgs_from_src.append(k)
                        os_pkgs.remove(k)
            if pkgs_from_src:
                cmds += ["brew install --build-from-source %s" % ' '.join(pkgs_from_src)]
            if os_pkgs:
                cmds += ["brew install %s" % ' '.join(os_pkgs)]
        elif _is_win:
            if windows_package_manager == 'choco':
                choco_pkgs += os_pkgs
            elif windows_package_manager == 'vcpkg':
                vcpkg_pkgs += os_pkgs
            else:
                raise NotImplementedError("Invalid package manager: '%s'"
                                          % windows_package_manager)
            if choco_pkgs:
                cmds += ["choco install %s" % ' '.join(choco_pkgs)]
            if vcpkg_pkgs:
                vcpkg_exe = 'vcpkg.exe'
                # if os.environ.get('VCPKG_ROOT', None):
                #     vcpkg_exe = os.path.join(os.environ['VCPKG_ROOT'],
                #                              vcpkg_exe)
                cmds += ["%s install %s --triplet x64-windows"
                         % (vcpkg_exe, ' '.join(vcpkg_pkgs))]
        else:
            raise NotImplementedError("No native package manager supported "
                                      "on Windows.")
    if fallback_to_conda:
        if verbose:
            install_flags = '-vvv'
        else:
            install_flags = '-q'
        install_flags += conda_flags
        if conda_pkgs:
            cmds += ["%s install %s %s" % (CONDA_CMD, install_flags,
                                           ' '.join(conda_pkgs))]
    else:
        pip_pkgs += conda_pkgs
    if pip_pkgs:
        if verbose:
            install_flags = '--verbose'
        else:
            install_flags = ''
        cmds += ["%s -m pip install %s %s" % (python_cmd, install_flags,
                                              ' '.join(pip_pkgs))]
    for x in requirements_files:
        flags = ''
        if conda_env:
            flags += ' --conda-env %s' % conda_env
        cmds += ["%s %s %s %s%s" % (python_cmd, install_req, method, x, flags)]
    if install_opts['lpy']:
        if verbose:
            install_flags = '-vvv'
        else:
            install_flags = '-q'
        install_flags += conda_flags
        if fallback_to_conda:
            cmds += ["%s install %s openalea.lpy boost=1.66.0 -c openalea"
                     % (CONDA_CMD, install_flags)]
        else:  # pragma: debug
            raise RuntimeError("Could not detect conda environment. "
                               "Cannot proceed with a conda deployment "
                               "(required for LPy).")
    if return_commands:
        return cmds
    cmds = SUMMARY_CMDS + cmds + SUMMARY_CMDS
    call_script(cmds)


def install_pkg(method, python=None, without_build=False,
                without_deps=False, verbose=False,
                skip_test_deps=False, include_dev_deps=False, include_doc_deps=False,
                windows_package_manager='vcpkg', install_opts=None, conda_env=None,
                always_yes=False, only_python=False, fallback_to_conda=False):
    r"""Build and install the package and its dependencies on a CI
    resource.

    Args:
        method (str): Method that should be used to build and install
            the package. Valid values include 'conda' and 'pip'.
        python (str, optional): Version of Python that package should be
            built for. Defaults to None if not provided and the current
            version of Python will be used. This will be ignored if
            without_build is True.
        without_build (bool, optional): If True, the package will not be
            built prior to install. Defaults to False.
        without_deps (bool, optional): If True the package dependencies will
            no be installed prior to installing the package. Defaults to
            False.
        verbose (bool, optional): If True, setup steps are run with verbosity
            turned up. Defaults to False.
        skip_test_deps (bool, optional): If True, dependencies required for running
            tests will not be installed. Defaults to False.
        include_dev_deps (bool, optional): If True, dependencies used during development
            will be installed. Defaults to False.
        include_doc_deps (bool, optional): If True, dependencies used during generating
            documentation will be installed. Defaults to False.
        windows_package_manager (str, optional): Name of the package
            manager that should be used on windows. Defaults to 'vcpkg'.
        install_opts (dict, optional): Mapping from language/package to bool
            specifying whether or not the language/package should be installed.
            If not provided, get_install_opts is used to create it.
        conda_env (str, optional): Name of the conda environment that packages
            should be installed in. Defaults to None and is ignored.
        always_yes (bool, optional): If True, conda commands are called with -y flag
            so that user interaction is not required. Defaults to False.
        only_python (bool, optional): If True, only Python packages will be installed.
            Defaults to False.
        fallback_to_conda (bool, optional): If True, conda will be used to install
            non-python dependencies and Python dependencies that cannot be installed
            via pip. Defaults to False.

    Raises:
        ValueError: If method is not 'conda' or 'pip'.

    """
    install_opts = get_install_opts(install_opts)
    python_cmd = PYTHON_CMD
    conda_flags = ''
    if conda_env:
        python_cmd = locate_conda_exe(conda_env, 'python')
        conda_flags += ' --name %s' % conda_env
    if always_yes:
        conda_flags += ' -y'
    cmds = []
    if method.endswith('-dev'):
        method_base = method.split('-dev')[0]
        for_development = True
        without_build = True
    else:
        method_base = method
        for_development = False
    if not without_build:
        cmds += build_pkg(method_base, python=python,
                          return_commands=True, verbose=verbose)
        cmds += SUMMARY_CMDS
    if not without_deps:
        cmds += install_deps(method_base, return_commands=True, verbose=verbose,
                             for_development=for_development,
                             skip_test_deps=skip_test_deps,
                             include_dev_deps=include_dev_deps,
                             include_doc_deps=include_doc_deps,
                             install_opts=install_opts,
                             windows_package_manager=windows_package_manager,
                             conda_env=conda_env, always_yes=always_yes,
                             only_python=only_python,
                             fallback_to_conda=fallback_to_conda)
        cmds += SUMMARY_CMDS
    # Install yggdrasil
    if method == 'conda':
        assert(CONDA_INDEX and os.path.isdir(CONDA_INDEX))
        # Install from conda build
        # Assumes that the target environment is active
        if verbose:
            install_flags = '-vvv'
        else:
            install_flags = '-q'
        if (not _on_gha) and _is_linux:
            install_flags = ''
        install_flags += conda_flags
        if _is_win:
            index_channel = CONDA_INDEX
        else:
            index_channel = "file:/%s" % CONDA_INDEX
        cmds += [
            # Related issues if this stops working again
            # https://github.com/conda/conda/issues/466#issuecomment-378050252
            "%s install %s --update-deps -c %s yggdrasil" % (
                CONDA_CMD, install_flags, index_channel)
        ]
    elif method == 'pip':
        if verbose:
            install_flags = '--verbose'
        else:
            install_flags = ''
        if _is_win:  # pragma: windows
            cmds += [
                "for %%a in (\"dist\\*.tar.gz\") do set YGGSDIST=%%a",
                "echo %YGGSDIST%"
            ]
            sdist = "%YGGSDIST%"
        else:
            sdist = "dist/*.tar.gz"
        cmds += [
            "%s -m pip install %s %s" % (python_cmd, install_flags, sdist),
            "%s create_coveragerc.py" % python_cmd
        ]
    elif method.endswith('-dev'):
        # Call setup.py in separate process from the package directory
        # cmds += ["%s setup.py develop" % python_cmd]
        pass
    else:  # pragma: debug
        raise ValueError("Invalid method: '%s'" % method)
    # Print summary of what was installed
    cmds = SUMMARY_CMDS + cmds + SUMMARY_CMDS
    call_script(cmds)
    if method.endswith('-dev'):
        print(call_conda_command([python_cmd, 'setup.py', 'develop'],
                                 cwd=_pkg_dir))
    if method == 'conda':
        src_dir = os.path.join(os.getcwd(),
                               os.path.dirname(os.path.dirname(__file__)))
        subprocess.check_call([python_cmd, "create_coveragerc.py"], cwd=src_dir)


def verify_pkg(install_opts=None):
    r"""Verify that the package was installed correctly.

    Args:
        install_opts (dict, optional): Mapping from language/package to bool
            specifying whether or not the language/package should be installed.
            If not provided, get_install_opts is used to create it.

    """
    install_opts = get_install_opts(install_opts)
    if _is_win and (not install_opts['zmq']):
        install_opts['c'] = False
        install_opts['fortran'] = False
    elif (not install_opts['fortran']) and shutil.which('gfortran'):
        install_opts['fortran'] = True
    src_dir = os.path.join(os.getcwd(),
                           os.path.dirname(os.path.dirname(__file__)))
    src_version = subprocess.check_output(
        ["python", "-c",
         "'import versioneer; print(versioneer.get_version())'"],
        cwd=src_dir)
    bld_version = subprocess.check_output(
        ["python", "-c",
         "'import yggdrasil; print(yggdrasil.__version__)'"],
        cwd=os.path.dirname(src_dir))
    if src_version != bld_version:
        raise RuntimeError("Installed version does not match the version of "
                           "this source code.\n"
                           "\tSource version: %s\n\tBuild  version: %s"
                           % (src_version, bld_version))
    if install_opts['R']:
        assert(shutil.which("R"))
        assert(shutil.which("Rscript"))
    subprocess.check_call(["flake8", "yggdrasil"], cwd=src_dir)
    if not os.path.isfile(".coveragerc"):
        raise RuntimeError(".coveragerc file dosn't exist.")
    with open(".coveragerc", "r") as fd:
        print(fd.read())
    subprocess.check_call(["ygginfo", "--verbose"], cwd=src_dir)
    if install_opts['c']:
        subprocess.check_call(["yggccflags"], cwd=src_dir)
        subprocess.check_call(["yggldflags"], cwd=src_dir)
    # Verify that languages are installed
    sys.stdout.flush()
    from yggdrasil.tools import is_lang_installed, is_comm_installed
    errors = []
    for name in ['c', 'R', 'fortran', 'sbml', 'lpy']:
        flag = install_opts[name]
        if flag and (not is_lang_installed(name)):
            errors.append("Language '%s' should be installed, but is not."
                          % name)
        elif (not flag) and is_lang_installed(name):
            errors.append("Language '%s' should NOT be installed, but is."
                          % name)
    for name in ['zmq', 'rmq']:
        flag = install_opts[name]
        if name == 'rmq':
            language = 'python'  # rmq dosn't work for C
        else:
            language = None
        if flag and (not is_comm_installed(name, language=language)):
            errors.append("Comm '%s' should be installed, but is not." % name)
        elif (not flag) and is_comm_installed(name, language=language):
            errors.append("Comm '%s' should NOT be installed, but is." % name)
    if errors:
        raise AssertionError("One or more languages was not installed as "
                             "expected\n\t%s" % "\n\t".join(errors))
    if _is_win:  # pragma: windows
        for k in ['HOME', 'USERPROFILE', 'HOMEDRIVE', 'HOMEPATH']:
            print('%s = %s' % (k, os.environ.get(k, None)))
        if os.environ.get('HOMEDRIVE', None):
            assert(os.path.expanduser('~').startswith(os.environ['HOMEDRIVE']))
        else:
            assert(os.path.expanduser('~').lower().startswith('c:'))


if __name__ == "__main__":
    install_opts = get_install_opts()
    parser = argparse.ArgumentParser(
        "Perform setup operations to test package build and "
        "installation on continuous integration services.")
    subparsers = parser.add_subparsers(
        dest='operation',
        help="CI setup operation that should be performed.")
    # Environment creation
    parser_env = subparsers.add_parser(
        'env', help="Setup an environment for testing.")
    parser_env.add_argument(
        'method', choices=['conda', 'virtualenv'],
        help=("Method that should be used to create "
              "the test environment."))
    parser_env.add_argument(
        'python',
        help="Version of python that should be tested.")
    parser_env.add_argument(
        '--env-name', default=None,
        help="Name that should be used for the environment.")
    # Build package
    parser_bld = subparsers.add_parser(
        'build', help="Build the package.")
    parser_bld.add_argument(
        'method', choices=['conda', 'pip'],
        help=("Method that should be used to build the package."))
    parser_bld.add_argument(
        '--python', default=None,
        help="Version of python that package should be built for.")
    parser_bld.add_argument(
        '--verbose', action='store_true',
        help="Turn up verbosity of output.")
    # Install dependencies
    parser_dep = subparsers.add_parser(
        'deps', help="Install the package dependencies.")
    parser_dep.add_argument(
        'method', choices=['conda', 'pip'],
        help=("Method that should be used to install the package dependencies."))
    parser_dep.add_argument(
        '--verbose', action='store_true',
        help="Turn up verbosity of output.")
    parser_dep.add_argument(
        '--for-development', action='store_true',
        help=("Install dependencies used during development and "
              "that would be missed when installing in development mode. "
              "Implies --include-dev-deps"))
    parser_dep.add_argument(
        '--skip-test-deps', action='store_true',
        help="Don't install dependencies used for testing.")
    parser_dep.add_argument(
        '--include-dev-deps', action='store_true',
        help="Install dependencies used during development.")
    parser_dep.add_argument(
        '--include-doc-deps', action='store_true',
        help="Install dependencies used during doc generation.")
    parser_dep.add_argument(
        '--windows-package-manager', default='vcpkg',
        help="Package manager that should be used on Windows.",
        choices=['vcpkg', 'choco'])
    parser_dep.add_argument(
        '--conda-env', default=None,
        help="Conda environment that dependencies should be installed in.")
    parser_dep.add_argument(
        '--always-yes', action='store_true',
        help="Pass -y to conda commands to avoid user interaction.")
    parser_dep.add_argument(
        '--only-python', '--python-only', action='store_true',
        help="Only install python dependencies.")
    for k, v in install_opts.items():
        if v:
            parser_dep.add_argument(
                '--dont-install-%s' % k, action='store_true',
                help=("Don't install %s" % k))
        else:
            parser_dep.add_argument(
                '--install-%s' % k, action='store_true',
                help=("Install %s" % k))
    # Install package
    parser_pkg = subparsers.add_parser(
        'install', help="Install the package.")
    parser_pkg.add_argument(
        'method', choices=['conda', 'pip', 'conda-dev', 'pip-dev'],
        help=("Method that should be used to install the package."))
    parser_pkg.add_argument(
        '--python', default=None,
        help="Version of python that package should be built/installed for.")
    parser_pkg.add_argument(
        '--without-build', action='store_true',
        help=("Perform installation steps without building first. (Assumes "
              "the package has already been built)."))
    parser_pkg.add_argument(
        '--without-deps', action='store_true',
        help=("Perform installation steps without installing dependencies first. "
              "(Assumes they have already been installed)."))
    parser_pkg.add_argument(
        '--verbose', action='store_true',
        help="Turn up verbosity of output.")
    parser_pkg.add_argument(
        '--skip-test-deps', action='store_true',
        help="Don't install dependencies used for testing.")
    parser_pkg.add_argument(
        '--include-dev-deps', action='store_true',
        help="Install dependencies used during development.")
    parser_pkg.add_argument(
        '--include-doc-deps', action='store_true',
        help="Install dependencies used during doc generation.")
    parser_pkg.add_argument(
        '--windows-package-manager', default='vcpkg',
        help="Package manager that should be used on Windows.",
        choices=['vcpkg', 'choco'])
    parser_pkg.add_argument(
        '--conda-env', default=None,
        help="Conda environment that the package should be installed in.")
    parser_pkg.add_argument(
        '--always-yes', action='store_true',
        help="Pass -y to conda commands to avoid user interaction.")
    parser_pkg.add_argument(
        '--only-python', '--python-only', action='store_true',
        help="Only install python dependencies.")
    for k, v in install_opts.items():
        if v:
            parser_pkg.add_argument(
                '--dont-install-%s' % k, action='store_true',
                help=("Don't install %s" % k))
        else:
            parser_pkg.add_argument(
                '--install-%s' % k, action='store_true',
                help=("Install %s" % k))
    # Installation verification
    parser_ver = subparsers.add_parser(
        'verify', help="Verify that the package was installed correctly.")
    for k, v in install_opts.items():
        if v:
            parser_ver.add_argument(
                '--dont-install-%s' % k, action='store_true',
                help=("Verify that %s is not installed." % k))
        else:
            parser_ver.add_argument(
                '--install-%s' % k, action='store_true',
                help=("Verify that %s is installed." % k))
    # Call methods
    args = parser.parse_args()
    if args.operation in ['env', 'setup']:
        create_env(args.method, args.python, name=args.env_name)
    elif args.operation == 'build':
        build_pkg(args.method, python=args.python,
                  verbose=args.verbose)
    elif args.operation == 'deps':
        install_deps(args.method, verbose=args.verbose,
                     skip_test_deps=args.skip_test_deps,
                     include_dev_deps=args.include_dev_deps,
                     include_doc_deps=args.include_doc_deps,
                     for_development=args.for_development,
                     windows_package_manager=args.windows_package_manager,
                     install_opts=install_opts,
                     conda_env=args.conda_env, always_yes=args.always_yes,
                     only_python=args.only_python)
    elif args.operation == 'install':
        install_pkg(args.method, python=args.python,
                    without_build=args.without_build,
                    without_deps=args.without_deps,
                    verbose=args.verbose,
                    skip_test_deps=args.skip_test_deps,
                    include_dev_deps=args.include_dev_deps,
                    include_doc_deps=args.include_doc_deps,
                    windows_package_manager=args.windows_package_manager,
                    install_opts=install_opts,
                    conda_env=args.conda_env, always_yes=args.always_yes,
                    only_python=args.only_python)
    elif args.operation == 'verify':
        verify_pkg(install_opts=install_opts)
