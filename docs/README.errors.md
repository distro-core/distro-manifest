# Error Conditions

*   Repository .repo/manifest appears to not track revision main/HEAD

    ~~~ bash
    $ repo sync
    ================================================================================
    Repo command failed: UpdateManifestError
    ~~~

    Initialize again to force manifest update

    ~~~ bash
    $ repo init -u https://github.com/distro-core/distro-manifest.git -b main -m distro-head-scarthgap.xml --no-clone-bundle
    repo: reusing existing repo client checkout in /srv/repo/distro-core

    Your Name  [Firstname Surname]:
    Your Email [username@users.noreply.github.com]:

    Your identity is: Firstname Surname <username@users.noreply.github.com>
    is this correct [y/N]? y

    repo has been initialized in /srv/repo/distro-core
    $ repo sync
    Fetching: 100% (12/12), done in 9.269s
    repo sync has finished successfully.
    ~~~

*   Bitbake out of memory error 137

    Certain tasks when run in parallel can run out of memory under WSL2; the following fragment pattern is used
    within a .bbappend to serialize building of the recipe with other recipes that also take large memory resources.

    ~~~ text
    # serialize building (avoid OOM)
    # PARALLEL_MAKE= "-j${@int(os.cpu_count() * 70 / 100 )}"
    # do_compile[depends] += "${PREFERRED_PROVIDER_virtual/kernel}:do_populate_sysroot"
    ~~~

    Avoid creation of circular dependency when using this technique. Bitbake will stall with the following

    ~~~ text
    ERROR: 781 unbuildable tasks were found.###################################################                                                                                        | ETA:  0:00:06
    These are usually caused by circular dependencies and any circular dependency chains found will be printed below. Increase the debug level to see a list of unbuildable tasks.
    ~~~

*   Bitbake appears to hang and timeout while running

    Tune paramaters at $USERPROFILE/.wslconfig; specific parameters are commented out to use the WSL2 defaults.
    Change values until the WSL2 subsystem seems to perform best, lower processors to less than the physical
    count of the host, modify swap space allocated, modify overall memory utilization.

    ~~~ text
    [wsl2]
    # swap=0
    # memory=32G
    # processors=12
    autoProxy=true
    vmIdleTimeout=120000
    ~~~

*   Bitbake has an error with fetch of arbitrary recipes

    ~~~ text
    ERROR: gnome-tweaks-40.0-r0 do_fetch: Fetcher failure for URL: 'https://download.gnome.org/sources//gnome-tweaks/40/gnome-tweaks-40.0.tar.xz;name=archive'. Checksum mismatch!
    File: '/srv/repo/distro-core/build/downloads/gnome-tweaks-40.0.tar.xz.tmp' has sha256 checksum 'c66ee1227f873d6d96a5372823b66d9e131a41febac7340156f260b1d0e795d2' when
    'f95f3fe031b0b01c02f79a1659f889152d3772ae3e44df8403d1460ba5eec36a' was expected
    If this change is expected (e.g. you have upgraded to a new version without updating the checksums) then you can use these lines within the recipe:
    SRC_URI[archive.sha256sum] = "c66ee1227f873d6d96a5372823b66d9e131a41febac7340156f260b1d0e795d2"
    ~~~

    The default remote mirrors no longer have a downloadable copy of the package itemized in its SRC_URI. The
    most expedient solution to try is to issue 'repo sync' and attempt to pickup the most recent copy of the
    package recipe.
